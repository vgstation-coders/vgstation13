#!/usr/bin/env python3
"""Compiles behavior tree .bt.json sources into runtime descriptors.

The source format is intentionally small:

    {
      "type": "selector",
      "children": [
        {"type": "pawn_health_below", "threshold": 0.5, "observer_abort": "self",
         "children": [{"type": "flee_target", "flee_distance": 6}]},
        {"type": "subtree", "subtree": "combat"}
      ]
    }

- "type" is a short node name (the last segment of its DM type path) or a full
  /datum/bt_node path. Short names are resolved against the DM sources, so the
  compiler knows when a node type or config var does not exist.
- "children" is a list of child nodes. Decorators take exactly one child.
- Any other key is a config var assigned to the node by configure().
- Strings in known enum keys are converted to the DM defines they stand for
  (observer_abort, success_policy, failure_policy).
- A {"type": "subtree", "subtree": "name"} node is expanded inline from
  trees/name.bt.json (override slots are not supported by this path).

The compiled output keeps the same nested shape but with full DM type paths, so
it can be loaded by ai_controller.load_tree_from_json() without the DM sources.
"""

import argparse
import json
import os
import re
import sys

NODE_ROOT = "/datum/bt_node"
TYPE_RE = re.compile(r"^(/datum/bt_node(?:/[A-Za-z0-9_]+)*)\s*$")
VAR_RE = re.compile(r"^\s+var/([A-Za-z0-9_]+)")

RESERVED_KEYS = {"type", "children", "subtree"}

ABORT_MODES = {"none": 0, "self": 1, "lower_priority": 2, "both": 3}
PARALLEL_SUCCESS = {"child_one": 0, "all": 1}
PARALLEL_FAILURE = {"child_one": 0, "any": 1}
SUBPLAN_SUCCESS = {"succeed_on_success": 0, "loop_on_success": 1}
SUBPLAN_FAILURE = {"fail_on_failure": 0, "loop_on_failure": 1}


class CompileError(Exception):
    pass


def relative(repo, path):
    try:
        return os.path.relpath(path, repo).replace(os.sep, "/")
    except ValueError:
        return path


def scan_registry(repo, ai_dir):
    """Returns {type path: set(declared var names)} for every bt_node in ai_dir."""
    registry = {}
    for root, _, files in os.walk(ai_dir):
        for name in sorted(files):
            if not name.endswith(".dm"):
                continue
            current = None
            with open(os.path.join(root, name), encoding="utf-8", errors="replace") as handle:
                for line in handle:
                    line = line.rstrip("\n")
                    if line and not line[0].isspace():
                        match = TYPE_RE.match(line)
                        current = match.group(1) if match else None
                        if current:
                            registry.setdefault(current, set())
                        continue
                    if current:
                        match = VAR_RE.match(line)
                        if match:
                            registry[current].add(match.group(1))
    if not registry:
        raise CompileError("no /datum/bt_node declarations found under %s" % relative(repo, ai_dir))
    return registry


def inherited_vars(registry, node_type):
    """Collects vars from node_type and its declared ancestors."""
    found = set()
    current = node_type
    while current:
        found.update(registry.get(current, set()))
        if current == NODE_ROOT:
            break
        parent = current.rsplit("/", 1)[0]
        current = parent if parent in registry else None
    return found


def build_short_names(registry):
    """Maps short node name -> type path; ambiguous names are dropped."""
    by_short = {}
    ambiguous = set()
    for path in registry:
        short = path.rsplit("/", 1)[-1]
        if short in by_short and by_short[short] != path:
            ambiguous.add(short)
        else:
            by_short[short] = path
    for short in ambiguous:
        by_short.pop(short, None)
    return by_short, ambiguous


def node_category(node_type):
    if node_type.startswith(NODE_ROOT + "/composite"):
        return "composite"
    if node_type.startswith(NODE_ROOT + "/decorator"):
        return "decorator"
    if node_type.startswith(NODE_ROOT + "/subtree"):
        return "subtree"
    if node_type.startswith(NODE_ROOT + "/ai_behavior"):
        return "behavior"
    return "unknown"


def coerce_enum(registry, node_type, key, value):
    if key == "observer_abort":
        table = ABORT_MODES
    elif key == "success_policy":
        if node_type.endswith("/parallel"):
            table = PARALLEL_SUCCESS
        elif node_type.endswith("/subplan"):
            table = SUBPLAN_SUCCESS
        else:
            return value
    elif key == "failure_policy":
        if node_type.endswith("/parallel"):
            table = PARALLEL_FAILURE
        elif node_type.endswith("/subplan"):
            table = SUBPLAN_FAILURE
        else:
            return value
    else:
        return value

    if not isinstance(value, str):
        return value
    if value not in table:
        raise CompileError(
            "%s: unknown %s value %r (expected one of %s)"
            % (node_type, key, value, ", ".join(sorted(table)))
        )
    return table[value]


def resolve_type(node, registry, short_names, ambiguous):
    name = node.get("type")
    if not isinstance(name, str) or not name:
        raise CompileError("every node needs a non-empty string 'type'")
    if name in short_names:
        return short_names[name]
    if name.startswith("/"):
        if name not in registry:
            raise CompileError("unknown node type %r" % name)
        return name
    if name in ambiguous:
        raise CompileError("node name %r is ambiguous; use the full type path" % name)
    raise CompileError("unknown node type %r" % name)


