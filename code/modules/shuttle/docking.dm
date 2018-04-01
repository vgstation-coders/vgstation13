//this is the main proc. It instantly moves our mobile port to stationary port new_dock
/obj/docking_port/mobile/proc/initiate_docking(obj/docking_port/stationary/new_dock, movement_direction, force=FALSE)
	// Crashing this ship with NO SURVIVORS

	if(new_dock.get_docked() == src)
		remove_ripples()
		return DOCKING_SUCCESS

	if(!force)
		if(!check_dock(new_dock))
			return DOCKING_BLOCKED
		if(!canMove())
			return DOCKING_IMMOBILIZED

	var/obj/docking_port/stationary/old_dock = get_docked()

	// The turf that gets placed under where the shuttle moved from
	var/underlying_turf_type = SHUTTLE_DEFAULT_TURF_TYPE

	// The baseturf that the gets assigned to the turf_type above
	var/underlying_baseturf_type = SHUTTLE_DEFAULT_BASETURF_TYPE

	// The area that gets placed under where the shuttle moved from
	var/underlying_area_type = SHUTTLE_DEFAULT_UNDERLYING_AREA

	// The baseturf cache is a typecache of what counts as a baseturf to be left behind
	var/list/baseturf_cache
	
	if(old_dock) //Dock overwrites
		underlying_turf_type = old_dock.turf_type
		underlying_baseturf_type = old_dock.baseturf_type
		underlying_area_type = old_dock.area_type
		baseturf_cache = old_dock.baseturf_cache
	else
		baseturf_cache = typecacheof(underlying_baseturf_type)

	/**************************************************************************************************************
		Both lists are associative with a turf:bitflag structure. (new_turfs bitflag space unused currently)
		The bitflag contains the data for what inhabitants of that coordinate should be moved to the new location
		The bitflags can be found in __DEFINES/shuttles.dm
	*/
	var/list/old_turfs = return_ordered_turfs(x, y, z, dir)
	var/list/new_turfs = return_ordered_turfs(new_dock.x, new_dock.y, new_dock.z, new_dock.dir)
	CHECK_TICK
	/**************************************************************************************************************/

	// The underlying old area is the area assumed to be under the shuttle's starting location
	// If it no longer/has never existed it will be created
	var/area/underlying_old_area = locate(underlying_area_type) in GLOB.sortedAreas
	if(!underlying_old_area)
		underlying_old_area = new underlying_area_type(null)

	var/rotation = 0
	if(new_dock.dir != dir) //Even when the dirs are the same rotation is coming out as not 0 for some reason
		rotation = dir2angle(new_dock.dir)-dir2angle(dir)
		if ((rotation % 90) != 0)
			rotation += (rotation % 90) //diagonal rotations not allowed, round up
		rotation = SIMPLIFY_DEGREES(rotation)

	if(!movement_direction)
		movement_direction = turn(preferred_direction, 180)

	var/list/moved_atoms = list() //Everything not a turf that gets moved in the shuttle
	var/list/areas_to_move = list() //unique assoc list of areas on turfs being moved

	remove_ripples()

	. = preflight_check(old_turfs, new_turfs, areas_to_move, rotation, underlying_turf_type, baseturf_cache)
	if(.)
		return

	/*******************************************Hiding turfs if necessary*******************************************/
	// TODO: Move this somewhere sane
	var/list/new_hidden_turfs
	if(hidden)
		new_hidden_turfs = list()
		for(var/i in 1 to old_turfs.len)
			CHECK_TICK
			var/turf/oldT = old_turfs[i]
			if(old_turfs[oldT] & MOVE_TURF)
				new_hidden_turfs += new_turfs[i]
		SSshuttle.update_hidden_docking_ports(null, new_hidden_turfs)
	/***************************************************************************************************************/

	if(!force)
		if(!check_dock(new_dock))
			return DOCKING_BLOCKED
		if(!canMove())
			return DOCKING_IMMOBILIZED

	takeoff(old_turfs, new_turfs, moved_atoms, rotation, movement_direction, old_dock, underlying_old_area)

	CHECK_TICK

	cleanup_runway(new_dock, old_turfs, new_turfs, areas_to_move, moved_atoms, rotation, movement_direction, underlying_old_area, underlying_turf_type, underlying_baseturf_type)

	CHECK_TICK

	/*******************************************Unhiding turfs if necessary******************************************/
	if(new_hidden_turfs)
		SSshuttle.update_hidden_docking_ports(hidden_turfs, null)
		hidden_turfs = new_hidden_turfs
	/****************************************************************************************************************/

	check_poddoors()
	new_dock.last_dock_time = world.time
	setDir(new_dock.dir)

	return DOCKING_SUCCESS

