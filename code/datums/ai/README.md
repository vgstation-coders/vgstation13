# Behavior trees (WIP port from tgstation)

Source: [tgstation/tgstation](https://github.com/tgstation/tgstation) `master`,
`code/datums/ai/_ai_bt_*.dm`, `code/datums/ai/_ai_behavior.dm`,
`code/datums/ai/_ai_controller.dm` and `code/__DEFINES/ai/behavior_trees.dm`.

**Status:** phase 10. The core, subsystem/possession path, sentience hooks,
path-cached movement, starter behavior leaves (attack, flee, retreat, hold,
smash, wait, speak, blackboard keys), target lifecycle hooks and target sources
(including retaliation), an ability system with a ranged and a charge ability, a
health decorator, the `.bt.json` compiler, an example hostile consumer and six
existing mapped mob types (space bear, space carp, strong/ranged/rapid hivebot,
viscerator) compile and pass the auxtools scenario. The wider basic mob behavior
set is still pending.

## Ported so far

- `trees/*.bt.json` + `compiled/*.compiled.json`: `.bt.json` sources and their
  committed compiled output (`guard` and the shared `combat` subtree).
- `tools/behavior_tree/bt_compiler.py`: validates sources against the scanned
  `/datum/bt_node` declarations, expands subtrees, converts enum names to DM
  defines and emits full-typepath descriptors. `--check` guards against stale
  output in CI.
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
  sentience (`/event/living_login`, `/event/logout`), subsystem routing, movement
  adapter, pawn death handling and the `ai_target_acquired()` /
  `ai_target_lost()` mob hooks.
- `_ai_movement.dm`: basic `get_path_to()` walker with a greedy step fallback
  while the pathfinder subsystem is not ready or has no route. Caches the path
  per controller/target and repaths after `repath_after` steps or a target change.
- `_ai_target_sources.dm`: `target_source` base plus `enemies` (closest pick,
  legacy distance rule), `enemies/wounded` (weakest pick) and
  `enemies/retaliate` (only mobs already in the pawn's legacy `enemies` list)
  sources. The `enemies` filter uses the pawn's `CanAttack()`, so only mobs that
  override it (hostile mobs) see healthy prey; the base simple_animal version
  only allows targets already in crit.
- `_ai_abilities.dm`: `ai_ability` base with cooldowns, plus `ranged_attack`
  (wraps the legacy `OpenFire`/`ranged_cooldown`) and `charge` (closes two tiles).
- `_ai_behaviors_basic.dm`: `acquire_target` (target sources, dead/invalid target
  cleanup), `move_to_target`, `attack_target`, `flee_target` (also the
  `retreat_from_target` keep-distance stance), `speak_line`, `use_ability`,
  `hold_position`, `smash_surroundings`, `wait`, `set_blackboard_key` and
  `clear_blackboard_key`, plus the `bt_hostile_combat_tree()` /
  `bt_basic_hostile_tree()` / `bt_fleeing_hostile_tree()` /
  `bt_ranged_hostile_tree()` / `bt_retaliating_hostile_tree()` descriptors.
- `bt_guard.dm`: example first consumer, a hostile simple animal whose decision
  layer is a behavior tree controller (not mapped; admin/spawn use). It composes
  a fleeing combat tree in parallel with ambient chatter.
- `bear.dm`: first existing mapped mob migration. Space bears (and their
  subtypes) now run the shared starter tree; the legacy hostile target
  acquisition is disabled.
- `carp.dm`: second existing mapped mob migration. Space carp (and their
  subtypes) now run the shared starter tree; their legacy target acquisition is
  disabled and the "gnashes at" emote moved to the `ai_target_acquired()` hook.
- `hivebot.dm`: third migration and the ranged consumers. `hivebot/strong`,
  `hivebot/range` and `hivebot/rapid` run `bt_ranged_hostile_tree()`: melee when
  adjacent, back off to `retreat_distance`, fire at range, hold while the gun
  cools down, chase otherwise. The beacon-spawned base `hivebot` and the `tele`
  beacon itself stay on the legacy AI on purpose.
- `viscerator.dm`: fourth migration. The viscerator runs the plain combat tree
  and is the first migrated mob that deletes itself on death, so it exercises
  controller cleanup (see below).
- `living.dm`: `/mob/living/Destroy()` now deletes the attached
  `ai_controller`, so a qdeleted pawn cannot leave an orphaned entry in the AI
  subsystem.
- `code/controllers/subsystem/ai_controllers.dm`: two subsystems —
  `SSai_controllers` for `AI_STATUS_ON` and `SSai_controllers_low` for
  `AI_STATUS_ON_LOW` at half rate. Controllers created before the subsystems
  start (mapped mobs load first) wait in `ai_controllers_pending` and are
  adopted by their owner subsystem.
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
  fallback (`polling_observers` + `polling_rate`) instead of signals, and
  sentience listens to the vg `/event/living_login` and `/event/logout` events.
- **Two controller subsystems, no z-level split yet.** High and low statuses
  have their own tick rate, but each subsystem walks one flat list instead of
  per-z lists. vg fires every z level anyway; revisit if a busy z level makes AI
  a measurable hotspot.
- **Simplified movement.** `ai_movement/basic` uses `get_path_to()` with a
  per-controller path cache. If `SSpathfinder.mobs` is not initialized or
  returns no route, it falls back to one greedy step instead of runtiming. That
  fallback has no obstacle avoidance: a blocked step fails the movement leaf and
  the tree retries on the next tick, so a pawn can stall on a single blocker.
- **Starter hostile behavior only.** The shared trees have acquire/move/attack,
  plus opt-in flee (`bt_fleeing_hostile_tree`), ranged combat with
  retreat/hold (`bt_ranged_hostile_tree`) and `speak_line`. Chatting leaves
  should pass explicit lines when the mob keeps legacy `handle_automated_speech()`
  to avoid double-speaking.
- **Ranged stance is selector-based.** The ranged tree evaluates melee, retreat,
  ability and hold in order; it cannot attack and back off on the same tick the
  way legacy `MoveToTarget()` does. A cornered ranged mob melees instead of
  failing to retreat.
- **Environment smashing is a fallback branch.** It calls the legacy
  `DestroySurroundings()` on a 2 second cooldown, only after the chase branch
  failed to move. It does not replace the legacy `EscapeConfinement()` loop.
- **Retaliation reads the legacy enemies list.** `target_source/enemies/retaliate`
  filters to `pawn.enemies`, which the `/hostile/retaliate` base fills on damage.
  A tree-driven retaliator therefore reacts on its next controller tick instead
  of instantly inside `adjustBruteLoss()`.
- **Target sources are polled, not event driven.** `acquire_target` asks its
  `target_source` for candidates on every run, so sources are cheap filters
  instead of signal subscriptions.
- **Abilities run synchronously.** `ai_ability/perform` must not sleep; anything
  with a windup belongs in a behavior leaf using `AI_BEHAVIOR_DELAY`. The ranged
  ability also respects the mob's legacy `ranged_cooldown`.
- **Migrations disable the legacy target acquisition** with a `FindTarget()`
  override. The legacy `Life()` still runs health/speech; only target
  acquisition, movement and attack are owned by the tree. Mobs can hook
  `ai_target_acquired()` / `ai_target_lost()` for reaction flavor; the target
  leaf also drops dead or unattackable targets instead of chasing them forever.
- **Death and sentience hooks.** Possession registers `/event/death`,
  `/event/living_login` and `/event/logout`; a client turns the AI off and
  logout resumes it unless the pawn is dead.
- **Compiled trees are generated, not authored in DM.** Sources live in
  `code/datums/ai/trees/*.bt.json`; `tools/behavior_tree/bt_compiler.py` validates
  them against the scanned `/datum/bt_node` declarations and writes
  `code/datums/ai/compiled/*.compiled.json` (committed). `--check` fails when the
  output is stale. Subtree references are expanded inline, so override slots are
  not reachable through JSON yet.
- **No async perform and no event logging.** The async leaf path and `EVLOG_*`
  calls are deferred with the controller/subsystem port.
- The BT viewer's `append_*` helpers are not ported yet.

## Next phases

1. **Behaviors:** port the remaining basic mob leaves (speech variants, more
   target sources, mob-specific specials, idle/wander) and keep migrating
   existing mobs.
2. **Controller integration:** z-level lists if AI becomes a hotspot; higher
   level path caching and multi-step movement.
3. **Tree tooling:** the BT viewer (the compiler and loader are in place).
4. **Migration:** move the remaining simple animal / NPC crew AI incrementally,
   with the behavior tree as the decision layer.

## Testing

The phase-10 scenario lives outside the repository (local auxtools harness):
build a sequence/selector/decorator/subtree, tick it across RUNNING/SUCCESS/
FAILURE, exercise the descriptor builder, cancel a running leaf, possess a mob,
verify sentience login/logout and high/low subsystem routing, trigger its death
event, test the path cache, load and run the compiled `guard.bt.compiled.json`
tree, move it towards a blackboard target, drive the
example `bt_guard` against an adjacent victim, make it flee while badly hurt and
resume combat after healing (in a cleared arena so the path is deterministic),
say a line, drop a dead target during acquisition, verify the closest and
wounded target sources pick the expected victim, fire the strong hivebot's
ranged ability, make it melee at adjacency, charge with a pawn, verify a ranged
hivebot retreats to its keep distance, smash surroundings as a hostile pawn,
test the wait/blackboard-key leaves, verify a retaliator stays passive until its
enemies list is filled, verify a destroyed pawn deletes its controller, and
verify the migrated space bear and space carp attack adjacent humans. Keep the
test leaves in `behavior_tree_test.dm` until real leaves and unit tests replace
them.
