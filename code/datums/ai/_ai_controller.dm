// Behavior tree controller for the WIP behavior tree port.
//
// Owns the blackboard, the resolved tree, target lifecycle, sentience, movement
// and the subsystem status. See code/datums/ai/README.md.
//
// Ported from tgstation/tgstation (code/datums/ai/_ai_controller.dm).

/datum/ai_controller
	/// The mob this controller is controlling. May be null in isolated tree tests.
	var/mob/living/pawn = null
	/// Associative list of data the AI knows and behaviors consume.
	var/alist/blackboard = alist()
	/// Roots of the behavior trees this controller runs.
	var/list/behavior_nodes = null
	/// Runtime override slots (assoc override_id -> /datum/bt_node/subtree).
	var/list/override_slots = null
	/// Decorators that poll their condition because vg has no DCS signals.
	var/list/polling_observers = null
	/// Current AI status; only controllers not in AI_STATUS_OFF are ticked.
	var/ai_status = AI_STATUS_OFF
	/// Movement adapter used by movement behaviors.
	var/datum/ai_movement/ai_movement = null
	/// Set by cancel_current_plan() mid-tick so composites abort the current tick loop.
	var/cancelled_during_tick = FALSE
	/// Execution index of the last leaf that returned BT_RUNNING.
	var/active_execution_index = 0
	/// Execution index of the leaf whose tick() is currently running.
	var/ticking_execution_index = 0
	/// Z bucket this controller is indexed under in its subsystem (null = none).
	var/ai_indexed_z = null

/datum/ai_controller/New(mob/living/new_pawn)
	change_ai_movement_type(/datum/ai_movement/basic)
	if(!isnull(new_pawn))
		PossessPawn(new_pawn)
	return ..()

/datum/ai_controller/Destroy()
	set_ai_status(AI_STATUS_OFF)
	if(pawn && pawn.ai_controller == src)
		pawn.ai_controller = null
	pawn = null
	QDEL_NULL(ai_movement)
	// behavior_nodes may still contain typepaths or descriptors if initialization
	// never ran; only qdel resolved datum instances.
	for(var/datum/entry in behavior_nodes)
		qdel(entry)
	behavior_nodes = null
	override_slots = null
	polling_observers = null
	blackboard = null
	return ..()

/// Attaches this controller to a living mob.
/datum/ai_controller/proc/PossessPawn(mob/living/new_pawn)
	if(!new_pawn)
		return FALSE
	if(pawn)
		UnpossessPawn()
	if(new_pawn.ai_controller)
		QDEL_NULL(new_pawn.ai_controller)
	pawn = new_pawn
	pawn.ai_controller = src
	blackboard[BB_MY_PAWN] = pawn
	pawn.register_event(/event/death, src, nameof(src::on_pawn_death()))
	pawn.register_event(/event/living_login, src, nameof(src::on_pawn_login()))
	pawn.register_event(/event/logout, src, nameof(src::on_pawn_logout()))
	// A pawn that already has a client is player-driven: keep the AI idle until
	// the client leaves.
	set_ai_status(new_pawn.client ? AI_STATUS_OFF : AI_STATUS_ON)
	return TRUE

/// Detaches this controller from its pawn and stops processing it.
/datum/ai_controller/proc/UnpossessPawn()
	set_ai_status(AI_STATUS_OFF)
	if(pawn)
		pawn.unregister_event(/event/death, src, nameof(src::on_pawn_death()))
		pawn.unregister_event(/event/living_login, src, nameof(src::on_pawn_login()))
		pawn.unregister_event(/event/logout, src, nameof(src::on_pawn_logout()))
		if(pawn.ai_controller == src)
			pawn.ai_controller = null
		pawn = null
	blackboard.Remove(BB_MY_PAWN)

/// Stops the AI when the pawn dies.
/datum/ai_controller/proc/on_pawn_death(mob/living/user, body_destroyed)
	set_ai_status(AI_STATUS_OFF)

/// Stops the AI while a client is driving the pawn.
/datum/ai_controller/proc/on_pawn_login(mob/user)
	if(!pawn || QDELETED(pawn))
		return
	set_ai_status(AI_STATUS_OFF)

/// Resumes the AI when the client leaves, unless the pawn is dead.
/datum/ai_controller/proc/on_pawn_logout(mob/user)
	if(!pawn || QDELETED(pawn) || pawn.stat == DEAD)
		return
	set_ai_status(AI_STATUS_ON)

/// Replaces the movement adapter. Takes a movement datum typepath.
/datum/ai_controller/proc/change_ai_movement_type(datum/ai_movement/new_movement)
	if(ai_movement)
		QDEL_NULL(ai_movement)
	ai_movement = new new_movement

/// Returns the subsystem that ticks controllers in this status, if any.
/datum/ai_controller/proc/get_subsystem_for_status(status)
	if(status == AI_STATUS_ON)
		return SSai_controllers
	if(status == AI_STATUS_ON_LOW)
		return SSai_controllers_low
	return null

