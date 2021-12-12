/atom/movable
	// Recycling shit

	var/w_type = NOT_RECYCLABLE  // Waste category for sorters. See setup.dm

	plane = OBJ_PLANE

	var/last_move = null //Direction in which this atom last moved
	var/last_moved = 0   //world.time when this atom last moved
	var/anchored = 0
	var/move_speed = 10
	var/l_move_time = 1
	var/m_flag = 1
	var/throwing = 0
	var/throw_speed = 2
	var/throw_range = 7
	var/moved_recently = 0
	var/mob/pulledby = null
	var/pass_flags = 0

	var/sound_override = 0 //Do we make a sound when bumping into something?
	var/hard_deleted
	var/pressure_resistance = ONE_ATMOSPHERE
	var/obj/effect/overlay/chain/tether = null
	var/tether_pull = 0

	//glide_size = 8

	//Material datums - the fun way of doing things in a laggy manner
	var/datum/materials/materials = null
	var/list/starting_materials //starting set of mats - used in New(), you can set this to an empty list to have the datum be generated but not filled

	//Atom locking stuff.
	var/list/locked_atoms // Assoc list of atom = category.
	var/atom/movable/locked_to
	var/list/datum/locking_category/locking_categories // List of categories, unorganized.
	var/list/datum/locking_category/locking_categories_name // Same as above but assoc with the key being the name or type.

	var/lockflags = 0 // Flags for locking. DO NOT CONFUSE WITH /datum/locking_category/flags! These effect being locked.

	// Can we send relaymove() if gravity is disabled or we are in space? (Should be handled by relaymove, but shitcode abounds)
	var/internal_gravity = 0
	var/inertia_dir = null
	var/kinetic_acceleration = 0
	var/throwpass = 0
	var/level = 2

	var/atom/movable/tether_master
	var/list/tether_slaves
	var/list/current_tethers
	var/obj/shadow/shadow

	var/ignore_blocking = 0

	var/last_explosion_push = 0
	var/mob/virtualhearer/virtualhearer

	var/list/could_bump //In a given movement, holds the objects that BYOND internally calls Bump() on, so we can pick one to call to_bump() on.

	var/atom/movable/border_dummy/border_dummy //Used for border objects. The old Uncross() method fails miserably with pixel movement or large hitboxes.

/atom/movable/New()
	. = ..()
	if((flags & HEAR) && !ismob(src))
		virtualhearer = new /mob/virtualhearer(src)

	if(starting_materials)
		materials = new /datum/materials(src)
		for(var/matID in starting_materials)
			materials.addAmount(matID, starting_materials[matID])

/atom/movable/Destroy()

	if(materials)
		qdel(materials)
		materials = null

	remove_border_dummy()

	INVOKE_EVENT(src, /event/destroyed, "thing" = src)

	var/turf/T = loc
	if (opacity && isturf(loc))
		T = loc // check_blocks_light() is called later on this

	for (var/atom/movable/AM in locked_atoms)
		unlock_atom(AM)

	if (locked_to)
		locked_to.unlock_atom(src)

	for (var/datum/locking_category/category in locking_categories)
		qdel(category)
	locking_categories      = null
	locking_categories_name = null

	break_all_tethers()

	forceMove(null)

	if (istype(T))
		T.check_blocks_light()

	if(virtualhearer)
		qdel(virtualhearer)
		virtualhearer = null

	for(var/atom/movable/AM in src)
		qdel(AM)

	..()

/atom/movable/Del()
	if (gcDestroyed)
		if (hard_deleted)
			delete_profile("[type]", 1)
		else
			delete_profile("[type]", 2)

	else // direct del calls or nulled explicitly.
		delete_profile("[type]", 0)
		Destroy()

	..()

//TODO move this somewhere else
/atom/movable/proc/set_glide_size(glide_size_override = 0, var/min = 0.9, var/max = WORLD_ICON_SIZE/2)
	glide_size_override *= step_size / WORLD_ICON_SIZE //This should probably go in DELAY2GLIDESIZE() instead but that would be a lot of changed macros
	if(!glide_size_override || glide_size_override > max)
		glide_size = 0
	else
		glide_size = max(min, glide_size_override)

