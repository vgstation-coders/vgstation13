# Behavior trees (WIP port from tgstation)

Source: [tgstation/tgstation](https://github.com/tgstation/tgstation) `master`,
`code/datums/ai/_ai_bt_*.dm`, `code/datums/ai/_ai_behavior.dm`,
`code/datums/ai/_ai_controller.dm` and `code/__DEFINES/ai/behavior_trees.dm`.

**Status:** phase 21. The core, subsystem/possession path, sentience hooks,
z-level-gated subsystems, path-cached movement, starter behavior leaves (attack,
flee, retreat, hold, smash, wait, wander, hunt, follow, idle work, speak,
blackboard keys), async actions, target lifecycle hooks and target sources
(enemies, wounded, retaliate, prey, including wanted objects), an ability system
with a ranged and a charge ability, a health decorator, the `.bt.json` compiler,
the admin BT viewer, an example hostile consumer and twenty-seven existing mapped
mob types plus the syndicate, mummy, jackal, vox, grey, nazi, mimic, frog and deer
families compile and pass the auxtools scenario. The wider basic mob behavior set
is still pending.

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
- `_ai_behavior.dm`: behavior leaf base (setup/perform/finish/cooldown) with the
  async path: `perform()` may return `AI_BEHAVIOR_ASYNC`, which starts
  `async_perform()` in a background context; a token invalidates results from
  cancelled actions.
- `_ai_controller.dm`: blackboard, descriptor/typepath tree construction,
  `SelectBehaviors()`, cancellation, tick-state reset, AI status, possession,
  sentience (`/event/living_login`, `/event/logout`), subsystem routing, movement
  adapter, pawn death handling and the `ai_target_acquired()` /
  `ai_target_lost()` mob hooks.
- `_ai_movement.dm`: basic `get_path_to()` walker with a greedy step fallback
  while the pathfinder subsystem is not ready or has no route. Caches the path
  per controller/target and repaths after `repath_after` steps or a target change.
- `_ai_target_sources.dm`: `target_source` base plus `enemies` (closest pick,
  legacy distance rule, plus wanted objects while the pawn still searches for
  them), `enemies/wounded` (weakest pick), `enemies/retaliate` (only mobs already
  in the pawn's legacy `enemies` list) and `prey` (a specific mob type, ignoring
  `CanAttack` so friendly hunters work) sources. The `enemies` filter uses the
  pawn's `CanAttack()`, so only mobs that override it (hostile mobs) see healthy
  prey; the base simple_animal version only allows targets already in crit.
- `_ai_abilities.dm`: `ai_ability` base with cooldowns, plus `ranged_attack`
  (wraps the legacy `OpenFire`/`ranged_cooldown`) and `charge` (closes two tiles).
- `_ai_behaviors_basic.dm`: `acquire_target` (target sources, dead/invalid target
  cleanup), `move_to_target`, `attack_target`, `flee_target` (also the
  `retreat_from_target` keep-distance stance), `speak_line`, `use_ability`,
  `hold_position`, `smash_surroundings`, `wait`, `set_blackboard_key`,
  `clear_blackboard_key` and `wander`, plus the `bt_hostile_combat_tree()` /
  `bt_basic_hostile_tree()` / `bt_fleeing_hostile_tree()` /
  `bt_ranged_hostile_tree()` / `bt_retaliating_hostile_tree()` /
  `bt_idle_tree()` / `bt_idle_hostile_tree()` / `bt_hunting_idle_tree()` /
  `bt_following_idle_tree()` descriptors and the `hunt_target` and
  `follow_leader` leaves.
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
- `cow.dm`: fifth migration and the first non-hostile consumer. Cows run
  `bt_idle_tree()` (wander/rest); legacy automated movement is disabled and
  legacy speech/milking stay untouched.
- `goat.dm`: sixth migration and the first production retaliator. Goats run
  `bt_idle_hostile_tree(retaliate)`: passive wander/rest until something fills
  the legacy `enemies` list (anger or damage), then fight. `Calm()` clears the
  tree's blackboard target as well as the legacy one.
- `chicken.dm`: seventh migration. Chickens run `bt_following_idle_tree()`; a
  befriended chicken (`master` set by petting) trails its owner within a few
  tiles, otherwise it wanders/rests. Egg laying, feather regen and speech stay in
  `Life()`.
- `cat.dm`: eighth migration and the first hunter. Cats run
  `bt_hunting_idle_tree(/mob/living/simple_animal/mouse)`: the `prey` source finds
  mice, `hunt_target` walks over and calls `ai_hunt_kill()`, which the cat
  overrides to splat the mouse with its legacy kill verbs. The legacy Life hunt
  loop was removed; the growl moved to `ai_target_acquired()`.
- `crab.dm` + `bigroach.dm`: ninth and tenth migrations. The megamadcrab and the
  roaches (queen included) run the shared combat tree; the queen keeps laying
  eggs because `attack_target` bridges to the legacy `AttackingTarget()` hook.
- `gingerbreadman.dm`, `gingerbreadmobs.dm` + `skeletonjack.dm`: eleventh to
  thirteenth migrations. The gingerbread man, the whole ginger family (chef,
  knight, broodmother, ...) and skeleton jack run the shared combat tree; the
  broodmother's special attack and skeleton jack's candybucket drop are untouched.
- `warriorbug.dm`, `retaliate/clown.dm`, `retaliate/mime.dm`,
  `retaliate/tomato.dm` + `puddi.dm`: fourteenth to eighteenth migrations. The
  warrior bug fights with the shared combat tree; clown, mime and tomato use
  `use_retaliating_tree()` (added on the retaliate base, now shared with the
  goat); puddi is a friendly idle/wander pet.
- `giant_spider/hunter.dm`: nineteenth migration. The hunter runs the idle combat
  tree, keeps the base spider's poison bite through the `AttackingTarget()` bridge
  and still smashes wanted objects (lights/bots) because `enemies` now includes
  them while `search_objects` is set.
- `human/pirate.dm` + `human/russian.dm`: twentieth and twenty-first migrations.
  A shared `use_humanoid_tree()` picks the ranged tree when `ranged_mode()` is set
  (gunner variants) and the melee combat tree otherwise; corpses/items on death
  are untouched.
- `giant_spider/nurse.dm`: twenty-second and twenty-third migrations (nurse and
  queen). They run a cocooning tree with async attacks (do_after cocoons no longer
  stall the tick), async idle work (web spinning, egg laying, evolution checks)
  and the queen's web projectile through the ranged ability.
- `human/syndicate.dm`, `human/mummy.dm` + `human/jackal.dm`: the syndicate,
  mummy and jackal families run `use_humanoid_tree()` (melee or gunner variants).
  The mummy priests and jackal pyromaniac keep their custom `Shoot()` spells
  because `ranged_attack` points the legacy `target` var at the shot target; the
  jackal embalmer targets dead bodies through the normal `CanAttack`/stat_attack
  rules.
- `human/vox.dm`: the vox families (prisoners, spaceraiders, crossbows, ions) run
  `use_humanoid_tree()`. Vox loot works because spacecash is a wanted object (the
  tree targets it and `AttackingTarget()` pockets it) and `ranged_attack` asks
  `ranged_mode()` with the blackboard target, so raiders run to the money instead
  of shooting it.
- `human/grey.dm`: the grey family (prisoners, soldiers, researchers, leader) runs
  `use_humanoid_tree()`. Weapon-mode switching, shields, grenadier reloading and
  the leader's psychic heals stay in `Life()`; the leader's legacy focus-fire
  propagation was removed because it would flip soldiers back to the legacy
  stance/movement.
- `human/nazi.dm`: the nazi family runs `use_humanoid_tree()`. Ammo counting and
  the "out of ammo -> knife" switch stay in `afterShoot()`; the drawn-weapon
  overlays now also key off `ai_has_target()` because the tree does not touch
  `stance`.
- `mimic.dm`: mimics run the combat tree with `target_source/enemies/mimic`,
  which stays empty until `anger()`; losing the target calls `calm_down()` again
  (re-disguise) because the tree never calls `LoseTarget()`.
- `frog.dm`: hoppers run the ranged tree; their `Shoot()` (leap or spear throw)
  keeps working because `ranged_attack` sets the legacy target, and the
  spear/climb logic stays in `AttackingTarget()`/`Life()`.
- `deer.dm`: deer acquire targets with the tree and set `BB_SPOOKED` through
  `ai_target_acquired()`; a decorator runs the flee stance and self-aborts when
  `calm_down()` clears the flag. Nearby deer get spooked too.
- `_ai_bt_viewer.dm` + `code/modules/admin/verbs/behavior_trees.dm`: admin
  "View Behavior Tree" verb rendering the tree, blackboard and live markers.
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
- **Two controller subsystems, z-level buckets, player gating.** Each subsystem
  keeps controllers in per-z buckets and skips z levels without a client: an
  unobserved z level does not need to simulate decisions. Buckets self-heal when
  a pawn changes z (`sync_z_buckets()`). The per-controller rate is unchanged.
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
  filters to `pawn.enemies`, which the `/hostile/retaliate` base fills on damage
  (and the goat fills on anger). A tree-driven retaliator therefore reacts on its
  next controller tick instead of instantly inside `adjustBruteLoss()`. Mob code
  that clears the legacy target (`goat/Calm()`) must also clear `BB_TARGET`; the
  goat does.
- **Prey sources bypass CanAttack.** `target_source/prey` matches its configured
  `prey_type` on a turf instead, so a friendly hunter (the cat) can target mice it
  is not allowed to "attack". The kill goes through the `ai_hunt_kill()` pawn
  hook, which defaults to `UnarmedAttack()` and is overridden for special kills.
- **attack_target bridges to legacy `AttackingTarget()`.** For hostile pawns the
  leaf sets the legacy `target` var for the call, invokes `AttackingTarget()` and
  clears it, so mob overrides (queen roach eggs, flying skull animation) keep
  working. Non-hostile pawns fall back to `UnarmedAttack()`.
- **Target acquisition calls `Aggro()`.** Acquiring a new target invokes the
  legacy `Aggro()` hook (vision range, spider icon swap, russian taunt).
  `LoseAggro()` is deliberately not called because it re-enables legacy automated
  movement; mobs that need an idle state restore it themselves.
- **Following uses a pawn hook.** `follow_leader` asks `ai_get_follow_target()`
  (default null; the chicken returns its `master`) and gives up when the leader is
  on another z level or farther than `max_distance`, falling back to idle.
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
- **Async actions run in a background context.** `async_perform()` may sleep (the
  nurse's `do_after` cocoons use this). Cancellation invalidates the action's
  result through a token, but it cannot interrupt a `do_after` already in
  progress: the side effect may still land. Event logging (`EVLOG_*`) is still
  deferred; the viewer renders on demand and does not drain a per-tick log.
- **Ranged shots set the legacy target.** Some legacy `Shoot()` overrides ignore
  their arguments and read `src.target`; `ranged_attack` sets it before
  `OpenFire()`. The legacy `Life()`'s idle `GiveTarget(null)` clears it again.
  `can_use()` also exposes the blackboard target while it asks `ranged_mode()`, so
  overrides like the vox raider's can tell money from a real target.
- **Ranged retreat distance is dynamic.** The ranged tree's retreat leaf reads
  `pawn.retreat_distance` on every activation, so mobs that change it at runtime
  (grey grenadier reloading, nazi switching to a knife when out of ammo) stop or
  start keeping distance without rebuilding the tree.
- **Dead bodies are not pre-filtered.** For simple animals the enemy source leaves
  the dead/alive decision to `CanAttack()` (which encodes `stat_attack` and
  `stat_exclusive`), so embalmers and nurse spiders can target corpses.
- **Controller death safety net.** `SelectBehaviors()` turns the AI off when the
  pawn is dead, covering death overrides that skip `..()` and never fire
  `/event/death`.

## Next phases

1. **Behaviors:** port the remaining basic mob leaves (speech variants, more
   target sources, mob-specific specials, idle/wander) and keep migrating
   existing mobs.
2. **Controller integration:** z-level lists if AI becomes a hotspot; higher
   level path caching and multi-step movement.
3. **Tree tooling:** richer viewer (execution log, TGUI window) and a subtree
   override editor.
4. **Migration:** move the remaining simple animal / NPC crew AI incrementally,
   with the behavior tree as the decision layer.

## Testing

The phase-20 scenario lives outside the repository (local auxtools harness):
build a sequence/selector/decorator/subtree, tick it across RUNNING/SUCCESS/
FAILURE, exercise the descriptor builder, cancel a running leaf, possess a mob,
verify sentience login/logout and high/low subsystem routing (per-z buckets),
trigger its death event, test the path cache, load and run the compiled
`guard.bt.compiled.json` tree, render a tree with the BT viewer, move it towards
a blackboard target, drive the
example `bt_guard` against an adjacent victim, make it flee while badly hurt and
resume combat after healing (in a cleared arena so the path is deterministic),
say a line, drop a dead target during acquisition, verify the closest and
wounded target sources pick the expected victim, fire the strong hivebot's
ranged ability, make it melee at adjacency, charge with a pawn, verify a ranged
hivebot retreats to its keep distance, smash surroundings as a hostile pawn,
test the wait/blackboard-key leaves, verify a retaliator stays passive until its
enemies list is filled, verify a destroyed pawn deletes its controller, verify
the cow and chicken idle trees wander, verify the goat fights its enemies and
`Calm()` clears the tree target, verify the cat hunts and kills a mouse, verify a
befriended chicken follows its master, verify the crab attacks through the combat
tree, verify the queen roach lays an egg through the legacy `AttackingTarget()`
bridge, verify the gingerbread/ginger/skeleton jack batch attacks through the
combat tree, verify the warrior bug/clown/tomato batch attacks, verify puddi's
idle tree wanders, verify the spider hunter targets a wanted object and then
attacks a living victim, verify the pirate/russian melee batch attacks and the
pirate gunner fires its ranged ability, exercise the async leaf state machine,
verify the nurse spider has the async attack leaf and spins a web in idle work,
verify the syndicate melee/gunner, mummy warrior/priest and jackal embalmer
families behave, verify the vox assassin fires and the base raider loots
spacecash, verify the grey regular fires and a grey prisoner melees, verify the
nazi trooper fires at its keep distance, verify the mimic stays passive until
angered, verify the frog leaps and the deer spooks/flees/calms, and verify the
migrated space bear and space carp attack adjacent humans. Keep the test leaves
in `behavior_tree_test.dm` until real leaves and unit tests replace them.
