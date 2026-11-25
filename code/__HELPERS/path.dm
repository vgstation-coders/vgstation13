/**
 * This file contains the stuff you need for using JPS (Jump Point Search) pathing, an alternative to A* that skips
 * over large numbers of uninteresting tiles resulting in much quicker pathfinding solutions. Mind that diagonals
 * cost the same as cardinal moves currently, so paths may look a bit strange, but should still be optimal.
 */

/// Diagnostic: nodes expanded by the most recent search().
var/global/jps_last_nodes = 0
/// Diagnostic: count of chase re-plans.
var/global/jps_chase_searches = 0

/**
 * This is the proc you use whenever you want to have pathfinding more complex than "try stepping towards the thing".
 * If no path was found, returns an empty list, which is important for bots like medibots who expect an empty list rather than nothing.
 *
 * Arguments:
 * * path_caller: The movable atom that's trying to find the path
 * * end: What we're trying to path to. It doesn't matter if this is a turf or some other atom, we're gonna just path to the turf it's on anyway
 * * max_distance: Max steps to search (default: 30). Must be > 0; 0 is a zero budget, not infinite.
 * * mintargetdistance: Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example.
 * * id: An ID card representing what access we have and what doors we can open. Its location relative to the pathing atom is irrelevant
 * * simulated_only: Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
 * * exclude: If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * * skip_first: Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break movement for some creatures.
 */
/proc/get_path_to(path_caller, end, max_distance = 30, mintargetdist, id=null, simulated_only = TRUE, turf/exclude, skip_first=TRUE, diagonally = FALSE, best_effort = FALSE, cardinalize = FALSE, smash_flags = 0)
	if(!path_caller || !get_turf(end))
		return

	var/l = SSpathfinder.mobs.getfree(path_caller)
	while(!l)
		stoplag(3)
		l = SSpathfinder.mobs.getfree(path_caller)

	var/list/path
	var/datum/pathfind/pathfind_datum = new(path_caller, end, id, max_distance, mintargetdist, simulated_only, exclude, diagonally, best_effort, cardinalize, smash_flags)
	path = pathfind_datum.search()
	qdel(pathfind_datum)

	SSpathfinder.mobs.found(l)
	if(!path)
		path = list()
	if(length(path) > 0 && skip_first)
		path.Cut(1,2)
	return path

/// Path for cardinal movers: fast diagonal search, rebuilt into a cardinal path. Contract as get_path_to().
/proc/get_walkable_path_to(path_caller, end, max_distance = 30, mintargetdist, id=null, simulated_only = TRUE, turf/exclude, skip_first=TRUE, best_effort = FALSE)
	return get_path_to(path_caller, end, max_distance, mintargetdist, id, simulated_only, exclude, skip_first, diagonally = FALSE, best_effort = best_effort, cardinalize = TRUE)

/// Searches and reports whether a route exists. Prefer this to testing get_path_to(): an empty list is truthy.
/proc/check_path_to(atom/movable/mover, atom/target, range = 1, id = null)
	if(!mover || !target || range <= 0)
		return FALSE
	return length(get_path_to(mover, target, max_distance = range, id = id, simulated_only = FALSE, skip_first = FALSE)) > 0

/**
 * A helper macro to see if it's possible to step from the first turf into the second one, minding things like door access and directional windows.
 * Note that this can only be used inside the [datum/pathfind][pathfind datum] since it uses variables from said datum.
 * If you really want to optimize things, optimize this, cuz this gets called a lot.
 */
