# Behavior trees (WIP port from tgstation)

Source: [tgstation/tgstation](https://github.com/tgstation/tgstation) `master`,
`code/datums/ai/_ai_bt_*.dm`, `code/datums/ai/_ai_behavior.dm`,
`code/datums/ai/_ai_controller.dm` and `code/__DEFINES/ai/behavior_trees.dm`.

**Status:** phase 1. The behavior tree core compiles and is exercised by a
standalone controller; it is not wired into mobs or the game subsystems yet.

## Ported in this phase

- `__DEFINES/behavior_trees.dm`: statuses, node types, abort modes, subplan and
  parallel policies, descriptor keys.
- `_ai_bt_node.dm`: node base, execution indices, tick/reset/finalize hooks.
- `_ai_bt_composites.dm`: sequence, selector, subplan, parallel.
- `_ai_bt_decorators.dm`: condition gate, blackboard key conditions.
- `_ai_bt_subtree.dm`: named reusable subtree and runtime override slots.
- `_ai_behavior.dm`: behavior leaf base (setup/perform/finish/cooldown).
- `_ai_controller.dm`: minimal controller with a blackboard, descriptor/typepath
  tree construction, `SelectBehaviors()`, cancellation and tick-state reset.
- `behavior_tree_test.dm`: test leaves used by the auxtools scenario.

## Deliberate deviations from tgstation

- **No DCS signals yet.** vgstation uses `/event` handlers instead of TG's
  `RegisterSignal`/`COMSIG` system. Decorator observer aborts and the
  `override_id_set` decorator are therefore not ported; conditions are evaluated
  synchronously while the child is inactive. The reactive layer belongs to the
  controller phase.
- **No `SSai_controllers`, AI status, movement or pathfinding.** `SelectBehaviors`
  is called directly by the test scenario. The subsystem and movement adapters
  are phase 2.
- **No compiled JSON files or compiler.** `BT_COMPILED_PATH` and
  `load_tree_from_json` are present for the next phase, but the WIP trees are
  built from typepaths or descriptor lists. The compiler that turns `.bt.json`
  into `.compiled.json` still needs to be ported/tooled.
- **No async perform and no event logging.** The async leaf path and
  `EVLOG_*` calls are deferred with the controller/subsystem port.
- The BT viewer's `append_*` helpers are not ported yet.

## Next phases

1. **Controller integration:** blackboard key defines, AI status, high/low
   priority subsystems, event-based observers/replanning, movement and
   pathfinding adapters, possession/sentience handling.
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