/atom/movable/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	if(!loc || !NewLoc)
		return 0
	INVOKE_EVENT(src, /event/before_move)

	if(current_tethers && current_tethers.len)
		for(var/datum/tether/master_slave/T in current_tethers)
			if(T.effective_slave == src)
				if(get_exact_dist(T.effective_master, src) > T.tether_distance)
					T.break_tether()
					break
				if(get_exact_dist(T.effective_master, NewLoc) > T.tether_distance)
					change_dir(Dir)
					INVOKE_EVENT(src, /event/after_move)
					return 0
		for(var/datum/tether/equal/restrictive/R in current_tethers)
			var/atom/movable/AM
			if(R.effective_slave == src)
				AM = R.effective_master
			else
				AM = R.effective_slave
			if(get_exact_dist(AM, src) > R.tether_distance)
				R.break_tether()
				break
			if(get_exact_dist(AM, NewLoc) > R.tether_distance)
				change_dir(Dir)
				INVOKE_EVENT(src, /event/after_move)
				return 0
	if(timestopped)
		if(!pulledby || pulledby.timestopped) //being moved by our wizard maybe?
			INVOKE_EVENT(src, /event/after_move)
			return 0

	var/can_pull_tether = 0
	if(tether)
		if(tether.attempt_to_follow(src,NewLoc))
			can_pull_tether = 1
		else
			INVOKE_EVENT(src, /event/after_move)
			return 0

	if(glide_size_override > 0)
		set_glide_size(glide_size_override)

	var/atom/oldloc = loc

	//We always split up movements into cardinals for issues with diagonal movements.
	if(Dir || (loc != NewLoc))
		if (!(Dir & (Dir - 1))) //Cardinal move
			could_bump = list()
			var/old_dir = dir
			. = ..()
			if(flow_flags & KEEP_DIR)
				dir = old_dir //We can set it directly instead of calling change_dir() because:
					//1. It wasn't changed through change_dir() in the supercall
					//2. update_dir() is called later anyway
			perform_bump()
		else //Diagonal move, split it into cardinal moves
			if (Dir & NORTH)
				if (Dir & EAST) //Northeast
					if (step(src, NORTH))
						. = step(src, EAST)
					else if (step(src, EAST))
						. = step(src, NORTH)
				else if (Dir & WEST) //Northwest
					if (step(src, NORTH))
						. = step(src, WEST)
					else if (step(src, WEST))
						. = step(src, NORTH)
			else if (Dir & SOUTH)
				if (Dir & EAST) //Southeast
					if (step(src, SOUTH))
						. = step(src, EAST)
					else if (step(src, EAST))
						. = step(src, SOUTH)
				else if (Dir & WEST) //Southwest
					if (step(src, SOUTH))
						. = step(src, WEST)
					else if (step(src, WEST))
						. = step(src, SOUTH)


	if(. && locked_atoms && locked_atoms.len)	//The move was succesful, update locked atoms.
		for(var/atom/movable/AM in locked_atoms)
			var/datum/locking_category/category = locked_atoms[AM]
			category.update_lock(AM)

	update_dir()

	if(!loc || (loc == oldloc && oldloc != NewLoc))
		last_move = 0
		INVOKE_EVENT(src, /event/after_move)
		return

	update_client_hook(loc)

	if(tether && can_pull_tether && !tether_pull)
		tether.follow(src,oldloc)
		var/datum/chain/tether_datum = tether.chain_datum
		if(!tether_datum.Check_Integrity())
			tether_datum.snap = 1
			tether_datum.Delete_Chain()

	last_move = (Dir || get_dir(oldloc, NewLoc)) //If direction isn't specified, calculate it ourselves
	set_inertia(last_move)

	last_moved = world.time
	src.move_speed = world.timeofday - src.l_move_time
	src.l_move_time = world.timeofday
	INVOKE_EVENT(src, /event/moved, "mover" = src)
	INVOKE_EVENT(src, /event/after_move)

/atom/movable/search_contents_for(path,list/filter_path=null) // For vehicles
	var/list/found = ..()
	for (var/atom/A in locked_atoms)
		found += A.search_contents_for(path,filter_path)
	return found

//The reason behind change_dir()
/atom/movable/proc/update_dir()
	for(var/atom/movable/AM in locked_atoms)
		if(dir != AM.dir)
			AM.change_dir(dir, src)
			var/datum/locking_category/category = locked_atoms[AM]
			category.update_lock(AM)

//Like forceMove(), but for dirs!
/atom/proc/change_dir(new_dir, changer)
	dir = new_dir

/atom/movable/change_dir(new_dir, changer)
	if(locked_to && changer != locked_to)
		return

	if(new_dir != dir)
		dir = new_dir
		update_dir()

// Atom locking, lock an atom to another atom, and the locked atom will move when the other atom moves.
// Essentially buckling mobs to chairs. For all atoms.
// Category is the locking category to lock this atom to, see /code/datums/locking_category.dm.
// For category you should pass the typepath of the category, however strings should be used for slots made dynamically at runtime.
/atom/movable/proc/lock_atom(var/atom/movable/AM, var/datum/locking_category/category = /datum/locking_category)
	locking_init()
	if (AM in locked_atoms || AM.locked_to || !istype(AM))
		return FALSE

	category = get_lock_cat(category)
	if (!category) // String category which didn't exist.
		return 0

	if (istype(AM, /mob/living)) //checks if the atom is a mob, and removes any grabs from the mob to prevent !!FUN!!
		var/mob/living/M = AM
		for(var/obj/item/weapon/grab/G in M.grabbed_by)
			if (istype(G, /obj/item/weapon/grab))
				qdel(G)

	AM.locked_to = src
	if (ismob(AM))
		var/mob/M = AM
		M.canmove = 0

	locked_atoms[AM] = category
	category.lock(AM)

	return TRUE

/atom/movable/proc/unlock_atom(var/atom/movable/AM)
	if (!locked_atoms || !locked_atoms.Find(AM))
		return FALSE

	var/datum/locking_category/category = locked_atoms[AM]
	locked_atoms    -= AM
	AM.locked_to     = null
	if (ismob(AM))
		var/mob/M = AM
		M.canmove = 1

	category.unlock(AM)
	//AM.reset_glide_size() // FIXME: Currently broken.

	return TRUE

/atom/movable/proc/unlock_from()
	if(!locked_to)
		return FALSE

	return locked_to.unlock_atom(src)

// Proc for adding an unique locking category with a certain ID.
/atom/movable/proc/add_lock_cat(var/type, var/id)
	locking_init()
	if(locking_categories_name.Find(id))
		return locking_categories_name[id]

	var/datum/locking_category/C = new type(src)
	C.name = id
	locking_categories_name[id] = C
	locking_categories += C
	return C

