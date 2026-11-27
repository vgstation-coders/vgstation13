// Minimal behavior tree controller for the WIP behavior tree port.
//
// This file intentionally contains only the tree/blackboard machinery needed to
// run the ported nodes. The full tgstation ai_controller (subsystems, movement,
// pathfinding, AI status, sentience/signal handling, basic mobs and the JSON
// compiler) is the next phase; see code/datums/ai/README.md.
//
// Ported from tgstation/tgstation (code/datums/ai/_ai_controller.dm).

/datum/ai_controller
	/// The atom this controller is controlling. May be null in isolated tree tests.
	var/atom/pawn = null
	/// Associative list of data the AI knows and behaviors consume.
	var/alist/blackboard = alist()
	/// Roots of the behavior trees this controller runs.
	var/list/behavior_nodes = null
	/// Runtime override slots (assoc override_id -> /datum/bt_node/subtree).
	var/list/override_slots = null
	/// Decorators that will poll their condition in the observer phase.
	var/list/polling_observers = null
	/// Set by cancel_current_plan() mid-tick so composites abort the current tick loop.
	var/cancelled_during_tick = FALSE
	/// Execution index of the last leaf that returned BT_RUNNING.
	var/active_execution_index = 0
	/// Execution index of the leaf whose tick() is currently running.
	var/ticking_execution_index = 0

/datum/ai_controller/New(atom/new_pawn)
	if(!isnull(new_pawn))
		pawn = new_pawn
	return ..()

/datum/ai_controller/Destroy()
	// behavior_nodes may still contain typepaths or descriptors if initialization
	// never ran; only qdel resolved datum instances.
	for(var/datum/entry in behavior_nodes)
		qdel(entry)
	behavior_nodes = null
	override_slots = null
	polling_observers = null
	blackboard = null
	return ..()

/// Builds the behavior tree roots from behavior_nodes (typepaths or descriptors).
/datum/ai_controller/proc/initialize_behavior_tree()
	if(!behavior_nodes || !length(behavior_nodes))
		return

	var/list/temp_subtree_list = list()
	if(!isnull(behavior_nodes[BT_DESC_TYPE]))
		var/datum/bt_node/node_instance = get_or_build_node(behavior_nodes)
		if(isnull(node_instance))
			stack_trace("[type]'s behavior_nodes BT descriptor could not be built")
		else
			temp_subtree_list += node_instance
	else
		for(var/entry in behavior_nodes)
			var/datum/bt_node/node_instance = get_or_build_node(entry)
			if(isnull(node_instance))
				stack_trace("[type]'s behavior_nodes contains unknown entry: [entry]")
				continue
			temp_subtree_list += node_instance
	behavior_nodes = temp_subtree_list
	finalize_tree()

/// Walks the resolved tree to set owning_controller and parent_node on all nodes,
/// populates override_slots, and assigns pre-order execution indices.
/datum/ai_controller/proc/finalize_tree()
	if(!behavior_nodes || !length(behavior_nodes))
		return
	override_slots = null
	var/list/to_visit = behavior_nodes.Copy()
	for(var/datum/bt_node/root in behavior_nodes)
		root.parent_node = null
	var/index = 1
	while(index <= length(to_visit))
		var/datum/bt_node/node = to_visit[index++]
		node.finalize_node(src, to_visit)
	var/counter = 1
	for(var/datum/bt_node/root in behavior_nodes)
		counter = root.assign_execution_indices(counter)

/// Ticks the roots until one is still running.
/datum/ai_controller/proc/SelectBehaviors(seconds_per_tick)
	SHOULD_NOT_SLEEP(TRUE)
	cancelled_during_tick = FALSE
	if(!behavior_nodes)
		return
	for(var/datum/bt_node/node in behavior_nodes)
		if(node.tick(src, seconds_per_tick) == BT_RUNNING)
			break

/// Cancels the current plan and resets every running leaf in the tree.
/datum/ai_controller/proc/cancel_current_plan()
	active_execution_index = 0
	cancelled_during_tick = TRUE
	reset_bt_tick_states()

/// Resets tick state across every root subtree.
/datum/ai_controller/proc/reset_bt_tick_states()
	if(!behavior_nodes)
		return
	for(var/datum/bt_node/root in behavior_nodes)
		root.reset_subtree_tick_states()

