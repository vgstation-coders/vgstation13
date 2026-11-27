# Behavior tree compiler

Compiles `.bt.json` behavior tree sources into the runtime descriptor format used
by `code/datums/ai` (see `code/datums/ai/README.md`).

## Usage

```sh
python tools/behavior_tree/bt_compiler.py --repo .
python tools/behavior_tree/bt_compiler.py --repo . --strict   # warnings are errors
python tools/behavior_tree/bt_compiler.py --repo . --check    # CI: fail on stale output
```

- Sources: `code/datums/ai/trees/*.bt.json`
- Output: `code/datums/ai/compiled/*.compiled.json` (committed; run `--check` in CI)
- Node registry: scanned from the `/datum/bt_node` declarations under
  `code/datums/ai`, so type names and config vars are validated against the real
  DM code instead of a hand-maintained list.

## Source format

```json
{
  "type": "selector",
  "children": [
    {
      "type": "pawn_health_below",
      "threshold": 0.5,
      "observer_abort": "self",
      "children": [
        {"type": "flee_target", "flee_distance": 6, "hold_while_target_alive": true}
      ]
    },
    {"type": "subtree", "subtree": "combat"}
  ]
}
```

- `type`: short node name (last segment of the DM path) or a full
  `/datum/bt_node/...` path. Short names come from the scanned registry.
- `children`: child nodes. Composites need at least one; decorators need exactly
  one; behavior leaves cannot have any.
- Any other key is a config var assigned by `configure()`.
- Enum strings are converted to their DM defines:
  - `observer_abort`: `none` / `self` / `lower_priority` / `both`
  - `success_policy`: `child_one` / `all` (parallel), `succeed_on_success` /
    `loop_on_success` (subplan)
  - `failure_policy`: `child_one` / `any` (parallel), `fail_on_failure` /
    `loop_on_failure` (subplan)
- `{"type": "subtree", "subtree": "name"}` is expanded inline from
  `trees/name.bt.json` at compile time. Override slots are not supported through
  JSON yet.

## Runtime side

`ai_controller.load_tree_from_json(BT_COMPILED_PATH("guard.bt.json"))` reads the
compiled file and converts the string typepaths with `text2path()` before handing
the descriptor to the normal tree builder.
