# Behavior trees (WIP port from tgstation)

Source: [tgstation/tgstation](https://github.com/tgstation/tgstation) `master`,
`code/datums/ai/_ai_bt_*.dm`, `code/datums/ai/_ai_behavior.dm`,
`code/datums/ai/_ai_controller.dm` and `code/__DEFINES/ai/behavior_trees.dm`.

**Status:** phase 5. The core, subsystem/possession path, pathfinding movement
adapter, starter behavior leaves, an example hostile consumer and the first
existing mapped mob (space bear) compile and pass the auxtools scenario. The wider
basic mob behavior set is still pending.

## Ported so far

- `__DEFINES/behavior_trees.dm`: statuses, node types, abort modes, subplan and
  parallel policies, descriptor keys, AI statuses, starter blackboard keys.
- `_ai_bt_node.dm`: node base, execution indices, tick/reset/finalize hooks.
- `_ai_bt_composites.dm`: sequence, selector, subplan, parallel.
- `_ai_bt_decorators.dm`: condition gate, blackboard key conditions, polling
  observer aborts, override slot gate.
- `_ai_bt_subtree.dm`: named reusable subtree and runtime override slots.
- `_ai_behavior.dm`: behavior leaf base (setup/perform/finish/cooldown).
- `_ai_controller.dm`: blackboard, descriptor/typepath tree construction,
  `SelectBehaviors()`, cancellation, tick-state reset, AI status, possession,
  movement adapter and pawn death handling.
- `_ai_movement.dm`: basic `get_path_to()` walker with a greedy step fallback
  while the pathfinder subsystem is not ready or has no route.
- `_ai_behaviors_basic.dm`: `acquire_target`, `move_to_target`, `attack_target`
  and the shared `bt_basic_hostile_tree()` descriptor.
- `bt_guard.dm`: example first consumer, a hostile simple animal whose decision
  layer is a behavior tree controller (not mapped; admin/spawn use).
- `bear.dm`: first existing mapped mob migration. Space bears (and their
  subtypes) now run the shared starter tree; the legacy hostile target
  acquisition is disabled.
- `code/controllers/subsystem/ai_controllers.dm`: `SSai_controllers` tick path
  for `AI_STATUS_ON` / `AI_STATUS_ON_LOW`.
- `behavior_tree_test.dm`: test leaves used by the auxtools scenario.

## Deliberate deviations from tgstation

- **No DCS signals.** vgstation uses `/event` handlers instead of TG's
  `RegisterSignal`/`COMSIG` system. Decorator observer aborts use the polling
  fallback (`polling_observers` + `polling_rate`) instead of signals. A future
  pass can register real vg events where they exist.
- **One controller subsystem.** Both `AI_STATUS_ON` and `AI_STATUS_ON_LOW` are
  processed by the same subsystem for now; the two-subsystem split is pending.
- **Simplified movement.** `ai_movement/basic` uses `get_path_to()` and has no
  cell grid or path caching yet. If `SSpathfinder.mobs` is not initialized or
  returns no route, it falls back to one greedy step instead of runtiming.
- **Starter hostile behavior only.** The shared tree has acquire/move/attack; it
  does not yet cover flee, speech, abilities, environment smashing or the legacy
  bear-specific burger behavior.
- **Migrations disable the legacy target acquisition** with a `FindTarget()`
  override. The legacy `Life()` still runs health/speech; only target
  acquisition, movement and attack are owned by the tree.
- **Death hook only.** Possession registers `/event/death` and turns the AI off.
  Client login/logout sentience hooks are still pending.
- **No compiled JSON files or compiler.** `BT_COMPILED_PATH` and
  `load_tree_from_json` are present, but WIP trees are built from typepaths or
  descriptor lists. The `.bt.json` compiler still needs to be ported/tooled.
- **No async perform and no event logging.** The async leaf path and `EVLOG_*`
  calls are deferred with the controller/subsystem port.
- The BT viewer's `append_*` helpers are not ported yet.

## Next phases

1. **Behaviors:** port the remaining basic mob leaves (flee, speech, abilities,
   target sources, environment smashing) and migrate more existing mobs.
2. **Controller integration:** client login/logout sentience hooks, the
   high/low priority subsystem split, z-level lists and path caching.
3. **Tree tooling:** `.bt.json` compiler and loader; BT viewer.
4. **Migration:** move the remaining simple animal / NPC crew AI incrementally,
   with the behavior tree as the decision layer.

## Testing

The phase-5 scenario lives outside the repository (local auxtools harness):
build a sequence/selector/decorator/subtree, tick it across RUNNING/SUCCESS/
FAILURE, exercise the descriptor builder, cancel a running leaf, possess a mob,
trigger its death event, move it towards a blackboard target, drive the example
`bt_guard` against an adjacent victim, and verify the migrated space bear attacks
an adjacent human. Keep the test leaves in `behavior_tree_test.dm` until real
leaves and unit tests replace them.