/// Resolves the children/child of a composite, decorator or subtree node.
/datum/ai_controller/proc/resolve_node_children(datum/bt_node/node)
	if(istype(node, /datum/bt_node/composite))
		var/datum/bt_node/composite/comp = node
		if(!comp.children_typepaths || !length(comp.children_typepaths) || (comp.children && length(comp.children)))
			return
		var/list/resolved_children = list()
		for(var/child_type in comp.children_typepaths)
			var/list/config = comp.children_typepaths[child_type]
			var/datum/bt_node/child = resolve_child_node(child_type, config)
			if(isnull(child))
				stack_trace("BT composite [node.type] references unknown child type [child_type]")
				continue
			resolved_children += child
		comp.children = resolved_children
	else if(istype(node, /datum/bt_node/decorator))
		var/datum/bt_node/decorator/dec = node
		if(isnull(dec.child_typepath) || !isnull(dec.child))
			return
		dec.child = resolve_child_node(dec.child_typepath, null)
		if(isnull(dec.child))
			stack_trace("BT decorator [node.type] references unknown child type [dec.child_typepath]")
	else if(istype(node, /datum/bt_node/subtree))
		var/datum/bt_node/subtree/sub = node
		if(!isnull(sub.behavior_nodes) && isnull(sub.root))
			sub.root = build_node_from_descriptor(sub.behavior_nodes)
		else if(!isnull(sub.behavior_tree_json) && isnull(sub.root))
			var/list/raw_desc = json_decode(file2text(file(BT_COMPILED_PATH(sub.behavior_tree_json))))
			if(raw_desc)
				sub.root = build_node_from_descriptor(raw_desc)

/// Always creates a fresh instance regardless of whether config is provided.
/datum/ai_controller/proc/resolve_child_node(child_type, list/config)
	if(!ispath(child_type, /datum/bt_node))
		return null
	var/datum/bt_node/child = new child_type
	if(config)
		child.configure(config)
	resolve_node_children(child)
	return child

/// Builds a node from a typepath or a descriptor list.
/datum/ai_controller/proc/get_or_build_node(entry)
	if(ispath(entry))
		if(!ispath(entry, /datum/bt_node))
			stack_trace("get_or_build_node() received non-BT typepath: [entry]")
			return null
		var/datum/bt_node/node = new entry
		resolve_node_children(node)
		return node
	if(islist(entry))
		return build_node_from_descriptor(entry)
	stack_trace("get_or_build_node() received unexpected entry type: [entry]")
	return null

/// Builds a node and its children from a descriptor list.
/datum/ai_controller/proc/build_node_from_descriptor(list/desc)
	var/node_type = desc[BT_DESC_TYPE]
	if(!ispath(node_type, /datum/bt_node))
		stack_trace("BT descriptor has invalid node type: [node_type]")
		return null

	var/datum/bt_node/node = new node_type
	var/list/config = desc.Copy()
	config -= BT_DESC_TYPE
	config -= BT_DESC_CHILDREN
	config -= BT_DESC_OVERRIDE_ID
	node.configure(config)

	if(istype(node, /datum/bt_node/subtree) && !isnull(desc[BT_DESC_OVERRIDE_ID]))
		var/datum/bt_node/subtree/sub = node
		sub.override_id = desc[BT_DESC_OVERRIDE_ID]

	if(!isnull(desc[BT_DESC_CHILDREN]))
		node.set_descriptor_children(desc[BT_DESC_CHILDREN], src)

	resolve_node_children(node)
	return node

/// Loads and decodes a compiled behavior tree JSON file into a node tree.
/datum/ai_controller/proc/load_tree_from_json(path)
	var/list/desc = json_decode(file2text(file(path)))
	if(!desc)
		return null
	return build_node_from_descriptor(desc)

/// Returns TRUE if we have a blackboard key and it is not qdeleting.
/datum/ai_controller/proc/blackboard_key_exists(key)
	var/datum/key_value = blackboard[key]
	if(isdatum(key_value))
		return !QDELETED(key_value)
	if(islist(key_value))
		return length(key_value) > 0
	return !!key_value

/datum/ai_controller/proc/set_blackboard_key(key, value)
	blackboard[key] = value

/datum/ai_controller/proc/clear_blackboard_key(key)
	blackboard.Remove(key)