/atom/movable/proc/get_lock_cat(var/category = /datum/locking_category)
	locking_init()
	. = locking_categories_name[category]

	if (!.)
		if (istext(category))
			return

		. = new category(src)
		locking_categories_name[category] = .
		locking_categories += .

// Returns the locking category for a locked atom.
// Returns null if the object is not locked to this.
/atom/movable/proc/get_lock_cat_for(var/atom/movable/AM)
	return locked_atoms && locked_atoms[AM]

// Returns a list (yes, always a list!) of things locked to this category.
/atom/movable/proc/get_locked(var/category, var/subtypes = FALSE)
	if (!locked_atoms) // Uninitialized
		return list()

	if (!category)
		return locked_atoms

	if (subtypes)
		. = list()
		for (var/datum/locking_category/C in locking_categories)
			if (istype(C, category))
				. += C.locked

		return

	if (locking_categories_name.Find(category))
		var/datum/locking_category/C = locking_categories_name[category]
		return C.locked

	return list()

// Returns the amount of things locked to this category.
// The length of get_locked() with the same arguments will always be equal to this.
/atom/movable/proc/is_locking(var/category, var/subtypes = FALSE)
	var/list/atom/movable/locked = get_locked(category, subtypes)
	return locked.len

// Checks if this atom is locking anything of a specific type, if category is not provided, search all categories.
/atom/movable/proc/is_locking_type(var/type, var/category, var/subtypes = FALSE)
	if (category)
		return locate(type) in get_locked(category, subtypes)
	else
		return locate(type) in locked_atoms

/atom/movable/proc/locking_init()
	if (!locked_atoms)
		locked_atoms            = list()
		locking_categories      = list()
		locking_categories_name = list()

/atom/movable/proc/recycle(var/datum/materials/rec)
	if(materials)
		rec.addFrom(materials, TRUE)
		return 1
	return 0

// Previously known as HasEntered()
// This is automatically called when something enters your square
/atom/movable/Crossed(atom/movable/AM)
	return

// Always override this proc instead of BYOND-provided Bump().
// This gives us better control over what actually gets bumped instead of being stuck with BYOND's decision.
/atom/movable/proc/to_bump(atom/Obstacle)
	if(airflow_speed > 0 && airflow_dest)
		airflow_hit(Obstacle)
	else
		airflow_speed = 0
		airflow_time = 0
		if(src.throwing)
			src.throw_impact(Obstacle)
			src.throwing = 0
		if(Obstacle)
			Obstacle.Bumped(src)
	sound_override = 0

//As it says above, don't override this. Override to_bump() and/or Obstacle's get_bump_target() instead. Assumes could_bump is already a list (not null).
/atom/movable/Bump(atom/Obstacle)
	SHOULD_NOT_OVERRIDE(TRUE)
	could_bump += Obstacle

//Choose an actual bump target from the list of potential bump targets, and to_bump() it.
//Bumps the first border object in the list, or the last object if there isn't one.
//This seems weird, but the list order is out of our control and essentially arbitrary, so it doesn't matter.
//The only relevant guarantee is that any turfs in the list will be at the end, so they have priority over non-border objects.
//(The order is based on ref, as far as I can tell.)
/atom/movable/proc/perform_bump()
	var/atom/target
	for(var/atom/A as anything in could_bump)
		target = A //Can't just use target as the loop variable. For some reason, BYOND nulls it after the loop in that case.
		if(target.flow_flags & ON_BORDER)
			break
	if(target)
		to_bump(target.get_bump_target())
	could_bump = null

/atom/movable/proc/setup_border_dummy()
	if(border_dummy)
		return
	border_dummy = new()
	lock_atom(border_dummy, /datum/locking_category/border_dummy)
	border_dummy.update_dir()

/atom/movable/proc/remove_border_dummy()
	if(border_dummy)
		unlock_atom(border_dummy)
		qdel(border_dummy)
		border_dummy = null

/atom/movable/proc/border_dummy_Cross(atom/movable/mover) //border_dummy calls this in its own Cross() to detect collision
	if(istype(mover) && mover.checkpass(pass_flags_self))
		return TRUE
	if(!density)
		return TRUE
	if(locate(/obj/effect/unwall_field) in loc) //Annoying workaround for this -kanef
		return TRUE
	return bounds_dist(src, mover) >= 0

