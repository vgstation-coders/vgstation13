// Starter behavior leaves for the WIP behavior tree port.
// These are intentionally small and use simple_animal primitives; the full
// basic mob behavior set is still to be ported.

// Shared starter trees for hostile consumers. These are building blocks: a mob
// can use bt_basic_hostile_tree() directly or compose it with extra branches.
// Try to attack an adjacent target, otherwise acquire and walk to it, then attack.
/proc/bt_hostile_combat_tree()
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
				BT_DESC_TYPE = /datum/bt_node/composite/sequence,
				BT_DESC_CHILDREN = list(
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/acquire_target),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/move_to_target),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/acquire_target),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/attack_target),
				),
			),
		),
	)

/// Default combat tree used by migrated mobs. Kept as a named entry point so
/// call sites do not depend on the composition details.
/proc/bt_basic_hostile_tree()
	return bt_hostile_combat_tree()

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

/// Hostile tree that opens with a ranged ability while the target is at range,
/// then falls back to the shared combat tree (which closes in and melees).
/proc/bt_ranged_hostile_tree(ability_type = /datum/ai_ability/ranged_attack, min_distance = 2, max_distance = 7)
	return list(
		BT_DESC_TYPE = /datum/bt_node/composite/selector,
		BT_DESC_CHILDREN = list(
			list(
				BT_DESC_TYPE = /datum/bt_node/ai_behavior/use_ability,
				ability_type = ability_type,
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
	return target_source

/// Returns TRUE while the stored target is still worth chasing.
/datum/bt_node/ai_behavior/acquire_target/proc/is_still_valid(datum/ai_controller/controller, atom/existing)
	if(!existing || QDELETED(existing))
		return FALSE
	if(isliving(existing))
		var/mob/living/living_target = existing
		if(living_target.stat == DEAD)
			return FALSE
	if(istype(controller.pawn, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = controller.pawn
		if(!animal.CanAttack(existing))
			return FALSE
	return TRUE

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
	// stored path runs out; this also recovers from a target that moved.
	if(!controller.ai_movement.has_path(controller) && !controller.ai_movement.start_moving_towards(controller, target, max_distance))
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

/datum/bt_node/ai_behavior/attack_target/perform(seconds_per_tick, datum/ai_controller/controller)

	var/atom/target = controller.blackboard[target_key]
	var/mob/living/pawn = controller.pawn
	if(!target || QDELETED(target) || !pawn || QDELETED(pawn))
		return AI_BEHAVIOR_FAILED
	if(get_dist(pawn, target) > 1)
		return AI_BEHAVIOR_FAILED

	pawn.UnarmedAttack(target)
	return AI_BEHAVIOR_SUCCEEDED

/// Runs away from the blackboard target until it is farther than flee_distance.
/// With hold_while_target_alive the leaf stays RUNNING once safe, so a
/// respond-to-damage branch keeps the pawn away instead of re-engaging.
/datum/bt_node/ai_behavior/flee_target
	var/target_key = BB_TARGET
	var/flee_distance = 5
	var/max_distance = 30
	var/hold_while_target_alive = FALSE

/datum/bt_node/ai_behavior/flee_target/setup(datum/ai_controller/controller)
	var/atom/threat = controller.blackboard[target_key]
	if(!threat || QDELETED(threat) || !controller.pawn || !controller.ai_movement)
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/flee_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/threat = controller.blackboard[target_key]
	var/mob/living/pawn = controller.pawn
	if(!threat || QDELETED(threat) || !pawn || QDELETED(pawn))
		return AI_BEHAVIOR_FAILED

	if(get_dist(pawn, threat) > flee_distance)
		if(controller.ai_movement)
			controller.ai_movement.stop_moving_towards(controller)
		if(hold_while_target_alive)
			return AI_BEHAVIOR_DELAY
		return AI_BEHAVIOR_SUCCEEDED

	if(!controller.ai_movement)
		return AI_BEHAVIOR_FAILED

	if(!controller.ai_movement.has_path(controller))
		var/away_dir = get_dir(threat, pawn)
		if(!away_dir)
			return AI_BEHAVIOR_FAILED
		var/turf/flee_turf = get_edge_target_turf(pawn, away_dir)
		if(!flee_turf || !controller.ai_movement.start_moving_towards(controller, flee_turf, max_distance))
			return AI_BEHAVIOR_FAILED

	if(!controller.ai_movement.process(controller))
		return AI_BEHAVIOR_FAILED

	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/flee_target/finish_action(datum/ai_controller/controller, succeeded)
	if(controller?.ai_movement)
		controller.ai_movement.stop_moving_towards(controller)
	return ..()

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