#define CAN_STEP(cur_turf, next,thing,id) (next && !next.density && !(simulated_only && SSpathfinder.space_type_cache[next.type]) && !cur_turf.LinkBlockedWithAccess(next, thing, id, smash_flags) && (next != avoid))
/// Another helper macro for JPS, for telling when a node has forced neighbors that need expanding
#define STEP_NOT_HERE_BUT_THERE(cur_turf, dirA, dirB,thing,id) ((!CAN_STEP(cur_turf,get_step(cur_turf,dirA),thing,id)) && CAN_STEP(cur_turf,get_step(cur_turf,dirB),thing,id))
/// True if a diagonal step has a walkable orthogonal detour, so it can't cut a wall corner.
#define DIAG_CORNER_OK(cur_turf, next, heading, thing, id) ( \
	(CAN_STEP(cur_turf, get_step(cur_turf, (heading) & (NORTH|SOUTH)), thing, id) && CAN_STEP(get_step(cur_turf, (heading) & (NORTH|SOUTH)), next, thing, id)) \
	|| (CAN_STEP(cur_turf, get_step(cur_turf, (heading) & (EAST|WEST)), thing, id) && CAN_STEP(get_step(cur_turf, (heading) & (EAST|WEST)), next, thing, id)) )
/// The JPS Node datum represents a turf that we find interesting enough to add to the open list and possibly search for new tiles from
/datum/jps_node
	/// The turf associated with this node
	var/turf/tile
	/// The node we just came from
	var/datum/jps_node/previous_node
	/// The A* node weight (f_value = number_of_tiles + heuristic)
	var/f_value
	/// The A* node heuristic (a rough estimate of how far we are from the goal)
	var/heuristic
	/// How many steps it's taken to get here from the start (currently pulling double duty as steps taken & cost to get here, since all moves incl diagonals cost 1 rn)
	var/number_tiles
	/// How many steps it took to get here from the last node
	var/jumps
	/// Nodes store the endgoal so they can process their heuristic without a reference to the pathfind datum
	var/turf/node_goal

/datum/jps_node/New(turf/our_tile, datum/jps_node/incoming_previous_node, jumps_taken, turf/incoming_goal)
	tile = our_tile
	jumps = jumps_taken
	if(incoming_goal) // if we have the goal argument, this must be the first/starting node
		node_goal = incoming_goal
	else if(incoming_previous_node) // if we have the parent, this is from a direct lateral/diagonal scan, we can fill it all out now
		previous_node = incoming_previous_node
		number_tiles = previous_node.number_tiles + jumps
		node_goal = previous_node.node_goal
		heuristic = get_dist(tile, node_goal)
		f_value = number_tiles + heuristic
	// otherwise, no parent node means this is from a subscan lateral scan, so we just need the tile for now until we call [datum/jps/proc/update_parent] on it

/datum/jps_node/Destroy()
	previous_node = null
	return ..()

/datum/jps_node/proc/update_parent(datum/jps_node/new_parent)
	previous_node = new_parent
	node_goal = previous_node.node_goal
	jumps = get_dist(tile, previous_node.tile)
	number_tiles = previous_node.number_tiles + jumps
	heuristic = get_dist(tile, node_goal)
	f_value = number_tiles + heuristic

/// TODO: Macro this to reduce proc overhead
/proc/HeapPathWeightCompare(datum/jps_node/a, datum/jps_node/b)
	return b.f_value - a.f_value

/// The datum used to handle the JPS pathfinding, completely self-contained
/datum/pathfind
	/// The thing that we're actually trying to path for
	var/atom/movable/path_caller
	/// The turf where we started at
	var/turf/start
	/// The turf we're trying to path to (note that this won't track a moving target)
	var/turf/end
	/// The open list/stack we pop nodes out from (TODO: make this a normal list and macro-ize the heap operations to reduce proc overhead)
	var/datum/heap/open
	///An assoc list that serves as the closed list & tracks what turfs came from where. Key is the turf, and the value is what turf it came from
	var/list/sources
	/// The list we compile at the end if successful to pass back
	var/list/path

	// general pathfinding vars/args
	/// An ID card representing what access we have and what doors we can open. Its location relative to the pathing atom is irrelevant
	var/obj/item/weapon/card/id/id
	/// How far away we have to get to the end target before we can call it quits
	var/mintargetdist = 0
	/// I don't know what this does vs , but they limit how far we can search before giving up on a path
	var/max_distance = 30
	/// Space is big and empty, if this is TRUE then we ignore pathing through unsimulated tiles
	var/simulated_only
	/// A specific turf we're avoiding, like if a mulebot is being blocked by someone t-posing in a doorway we're trying to get through
	var/turf/avoid
	/// Are we calculating diagonal stuff?
	var/diagonally = 0
	/// If TRUE, when the exact goal can't be reached we return a path to the closest reachable tile instead of nothing
	var/best_effort = 0
	/// If TRUE, rebuild the result into a pure cardinal path.
	var/cardinalize = 0
	/// Non-zero = environment_smash_flags: barriers this mob could smash count as passable.
	var/smash_flags = 0