def compile_node(node, registry, short_names, ambiguous, source_dir, repo, warnings, stack):
    if not isinstance(node, dict):
        raise CompileError("node must be a JSON object, got %r" % (node,))

    # Subtree references are expanded inline before anything else.
    if "subtree" in node:
        name = node["subtree"]
        if not isinstance(name, str) or not name:
            raise CompileError("subtree node needs a non-empty 'subtree' name")
        for key in set(node) - {"type", "subtree"}:
            warnings.append("subtree %r: ignoring key %r (override slots are not supported)" % (name, key))
        if name in stack:
            raise CompileError("subtree cycle: %s" % " -> ".join(stack + [name]))
        path = os.path.join(source_dir, name + ".bt.json")
        if not os.path.isfile(path):
            raise CompileError("subtree %r not found at %s" % (name, relative(repo, path)))
        with open(path, encoding="utf-8-sig") as handle:
            subtree = json.load(handle)
        return compile_node(
            subtree, registry, short_names, ambiguous, source_dir, repo, warnings, stack + [name]
        )

    node_type = resolve_type(node, registry, short_names, ambiguous)
    category = node_category(node_type)
    compiled = {"type": node_type}

    declared = inherited_vars(registry, node_type)
    for key, value in node.items():
        if key in RESERVED_KEYS:
            continue
        if key not in declared:
            warnings.append("%s: unknown config var %r" % (node_type, key))
        compiled[key] = coerce_enum(registry, node_type, key, value)

    children = node.get("children")
    if children is not None:
        if not isinstance(children, list):
            raise CompileError("%s: 'children' must be a list" % node_type)
        if category == "behavior":
            raise CompileError("%s: behavior leaves cannot have children" % node_type)
        if category == "subtree":
            raise CompileError("%s: subtree nodes cannot have children" % node_type)
        compiled["children"] = [
            compile_node(child, registry, short_names, ambiguous, source_dir, repo, warnings, stack)
            for child in children
        ]

    if category == "decorator":
        count = len(compiled.get("children", []))
        if count != 1:
            raise CompileError("%s: decorators wrap exactly one child (got %d)" % (node_type, count))
    elif category == "composite" and not compiled.get("children"):
        raise CompileError("%s: composites need at least one child" % node_type)

    return compiled


def compile_file(path, registry, short_names, ambiguous, source_dir, repo, strict):
    with open(path, encoding="utf-8-sig") as handle:
        try:
            tree = json.load(handle)
        except ValueError as error:
            raise CompileError("%s: invalid JSON: %s" % (relative(repo, path), error))
    warnings = []
    compiled = compile_node(tree, registry, short_names, ambiguous, source_dir, repo, warnings, [])
    if strict and warnings:
        raise CompileError("%s:\n  %s" % (relative(repo, path), "\n  ".join(warnings)))
    for warning in warnings:
        print("warning: %s: %s" % (relative(repo, path), warning), file=sys.stderr)
    return json.dumps(compiled, indent=2, sort_keys=True) + "\n"


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--repo", default=os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")),
                        help="repository root (default: two levels above this script)")
    parser.add_argument("--source", default="code/datums/ai/trees", help="directory with .bt.json sources")
    parser.add_argument("--out", default="code/datums/ai/compiled", help="directory for .compiled.json output")
    parser.add_argument("--ai-dir", default="code/datums/ai", help="directory scanned for bt_node declarations")
    parser.add_argument("--check", action="store_true", help="fail if the compiled files are not up to date")
    parser.add_argument("--strict", action="store_true", help="treat compiler warnings as errors")
    args = parser.parse_args(argv)

    repo = os.path.abspath(args.repo)
    ai_dir = os.path.join(repo, args.ai_dir)
    source_dir = os.path.join(repo, args.source)
    out_dir = os.path.join(repo, args.out)

    try:
        registry = scan_registry(repo, ai_dir)
        short_names, ambiguous = build_short_names(registry)
    except CompileError as error:
        print("error: %s" % error, file=sys.stderr)
        return 1

    if not os.path.isdir(source_dir):
        print("error: source directory %s does not exist" % relative(repo, source_dir), file=sys.stderr)
        return 1

    sources = sorted(name for name in os.listdir(source_dir) if name.endswith(".bt.json"))
    if not sources:
        print("error: no .bt.json files in %s" % relative(repo, source_dir), file=sys.stderr)
        return 1

    os.makedirs(out_dir, exist_ok=True)
    failed = False
    for name in sources:
        source_path = os.path.join(source_dir, name)
        output_name = name[:-len(".json")] + ".compiled.json"
        output_path = os.path.join(out_dir, output_name)
        try:
            compiled = compile_file(source_path, registry, short_names, ambiguous, source_dir, repo, args.strict)
        except CompileError as error:
            print("error: %s" % error, file=sys.stderr)
            failed = True
            continue

        if args.check:
            existing = None
            if os.path.isfile(output_path):
                with open(output_path, encoding="utf-8") as handle:
                    existing = handle.read()
            if existing != compiled:
                print("stale: %s (run the compiler)" % relative(repo, output_path), file=sys.stderr)
                failed = True
            else:
                print("ok: %s" % relative(repo, output_path))
        else:
            with open(output_path, "w", encoding="utf-8", newline="\n") as handle:
                handle.write(compiled)
            print("compiled %s -> %s" % (relative(repo, source_path), relative(repo, output_path)))

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
