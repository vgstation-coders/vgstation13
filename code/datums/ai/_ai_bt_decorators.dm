// Behavior tree decorators (condition gates around a single child).
// Ported from tgstation/tgstation (code/datums/ai/_ai_bt_decorators.dm).
//
// Phase 1 keeps the condition check synchronous: the condition is evaluated when
// the child is not active. Reactive observer aborts (signals/polling) are left for
// the controller phase, where vg's event system will replace TG's DCS signals.

/// Base decorator node. Wraps a single child with a condition check.
/datum/bt_node/decorator
	node_type = BT_NODE_DECORATOR
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

/datum/bt_node/decorator/Destroy()
	QDEL_NULL(child)
	return ..()

/datum/bt_node/decorator/get_children()
	return child ? list(child) : null

/datum/bt_node/decorator/has_active_descendants()
	return child ? child.has_active_descendants() : FALSE

/datum/bt_node/decorator/finalize_node(datum/ai_controller/controller, list/to_visit)
	..()
	if(child)
		child.parent_node = src
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

/datum/bt_node/decorator/reset_tick_state()
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
