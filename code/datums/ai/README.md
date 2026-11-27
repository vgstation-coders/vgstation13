# Behavior trees (WIP port from tgstation)

Source: [tgstation/tgstation](https://github.com/tgstation/tgstation) `master`,
`code/datums/ai/_ai_bt_*.dm`, `code/datums/ai/_ai_behavior.dm`,
`code/datums/ai/_ai_controller.dm` and `code/__DEFINES/ai/behavior_trees.dm`.

**Status:** phase 2. The core compiles, the subsystem/possession path is wired,
and the tree is exercised by a standalone controller. It is still not wired into
mob life or basic mobs.

## Ported so far

- `__DEFINES/behavior_trees.dm`: statuses, node types, abort modes, subplan and
  parallel policies, descriptor keys, AI statuses.
- `_ai_bt_node.dm`: node base, execution indices, tick/reset/finalize hooks.
- `_ai_bt_composites.dm`: sequence, selector, subplan, parallel.
- `_ai_bt_decorators.dm`: condition gate, blackboard key conditions, polling
  observer aborts, override slot gate.
- `_ai_bt_subtree.dm`: named reusable subtree and runtime override slots.
- `_ai_behavior.dm`: behavior leaf base (setup/perform/finish/cooldown).
- `_ai_controller.dm`: blackboard, descriptor/typepath tree construction,
  `SelectBehaviors()`, cancellation, tick-state reset, AI status and possession.
- `code/controllers/subsystem/ai_controllers.dm`: `SSai_controllers` tick path
  for `AI_STATUS_ON` / `AI_STATUS_ON_LOW`.
- `behavior_tree_test.dm`: test leaves used by the auxtools scenario.

## Deliberate deviations from tgstation

- **No DCS signals.** vgstation uses `/event` handlers instead of TG's
  `RegisterSignal`/`COMSIG` system. Decorator observer aborts use the polling
  fallback (`polling_observers` + `polling_rate`) instead of signals. A future
  pass can register real vg events where they exist.
- **One controller subsystem.** Both `AI_STATUS_ON` and `AI_STATUS_ON_LOW` are
  processed by the same subsystem for now; the two-subsystem split is phase 3.
- **No movement or pathfinding.** `ai_movement`, `can_reach_target` and the cell
  grid are still missing; behaviors that move must wait for that adapter.
- **No sentience/death events.** Possession sets `ai_status`; turning the AI off
  when a client takes over or the pawn dies is phase 3.
- **No compiled JSON files or compiler.** `BT_COMPILED_PATH` and
  `load_tree_from_json` are present, but WIP trees are built from typepaths or
  descriptor lists. The `.bt.json` compiler still needs to be ported/tooled.
- **No async perform and no event logging.** The async leaf path and `EVLOG_*`
  calls are deferred with the controller/subsystem port.
- The BT viewer's `append_*` helpers are not ported yet.

## Next phases

1. **Controller integration:** movement/pathfinding adapter, possession/sentience
   hooks (client login/logout, death), high/low priority split, z-level lists.
2. **Tree tooling:** `.bt.json` compiler and loader; BT viewer.
3. **Behaviors and mobs:** port the basic mob behavior leaves (targeting,
   movement, attack, flee, speech, abilities) and integrate a simple animal or a
   dedicated basic mob as the first consumer.
4. **Migration:** move the existing simple animal / NPC crew AI incrementally,
   with the behavior tree as the decision layer.

## Testing

The phase-1 scenario lives outside the repository (local auxtools harness):
build a sequence/selector/decorator/subtree, tick it across RUNNING/SUCCESS/
FAILURE, exercise the descriptor builder, and cancel a running leaf. Keep the
test leaves in `behavior_tree_test.dm` until real leaves and unit tests replace
them.