/datum/pathfind/New(atom/movable/path_caller, atom/goal, id, max_distance, mintargetdist, simulated_only, avoid, diagonally = 0, best_effort = 0, cardinalize = 0, smash_flags = 0)
	src.path_caller = path_caller
	end = get_turf(goal)
	open = new /datum/heap(/proc/HeapPathWeightCompare)
	sources = new()
	src.id = id
	src.max_distance = max_distance
	src.mintargetdist = mintargetdist
	src.simulated_only = simulated_only
	src.avoid = avoid
	src.cardinalize = cardinalize
	src.smash_flags = smash_flags
	src.diagonally = diagonally || cardinalize
	src.best_effort = best_effort

/**
 * search() is the proc you call to kick off and handle the actual pathfinding, and kills the pathfind datum instance when it's done.
 *
 * If a valid path was found, it's returned as a list. If invalid or cross-z-level params are entered, or if there's no valid path found, we
 * return null, which [/proc/get_path_to] translates to an empty list (notable for simple bots, who need empty lists)
 */
/datum/pathfind/proc/search()
	start = get_turf(path_caller)
	if(!start || !end)
		stack_trace("Invalid A* start or destination")
		return
	if(start.z != end.z || start == end ) //no pathfinding between z levels
		return
	if(!best_effort && max_distance && (max_distance < get_dist(start, end))) //if start turf is farther than max_distance from end turf, no need to do anything
		return

	// Fast path: a clear cardinal staircase skips the search entirely.
	if(cardinalize && !mintargetdist)
		var/list/direct = try_direct_cardinal_path()
		if(direct)
			path = direct
			sources = null
			qdel(open)
			return path

	//initialization
	jps_last_nodes = 0
	var/datum/jps_node/current_processed_node = new (start, -1, 0, end)
	open.insert(current_processed_node)
	sources[start] = start // i'm sure this is fine

	var/datum/jps_node/closest_node
	var/closest_dist = INFINITY

	//then run the main loop
	while(!open.is_empty() && !path)
		if(!path_caller)
			return
		current_processed_node = open.pop() //get the lower f_value turf in the open list
		jps_last_nodes++
		if(max_distance && (current_processed_node.number_tiles > max_distance))//if too many steps, don't process that path
			continue

		if(best_effort)
			var/node_dist = get_dist(current_processed_node.tile, end)
			if(node_dist < closest_dist)
				closest_dist = node_dist
				closest_node = current_processed_node

		var/turf/current_turf = current_processed_node.tile
		for(var/scan_direction in list(EAST, WEST, NORTH, SOUTH))
			lateral_scan_spec(current_turf, scan_direction, current_processed_node)
		if(diagonally)
			for(var/scan_direction in list(NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST))
				diag_scan_spec(current_turf, scan_direction, current_processed_node)

		CHECK_TICK

	if(!path && best_effort && closest_node && closest_node.tile != start)
		unwind_path(closest_node)

	//we're done! reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5 * length(path)))
			path.Swap(i, length(path) - i + 1)
		if(cardinalize)
			cardinalize_path()

	sources = null
	qdel(open)
	return path