/obj/docking_port/mobile/proc/preflight_check(
	list/old_turfs,
	list/new_turfs,
	list/areas_to_move,
	rotation,
	underlying_turf_type,
	baseturf_cache,
	)
	
	for(var/i in 1 to old_turfs.len)
		CHECK_TICK
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		if(!newT)
			return DOCKING_NULL_DESTINATION
		if(!oldT)
			return DOCKING_NULL_SOURCE

		var/area/old_area = oldT.loc
		var/move_mode = old_area.beforeShuttleMove(shuttle_areas)											//areas

		var/list/old_contents = oldT.contents
		for(var/k in 1 to old_contents.len)
			CHECK_TICK
			var/atom/movable/moving_atom = old_contents[k]
			if(moving_atom.loc != oldT) //fix for multi-tile objects
				continue
			move_mode = moving_atom.beforeShuttleMove(newT, rotation, move_mode, src)						//atoms

		move_mode = oldT.fromShuttleMove(newT, underlying_turf_type, baseturf_cache, move_mode)				//turfs
		move_mode = newT.toShuttleMove(oldT, move_mode , src)												//turfs

		if(move_mode & MOVE_AREA)
			areas_to_move[old_area] = TRUE

		old_turfs[oldT] = move_mode

/obj/docking_port/mobile/proc/takeoff(
	list/old_turfs,
	list/new_turfs,
	list/moved_atoms,
	rotation,
	movement_direction,
	old_dock,
	area/underlying_old_area,
	)

	for(var/i in 1 to old_turfs.len)
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		var/move_mode = old_turfs[oldT]
		if(move_mode & MOVE_CONTENTS)
			for(var/k in oldT)
				var/atom/movable/moving_atom = k
				if(moving_atom.loc != oldT) //fix for multi-tile objects
					continue
				moving_atom.onShuttleMove(newT, oldT, movement_force, movement_direction, old_dock, src)	//atoms
				moved_atoms[moving_atom] = oldT

		if(move_mode & MOVE_TURF)
			oldT.onShuttleMove(newT, movement_force, movement_direction)									//turfs

		if(move_mode & MOVE_AREA)
			var/area/shuttle_area = oldT.loc
			shuttle_area.onShuttleMove(oldT, newT, underlying_old_area)										//areas

/obj/docking_port/mobile/proc/cleanup_runway(
	obj/docking_port/stationary/new_dock,
	list/old_turfs,
	list/new_turfs,
	list/areas_to_move,
	list/moved_atoms,
	rotation,
	movement_direction,
	area/underlying_old_area,
	underlying_turf_type,
	underlying_baseturf_type,
	)
	
	underlying_old_area.afterShuttleMove()

	// Parallax handling
	// This needs to be done before the atom after move
	var/new_parallax_dir = FALSE
	if(istype(new_dock, /obj/docking_port/stationary/transit))
		new_parallax_dir = preferred_direction
	for(var/i in 1 to areas_to_move.len)
		CHECK_TICK
		var/area/internal_area = areas_to_move[i]
		internal_area.afterShuttleMove(new_parallax_dir)													//areas

	for(var/i in 1 to old_turfs.len)
		CHECK_TICK
		if(!(old_turfs[old_turfs[i]] & MOVE_TURF))
			continue
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		newT.afterShuttleMove(oldT, underlying_turf_type, underlying_baseturf_type, rotation)				//turfs

	for(var/i in 1 to moved_atoms.len)
		CHECK_TICK
		var/atom/movable/moved_object = moved_atoms[i]
		if(QDELETED(moved_object))
			continue
		var/turf/oldT = moved_atoms[moved_object]
		moved_object.afterShuttleMove(oldT, movement_force, dir, preferred_direction, movement_direction, rotation)//atoms

	for(var/i in 1 to old_turfs.len)
		CHECK_TICK
		// Objects can block air so either turf or content changes means an air update is needed
		if(!(old_turfs[old_turfs[i]] & MOVE_CONTENTS | MOVE_TURF))
			continue
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		oldT.blocks_air = initial(oldT.blocks_air)
		oldT.air_update_turf(TRUE)
		newT.blocks_air = initial(newT.blocks_air)
		newT.air_update_turf(TRUE)