/atom/movable/proc/forceMove(atom/NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0, from_tp = 0)

	INVOKE_EVENT(src, /event/before_move)
	if(glide_size_override)
		glide_size = glide_size_override

	var/list/atom/old_locs = locs //locs is implicitly copied on assignment, not aliased
	var/atom/old_loc = loc //Just for convenience; should be equivalent to old_locs[1].
	var/list/atom/uncrossing
	if(isturf(loc)) //obounds() provides nonsense results when Ref.loc isn't a turf.
		uncrossing = obounds(src)
	else
		uncrossing = loc?.contents //contents IS aliased on assignment but we're not changing it so it's fine

	loc = NewLoc

	src.step_x = step_x
	src.step_y = step_y

	last_moved = world.time

	for(var/atom/A in old_locs)
		A.Exited(src, loc)
	for(var/atom/A in uncrossing)
		A.Uncrossed(src)

	if(loc)
		last_move = get_dir(old_loc, loc)

		for(var/atom/A in locs)
			A.Entered(src, old_loc)
		if(isturf(loc))
			var/area/A = loc.loc
			A.Entered(src, old_loc)

			for(var/atom/movable/AM in loc)
				AM.Crossed(src, from_tp) // Says if we crossed it from a teleporter.


	for(var/atom/movable/AM in locked_atoms)
		var/datum/locking_category/category = locked_atoms[AM]
		category.update_lock(AM)

	update_client_hook(loc)

	INVOKE_EVENT(src, /event/moved, "mover" = src)

	var/turf/from_turf = get_turf(old_loc)
	var/turf/to_turf = get_turf(NewLoc)
	if(from_turf && to_turf && (from_turf.z != to_turf.z))
		INVOKE_EVENT(src, /event/z_transition, "user" = src, "from_z" = from_turf.z, "to_z" = to_turf.z)

	INVOKE_EVENT(src, /event/after_move)
	return 1

/atom/movable/proc/update_client_hook(atom/destination)
	if(locate(/mob) in src)
		for(var/client/C in clients)
			if((get_turf(C.eye) == destination) && (C.mob.hud_used))
				C.update_special_views()
				C.mob.set_glide_size(glide_size)


/mob/update_client_hook(atom/destination)
	if(locate(/mob) in src)
		for(var/client/C in clients)
			if((get_turf(C.eye) == destination) && (C.mob.hud_used))
				C.update_special_views()
				C.mob.set_glide_size(glide_size)
	else if(client && hud_used)
		var/client/C = client
		C.update_special_views()

/atom/movable/proc/forceEnter(atom/destination)
	var/atom/movable/old_loc = loc
	if(destination)
		loc = destination
		if(old_loc)
			old_loc.Exited(src)
		loc.Entered(src)
		if(isturf(destination))
			var/area/A = get_area(destination)
			A.Entered(src)

		for(var/atom/movable/AM in locked_atoms)
			AM.forceMove(loc)

		update_client_hook(destination)
		return 1
	return 0

//Called below in hit_check to see if it can be hit
//Return TRUE if not hit.
/atom/proc/PreImpact(atom/movable/A, speed)
	return TRUE

/atom/movable/proc/hit_check(var/speed, mob/user)
	. = 1

	if(throwing)
		for(var/atom/A in get_turf(src))
			if(A == src)
				continue

			if(!A.PreImpact(src,speed))
				throw_impact(A,speed,user)
				if(throwing==1)
					throwing = 0
					. = 0