/// Expands each diagonal hop into a legal orthogonal go-between. DIAG_CORNER_OK guarantees one exists.
/datum/pathfind/proc/cardinalize_path()
	if(!path || length(path) < 2)
		return
	var/list/cardinal_path = list()
	var/turf/prev_turf = path[1]
	cardinal_path += prev_turf
	for(var/i = 2 to length(path))
		var/turf/step_turf = path[i]
		var/step_dir = get_dir(prev_turf, step_turf)
		if(step_dir & (step_dir - 1)) // diagonal dirs have >1 bit set; insert an orthogonal go-between
			var/turf/detour = get_step(prev_turf, step_dir & (NORTH|SOUTH))
			if(!(CAN_STEP(prev_turf, detour, path_caller, id) && CAN_STEP(detour, step_turf, path_caller, id)))
				detour = get_step(prev_turf, step_dir & (EAST|WEST))
			cardinal_path += detour
		cardinal_path += step_turf
		prev_turf = step_turf
	path = cardinal_path

/**
 * Greedy cardinal staircase from start to end, each step run through the same CAN_STEP checks as the
 * full search. Returns a complete path only if every step is clear, else null to fall back to JPS.
 */
/datum/pathfind/proc/try_direct_cardinal_path()
	var/manhattan = abs(end.x - start.x) + abs(end.y - start.y)
	if(max_distance && (manhattan > max_distance))
		return null
	var/list/direct = list(start)
	var/turf/current_turf = start
	while(current_turf != end)
		var/dx = end.x - current_turf.x
		var/dy = end.y - current_turf.y
		var/step_dir
		if(abs(dx) >= abs(dy) && dx != 0) // close the larger gap first
			step_dir = (dx > 0) ? EAST : WEST
		else
			step_dir = (dy > 0) ? NORTH : SOUTH
		var/turf/next_turf = get_step(current_turf, step_dir)
		if(!CAN_STEP(current_turf, next_turf, path_caller, id))
			return null
		direct += next_turf
		current_turf = next_turf
	return direct

/// Called when we've hit the goal with the node that represents the last tile, then sets the path var to that path so it can be returned by [datum/pathfind/proc/search]
/datum/pathfind/proc/unwind_path(datum/jps_node/unwind_node)
	path = new()
	var/turf/iter_turf = unwind_node.tile
	path.Add(iter_turf)

	while(unwind_node.previous_node)
		var/dir_goal = get_dir(iter_turf, unwind_node.previous_node.tile)
		for(var/i = 1 to unwind_node.jumps)
			iter_turf = get_step(iter_turf,dir_goal)
			path.Add(iter_turf)
		unwind_node = unwind_node.previous_node

