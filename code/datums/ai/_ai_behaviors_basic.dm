// Starter behavior leaves for the WIP behavior tree port.
// These are intentionally small and use simple_animal primitives; the full
// basic mob behavior set is still to be ported.

// Shared starter trees for hostile consumers. These are building blocks: a mob
// can use bt_basic_hostile_tree() directly or compose it with extra branches.
// Try to attack an adjacent target, otherwise acquire and walk to it, then attack.
/proc/bt_hostile_combat_tree(target_source_type = /datum/target_source/enemies, attack_leaf_type = /datum/bt_node/ai_behavior/attack_target)
	return list(
		BT_DESC_TYPE = /datum/bt_node/composite/selector,
		BT_DESC_CHILDREN = list(
			list(
				BT_DESC_TYPE = /datum/bt_node/composite/sequence,
				BT_DESC_CHILDREN = list(
					list(
						BT_DESC_TYPE = /datum/bt_node/ai_behavior/acquire_target,
						target_source_type = target_source_type,
					),
					list(BT_DESC_TYPE = attack_leaf_type),
				),
			),
			list(
				BT_DESC_TYPE = /datum/bt_node/composite/sequence,
				BT_DESC_CHILDREN = list(
					list(
						BT_DESC_TYPE = /datum/bt_node/ai_behavior/acquire_target,
						target_source_type = target_source_type,
					),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/move_to_target),
					list(
						BT_DESC_TYPE = /datum/bt_node/ai_behavior/acquire_target,
						target_source_type = target_source_type,
					),
					list(BT_DESC_TYPE = attack_leaf_type),
				),
			),
			// Last resort when the chase branch could not move: break what is in
			// the way instead of standing still forever.
			list(
				BT_DESC_TYPE = /datum/bt_node/composite/sequence,
				BT_DESC_CHILDREN = list(
					list(
						BT_DESC_TYPE = /datum/bt_node/ai_behavior/acquire_target,
						target_source_type = target_source_type,
					),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/smash_surroundings),
				),
			),
		),
	)

/// Idle layer: wander occasionally, otherwise rest. Used by non-hostile mobs
/// and as the fallback of the idle hostile tree. With blocking_wait the rest leaf
/// returns RUNNING, so a selector holds it instead of re-running acquisition every
/// tick; hostile trees pass FALSE so combat is re-checked each tick.
/proc/bt_idle_tree(wander_chance = 50, wander_cooldown = 5 SECONDS, rest_time = 4 SECONDS, blocking_wait = TRUE)
	var/list/rest_leaf
	if(blocking_wait)
		rest_leaf = list(
			BT_DESC_TYPE = /datum/bt_node/ai_behavior/wait,
			wait_time = rest_time,
		)
	else
		rest_leaf = list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/idle)
	return list(
		BT_DESC_TYPE = /datum/bt_node/composite/selector,
		BT_DESC_CHILDREN = list(
			list(
				BT_DESC_TYPE = /datum/bt_node/ai_behavior/wander,
				move_chance = wander_chance,
				cooldown = wander_cooldown,
			),
			rest_leaf,
		),
	)

/// Hostile tree with an idle layer: fight when there is a target, otherwise
/// wander/rest. The rest leaf does not hold the selector, so a mob that is
/// provoked (or whose legacy enemies list fills) reacts on the next tick.
/proc/bt_idle_hostile_tree(target_source_type = /datum/target_source/enemies, wander_chance = 50, wander_cooldown = 5 SECONDS, rest_time = 4 SECONDS)
	return list(
		BT_DESC_TYPE = /datum/bt_node/composite/selector,
		BT_DESC_CHILDREN = list(
			bt_hostile_combat_tree(target_source_type),
			bt_idle_tree(wander_chance, wander_cooldown, rest_time, FALSE),
		),
	)

/// Hunts a specific prey type with the hunt leaf; otherwise wanders/rests.
/proc/bt_hunting_idle_tree(prey_type)
	return list(
		BT_DESC_TYPE = /datum/bt_node/composite/selector,
		BT_DESC_CHILDREN = list(
			list(
				BT_DESC_TYPE = /datum/bt_node/composite/sequence,
				BT_DESC_CHILDREN = list(
					list(
						BT_DESC_TYPE = /datum/bt_node/ai_behavior/acquire_target,
						target_source_type = /datum/target_source/prey,
						target_source_config = list("prey_type" = prey_type),
						search_range = 4,
					),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/hunt_target),
				),
			),
			bt_idle_tree(),
		),
	)

