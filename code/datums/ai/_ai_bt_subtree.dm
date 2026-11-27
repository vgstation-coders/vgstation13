// Behavior tree subtree node: a named, re-usable BT subgraph.
// Ported from tgstation/tgstation (code/datums/ai/_ai_bt_subtree.dm).

/datum/bt_node/subtree
	node_type = BT_NODE_SUBTREE
	/// Repo-relative path to the .bt.json source file. The compiled JSON loader is
	/// part of the controller port; until then build subtrees from behavior_nodes.
	var/behavior_tree_json = null
	/// List of BT node descriptors defining this subtree's root.
	var/list/behavior_nodes = null
	/// The internal root node, populated by the controller's resolve_node_children().
	var/datum/bt_node/root = null
	/// Runtime override slot id, used by pet commands and similar systems.
	var/override_id = null
	/// Active override subtree. When set, tick() delegates to this node instead of root.
	var/datum/bt_node/subtree/override_node = null

/datum/bt_node/subtree/Destroy()
	if(!isnull(override_id) && owning_controller?.override_slots)
		if(owning_controller.override_slots[override_id] == src)
			owning_controller.override_slots -= override_id
	QDEL_NULL(root)
	QDEL_NULL(override_node)
	return ..()

/datum/bt_node/subtree/tick(datum/ai_controller/controller, seconds_per_tick)
	if(override_node)
		return override_node.tick(controller, seconds_per_tick)
	if(!root)
		return BT_FAILURE
	return root.tick(controller, seconds_per_tick)

/datum/bt_node/subtree/get_children()
	if(override_node)
		return override_node.root ? list(override_node.root) : null
	return root ? list(root) : null

/datum/bt_node/subtree/has_active_descendants()
	if(override_node)
		return override_node.has_active_descendants()
	return root ? root.has_active_descendants() : FALSE

/datum/bt_node/subtree/finalize_node(datum/ai_controller/controller, list/to_visit)
	..()
	if(!isnull(override_id))
		if(!controller.override_slots)
			controller.override_slots = list()
		controller.override_slots[override_id] = src
	if(root)
		root.parent_node = src
		to_visit += root
	if(override_node)
		override_node.parent_node = src
		to_visit += override_node

/datum/bt_node/subtree/collect_reset_children(list/to_visit)
	if(root)
		to_visit += root
	if(override_node)
		to_visit += override_node

/datum/bt_node/subtree/assign_execution_indices(counter)
	execution_index = counter
	counter++
	if(root)
		counter = root.assign_execution_indices(counter)
	if(override_node)
		counter = override_node.assign_execution_indices(counter)
	last_execution_index = counter - 1
	return counter