/**
 * For performing lateral scans from a given starting turf.
 *
 * These scans are called from both the main search loop, as well as subscans for diagonal scans, and they treat finding interesting turfs slightly differently.
 * If we're doing a normal lateral scan, we already have a parent node supplied, so we just create the new node and immediately insert it into the heap, ezpz.
 * If we're part of a subscan, we still need for the diagonal scan to generate a parent node, so we return a node datum with just the turf and let the diag scan
 * proc handle transferring the values and inserting them into the heap.
 *
 * Arguments:
 * * original_turf: What turf did we start this scan at?
 * * heading: What direction are we going in? Obviously, should be cardinal
 * * parent_node: Only given for normal lateral scans, if we don't have one, we're a diagonal subscan.
*/
/datum/pathfind/proc/lateral_scan_spec(turf/original_turf, heading, datum/jps_node/parent_node)
	var/steps_taken = 0

	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf

	while(TRUE)
		if(path)
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!CAN_STEP(lag_turf,current_turf,path_caller,id))
			return

		if(current_turf == end || (mintargetdist && (get_dist(current_turf, end) <= mintargetdist)))
			var/datum/jps_node/final_node = new(current_turf, parent_node, steps_taken)
			sources[current_turf] = original_turf
			if(parent_node) // if this is a direct lateral scan we can wrap up, if it's a subscan from a diag, we need to let the diag make their node first, then finish
				unwind_path(final_node)
			return final_node
		else if(sources[current_turf]) // already visited, essentially in the closed list
			return
		else
			sources[current_turf] = original_turf

		if(parent_node && parent_node.number_tiles + steps_taken > max_distance)
			return

		var/interesting = FALSE // have we found a forced neighbor that would make us add this turf to the open list?
		switch(heading)
			if(NORTH)
				if(diagonally)
					if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, NORTHWEST, path_caller, id) || STEP_NOT_HERE_BUT_THERE(current_turf, EAST, NORTHEAST, path_caller, id))
						interesting = TRUE
				else
					if(CAN_STEP(current_turf, get_step(current_turf, EAST), path_caller, id) || CAN_STEP(current_turf, get_step(current_turf, WEST), path_caller, id))
						interesting = TRUE
			if(SOUTH)
				if(diagonally)
					if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, SOUTHWEST, path_caller, id) || STEP_NOT_HERE_BUT_THERE(current_turf, EAST, SOUTHEAST, path_caller, id))
						interesting = TRUE
				else
					if(CAN_STEP(current_turf, get_step(current_turf, EAST), path_caller, id) || CAN_STEP(current_turf, get_step(current_turf, WEST), path_caller, id))
						interesting = TRUE
			if(EAST)
				if(diagonally)
					if(STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHEAST, path_caller, id) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHEAST, path_caller, id))
						interesting = TRUE
				else
					if(CAN_STEP(current_turf, get_step(current_turf, NORTH), path_caller, id) || CAN_STEP(current_turf, get_step(current_turf, SOUTH), path_caller, id))
						interesting = TRUE
			if(WEST)
				if(diagonally)
					if(STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHWEST, path_caller, id) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHWEST, path_caller, id))
						interesting = TRUE
				else
					if(CAN_STEP(current_turf, get_step(current_turf, NORTH), path_caller, id) || CAN_STEP(current_turf, get_step(current_turf, SOUTH), path_caller, id))
						interesting = TRUE
		if(interesting)
			var/datum/jps_node/newnode = new(current_turf, parent_node, steps_taken)
			if(parent_node) // if we're a diagonal subscan, we'll handle adding ourselves to the heap in the diag
				open.insert(newnode)
			return newnode

/**
 * For performing diagonal scans from a given starting turf.
 *
 * Unlike lateral scans, these only are called from the main search loop, so we don't need to worry about returning anything,
 * though we do need to handle the return values of our lateral subscans of course.
 *
 * Arguments:
 * * original_turf: What turf did we start this scan at?
 * * heading: What direction are we going in? Obviously, should be diagonal
 * * parent_node: We should always have a parent node for diagonals
*/
/datum/pathfind/proc/diag_scan_spec(turf/original_turf, heading, datum/jps_node/parent_node)
	var/steps_taken = 0
	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf

	while(TRUE)
		if(path)
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!CAN_STEP(lag_turf,current_turf,path_caller,id))
			return
		// Move() splits diagonals into two cardinal steps, so a corner-cutting hop would just stall.
		if(!DIAG_CORNER_OK(lag_turf, current_turf, heading, path_caller, id))
			return

		if(current_turf == end || (mintargetdist && (get_dist(current_turf, end) <= mintargetdist)))
			var/datum/jps_node/final_node = new(current_turf, parent_node, steps_taken)
			sources[current_turf] = original_turf
			unwind_path(final_node)
			return
		else if(sources[current_turf]) // already visited, essentially in the closed list
			return
		else
			sources[current_turf] = original_turf

		if(parent_node.number_tiles + steps_taken > max_distance)
			return

		var/interesting = FALSE // have we found a forced neighbor that would make us add this turf to the open list?
		var/datum/jps_node/possible_child_node // otherwise, did one of our lateral subscans turn up something?

		switch(heading)
			if(NORTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, EAST, NORTHEAST,path_caller,id) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHWEST,path_caller,id))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, WEST) || lateral_scan_spec(current_turf, NORTH))
			if(NORTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, NORTHWEST,path_caller,id) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHEAST,path_caller,id))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, EAST) || lateral_scan_spec(current_turf, NORTH))
			if(SOUTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, EAST, SOUTHEAST,path_caller,id) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHWEST,path_caller,id))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, SOUTH) || lateral_scan_spec(current_turf, WEST))
			if(SOUTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, SOUTHWEST,path_caller,id) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHEAST,path_caller,id))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, SOUTH) || lateral_scan_spec(current_turf, EAST))

		if(interesting || possible_child_node)
			var/datum/jps_node/newnode = new(current_turf, parent_node, steps_taken)
			open.insert(newnode)
			if(possible_child_node)
				possible_child_node.update_parent(newnode)
				open.insert(possible_child_node)
				if(possible_child_node.tile == end || (mintargetdist && (get_dist(possible_child_node.tile, end) <= mintargetdist)))
					unwind_path(possible_child_node)
			return

