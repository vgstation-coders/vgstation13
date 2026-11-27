// Behavior tree composites (sequence, selector, subplan, parallel).
// Ported from tgstation/tgstation (code/datums/ai/_ai_bt_composites.dm).

/// Base composite node. Holds an ordered list of child bt_node instances.
/datum/bt_node/composite
	/// Typepaths of child nodes declared on the type. Resolved to instances at tree construction.
	var/list/children_typepaths = null
	/// Resolved child instances. Populated at tree construction. Do not set directly.
	var/list/children = null

/datum/bt_node/composite/Destroy()
	QDEL_LIST(children)
	return ..()

/datum/bt_node/composite/get_children()
	return children

/datum/bt_node/composite/finalize_node(datum/ai_controller/controller, list/to_visit)
	..()
	if(!children)
		return
	to_visit += children

/datum/bt_node/composite/set_descriptor_children(list/children_descs, datum/ai_controller/controller)
	var/list/resolved = list()
	for(var/child_entry in children_descs)
		var/datum/bt_node/child_node = controller.get_or_build_node(child_entry)
		if(!isnull(child_node))
			resolved += child_node
	children = resolved

/datum/bt_node/composite/collect_reset_children(list/to_visit)
	if(children)
		to_visit += children

/datum/bt_node/composite/assign_execution_indices(counter)
	execution_index = counter
	counter++
	for(var/datum/bt_node/child in children)
		counter = child.assign_execution_indices(counter)
	last_execution_index = counter - 1
	return counter

/**
 * Sequence node: ticks children in order.
 * Returns BT_FAILURE on the first child failure.
 * Returns BT_RUNNING on the first child returning BT_RUNNING (stops further evaluation).
 * Returns BT_SUCCESS only if all children succeed.
 *
 * Resumes from the last RUNNING child index rather than restarting from child 1.
 */
/datum/bt_node/composite/sequence
	/// Index of the child that last returned BT_RUNNING.
	var/running_child_index = 0

/datum/bt_node/composite/sequence/tick(datum/ai_controller/controller, seconds_per_tick)
	var/result = BT_SUCCESS
	var/start = running_child_index || 1
	for(var/i in start to length(children))
		var/datum/bt_node/child = children[i]
		var/child_result = child.tick(controller, seconds_per_tick)
		if(controller.cancelled_during_tick)
			return BT_FAILURE
		if(child_result != BT_SUCCESS)
			result = child_result
			if(child_result == BT_RUNNING)
				running_child_index = i
			else
				running_child_index = 0
			return result

	running_child_index = 0
	return result

/datum/bt_node/composite/sequence/reset_tick_state()
	. = ..()
	running_child_index = 0

/**
 * Selector node: ticks children in order.
 * Returns the first non-BT_FAILURE result (BT_SUCCESS or BT_RUNNING), stopping further evaluation.
 * Returns BT_FAILURE only if all children fail.
 *
 * Resumes from the last RUNNING child index rather than restarting from child 1.
 */
/datum/bt_node/composite/selector
	/// Index of the child that last returned BT_RUNNING.
	var/running_child_index = 0

/datum/bt_node/composite/selector/tick(datum/ai_controller/controller, seconds_per_tick)
	var/result = BT_FAILURE
	var/start = running_child_index || 1
	for(var/i in start to length(children))
		var/datum/bt_node/child = children[i]
		var/child_result = child.tick(controller, seconds_per_tick)
		if(controller.cancelled_during_tick)
			return BT_FAILURE
		if(child_result != BT_FAILURE)
			result = child_result
			if(child_result == BT_RUNNING)
				running_child_index = i
			else
				running_child_index = 0
			return result

	running_child_index = 0
	return result

/datum/bt_node/composite/selector/reset_tick_state()
	. = ..()
	running_child_index = 0

/**
 * Subplan node: runs a child and applies configurable restart policies when it completes
 * instead of propagating completion directly.
 */
/datum/bt_node/composite/subplan
	/// BT_SUBPLAN_SUCCEED_ON_SUCCESS: propagate success (default). BT_SUBPLAN_LOOP_ON_SUCCESS: restart.
	var/success_policy = BT_SUBPLAN_SUCCEED_ON_SUCCESS
	/// BT_SUBPLAN_FAIL_ON_FAILURE: propagate failure (default). BT_SUBPLAN_LOOP_ON_FAILURE: restart.
	var/failure_policy = BT_SUBPLAN_FAIL_ON_FAILURE
	/// Minimum delay before ticking again after a loop policy restarts the child. 0 = immediate.
	var/loop_delay = 0
	/// world.time when this subplan is next allowed to tick after a loop restart.
	var/next_loop_time = 0