/atom/movable/proc/throw_at(atom/target, range, speed, override = 1, var/fly_speed = 0) //fly_speed parameter: if 0, does nothing. Otherwise, changes how fast the object flies WITHOUT affecting damage!
	set waitfor = FALSE
	if(!target || !src)
		return 0
	if(override)
		sound_override = 1
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target
	var/kinetic_sum = 0
	throwing = 1
	if(!speed)
		speed = throw_speed
	if(!fly_speed)
		fly_speed = speed

	var/mob/user
	if(usr)
		user = usr
		if(M_HULK in usr.mutations)
			src.throwing = 2 // really strong throw!

	if(istype(src,/obj/mecha))
		var/obj/mecha/M = src
		M.dash_dir = dir
		src.throwing = 2// mechas will crash through windows, grilles, tables, people, you name it

	var/afterimage = 0
	if(istype(src,/mob/living/simple_animal/construct/armoured/perfect))
		var/mob/living/simple_animal/construct/armoured/perfect/M = src
		M.dash_dir = dir
		src.throwing = 2
		afterimage = 1

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)

	var/dx
	if (target.x > src.x)
		dx = EAST
	else
		dx = WEST

	var/dy
	if (target.y > src.y)
		dy = NORTH
	else
		dy = SOUTH
	var/dist_travelled = 0
	var/dist_since_sleep = 0
	var/area/a = get_area(src.loc)

	. = 1

	if(dist_x > dist_y)
		var/error = dist_x/2 - dist_y


		var/tS = 0
		while(src && target &&((((src.x < target.x && dx == EAST) || (src.x > target.x && dx == WEST)) && dist_travelled < range) || (a && a.gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(tS && dist_travelled)
				timestopped = loc.timestopped
				tS = 0
			if(timestopped && !dist_travelled)
				timestopped = 0
				tS = 1
			while((loc.timestopped || timestopped) && dist_travelled)
				sleep(3)
			if(kinetic_acceleration>kinetic_sum)
				fly_speed += kinetic_acceleration-kinetic_sum
				kinetic_sum = kinetic_acceleration
			if(afterimage)
				new /obj/effect/afterimage/red(loc,src)
			if(error < 0)
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					. = 0
					break

				src.Move(step, dy, glide_size_override = DELAY2GLIDESIZE(fly_speed))
				. = hit_check(speed, user)
				error += dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= fly_speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					. = 0
					break

				src.Move(step, dx, glide_size_override = DELAY2GLIDESIZE(fly_speed))
				. = hit_check(speed, user)
				error -= dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= fly_speed)
					dist_since_sleep = 0
					sleep(1)
			a = get_area(src.loc)
	else
		var/error = dist_y/2 - dist_x
		while(src && target &&((((src.y < target.y && dy == NORTH) || (src.y > target.y && dy == SOUTH)) && dist_travelled < range) || (a && a.gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(timestopped)
				sleep(1)
				continue
			if(kinetic_acceleration>0)
				fly_speed += kinetic_acceleration
				kinetic_acceleration = 0
			if(afterimage)
				new /obj/effect/afterimage/red(loc,src)
			if(error < 0)
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					. = 0
					break

				src.Move(step, dx, glide_size_override = DELAY2GLIDESIZE(fly_speed))
				. = hit_check(speed, user)
				error += dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= fly_speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					. = 0
					break

				src.Move(step, dy, glide_size_override = DELAY2GLIDESIZE(fly_speed))
				. = hit_check(speed, user)
				error -= dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= fly_speed)
					dist_since_sleep = 0
					sleep(1)

			a = get_area(src.loc)

	//done throwing, either because it hit something or it finished moving
	src.throwing = 0
	kinetic_acceleration = 0
	if(isobj(src))
		src.throw_impact(get_turf(src), speed, user)

//Overlays

/datum/locking_category/overlay

/atom/movable/overlay
	var/atom/master = null
	anchored = 1
	lockflags = 0 //Neither dense when locking or dense when locked to something

/atom/movable/overlay/New()
	. = ..()
	if(!loc)
		qdel(src)
		CRASH("[type] created in nullspace.")

	master = loc
	name = master.name
	dir = master.dir

	if(istype(master, /atom/movable))
		var/atom/movable/AM = master
		AM.lock_atom(src, /datum/locking_category/overlay)
	if (istype(master, /atom/movable))
		var/atom/movable/AM = master
		AM.register_event(/event/destroyed, src, .proc/qdel_self)
	verbs.len = 0

/atom/movable/overlay/proc/qdel_self(datum/thing)
	qdel(src) // Rest in peace

/atom/movable/overlay/Destroy()
	if(istype(master, /atom/movable))
		var/atom/movable/AM = master
		AM.unlock_atom(src)
		AM.unregister_event(/event/destroyed, src, .proc/qdel_self)
	master = null
	return ..()

/atom/movable/overlay/blob_act()
	return

/atom/movable/overlay/attackby(a, b, c)
	if (src.master)
		return src.master.attackby(a, b, c)
	return

/atom/movable/overlay/attack_paw(a, b, c)
	if (src.master)
		return src.master.attack_paw(a, b, c)
	return

/atom/movable/overlay/attack_hand(a, b, c)
	if (src.master)
		return src.master.attack_hand(a, b, c)
	return

/atom/movable/overlay/proc/move_to_turf_or_null(atom/movable/mover)
	var/turf/T = get_turf(mover)
	var/atom/movable/AM = master // the proc is only called if the master has a "on_moved" event.
	if(T != loc)
		forceMove(T, glide_size_override = DELAY2GLIDESIZE(AM.move_speed))

/atom/movable/proc/attempt_to_follow(var/atom/movable/A,var/turf/T)
	if(anchored)
		return 0
	if(get_dist(T,loc) <= 1)
		return 1
	else
		var/turf/U = get_turf(A)
		if(!U)
			return null
		return src.forceMove(U)

/atom/movable/overlay/crit
	icon = 'icons/random_krit.dmi'
	icon_state = "randomcrit"
	plane = ABOVE_HUMAN_PLANE

/////////////////////////////
// SINGULOTH PULL REFACTOR
/////////////////////////////
/atom/movable/proc/canSingulothPull(var/obj/machinery/singularity/singulo)
	return 1

/atom/movable/proc/say_understands(var/mob/other)
	return 1

////////////
/// HEAR ///
////////////
/atom/movable/proc/addHear(var/hearer_type = /mob/virtualhearer)
	flags |= HEAR
	virtualhearer = new hearer_type(src)

/atom/movable/proc/removeHear()
	flags &= ~HEAR
	if(virtualhearer)
		qdel(virtualhearer)
		virtualhearer = null

//Can it be moved by a shuttle?
/atom/movable/proc/can_shuttle_move(var/datum/shuttle/S)
	return !locked_to

/atom/movable/proc/Process_Spacemove(check_drift)
	var/dense_object = 0
	for(var/turf/turf in orange(1,src))
		if(!turf.has_gravity(src))
			continue

		dense_object++
		break

	if(!dense_object && (locate(/obj/structure/lattice) in oview(1, src)))
		dense_object++
	if(!dense_object && (locate(/obj/structure/catwalk) in oview(1, src)))
		dense_object++
	if(!dense_object && (locate(/obj/effect/blob) in oview(1, src)))
		dense_object++

	//Lastly attempt to locate any dense objects we could push off of
	//TODO: If we implement objects drifing in space this needs to really push them
	//Due to a few issues only anchored and dense objects will now work.
	if(!dense_object)
		for(var/obj/O in oview(1, src))
			if((O) && (O.density) && (O.anchored))
				dense_object++
				break

	//Nothing to push off of so end here
	if(!dense_object)
		return 0

	//If not then we can reset inertia and move
	inertia_dir = 0
	return 1

//INERTIA


/atom/movable/proc/apply_inertia(direction)
	if(isturf(loc))
		var/turf/T = loc
		if(!T.has_gravity())
			src.inertia_dir = direction
			step(src, src.inertia_dir)
			return 1
	else if(istype(loc, /atom/movable))
		var/atom/movable/AM = loc
		return AM.apply_inertia(direction)

/atom/movable/proc/set_inertia(direction)
	inertia_dir = direction

/atom/movable/proc/process_inertia(turf/start)
	set waitfor = 0
	if(Process_Spacemove(1))
		inertia_dir  = 0
		return

	sleep(INERTIA_MOVEDELAY)

	if(can_apply_inertia() && (src.loc == start))
		if(!inertia_dir)
			return //inertia_dir = last_move

		set_glide_size(DELAY2GLIDESIZE(INERTIA_MOVEDELAY))
		step(src, inertia_dir)

/atom/movable/proc/reset_inertia()
	inertia_dir = 0

/atom/movable/proc/can_apply_inertia()
	return (!src.anchored && !(src.pulledby && src.pulledby.Adjacent(src)))

//Called when somebody begins to pull this atom
/atom/movable/proc/on_pull_start(mob/living/L)
	return

/atom/movable/proc/send_to_future(var/duration)	//don't override this, only call it
	spawn()
		actual_send_to_future(duration)

/atom/movable/proc/actual_send_to_future(var/duration)	//don't call this, only override it
	var/init_invisibility = invisibility
	var/init_invuln = flags & INVULNERABLE
	var/init_density = density
	var/init_anchored = anchored
	var/init_timeless = flags & TIMELESS

	invisibility = INVISIBILITY_MAXIMUM
	flags |= INVULNERABLE
	setDensity(FALSE)
	anchored = 1
	flags |= TIMELESS
	if(!ignoreinvert)
		invertcolor(src)
	timestopped = 1

	for(var/atom/movable/AM in contents)
		AM.send_to_future(duration)

	sleep(duration)
	timestopped = 0
	if(!init_invuln)
		flags &= ~INVULNERABLE
	setDensity(init_density)
	anchored = init_anchored
	if(!init_timeless)
		flags &= ~TIMELESS
	appearance = falltempoverlays[src]
	falltempoverlays -= src
	ignoreinvert = initial(ignoreinvert)
	invisibility = init_invisibility

/datum/proc/send_to_past(var/duration)
	return

/datum/var/being_sent_to_past

/atom/movable/send_to_past(var/duration)
	var/current_loc = loc
	var/static/list/resettable_vars = list(
		"being_sent_to_past",
		"invisibility",
		"alpha",
		"name",
		"desc",
		"dir",
		"pixel_x",
		"pixel_y",
		"layer",
		"transform",
		"density",
		"last_move",
		"last_moved",
		"anchored",
		"move_speed",
		"throw_speed",
		"throw_range",
		"timestopped",
		"flags",
		"gcDestroyed")
	var/list/stored_vars = list()
	for(var/x in resettable_vars)
		if(istype(vars[x], /list))
			var/list/L = vars[x]
			stored_vars[x] = L.Copy()
			continue
		stored_vars[x] = vars[x]

	for(var/atom/movable/AM in contents)
		AM.send_to_past(duration)
	if(reagents)
		reagents.send_to_past(duration)

	being_sent_to_past = TRUE
	spawn(duration)
		if(istype(loc, /mob))
			var/mob/M = loc
			M.drop_item(src, force_drop = 1)
		forceMove(current_loc)
		for(var/x in stored_vars)
			if(istype(stored_vars[x], /list))
				var/list/L = stored_vars[x]
				if(!L)
					vars[x] = null
					continue
				else if(!L.len)
					vars[x] = list()
					continue
			vars[x] = stored_vars[x]
		update_icon()

/datum/proc/reset_vars_after_duration(var/list/to_reset, var/duration, var/sending_to_past = FALSE)
	if(!to_reset || !to_reset.len || !duration)
		return
	if(sending_to_past)
		to_reset.Add("being_sent_to_past")
	var/list/stored_vars = list()
	for(var/x in to_reset)
		if(istype(vars[x], /list))
			var/list/L = vars[x]
			stored_vars[x] = L.Copy()
			continue
		stored_vars[x] = vars[x]

	if(sending_to_past)
		being_sent_to_past = TRUE
	spawn(duration)
		for(var/x in stored_vars)
			if(istype(stored_vars[x], /list))
				var/list/L = stored_vars[x]
				if(!L)
					vars[x] = null
					continue
				else if(!L.len)
					vars[x] = list()
					continue
			vars[x] = stored_vars[x]

/atom/proc/attack_icon()
	return appearance

/atom/movable/proc/do_attack_animation(atom/target, atom/tool)
	set waitfor = 0

	ASSERT(tool) //If no tool, shut down the proc and call the coder police

	if(target == src)
		return
	var/horizontal = 0
	var/vertical = 0

	var/direction = get_dir(src, target)

	if(direction & NORTH)
		vertical = 1
	else if(direction & SOUTH)
		vertical = -1

	if(direction & EAST)
		horizontal = 1
	else if(direction & WEST)
		horizontal = -1

//Attack animation that looks like person being pixel shifted
	spawn()
		var/image/override_image = image(icon = icon, icon_state = icon_state) //only because byond will not create an image if you do not give it some values
		override_image.appearance = appearance
		override_image.override = 1
		override_image.loc = src
		override_image.pixel_x = pixel_x
		override_image.pixel_y = pixel_y
		override_image.dir = dir

		var/adjusted_x = pixel_x + horizontal * 3 * PIXEL_MULTIPLIER
		var/adjusted_y = pixel_y + vertical * 3 * PIXEL_MULTIPLIER
		var/viewers = person_animation_viewers.Copy()
		for(var/client/C in viewers)
			C.images += override_image

		animate(override_image, pixel_x = adjusted_x, pixel_y = adjusted_y, time = 1)
		animate(pixel_x = pixel_x, pixel_y = pixel_y, time = 1)
		sleep(2)
		for(var/client/C in viewers)
			C.images -= override_image

	spawn()
		//Attack Animation for ghost object being pixel shifted onto person
		var/image/item = image(icon=tool.icon, icon_state = tool.icon_state)
		item.appearance = tool.attack_icon()
		item.alpha = 128
		item.loc = target
		item.pixel_x = target.pixel_x - horizontal * 0.5 * WORLD_ICON_SIZE
		item.pixel_y = target.pixel_y - vertical * 0.5 * WORLD_ICON_SIZE
		item.mouse_opacity = 0

		var/viewers = item_animation_viewers.Copy()
		for(var/client/C in viewers)
			C.images += item

		animate(item, pixel_x = target.pixel_x, pixel_y = target.pixel_y, time = 3)
		sleep(3)
		for(var/client/C in viewers)
			C.images -= item

	spawn()
		target.do_hitmarker(usr)

/atom/proc/do_hitmarker(mob/shooter)
	spawn()
		var/datum/role/streamer/streamer_role = shooter?.mind?.GetRole(STREAMER)
		if(streamer_role && streamer_role.team == ESPORTS_SECURITY)
			streamer_role.hits += IS_WEEKEND ? 2 : 1
			streamer_role.update_antag_hud()
			playsound(src, 'sound/effects/hitmarker.ogg', 100, FALSE)
			var/image/hitmarker = image(icon='icons/effects/effects.dmi', loc=src, icon_state="hitmarker")
			for(var/client/C in clients)
				C.images += hitmarker
			sleep(3)
			for(var/client/C in clients)
				C.images -= hitmarker

/atom/movable/proc/make_invisible(var/source_define, var/time, var/include_clothing)	//Makes things practically invisible, not actually invisible. Alpha is set to 1.
	return invisibility || alpha <= 1	//already invisible

/atom/movable/proc/break_all_tethers()	//Breaks all tethers
	if(current_tethers)
		for(var/datum/tether/T in current_tethers)
			T.break_tether()

/atom/movable/proc/on_tether_broken(atom/movable/other_end)	//To allow for code based on when a tether with a specific thing is broken
	return

/atom/movable/proc/area_entered(var/area/A)
	return

/atom/movable/proc/can_be_pulled(var/mob/user)
	return TRUE

/atom/movable/proc/setPixelOffsetsFromParams(params, mob/user, base_pixx = 0, base_pixy = 0, clamp = TRUE)
	if(anchored)
		return 0
	if(user && (!Adjacent(user) || !src.Adjacent(user) || user.incapacitated() || !src.can_be_pulled(user)))
		return 0
	var/list/params_list = params2list(params)
	if(clamp)
		pixel_x = clamp(base_pixx + text2num(params_list["icon-x"]) - WORLD_ICON_SIZE/2, -WORLD_ICON_SIZE/2, WORLD_ICON_SIZE/2)
		pixel_y = clamp(base_pixy + text2num(params_list["icon-y"]) - WORLD_ICON_SIZE/2, -WORLD_ICON_SIZE/2, WORLD_ICON_SIZE/2)
	else
		pixel_x = base_pixx + text2num(params_list["icon-x"]) - WORLD_ICON_SIZE/2
		pixel_y = base_pixy + text2num(params_list["icon-y"]) - WORLD_ICON_SIZE/2
	return 1

//Overwriting BYOND proc used for simple animal and NPCbot movement, Pomf help me
/atom/movable/proc/start_walk_to(Trg,Min=0,Lag=0,Speed=0)
	if(Lag > 0)
		set_glide_size(DELAY2GLIDESIZE(Lag))
	walk_to(src,Trg,Min,Lag,Speed)

/atom/movable/proc/can_be_pushed(mob/user)
	return 1

/atom/movable/proc/ThrowAtStation(var/radius = 30, var/throwspeed = null, var/startside = null) //throws a thing at the station from the edges
	var/startx = 0
	var/starty = 0
	var/endy = 0
	var/endx = 0
	if (!startside)
		startside = pick(cardinal)

	switch(startside)
		if(NORTH)
			starty = world.maxy-TRANSITIONEDGE-5
			startx = rand(TRANSITIONEDGE+5,world.maxx-TRANSITIONEDGE-5)
		if(EAST)
			starty = rand(TRANSITIONEDGE+5,world.maxy-TRANSITIONEDGE-5)
			startx = world.maxx-TRANSITIONEDGE-5
		if(SOUTH)
			starty = TRANSITIONEDGE+5
			startx = rand(TRANSITIONEDGE+5,world.maxx-TRANSITIONEDGE-5)
		if(WEST)
			starty = rand(TRANSITIONEDGE+5,world.maxy-TRANSITIONEDGE-5)
			startx = TRANSITIONEDGE+5

	//grabs a turf in the center of the z-level
	//range of turfs determined by radius var
	endx = rand((world.maxx/2)-radius,(world.maxx/2)+radius)
	endy = rand((world.maxy/2)-radius,(world.maxy/2)+radius)
	var/turf/startzone = locate(startx, starty, 1)
	var/turf/endzone = locate(endx, endy, 1)
	var/area/startzone_area = get_area(startzone)
	if(!isspace(startzone_area))
		return FALSE
	forceMove(startzone)
	throw_at(endzone, null, throwspeed)
	return TRUE

/mob/living/carbon/human/ThrowAtStation(var/radius = 30, var/throwspeed = null, var/startside = null, var/entry_vehicle = /obj/item/airbag)
	var/turf/prev_turf = get_turf(src)
	var/obj/AB = new entry_vehicle(null, TRUE)
	forceMove(AB)
	if(AB.ThrowAtStation(radius, throwspeed, startside))
		return TRUE
	else
		forceMove(prev_turf)
		qdel(AB)
		return FALSE

/atom/movable/proc/spawn_rand_maintenance()
	var/list/potential_locations = list()
	for(var/area/maintenance/A in areas)
		potential_locations.Add(A)

	while(potential_locations.len)
		var/area/maintenance/A = pick(potential_locations)
		potential_locations.Remove(A)
		for(var/turf/simulated/floor/F in A.contents)
			if(!F.has_dense_content())
				forceMove(F)
				return TRUE
	return FALSE

/atom/movable/proc/teleport_radius(var/range)
	var/list/best_options = list()
	var/list/backup_options = list()
	var/turf/picked
	for(var/turf/T in orange(range, src))
		if(T.x>world.maxx-6 || T.x<6 || T.y>world.maxy-6 || T.y<6) //Conditions we will NEVER accept: too close to edge
			continue
		if(istype(T,/turf/space) || T.density) //Only as a fallback: dense turf or space
			backup_options += T
			continue
		best_options += T
	if(best_options.len)
		picked = pick(best_options)
	else if(backup_options.len)
		picked = pick(backup_options)
	else
		return
	forceMove(picked)


//border_dummy

//Replaces the use of Uncross() for border object collision, because Uncross() is not quite correct for that.
//Using Uncross() causes various problems for objects with altered bounding boxes or step_size.
//The solution used here is absolutely idiotic, but as far as I can figure is the most correct approach within BYOND's stock movecode.

//#define DEBUG_BORDER_DUMMY

/atom/movable/border_dummy
	#ifdef DEBUG_BORDER_DUMMY
	icon = 'icons/obj/structures.dmi'
	icon_state = "window"
	color = "red"
	#else
	invisibility = 101
	#endif
	flow_flags = ON_BORDER
	flags = TIMELESS | INVULNERABLE

//The following serves to prevent objects from overlapping the border object from the side.
//By widening the border_dummy to either side of the border object, we make it so that objects approaching from the edge overlap it as well as objects in front of the border object.
/atom/movable/border_dummy/update_dir()
	..()
	//A general system to let arbitrary atoms rotate their bounds with dir would be good, but this is enough for now
	switch(dir)
		if(NORTH, SOUTH)
			bound_x = -WORLD_ICON_SIZE
			bound_width = 3 * WORLD_ICON_SIZE
			bound_y = 0
			bound_height = WORLD_ICON_SIZE
		if(EAST, WEST)
			bound_x = 0
			bound_width = WORLD_ICON_SIZE
			bound_y = -WORLD_ICON_SIZE
			bound_height = 3 * WORLD_ICON_SIZE
		else //Shouldn't happen
			CRASH("border_dummy has invalid dir [dir]")


/atom/movable/border_dummy/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(!istype(mover))
		return TRUE //The parent object will handle airflow calculations.
	if(!locked_to)
		CRASH("border_dummy was collision checked while not locked to anything! ([x], [y], [z])")
	return (mover == locked_to) || locked_to.border_dummy_Cross(mover) //An object will hit its own border_dummy if the (mover == locked_to) isn't included.

/atom/movable/border_dummy/throw_at(atom/target, range, speed, override = 1, var/fly_speed = 0)
	return //It wouldn't actually move even without this override, but it would still hit things on its own tile.

/atom/movable/border_dummy/get_bump_target()
	return locked_to.get_bump_target() //I don't think it's possible for this line to execute if locked_to is null due to Cross() above.


/datum/locking_category/border_dummy
	y_offset = 1
	rotate_offsets = TRUE

#ifdef DEBUG_BORDER_DUMMY
#undef DEBUG_BORDER_DUMMY
#endif


// -- trackers

/atom/movable/proc/add_tracker(var/datum/tracker/T)
	register_event(T, /datum/tracker/proc/recieve_position)

/datum/tracker
	var/name = "Tracker"
	var/active = TRUE
	var/changed = FALSE

	var/turf/target

	var/tick_refresh = 5 // The number of moved events before we update the position.
	var/current_tick = 1

	var/lost_position_probability = 0 // Probability of losing the target
	var/lost_position_distance = 0 // Distance at which the tracker loses the target

/datum/tracker/proc/recieve_position(var/list/loc)

	ASSERT(loc)

	if (!active)
		return
	if (current_tick < tick_refresh)
		current_tick++
		return

	if (prob(lost_position_probability))
		active = FALSE
		return

	var/target_loc = loc["loc"]
	if (target != target_loc)
		changed = TRUE

	target = get_turf(target_loc)

	current_tick = 1


/atom/movable/proc/speen(times = 4)
	set waitfor = FALSE
	var/prev_dir = dir
	for(var/i in 1 to times)
		for(var/new_dir in cardinal)
			change_dir(new_dir)
			sleep(1)
	change_dir(prev_dir)
