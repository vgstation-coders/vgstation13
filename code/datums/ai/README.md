# Behavior trees (WIP port from tgstation)

Source: [tgstation/tgstation](https://github.com/tgstation/tgstation) `master`,
`code/datums/ai/_ai_bt_*.dm`, `code/datums/ai/_ai_behavior.dm`,
`code/datums/ai/_ai_controller.dm` and `code/__DEFINES/ai/behavior_trees.dm`.

**Status:** phase 8. The core, subsystem/possession path, pathfinding movement
adapter, starter behavior leaves (attack, flee, speak), target lifecycle hooks and
target sources, an ability system with a ranged and a charge ability, a health
decorator, an example hostile consumer and three existing mapped mobs (space bear,
space carp, strong hivebot) compile and pass the auxtools scenario. The wider
basic mob behavior set is still pending.

## Ported so far

- `__DEFINES/behavior_trees.dm`: statuses, node types, abort modes, subplan and
  parallel policies, descriptor keys, AI statuses, starter blackboard keys.
- `_ai_bt_node.dm`: node base, execution indices, tick/reset/finalize hooks.
- `_ai_bt_composites.dm`: sequence, selector, subplan, parallel.
- `_ai_bt_decorators.dm`: condition gate, blackboard key conditions, polling
  observer aborts, override slot gate, `pawn_health_below` health gate.
- `_ai_bt_subtree.dm`: named reusable subtree and runtime override slots.
- `_ai_behavior.dm`: behavior leaf base (setup/perform/finish/cooldown).
- `_ai_controller.dm`: blackboard, descriptor/typepath tree construction,
  `SelectBehaviors()`, cancellation, tick-state reset, AI status, possession,
  movement adapter, pawn death handling and the `ai_target_acquired()` /
  `ai_target_lost()` mob hooks.
- `_ai_movement.dm`: basic `get_path_to()` walker with `has_path()` and a greedy
  step fallback while the pathfinder subsystem is not ready or has no route.
- `_ai_target_sources.dm`: `target_source` base plus `enemies` (closest pick,
  legacy distance rule) and `enemies/wounded` (weakest pick) sources. The
  `enemies` filter uses the pawn's `CanAttack()`, so only mobs that override it
  (hostile mobs) see healthy prey; the base simple_animal version only allows
  targets already in crit.
- `_ai_abilities.dm`: `ai_ability` base with cooldowns, plus `ranged_attack`
  (wraps the legacy `OpenFire`/`ranged_cooldown`) and `charge` (closes two tiles).
- `_ai_behaviors_basic.dm`: `acquire_target` (target sources, dead/invalid target
  cleanup), `move_to_target`, `attack_target`, `flee_target`, `speak_line`,
  `use_ability`, and the `bt_hostile_combat_tree()` /
  `bt_basic_hostile_tree()` / `bt_fleeing_hostile_tree()` /
  `bt_ranged_hostile_tree()` descriptors.
- `bt_guard.dm`: example first consumer, a hostile simple animal whose decision
  layer is a behavior tree controller (not mapped; admin/spawn use). It composes
  a fleeing combat tree in parallel with ambient chatter.
- `bear.dm`: first existing mapped mob migration. Space bears (and their
  subtypes) now run the shared starter tree; the legacy hostile target
  acquisition is disabled.
- `carp.dm`: second existing mapped mob migration. Space carp (and their
  subtypes) now run the shared starter tree; their legacy target acquisition is
  disabled and the "gnashes at" emote moved to the `ai_target_acquired()` hook.
- `hivebot.dm`: third migration and the first ranged consumer. `hivebot/strong`
  runs `bt_ranged_hostile_tree()`: fire at range through `use_ability`, melee when
  adjacent. The beacon-spawned `hivebot`, `range` and `rapid` variants are still on
  the legacy AI on purpose (they need retreat-distance handling).
- `code/controllers/subsystem/ai_controllers.dm`: `SSai_controllers` tick path
  for `AI_STATUS_ON` / `AI_STATUS_ON_LOW`.
- `behavior_tree_test.dm`: test leaves used by the auxtools scenario.

## Descriptor format

Trees are nested lists keyed by `BT_DESC_TYPE`, `BT_DESC_CHILDREN` and optional
config vars (`configure()` assigns them to same-named vars). A decorator wraps
exactly one child, so the child node must go inside the decorator's
`BT_DESC_CHILDREN`; listing it next to the decorator leaves the decorator
childless and it fails every tick.

## Deliberate deviations from tgstation

- **No DCS signals.** vgstation uses `/event` handlers instead of TG's
  `RegisterSignal`/`COMSIG` system. Decorator observer aborts use the polling
  fallback (`polling_observers` + `polling_rate`) instead of signals. A future
  pass can register real vg events where they exist.
- **One controller subsystem.** Both `AI_STATUS_ON` and `AI_STATUS_ON_LOW` are
  processed by the same subsystem for now; the two-subsystem split is pending.
- **Simplified movement.** `ai_movement/basic` uses `get_path_to()` and has no
  cell grid or path caching yet. If `SSpathfinder.mobs` is not initialized or
  returns no route, it falls back to one greedy step instead of runtiming. That
  fallback has no obstacle avoidance: a blocked step fails the movement leaf and
  the tree retries on the next tick, so a pawn can stall on a single blocker.
- **Starter hostile behavior only.** The shared trees have acquire/move/attack,
  plus opt-in flee (`bt_fleeing_hostile_tree`), ranged attacks
  (`bt_ranged_hostile_tree`) and `speak_line`. Environment smashing and the legacy
  bear-specific burger behavior are still missing. Chatting leaves should pass
  explicit lines when the mob keeps legacy `handle_automated_speech()` to avoid
  double-speaking.
- **Target sources are polled, not event driven.** `acquire_target` asks its
  `target_source` for candidates on every run, so sources are cheap filters
  instead of signal subscriptions.
- **Abilities run synchronously.** `ai_ability/perform` must not sleep; anything
  with a windup belongs in a behavior leaf using `AI_BEHAVIOR_DELAY`. The ranged
  ability also respects the mob's legacy `ranged_cooldown`, and there is no
  retreat-distance handling yet, so a ranged tree holds position instead of
  backing off.
- **Migrations disable the legacy target acquisition** with a `FindTarget()`
  override. The legacy `Life()` still runs health/speech; only target
  acquisition, movement and attack are owned by the tree. Mobs can hook
  `ai_target_acquired()` / `ai_target_lost()` for reaction flavor; the target
  leaf also drops dead or unattackable targets instead of chasing them forever.
- **Death hook only.** Possession registers `/event/death` and turns the AI off.
  Client login/logout sentience hooks are still pending.
- **No compiled JSON files or compiler.** `BT_COMPILED_PATH` and
  `load_tree_from_json` are present, but WIP trees are built from typepaths or
  descriptor lists. The `.bt.json` compiler still needs to be ported/tooled.
- **No async perform and no event logging.** The async leaf path and `EVLOG_*`
  calls are deferred with the controller/subsystem port.
- The BT viewer's `append_*` helpers are not ported yet.

## Next phases

1. **Behaviors:** port the remaining basic mob leaves (environment smashing,
   speech variants, more target sources) and keep migrating existing mobs.
2. **Controller integration:** client login/logout sentience hooks, the
   high/low priority subsystem split, z-level lists and path caching.
3. **Tree tooling:** `.bt.json` compiler and loader; BT viewer.
4. **Migration:** move the remaining simple animal / NPC crew AI incrementally,
   with the behavior tree as the decision layer.

## Testing

The phase-8 scenario lives outside the repository (local auxtools harness):
build a sequence/selector/decorator/subtree, tick it across RUNNING/SUCCESS/
FAILURE, exercise the descriptor builder, cancel a running leaf, possess a mob,
trigger its death event, move it towards a blackboard target, drive the example
`bt_guard` against an adjacent victim, make it flee while badly hurt and resume
combat after healing (in a cleared arena so the path is deterministic), say a
line, drop a dead target during acquisition, verify the closest and wounded
target sources pick the expected victim, fire the strong hivebot's ranged
ability, make it melee at adjacency, charge with a pawn, and verify the migrated
space bear and space carp attack adjacent humans. Keep the test leaves in
`behavior_tree_test.dm` until real leaves and unit tests replace them.
