// Starter behavior leaves for the WIP behavior tree port.
// These are intentionally small and use simple_animal primitives; the full
// basic mob behavior set is still to be ported.

// Shared starter tree for the first hostile consumers: try to attack an
// adjacent target, otherwise acquire and walk to it, then attack.
/proc/bt_basic_hostile_tree()
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

/// Finds a living target in view and stores it in the blackboard.
/datum/bt_node/ai_behavior/acquire_target
	var/target_key = BB_TARGET
	/// How far to look for a target, in tiles.
	var/search_range = 7

/datum/bt_node/ai_behavior/acquire_target/perform(seconds_per_tick, datum/ai_controller/controller)

	var/mob/living/pawn = controller.pawn
	if(!pawn || QDELETED(pawn))
		return AI_BEHAVIOR_FAILED

	var/atom/existing = controller.blackboard[target_key]
	if(existing && !QDELETED(existing))
		return AI_BEHAVIOR_SUCCEEDED

	for(var/mob/living/candidate in oview(search_range, pawn))
		if(candidate == pawn || candidate.stat == DEAD)
			continue
		if(istype(pawn, /mob/living/simple_animal))
			var/mob/living/simple_animal/animal = pawn
			if(!animal.CanAttack(candidate))
				continue
		controller.blackboard[target_key] = candidate
		return AI_BEHAVIOR_SUCCEEDED

	controller.blackboard.Remove(target_key)
	return AI_BEHAVIOR_FAILED

/// Walks the pawn towards the blackboard target using the controller's movement adapter.
/datum/bt_node/ai_behavior/move_to_target
	var/target_key = BB_TARGET
	var/max_distance = 30

/datum/bt_node/ai_behavior/move_to_target/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(!target || QDELETED(target) || !controller.pawn || !controller.ai_movement)
		return FALSE
	return controller.ai_movement.start_moving_towards(controller, target, max_distance)

/datum/bt_node/ai_behavior/move_to_target/perform(seconds_per_tick, datum/ai_controller/controller)

	var/atom/target = controller.blackboard[target_key]
	var/mob/living/pawn = controller.pawn
	if(!target || QDELETED(target) || !pawn || QDELETED(pawn))
		return AI_BEHAVIOR_FAILED

	if(get_dist(pawn, target) <= 1)
		if(controller.ai_movement)
			controller.ai_movement.stop_moving_towards(controller)
		return AI_BEHAVIOR_SUCCEEDED

	if(!controller.ai_movement || !controller.ai_movement.process(controller))
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
