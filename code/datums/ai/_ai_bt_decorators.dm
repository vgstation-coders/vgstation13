// Behavior tree decorators (condition gates around a single child).
// Ported from tgstation/tgstation (code/datums/ai/_ai_bt_decorators.dm).
//
// Condition checks are synchronous: the condition is evaluated when the child is
// not active. Reactive aborts use the polling observer because vg has no DCS
// signals.

/// Base decorator node. Wraps a single child with a condition check.
/datum/bt_node/decorator
	/// Typepath of the single child node. Resolved to an instance at tree construction.
	var/child_typepath = null
	/// Resolved child instance. Populated at tree construction. Do not set directly.
	var/datum/bt_node/child = null
	/// Reserved for the observer abort port: BT_ABORT_NONE / SELF / LOWER_PRIORITY / BOTH.
	var/observer_abort = BT_ABORT_NONE
	/// If TRUE, the result of check_condition() is inverted before gating the child.
	var/invert = FALSE
	/// Whether the child is currently BT_RUNNING. Makes tick() skip check_condition() and delegate to child.tick().
	var/child_active = FALSE
	/// TRUE while tick() is running our child.
	var/ticking_child = FALSE
	/// Last result seen by poll_condition(). null = not yet polled.
	var/last_poll_result = null
	/// world.time of the last poll_condition() evaluation.
	var/last_poll_time = 0
	/// Minimum deciseconds between condition polls when using polling observers. 0 = every controller tick.
	var/polling_rate = 0

/datum/bt_node/decorator/Destroy()
	if(owning_controller?.polling_observers)
		owning_controller.polling_observers -= src
	QDEL_NULL(child)
	return ..()

/datum/bt_node/decorator/get_children()
	return child ? list(child) : null

/datum/bt_node/decorator/finalize_node(datum/ai_controller/controller, list/to_visit)
	..()
	if(observer_abort != BT_ABORT_NONE)
		if(!controller.polling_observers)
			controller.polling_observers = list()
		controller.polling_observers |= src
	if(child)
		to_visit += child

/datum/bt_node/decorator/set_descriptor_children(list/children_descs, datum/ai_controller/controller)
	if(!children_descs || !length(children_descs))
		return
	var/datum/bt_node/resolved = controller.get_or_build_node(children_descs[1])
	if(!isnull(resolved))
		child = resolved

/datum/bt_node/decorator/collect_reset_children(list/to_visit)
	if(child)
		to_visit += child

/datum/bt_node/decorator/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!child)
		return BT_FAILURE

	var/child_ticked = FALSE
	var/result

	if(child_active)
		ticking_child = TRUE
		result = child.tick(controller, seconds_per_tick)
		ticking_child = FALSE
		child_ticked = TRUE
	else if(!!check_condition(controller) == invert)
		return BT_FAILURE
	else
		ticking_child = TRUE
		result = child.tick(controller, seconds_per_tick)
		ticking_child = FALSE
		child_ticked = TRUE

	if(controller.cancelled_during_tick)
		child_active = FALSE
		return BT_FAILURE

	child_active = (result == BT_RUNNING)
	if(child_ticked && !child_active)
		on_child_complete(controller, result)

	return result

/// Called when the child finishes (returns a non-RUNNING result after being ticked).
/datum/bt_node/decorator/proc/on_child_complete(datum/ai_controller/controller, result)
	return

/// Override to implement custom condition logic.
/datum/bt_node/decorator/proc/check_condition(datum/ai_controller/controller)
	return TRUE

/// Returns the condition result as the observer system sees it.
/datum/bt_node/decorator/proc/evaluate_for_observer(datum/ai_controller/controller)
	return !!check_condition(controller) != invert

/// Polls the condition when this decorator has an observer_abort and vg has no
/// signal equivalent. Called by SelectBehaviors before ticking the tree.
/datum/bt_node/decorator/proc/poll_condition(datum/ai_controller/controller)
	if(polling_rate && last_poll_time + polling_rate > world.time)
		return
	last_poll_time = world.time
	var/current = evaluate_for_observer(controller)
	if(isnull(last_poll_result))
		last_poll_result = current
		return
	if(current != last_poll_result)
		last_poll_result = current
		on_observed_change(controller)

/// Applies the observer abort policy after the watched condition changes.
/datum/bt_node/decorator/proc/on_observed_change(datum/ai_controller/controller)
	var/condition_result = evaluate_for_observer(controller)

	if(!condition_result && (observer_abort & BT_ABORT_SELF))
		if(child_active || ticking_child)
			controller.cancel_current_plan()

	if(condition_result && (observer_abort & BT_ABORT_LOWER_PRIORITY))
		var/active = controller.ticking_execution_index || controller.active_execution_index
		if(execution_index && active && active > last_execution_index)
			controller.cancel_current_plan()

/datum/bt_node/decorator/reset_tick_state()
	last_poll_result = null
	last_poll_time = 0
	child_active = FALSE
	ticking_child = FALSE
	..()

/datum/bt_node/decorator/assign_execution_indices(counter)
	execution_index = counter
	counter++
	if(child)
		counter = child.assign_execution_indices(counter)
	last_execution_index = counter - 1
	return counter

/// Returns TRUE if the blackboard key holds a non-null, non-deleted value.
/datum/bt_node/decorator/proc/bb_key_exists(datum/ai_controller/controller, key)
	return controller.blackboard_key_exists(key)

/// Returns TRUE if the blackboard value at key equals the given value.
/datum/bt_node/decorator/proc/bb_key_equals(datum/ai_controller/controller, key, value)
	return controller.blackboard[key] == value

/// Returns TRUE if the blackboard value at key is strictly greater than threshold.
/datum/bt_node/decorator/proc/bb_key_greater(datum/ai_controller/controller, key, threshold)
	return controller.blackboard[key] > threshold

/// Gate on a blackboard key existing and being non-null.
/datum/bt_node/decorator/bb_key_exists
	var/key = null

/datum/bt_node/decorator/bb_key_exists/check_condition(datum/ai_controller/controller)
	return bb_key_exists(controller, key)

/// Gate on a blackboard key equalling a value.
/datum/bt_node/decorator/bb_key_equals
	var/key = null
	var/value = null

/datum/bt_node/decorator/bb_key_equals/check_condition(datum/ai_controller/controller)
	return bb_key_equals(controller, key, value)

/// Gate on a blackboard key being greater than a threshold.
/datum/bt_node/decorator/bb_key_greater
	var/key = null
	var/threshold = 0

/datum/bt_node/decorator/bb_key_greater/check_condition(datum/ai_controller/controller)
	return bb_key_greater(controller, key, threshold)

/// Gate on the pawn's health being below a fraction of its maximum.
/// Use observer_abort = BT_ABORT_SELF so a running respond-to-damage branch ends
/// when the pawn heals back above the threshold.
/datum/bt_node/decorator/pawn_health_below
	/// Fraction of max health below which the condition is true (0 to 1).
	var/threshold = 0.3

/datum/bt_node/decorator/pawn_health_below/check_condition(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	if(!pawn || QDELETED(pawn) || pawn.maxHealth <= 0)
		return FALSE
	return (pawn.health / pawn.maxHealth) < threshold

/// Gate on a named override slot currently having an active override installed.
/// Polling observers can react to controller.override_slots changes.
/datum/bt_node/decorator/override_id_set
	var/override_id = null

/datum/bt_node/decorator/override_id_set/check_condition(datum/ai_controller/controller)
	if(isnull(override_id) || !controller.override_slots)
		return FALSE
	var/datum/bt_node/subtree/sub = controller.override_slots[override_id]
	return !isnull(sub?.override_node)