/// Follows the pawn's leader when it wanders off, otherwise wanders/rests.
/proc/bt_following_idle_tree(wander_chance = 50, wander_cooldown = 5 SECONDS, rest_time = 4 SECONDS)
	return list(
		BT_DESC_TYPE = /datum/bt_node/composite/selector,
		BT_DESC_CHILDREN = list(
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/follow_leader),
			bt_idle_tree(wander_chance, wander_cooldown, rest_time),
		),
	)

/// Default combat tree used by migrated mobs. Kept as a named entry point so
/// call sites do not depend on the composition details.
/proc/bt_basic_hostile_tree()
	return bt_hostile_combat_tree()

/// Companion tree for mobs that follow their owner instead of chasing: attack
/// only when a target is already adjacent, otherwise trail the follow target
/// (ai_get_follow_target). The arcane golem uses this.
/proc/bt_companion_hostile_tree(target_source_type = /datum/target_source/enemies)
	return list(
		BT_DESC_TYPE = /datum/bt_node/composite/selector,
		BT_DESC_CHILDREN = list(
			list(
				BT_DESC_TYPE = /datum/bt_node/composite/sequence,
				BT_DESC_CHILDREN = list(
					list(
						BT_DESC_TYPE = /datum/bt_node/ai_behavior/acquire_target,
						target_source_type = target_source_type,
					),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/attack_target),
				),
			),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/follow_leader, follow_distance = 2, max_distance = 40),
		),
	)

/// Combat tree that prefers to flee while badly hurt. The decorator self-aborts
/// (through the polling observer) once health recovers, so combat resumes.
/proc/bt_fleeing_hostile_tree(flee_below_health = 0.3, flee_distance = 5)
	return list(
		BT_DESC_TYPE = /datum/bt_node/composite/selector,
		BT_DESC_CHILDREN = list(
			list(
				BT_DESC_TYPE = /datum/bt_node/decorator/pawn_health_below,
				threshold = flee_below_health,
				observer_abort = BT_ABORT_SELF,
				BT_DESC_CHILDREN = list(
					list(
						BT_DESC_TYPE = /datum/bt_node/ai_behavior/flee_target,
						flee_distance = flee_distance,
						hold_while_target_alive = TRUE,
					),
				),
			),
			bt_hostile_combat_tree(),
		),
	)

/// Ranged tree: melee when adjacent, keep the retreat distance, fire when ready,
/// hold position while the gun cools down, and only then chase. The melee branch
/// comes first so a cornered ranged mob fights instead of failing to back off.
/proc/bt_ranged_hostile_tree(ability_type = /datum/ai_ability/ranged_attack, min_distance = 2, max_distance = 7, retreat_distance = 0)
	return list(
		BT_DESC_TYPE = /datum/bt_node/composite/selector,
		BT_DESC_CHILDREN = list(
			list(
				BT_DESC_TYPE = /datum/bt_node/composite/sequence,
				BT_DESC_CHILDREN = list(
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/acquire_target),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/attack_target),
				),
			),
			list(
				BT_DESC_TYPE = /datum/bt_node/ai_behavior/flee_target/retreat,
				flee_distance = retreat_distance,
				use_pawn_retreat_distance = TRUE,
			),
			list(
				BT_DESC_TYPE = /datum/bt_node/ai_behavior/use_ability,
				ability_type = ability_type,
				min_distance = min_distance,
				max_distance = max_distance,
			),
			list(
				BT_DESC_TYPE = /datum/bt_node/ai_behavior/hold_position,
				min_distance = min_distance,
				max_distance = max_distance,
			),
			bt_hostile_combat_tree(),
		),
	)

/// Finds a living target in view and stores it in the blackboard. The pawn's
/// ai_target_acquired()/ai_target_lost() hooks are called on changes so mobs can
/// react (emotes, sounds) without replacing this leaf. The candidate list and
/// priority come from target_source_type.
/datum/bt_node/ai_behavior/acquire_target
	var/target_key = BB_TARGET
	/// How far to look for a target, in tiles.
	var/search_range = 7
	/// Target source that decides which candidates exist and which one wins.
	var/target_source_type = /datum/target_source/enemies
	/// Optional config list applied to the target source instance.
	var/list/target_source_config = null
	/// Lazily built instance of target_source_type.
	var/datum/target_source/target_source = null

