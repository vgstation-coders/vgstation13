// Base node for the behavior tree system.
// Ported from tgstation/tgstation (code/datums/ai/_ai_bt_node.dm).

/datum/bt_node
	/// Pre-order depth-first index of this node in the tree. Assigned by assign_execution_indices().
	var/execution_index = 0
	/// Index of the last descendant node in this subtree. Equal to execution_index for leaves.
	var/last_execution_index = 0
	/// Owning controller for this node.
	var/datum/ai_controller/owning_controller = null

/// Ticked by the ai_controller. Returns BT_SUCCESS, BT_FAILURE, or BT_RUNNING.
/// Leaves may call legacy procs whose rare overrides sleep (Move/Crossed, death,
/// attacks); sleeping actions belong in async_perform(), so this path carries no
/// SHOULD_NOT_SLEEP annotation.
/datum/bt_node/proc/tick(datum/ai_controller/controller, seconds_per_tick)
	return BT_FAILURE

/// Resets per-tick state for this node instance. Override in subtypes that hold tick state.
/datum/bt_node/proc/reset_tick_state()
	return

/// Resets this node and all of its descendants, cancelling any behaviors still running in the subtree.
/datum/bt_node/proc/reset_subtree_tick_states()
	var/list/to_visit = list(src)
	var/index = 1
	while(index <= length(to_visit))
		var/datum/bt_node/node = to_visit[index++]
		node.reset_tick_state()
		node.collect_reset_children(to_visit)

/// Assigns pre-order depth-first execution indices to this node and its subtree.
/datum/bt_node/proc/assign_execution_indices(counter)
	execution_index = counter
	last_execution_index = counter
	return counter + 1

/// Applies a configuration list to this node instance by assigning vars directly.
/datum/bt_node/proc/configure(list/config)
	for(var/var_name in config)
		vars[var_name] = config[var_name]

/// Returns the list of direct child bt_node instances for tree traversal.
/// Returns null for leaf nodes (default). Overridden in composites, decorators and subtrees.
/datum/bt_node/proc/get_children()
	return null

/// Walks descendants to find the node with the given execution_index. Returns null if not found.
/datum/bt_node/proc/find_by_index(target_index)
	if(execution_index == target_index)
		return src
	var/list/ch = get_children()
	if(!ch)
		return null
	for(var/datum/bt_node/child in ch)
		var/found = child.find_by_index(target_index)
		if(found)
			return found
	return null

/// Called during finalize_tree() to set owning_controller, register overrides and enqueue children.
/datum/bt_node/proc/finalize_node(datum/ai_controller/controller, list/to_visit)
	owning_controller = controller

/// Called during build_node_from_descriptor() to resolve and assign child nodes from descriptors.
/datum/bt_node/proc/set_descriptor_children(list/children_descs, datum/ai_controller/controller)
	return

/// Returns a single-character status marker. Overridden by ai_behavior to check running.
/datum/bt_node/proc/get_status_marker()
	return "o"

/// Adds all children that must be visited during reset to to_visit. No-op for leaf nodes.
/datum/bt_node/proc/collect_reset_children(list/to_visit)
	return

/datum/bt_node/Destroy()
	owning_controller = null
	return ..()