/**
 * For seeing if we can actually move between 2 given turfs while accounting for our access and the path_caller's pass_flags
 *
 * Arguments:
 * * path_caller: The movable, if one exists, being used for mobility checks to see what tiles it can reach
 * * ID: An ID card that decides if we can gain access to doors that would otherwise block a turf
 * * smash_flags: If non-zero, blockers this mob could smash are treated as passable.
*/
/turf/proc/LinkBlockedWithAccess(turf/destination_turf, path_caller, ID, smash_flags = 0)
	var/actual_dir = get_dir(src, destination_turf)

	// Border objects block leaving across the edge they face; others don't block exit.
	for(var/obj/iter_object in src)
		if((iter_object.flow_flags & ON_BORDER) && !iter_object.CanPathPass(ID, actual_dir, path_caller))
			if(smash_flags && iter_object.is_smashable_barrier(smash_flags))
				continue
			return TRUE

	var/reverse_dir = get_dir(destination_turf, src)
	for(var/obj/iter_object in destination_turf)
		if(!iter_object.CanPathPass(ID, reverse_dir, path_caller))
			if(smash_flags && iter_object.is_smashable_barrier(smash_flags))
				continue
			return TRUE

	return FALSE

/// Would this mob break through the object if it were in the way? Mirrors DestroySurroundings()'s
/// destructible list, minus walls and airlocks/firedoors.
/obj/proc/is_smashable_barrier(smash_flags)
	return FALSE

/obj/structure/window/is_smashable_barrier(smash_flags)
	return smash_flags & SMASH_LIGHT_STRUCTURES

/obj/structure/grille/is_smashable_barrier(smash_flags)
	return smash_flags & SMASH_LIGHT_STRUCTURES

/obj/structure/table/is_smashable_barrier(smash_flags)
	return smash_flags & SMASH_LIGHT_STRUCTURES

/obj/structure/rack/is_smashable_barrier(smash_flags)
	return smash_flags & SMASH_LIGHT_STRUCTURES

/obj/structure/railing/is_smashable_barrier(smash_flags)
	return smash_flags & SMASH_LIGHT_STRUCTURES

/obj/structure/girder/is_smashable_barrier(smash_flags)
	return smash_flags & SMASH_WALLS

/obj/structure/emergency_shield/is_smashable_barrier(smash_flags)
	return smash_flags & SMASH_LIGHT_STRUCTURES

/obj/machinery/shieldwall/is_smashable_barrier(smash_flags)
	return smash_flags & SMASH_LIGHT_STRUCTURES

/obj/machinery/door/window/is_smashable_barrier(smash_flags)
	return smash_flags & SMASH_LIGHT_STRUCTURES

/obj/machinery/door/table/is_smashable_barrier(smash_flags)
	return smash_flags & SMASH_LIGHT_STRUCTURES

/obj/structure/closet/is_smashable_barrier(smash_flags)
	return smash_flags & SMASH_CONTAINERS

#undef CAN_STEP
#undef STEP_NOT_HERE_BUT_THERE
#undef DIAG_CORNER_OK