/datum/bt_node/ai_behavior/acquire_target/Destroy()
	QDEL_NULL(target_source)
	return ..()

/datum/bt_node/ai_behavior/acquire_target/proc/get_target_source()
	if(isnull(target_source) || target_source.type != target_source_type)
		QDEL_NULL(target_source)
		if(ispath(target_source_type, /datum/target_source))
			target_source = new target_source_type
			if(target_source_config)
				target_source.configure(target_source_config)
	return target_source

/// Returns TRUE while the stored target is still worth chasing. The target
/// source owns the "would I still attack this" rule.
/datum/bt_node/ai_behavior/acquire_target/proc/is_still_valid(datum/ai_controller/controller, atom/existing)
	if(!existing || QDELETED(existing))
		return FALSE
	if(isliving(existing))
		var/mob/living/living_target = existing
		if(living_target.stat == DEAD)
			return FALSE
	var/datum/target_source/source = get_target_source()
	if(!source)
		return TRUE
	return source.is_valid_target(controller, controller.pawn, existing)

/datum/bt_node/ai_behavior/acquire_target/perform(seconds_per_tick, datum/ai_controller/controller)

	var/mob/living/pawn = controller.pawn
	if(!pawn || QDELETED(pawn))
		return AI_BEHAVIOR_FAILED

	var/datum/target_source/source = get_target_source()
	if(!source)
		return AI_BEHAVIOR_FAILED

	var/atom/existing = controller.blackboard[target_key]
	if(existing)
		if(is_still_valid(controller, existing))
			return AI_BEHAVIOR_SUCCEEDED
		// Drop dead or otherwise invalid targets instead of chasing them forever.
		controller.blackboard.Remove(target_key)
		pawn.ai_target_lost(existing)

	var/atom/picked = source.pick_target(controller, pawn, source.find_targets(controller, pawn, search_range))
	if(!picked)
		controller.blackboard.Remove(target_key)
		return AI_BEHAVIOR_FAILED

	controller.blackboard[target_key] = picked
	pawn.ai_target_acquired(picked)
	// Fidelity: legacy GiveTarget() called Aggro(), which resets vision range and
	// drives mob overrides (spider icon swap, russian taunt). Only on a new target.
	if(istype(pawn, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/hostile_pawn = pawn
		hostile_pawn.Aggro()
	return AI_BEHAVIOR_SUCCEEDED

/// Walks the pawn towards the blackboard target using the controller's movement adapter.
/datum/bt_node/ai_behavior/move_to_target
	var/target_key = BB_TARGET
	var/max_distance = 30

/datum/bt_node/ai_behavior/move_to_target/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(!target || QDELETED(target) || !controller.pawn || !controller.ai_movement)
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/move_to_target/perform(seconds_per_tick, datum/ai_controller/controller)

	var/atom/target = controller.blackboard[target_key]
	var/mob/living/pawn = controller.pawn
	if(!target || QDELETED(target) || !pawn || QDELETED(pawn))
		return AI_BEHAVIOR_FAILED

	if(get_dist(pawn, target) <= 1)
		if(controller.ai_movement)
			controller.ai_movement.stop_moving_towards(controller)
		return AI_BEHAVIOR_SUCCEEDED

	if(!controller.ai_movement)
		return AI_BEHAVIOR_FAILED

	// The pathfinder fallback is a single greedy step, so recompute whenever the
	// moved path runs out; this also recovers from a target that moved.
	if(controller.ai_movement.needs_repath(controller, target) && !controller.ai_movement.start_moving_towards(controller, target, max_distance))
		return AI_BEHAVIOR_FAILED

	if(!controller.ai_movement.process(controller))
		return AI_BEHAVIOR_FAILED

	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/move_to_target/finish_action(datum/ai_controller/controller, succeeded)
	if(controller?.ai_movement)
		controller.ai_movement.stop_moving_towards(controller)
	return ..()

/// Attacks the blackboard target when adjacent. Returns failure when the target
/// is not adjacent so a selector can fall through to a movement branch.
/datum/bt_node/ai_behavior/attack_target
	var/target_key = BB_TARGET

/datum/bt_node/ai_behavior/attack_target/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(!target || QDELETED(target) || !controller.pawn)
		return FALSE
	return get_dist(controller.pawn, target) <= 1

/// Returns TRUE when the blackboard target is still adjacent and attackable.
/datum/bt_node/ai_behavior/attack_target/proc/can_attack(datum/ai_controller/controller, atom/target)
	if(!target || QDELETED(target) || !controller.pawn || QDELETED(controller.pawn))
		return FALSE
	return get_dist(controller.pawn, target) <= 1

/// Runs the attack (or the mob's legacy AttackingTarget override) once.
/datum/bt_node/ai_behavior/attack_target/proc/do_attack(datum/ai_controller/controller, atom/target)
	var/mob/living/pawn = controller.pawn
	// Bridge to the legacy combat hook so mob overrides keep working: the queen
	// roach lays eggs, the flying skull plays its bite animation, and so on.
	// The legacy hook reads src.target, so point it at the blackboard target for
	// this call and clear it afterwards to avoid a stale legacy target.
	if(istype(pawn, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/hostile_pawn = pawn
		hostile_pawn.target = target
		hostile_pawn.AttackingTarget()
		hostile_pawn.target = null
	else
		pawn.UnarmedAttack(target)
	return AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/attack_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(!can_attack(controller, target))
		return AI_BEHAVIOR_FAILED
	return do_attack(controller, target)

/// Attack variant for mobs whose attack sleeps (nurse spider cocooning with
/// do_after). perform() hands off to async_perform() so the tick never blocks.
/datum/bt_node/ai_behavior/attack_target/async
/datum/bt_node/ai_behavior/attack_target/async/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(!can_attack(controller, target))
		return AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_ASYNC

/datum/bt_node/ai_behavior/attack_target/async/async_perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(!can_attack(controller, target))
		return AI_BEHAVIOR_FAILED
	return do_attack(controller, target)

/// Runs away from the blackboard target until it is farther than flee_distance.
/// With hold_while_target_alive the leaf stays RUNNING once safe, so a
/// respond-to-damage branch keeps the pawn away instead of re-engaging.
/// With gate_on_distance the leaf is a retreat stance: it only activates while
/// closer than flee_distance and finishes once that distance is reached.
/datum/bt_node/ai_behavior/flee_target
	var/target_key = BB_TARGET
	var/flee_distance = 5
	var/max_distance = 30
	var/hold_while_target_alive = FALSE
	/// When TRUE, act as a keep-distance stance instead of a full flee.
	var/gate_on_distance = FALSE
	/// When TRUE, read the keep distance from the pawn's `retreat_distance`
	/// every activation instead of the configured `flee_distance`.
	var/use_pawn_retreat_distance = FALSE

/datum/bt_node/ai_behavior/flee_target/setup(datum/ai_controller/controller)
	var/atom/threat = controller.blackboard[target_key]
	if(!threat || QDELETED(threat) || !controller.pawn || !controller.ai_movement)
		return FALSE
	if(use_pawn_retreat_distance)
		var/mob/living/simple_animal/hostile/hostile_pawn = controller.pawn
		// Mobs flip retreat_distance at runtime (the nazi switches to melee when
		// out of ammo, the grey grenadier reloads farther away).
		if(!istype(hostile_pawn) || !hostile_pawn.retreat_distance)
			return FALSE
		flee_distance = hostile_pawn.retreat_distance
	if(flee_distance <= 0)
		return FALSE
	if(gate_on_distance && get_dist(controller.pawn, threat) >= flee_distance)
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/flee_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/threat = controller.blackboard[target_key]
	var/mob/living/pawn = controller.pawn
	if(!threat || QDELETED(threat) || !pawn || QDELETED(pawn))
		return AI_BEHAVIOR_FAILED

	if(get_dist(pawn, threat) >= flee_distance)
		if(controller.ai_movement)
			controller.ai_movement.stop_moving_towards(controller)
		if(hold_while_target_alive)
			return AI_BEHAVIOR_DELAY
		return AI_BEHAVIOR_SUCCEEDED

	if(!controller.ai_movement)
		return AI_BEHAVIOR_FAILED

	var/away_dir = get_dir(threat, pawn)
	if(!away_dir)
		return AI_BEHAVIOR_FAILED
	var/turf/flee_turf = get_edge_target_turf(pawn, away_dir)
	if(!flee_turf)
		return AI_BEHAVIOR_FAILED
	if(controller.ai_movement.needs_repath(controller, flee_turf) && !controller.ai_movement.start_moving_towards(controller, flee_turf, max_distance))
		return AI_BEHAVIOR_FAILED

	if(!controller.ai_movement.process(controller))
		return AI_BEHAVIOR_FAILED

	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/flee_target/finish_action(datum/ai_controller/controller, succeeded)
	if(controller?.ai_movement)
		controller.ai_movement.stop_moving_towards(controller)
	return ..()

/// Keep-distance stance for ranged mobs: backs off while the target is closer
/// than flee_distance and yields once the distance is restored. Subtype of
/// flee_target so it shares the pathing/stop logic.
/datum/bt_node/ai_behavior/flee_target/retreat
	gate_on_distance = TRUE

/// Says one of the provided lines (or the pawn's speak list) on a cooldown.
/// Note: simple animals that keep legacy speech (handle_automated_speech) should
/// pass an explicit lines list to avoid double-speaking from pawn.speak.
/datum/bt_node/ai_behavior/speak_line
	var/list/lines = null
	/// Percent chance to say something on a perform tick.
	var/speak_chance = 100
	/// Cooldown between speak attempts.
	var/cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/speak_line/get_cooldown(datum/ai_controller/controller)
	return cooldown

/datum/bt_node/ai_behavior/speak_line/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	if(!pawn || QDELETED(pawn))
		return AI_BEHAVIOR_FAILED

	if(prob(speak_chance))
		var/list/choices = lines
		if(!choices || !length(choices))
			if(istype(pawn, /mob/living/simple_animal))
				var/mob/living/simple_animal/animal = pawn
				choices = animal.speak
		if(choices && length(choices))
			pawn.say(pick(choices))

	return AI_BEHAVIOR_DELAY

/// Triggers an /datum/ai_ability when the blackboard target is within range and
/// the ability is ready. On a cooldown or out of range it fails so a selector can
/// fall through to the next branch (usually movement or melee).
/datum/bt_node/ai_behavior/use_ability
	var/target_key = BB_TARGET
	var/ability_type = null
	/// Lazily built instance of ability_type.
	var/datum/ai_ability/ability = null
	/// Ability only fires while the target is at least this many tiles away.
	var/min_distance = 2
	/// ...and at most this many tiles away.
	var/max_distance = 7

/datum/bt_node/ai_behavior/use_ability/Destroy()
	QDEL_NULL(ability)
	return ..()

/datum/bt_node/ai_behavior/use_ability/proc/get_ability()
	if(isnull(ability) || ability.type != ability_type)
		QDEL_NULL(ability)
		if(ispath(ability_type, /datum/ai_ability))
			ability = new ability_type
	return ability

/datum/bt_node/ai_behavior/use_ability/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	var/mob/living/pawn = controller.pawn
	if(!target || QDELETED(target) || !pawn || QDELETED(pawn))
		return FALSE
	if(!ispath(ability_type, /datum/ai_ability))
		return FALSE

	var/distance = get_dist(pawn, target)
	if(distance < min_distance || distance > max_distance)
		return FALSE

	var/datum/ai_ability/ready_ability = get_ability()
	return ready_ability ? ready_ability.can_use(controller) : FALSE

/datum/bt_node/ai_behavior/use_ability/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(!target || QDELETED(target) || isnull(ability))
		return AI_BEHAVIOR_FAILED

	var/result = ability.perform(controller, target)
	if(result & AI_BEHAVIOR_SUCCEEDED)
		ability.start_cooldown(controller)
	return result

/// Does nothing for a tick when the target is inside the ability's range but the
/// ability is not ready. Returning SUCCESS lets the selector re-check next tick
/// instead of walking the pawn into melee.
/datum/bt_node/ai_behavior/hold_position
	var/target_key = BB_TARGET
	var/min_distance = 1
	var/max_distance = 7

/datum/bt_node/ai_behavior/hold_position/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	var/mob/living/pawn = controller.pawn
	if(!target || QDELETED(target) || !pawn || QDELETED(pawn))
		return FALSE
	var/distance = get_dist(pawn, target)
	return distance > min_distance && distance <= max_distance

/datum/bt_node/ai_behavior/hold_position/perform(seconds_per_tick, datum/ai_controller/controller)
	return AI_BEHAVIOR_SUCCEEDED

/// Breaks obstacles in the pawn's way through the legacy DestroySurroundings().
/// Only useful for hostile mobs; other pawns fail the branch.
/datum/bt_node/ai_behavior/smash_surroundings
	/// Cooldown between smashing attempts so a blocked pawn does not spam attacks.
	var/cooldown = 2 SECONDS
	/// world.time before which the leaf reports failure instead of smashing.
	var/next_smash_time = 0

/datum/bt_node/ai_behavior/smash_surroundings/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/hostile/hostile = controller.pawn
	if(!istype(hostile) || QDELETED(hostile))
		return AI_BEHAVIOR_FAILED
	// Fail (instead of returning DELAY) so the selector keeps re-evaluating the
	// higher-priority branches while the smash is on cooldown.
	if(world.time < next_smash_time)
		return AI_BEHAVIOR_FAILED
	next_smash_time = world.time + cooldown
	hostile.DestroySurroundings()
	return AI_BEHAVIOR_SUCCEEDED

/// Idles for wait_time, then succeeds. Useful as the last branch of a tree so an
/// idle pawn stops re-running target acquisition every controller tick.
/datum/bt_node/ai_behavior/wait
	var/wait_time = 2 SECONDS
	/// world.time when the wait is over; set on setup().
	var/end_time = 0

/datum/bt_node/ai_behavior/wait/setup(datum/ai_controller/controller)
	end_time = world.time + max(0, wait_time)
	return TRUE

/datum/bt_node/ai_behavior/wait/perform(seconds_per_tick, datum/ai_controller/controller)
	if(world.time >= end_time)
		return AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY

/// No-op leaf that succeeds immediately. Used as the non-blocking rest of the
/// hostile idle tree so a selector re-checks combat every tick.
/datum/bt_node/ai_behavior/idle

/datum/bt_node/ai_behavior/idle/perform(seconds_per_tick, datum/ai_controller/controller)
	return AI_BEHAVIOR_SUCCEEDED

/// Writes a value to the blackboard. Fails without a key.
/datum/bt_node/ai_behavior/set_blackboard_key
	var/key = null
	var/value = null

/datum/bt_node/ai_behavior/set_blackboard_key/perform(seconds_per_tick, datum/ai_controller/controller)
	if(isnull(key))
		return AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(key, value)
	return AI_BEHAVIOR_SUCCEEDED

/// Removes a blackboard key. Fails without a key.
/datum/bt_node/ai_behavior/clear_blackboard_key
	var/key = null

/datum/bt_node/ai_behavior/clear_blackboard_key/perform(seconds_per_tick, datum/ai_controller/controller)
	if(isnull(key))
		return AI_BEHAVIOR_FAILED
	controller.clear_blackboard_key(key)
	return AI_BEHAVIOR_SUCCEEDED

/// Takes one random step, or fails so an idle sibling branch (wait) can run.
/// A manual cooldown keeps a selector from re-triggering it every tick.
/datum/bt_node/ai_behavior/wander
	/// Percent chance to take a step when off cooldown.
	var/move_chance = 50
	/// Cooldown between step attempts.
	var/cooldown = 5 SECONDS
	/// world.time before which this leaf reports failure.
	var/next_move_time = 0

/datum/bt_node/ai_behavior/wander/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	if(!pawn || QDELETED(pawn))
		return AI_BEHAVIOR_FAILED
	if(world.time < next_move_time)
		return AI_BEHAVIOR_FAILED

	next_move_time = world.time + cooldown
	if(!prob(move_chance))
		return AI_BEHAVIOR_FAILED

	var/turf/destination = get_step(pawn, pick(alldirs))
	if(!destination || !pawn.Move(destination))
		return AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_SUCCEEDED

/// Moves to the blackboard target and lets the pawn kill it through
/// ai_hunt_kill(). Unlike attack_target this works for non-hostile pawns and
/// respects a custom kill hook (the cat's splat).
/datum/bt_node/ai_behavior/hunt_target
	var/target_key = BB_TARGET
	var/max_distance = 10

/datum/bt_node/ai_behavior/hunt_target/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	var/mob/living/pawn = controller.pawn
	if(!target || QDELETED(target) || !pawn || QDELETED(pawn) || !controller.ai_movement)
		return FALSE
	// Held, restrained or unconscious pawns do not hunt.
	if(pawn.stat || pawn.locked_to)
		return FALSE
	return get_dist(pawn, target) <= max_distance

/datum/bt_node/ai_behavior/hunt_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	var/mob/living/pawn = controller.pawn
	if(!target || QDELETED(target) || !pawn || QDELETED(pawn))
		return AI_BEHAVIOR_FAILED

	if(get_dist(pawn, target) <= 1)
		pawn.ai_hunt_kill(target)
		if(controller.ai_movement)
			controller.ai_movement.stop_moving_towards(controller)
		return AI_BEHAVIOR_SUCCEEDED

	if(!controller.ai_movement)
		return AI_BEHAVIOR_FAILED
	if(controller.ai_movement.needs_repath(controller, target) && !controller.ai_movement.start_moving_towards(controller, target, max_distance))
		return AI_BEHAVIOR_FAILED
	if(!controller.ai_movement.process(controller))
		return AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/hunt_target/finish_action(datum/ai_controller/controller, succeeded)
	if(controller?.ai_movement)
		controller.ai_movement.stop_moving_towards(controller)
	return ..()

/// Follows the pawn's leader (ai_get_follow_target()) to within follow_distance,
/// then yields so the idle branch can run. Pets use this to trail their master.
/datum/bt_node/ai_behavior/follow_leader
	/// Stop chasing once the leader is this close (tiles).
	var/follow_distance = 2
	/// Give up and idle if the leader is farther than this (tiles).
	var/max_distance = 12

/datum/bt_node/ai_behavior/follow_leader/setup(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	if(!pawn || QDELETED(pawn) || !controller.ai_movement)
		return FALSE
	var/atom/leader = pawn.ai_get_follow_target()
	if(!leader || QDELETED(leader) || leader.z != pawn.z)
		return FALSE
	var/distance = get_dist(pawn, leader)
	return distance > follow_distance && distance <= max_distance

/datum/bt_node/ai_behavior/follow_leader/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	if(!pawn || QDELETED(pawn))
		return AI_BEHAVIOR_FAILED
	var/atom/leader = pawn.ai_get_follow_target()
	if(!leader || QDELETED(leader) || leader.z != pawn.z)
		return AI_BEHAVIOR_FAILED

	if(get_dist(pawn, leader) <= follow_distance)
		if(controller.ai_movement)
			controller.ai_movement.stop_moving_towards(controller)
		return AI_BEHAVIOR_SUCCEEDED

	if(!controller.ai_movement)
		return AI_BEHAVIOR_FAILED
	if(controller.ai_movement.needs_repath(controller, leader) && !controller.ai_movement.start_moving_towards(controller, leader, max_distance))
		return AI_BEHAVIOR_FAILED
	if(!controller.ai_movement.process(controller))
		return AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/follow_leader/finish_action(datum/ai_controller/controller, succeeded)
	if(controller?.ai_movement)
		controller.ai_movement.stop_moving_towards(controller)
	return ..()

/// Runs the pawn's idle work (web spinning, egg laying, ...) in a background
/// action so do_after() cannot stall the controller tick.
/datum/bt_node/ai_behavior/idle_work
	/// Cooldown between idle work attempts.
	var/cooldown = 5 SECONDS
	/// world.time before which the leaf reports failure.
	var/next_work_time = 0

/datum/bt_node/ai_behavior/idle_work/setup(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	if(!pawn || QDELETED(pawn))
		return FALSE
	return world.time >= next_work_time

/datum/bt_node/ai_behavior/idle_work/perform(seconds_per_tick, datum/ai_controller/controller)
	next_work_time = world.time + cooldown
	return AI_BEHAVIOR_ASYNC

/datum/bt_node/ai_behavior/idle_work/async_perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	if(!pawn || QDELETED(pawn))
		return AI_BEHAVIOR_FAILED
	pawn.ai_idle_work()
	return AI_BEHAVIOR_SUCCEEDED