/datum/bt_node/composite/subplan/tick(datum/ai_controller/controller, seconds_per_tick)
	if(loop_delay > 0 && next_loop_time > world.time)
		return BT_RUNNING

	var/datum/bt_node/child = children && children[1]
	if(isnull(child))
		next_loop_time = 0
		return BT_FAILURE

	var/child_result = child.tick(controller, seconds_per_tick)
	if(controller.cancelled_during_tick)
		return BT_FAILURE

	if(child_result == BT_RUNNING)
		return BT_RUNNING

	if(child_result == BT_FAILURE)
		if(failure_policy == BT_SUBPLAN_LOOP_ON_FAILURE)
			child.reset_tick_state()
			if(loop_delay > 0)
				next_loop_time = world.time + loop_delay
			return BT_RUNNING
		next_loop_time = 0
		return BT_FAILURE

	if(success_policy == BT_SUBPLAN_LOOP_ON_SUCCESS)
		child.reset_tick_state()
		if(loop_delay > 0)
			next_loop_time = world.time + loop_delay
		return BT_RUNNING
	next_loop_time = 0
	return BT_SUCCESS

/datum/bt_node/composite/subplan/reset_tick_state()
	. = ..()
	next_loop_time = 0

/datum/bt_node/composite/subplan/set_descriptor_children(list/children_descs, datum/ai_controller/controller)
	..()
	if(length(children) > 1)
		var/datum/bt_node/composite/sequence/legacy_subplan_sequence = new
		legacy_subplan_sequence.children = children
		children = list(legacy_subplan_sequence)

/**
 * Parallel node: ticks ALL children every planning cycle, regardless of intermediate results.
 * Success and failure are determined by the configurable success_policy and failure_policy.
 */
/datum/bt_node/composite/parallel
	/// BT_PARALLEL_SUCCESS_CHILD_ONE: succeed when child 1 succeeds (default).
	/// BT_PARALLEL_SUCCESS_ALL: succeed only when all children succeed.
	var/success_policy = BT_PARALLEL_SUCCESS_CHILD_ONE
	/// BT_PARALLEL_FAILURE_CHILD_ONE: fail when child 1 fails (default).
	/// BT_PARALLEL_FAILURE_ANY: fail when any child fails.
	var/failure_policy = BT_PARALLEL_FAILURE_CHILD_ONE
	/// If TRUE, children 2+ that complete are reset and reticked.
	var/repeat_secondary = FALSE
	/// Minimum delay before a repeat_secondary child can be re-ticked after completing.
	var/repeat_secondary_delay = 0
	/// world.time values for when each secondary child is next allowed to tick.
	var/list/secondary_ready_at = null
	/// If TRUE, when child 1 finishes (non-RUNNING), all children 2+ are cancelled and the parallel returns child 1's result.
	var/finish_on_primary = FALSE

/datum/bt_node/composite/parallel/tick(datum/ai_controller/controller, seconds_per_tick)
	var/succeeded = 0
	var/failed = 0
	var/primary_result

	for(var/i in 1 to length(children))
		var/datum/bt_node/child = children[i]

		if(i > 1 && repeat_secondary && repeat_secondary_delay > 0 && secondary_ready_at && secondary_ready_at[i] > world.time)
			continue

		var/child_result = child.tick(controller, seconds_per_tick)
		if(controller.cancelled_during_tick)
			return BT_FAILURE

		if(i == 1)
			primary_result = child_result
			if(child_result == BT_SUCCESS)
				succeeded++
			else if(child_result == BT_FAILURE)
				failed++
		else if(repeat_secondary && child_result != BT_RUNNING)
			child.reset_tick_state()
			if(repeat_secondary_delay > 0)
				if(!secondary_ready_at)
					secondary_ready_at = list()
				secondary_ready_at[i] = world.time + repeat_secondary_delay
		else
			if(child_result == BT_SUCCESS)
				succeeded++
			else if(child_result == BT_FAILURE)
				failed++

	if(finish_on_primary && primary_result != BT_RUNNING)
		for(var/i in 2 to length(children))
			var/datum/bt_node/child = children[i]
			child.reset_subtree_tick_states()
		return primary_result

	if((failure_policy == BT_PARALLEL_FAILURE_CHILD_ONE && primary_result == BT_FAILURE) || \
			(failure_policy == BT_PARALLEL_FAILURE_ANY && failed > 0))
		return BT_FAILURE
	if((success_policy == BT_PARALLEL_SUCCESS_CHILD_ONE && primary_result == BT_SUCCESS) || \
			(success_policy == BT_PARALLEL_SUCCESS_ALL && succeeded == length(children)))
		return BT_SUCCESS
	return BT_RUNNING

/datum/bt_node/composite/parallel/reset_tick_state()
	. = ..()
	secondary_ready_at = null