/// Moves the controller between the AI status lists/subsystems.
/datum/ai_controller/proc/set_ai_status(new_status)
	if(ai_status == new_status)
		return FALSE

	var/datum/subsystem/ai_controllers/old_subsystem = get_subsystem_for_status(ai_status)
	if(old_subsystem)
		old_subsystem.unindex_controller(src)
	else if(ai_status != AI_STATUS_OFF)
		ai_controllers_pending -= src

	var/datum/subsystem/ai_controllers/new_subsystem = get_subsystem_for_status(new_status)
	if(new_subsystem)
		new_subsystem.index_controller(src)
	else if(new_status != AI_STATUS_OFF)
		// The map loads before the subsystems start, so mapped mobs create their
		// controllers first. Wait here until the owner subsystem adopts us.
		ai_controllers_pending += src

	ai_status = new_status
	if(ai_status == AI_STATUS_OFF)
		cancel_current_plan()
	return TRUE


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

/// Walks the resolved tree to set owning_controller on all nodes, populates
/// override_slots, and assigns pre-order execution indices.
/datum/ai_controller/proc/finalize_tree()
	if(!behavior_nodes || !length(behavior_nodes))
		return
	override_slots = null
	polling_observers = null
	var/list/to_visit = behavior_nodes.Copy()
	var/index = 1
	while(index <= length(to_visit))
		var/datum/bt_node/node = to_visit[index++]
		node.finalize_node(src, to_visit)
	var/counter = 1
	for(var/datum/bt_node/root in behavior_nodes)
		counter = root.assign_execution_indices(counter)

/// Ticks the roots until one is still running.
/datum/ai_controller/proc/SelectBehaviors(seconds_per_tick)
	// Leaves call legacy procs whose rare overrides can sleep; the async action
	// path is where sleeping actions belong.
	// Safety net for death overrides that skip ..() and never fire /event/death.
	if(pawn && pawn.stat == DEAD)
		set_ai_status(AI_STATUS_OFF)
		return
	cancelled_during_tick = FALSE
	if(polling_observers)
		for(var/datum/bt_node/decorator/observer in polling_observers.Copy())
			observer.poll_condition(src)
	// An observer abort already cancelled the plan; do not run a half tick.
	if(cancelled_during_tick)
		cancelled_during_tick = FALSE
		return
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
	return build_node_from_descriptor(json_to_descriptor(desc))

/// Recursively converts a decoded JSON descriptor into a runtime descriptor.
/// The compiler writes DM typepaths as strings, so "type" (and any config value
/// that looks like a typepath) is resolved with text2path().
/datum/ai_controller/proc/json_to_descriptor(list/desc)
	if(!islist(desc))
		return desc
	var/list/converted = list()
	for(var/key in desc)
		var/value = desc[key]
		if(key == BT_DESC_TYPE && istext(value))
			converted[key] = text2path(value)
		else if(key == BT_DESC_CHILDREN && islist(value))
			var/list/children = list()
			for(var/child in value)
				// `+=` would flatten the child descriptor list; append it whole.
				children.len++
				children[children.len] = json_to_descriptor(child)
			converted[key] = children
		else if(istext(value) && copytext(value, 1, 2) == "/")
			converted[key] = text2path(value)
		else
			converted[key] = value
	return converted

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

// Attached controllers. Defined here so the AI port does not need to edit living.dm.
/mob/living
	var/datum/ai_controller/ai_controller = null
	/// Pauses the tree's wander leaf without taking the controller offline.
	var/ai_wander_paused = FALSE

// Hooks called by the target acquisition leaf when the controller gains or drops
// a target. Mobs override these for emotes/sounds; the leaves stay generic.
/mob/living/proc/ai_target_acquired(atom/target)
	return

/mob/living/proc/ai_target_lost(atom/target)
	return

/// Called by the hunt leaf when the pawn reaches its prey. Defaults to a normal
/// attack; mobs with a special kill (the cat's splat) override it.
/mob/living/proc/ai_hunt_kill(atom/target)
	if(target)
		UnarmedAttack(target)
	return TRUE

/// Returns the mob this pawn follows (pets and chickens with a master).
/mob/living/proc/ai_get_follow_target()
	return null

/// Runs one unit of idle work (nurse spiders spin webs and lay eggs). Called
/// from the idle_work leaf in a background context, so it may sleep.
/mob/living/proc/ai_idle_work()
	return

/// TRUE when the pawn is hungry enough for the food target source to look for
/// snacks. Defaults to never; pets override it.
/mob/living/proc/ai_wants_food()
	return FALSE

/// Called by fetch_food when the snack is held by a human and the pawn would beg
/// instead of eating it. Mobs override this for their own line/emote.
/mob/living/proc/ai_beg_for_food(atom/target, mob/living/holder)
	return

/// TRUE when this controller currently has a blackboard target. Mobs use it to
/// drive visual state that the legacy AI keyed off `stance` (nazi gun overlays).
/mob/living/proc/ai_has_target()
	return ai_controller && ai_controller.blackboard && ai_controller.blackboard[BB_TARGET]
