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

	var/area/areaMaster

	var/sound_override = 0 //Do we make a sound when bumping into something?
	var/hard_deleted = 0
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

	var/throwpass = 0
	var/level = 2

	// When this object moves. (args: loc)
	var/event/on_moved

	var/atom/movable/tether_master
	var/list/tether_slaves
	var/list/current_tethers

/atom/movable/New()
	. = ..()
	areaMaster = get_area_master(src)
	if((flags & HEAR) && !ismob(src))
		getFromPool(/mob/virtualhearer, src)

	if(starting_materials)
		materials = getFromPool(/datum/materials, src)
		for(var/matID in starting_materials)
			materials.addAmount(matID, starting_materials[matID])

	on_moved = new("owner"=src)

/atom/movable/Destroy()
	gcDestroyed = "Bye, world!"
	tag = null

	if(materials)
		returnToPool(materials)
		materials = null

	if(on_moved)
		on_moved.holder = null
		on_moved = null

	var/turf/un_opaque
	if (opacity && isturf(loc))
		un_opaque = loc

	loc = null
	if (un_opaque)
		un_opaque.recalc_atom_opacity()

	for (var/atom/movable/AM in locked_atoms)
		unlock_atom(AM)

	if (locked_to)
		locked_to.unlock_atom(src)

	for (var/datum/locking_category/category in locking_categories)
		qdel(category)

	locking_categories      = null
	locking_categories_name = null

	break_all_tethers()

	if((flags & HEAR) && !ismob(src))
		for(var/mob/virtualhearer/VH in virtualhearers)
			if(VH.attached == src)
				returnToPool(VH)

	..()

/proc/delete_profile(var/type, code = 0)
	if(!ticker || ticker.current_state < 3)
		return
	if(code == 0)
		if (!("[type]" in del_profiling))
			del_profiling["[type]"] = 0

		del_profiling["[type]"] += 1
	else if(code == 1)
		if (!("[type]" in ghdel_profiling))
			ghdel_profiling["[type]"] = 0

		ghdel_profiling["[type]"] += 1
	else
		if (!("[type]" in gdel_profiling))
			gdel_profiling["[type]"] = 0

		gdel_profiling["[type]"] += 1
		soft_dels += 1

/atom/movable/Del()
	if (gcDestroyed)

		if (hard_deleted)
			delete_profile("[type]", 1)
		else
			garbageCollector.dequeue("\ref[src]") // hard deletions have already been handled by the GC queue.
			delete_profile("[type]", 2)
	else // direct del calls or nulled explicitly.
		delete_profile("[type]", 0)
		Destroy()

	..()

/atom/movable/proc/get_move_delay()
	// Copied from Move().
	if(ismob(src))
		var/mob/M = src
		if(M.client)
			return (3+(M.client.move_delayer.next_allowed - world.time))*world.tick_lag
	return max(5 * world.tick_lag, 1)

// This is designed to only be used occasionally, since procs add overhead.
/atom/movable/proc/reset_glide_size()
	glide_size = Ceiling(WORLD_ICON_SIZE / src.get_move_delay() * world.tick_lag) - 1 //We always split up movements into cardinals for issues with diagonal movements.
	//glide_size = WORLD_ICON_SIZE / max(move_delay, world.tick_lag) * world.tick_lag // Updated calc from http://www.byond.com/forum/?post=1573076

/mob/verb/fix_gliding()
	set category = "OOC"
	set name = "Fix Movement"
	set desc = "Fixes jerky movement caused by BYOND being dumb."
	reset_glide_size()


/atom/movable/Move(newLoc,Dir=0,step_x=0,step_y=0)
	if(!loc || !newLoc)
		return 0
	//set up glide sizes before the move
	//ensure this is a step, not a jump

	//. = ..(NewLoc,Dir,step_x,step_y)
	if(current_tethers && current_tethers.len)
		for(var/datum/tether/master_slave/T in current_tethers)
			if(T.effective_slave == src)
				if(get_exact_dist(T.effective_master, src) > T.tether_distance)
					T.break_tether()
					break
				if(get_exact_dist(T.effective_master, newLoc) > T.tether_distance)
					change_dir(Dir)
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
			if(get_exact_dist(AM, newLoc) > R.tether_distance)
				change_dir(Dir)
				return 0
	if(timestopped)
		if(!pulledby || pulledby.timestopped) //being moved by our wizard maybe?
			return 0
	var/move_delay = max(5 * world.tick_lag, 1)
	if(ismob(src))
		var/mob/M = src
		if(M.client)
			move_delay = (3+(M.client.move_delayer.next_allowed - world.time))*world.tick_lag

	var/can_pull_tether = 0
	if(tether)
		if(tether.attempt_to_follow(src,newLoc))
			can_pull_tether = 1
		else
			return 0
	glide_size = Ceiling(WORLD_ICON_SIZE / move_delay * world.tick_lag) - 1 //We always split up movements into cardinals for issues with diagonal movements.
	var/atom/oldloc = loc
	if((bound_height != WORLD_ICON_SIZE || bound_width != WORLD_ICON_SIZE) && (loc == newLoc))
		. = ..()

		update_dir()
		return

	if(loc != newLoc)
		if (!(Dir & (Dir - 1))) //Cardinal move
			. = ..()
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
		spawn(0)
			for(var/atom/movable/AM in locked_atoms)
				var/datum/locking_category/category = locked_atoms[AM]
				category.update_lock(AM)

	update_dir()

	if(!loc || (loc == oldloc && oldloc != newLoc))
		last_move = 0
		return

	update_client_hook(loc)

	if(tether && can_pull_tether && !tether_pull)
		tether.follow(src,oldloc)
		var/datum/chain/tether_datum = tether.chain_datum
		if(!tether_datum.Check_Integrity())
			tether_datum.snap = 1
			tether_datum.Delete_Chain()

	last_move = (Dir || get_dir(oldloc, newLoc)) //If direction isn't specified, calculate it ourselves
	set_inertia(last_move)

	last_moved = world.time
	src.move_speed = world.timeofday - src.l_move_time
	src.l_move_time = world.timeofday
	// Update on_moved listeners.
	INVOKE_EVENT(on_moved,list("loc"=newLoc))
	return .

//The reason behind change_dir()
/atom/movable/proc/update_dir()
	for(var/atom/movable/AM in locked_atoms)
		if(dir != AM.dir)
			AM.change_dir(dir, src)

//Like forceMove(), but for dirs!
/atom/movable/proc/change_dir(new_dir, var/changer)
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

	AM.locked_to = src

	locked_atoms[AM] = category
	category.lock(AM)

	return TRUE

/atom/movable/proc/unlock_atom(var/atom/movable/AM)
	if (!locked_atoms || !locked_atoms.Find(AM))
		return FALSE

	var/datum/locking_category/category = locked_atoms[AM]
	locked_atoms    -= AM
	AM.locked_to     = null
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

	var/datum/locking_category/C = getFromPool(type, src)
	C.name = id
	locking_categories_name[id] = C
	locking_categories += C

/atom/movable/proc/get_lock_cat(var/category = /datum/locking_category)
	locking_init()
	. = locking_categories_name[category]

	if (!.)
		if (istext(category))
			return

		. = getFromPool(category, src)
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
		for(var/matid in materials.storage)
			var/datum/material/material = materials.getMaterial(matid)
			rec.addAmount(matid, materials.storage[matid] / material.cc_per_sheet) //the recycler's material is read as 1 = 1 sheet
			materials.storage[matid] = 0
		return 1
	return 0

// Previously known as HasEntered()
// This is automatically called when something enters your square
/atom/movable/Crossed(atom/movable/AM)
	return

/atom/movable/to_bump(atom/Obstacle)
	if(src.throwing)
		src.throw_impact(Obstacle)
		src.throwing = 0

	if (Obstacle)
		Obstacle.Bumped(src)

// harderforce is for things like lighting overlays which should only be moved in EXTREMELY specific sitations.
/atom/movable/proc/forceMove(atom/destination,var/no_tp=0, var/harderforce = FALSE)
	var/atom/old_loc = loc
	loc = destination
	last_moved = world.time

	if(old_loc)
		old_loc.Exited(src, destination)
		for(var/atom/movable/AM in old_loc)
			AM.Uncrossed(src)

	if(loc)
		last_move = get_dir(old_loc, loc)

		loc.Entered(src, old_loc)
		if(isturf(loc))
			var/area/A = get_area_master(loc)
			A.Entered(src, old_loc)

			for(var/atom/movable/AM in loc)
				AM.Crossed(src,no_tp)


	for(var/atom/movable/AM in locked_atoms)
		var/datum/locking_category/category = locked_atoms[AM]
		category.update_lock(AM)

	update_client_hook(loc)

	// Update on_moved listeners.
	INVOKE_EVENT(on_moved,list("loc"=loc))
	return 1

/atom/movable/proc/update_client_hook(atom/destination)
	if(locate(/mob) in src)
		for(var/client/C in clients)
			if((get_turf(C.eye) == destination) && (C.mob.hud_used))
				C.update_special_views()

/mob/update_client_hook(atom/destination)
	if(locate(/mob) in src)
		for(var/client/C in clients)
			if((get_turf(C.eye) == destination) && (C.mob.hud_used))
				C.update_special_views()
	else if(client && hud_used)
		var/client/C = client
		C.update_special_views()

/atom/movable/proc/forceEnter(atom/destination)
	if(destination)
		if(loc)
			loc.Exited(src)
		loc = destination
		loc.Entered(src)
		if(isturf(destination))
			var/area/A = get_area_master(destination)
			A.Entered(src)

		for(var/atom/movable/AM in locked_atoms)
			AM.forceMove(loc)

		update_client_hook(destination)
		return 1
	return 0

/atom/movable/proc/hit_check(var/speed, mob/user)
	. = 1

	if(src.throwing)
		for(var/atom/A in get_turf(src))
			if(A == src)
				continue

			if(isliving(A))
				var/mob/living/L = A
				if(L.lying)
					continue
				src.throw_impact(L, speed, user)

				if(src.throwing == 1) //If throwing == 1, the throw was weak and will stop when it hits a dude. If a hulk throws this item, throwing is set to 2 (so the item will pass through multiple mobs)
					src.throwing = 0
					. = 0

			else if(isobj(A))
				var/obj/O = A
				if(O.density && !O.throwpass)	// **TODO: Better behaviour for windows which are dense, but shouldn't always stop movement
					src.throw_impact(O, speed, user)
					src.throwing = 0
					. = 0

/atom/movable/proc/throw_at(atom/target, range, speed, override = 1, var/fly_speed = 0) //fly_speed parameter: if 0, does nothing. Otherwise, changes how fast the object flies WITHOUT affecting damage!
	if(!target || !src)
		return 0
	if(override)
		sound_override = 1
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target

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
		while(src && target &&((((src.x < target.x && dx == EAST) || (src.x > target.x && dx == WEST)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(tS && dist_travelled)
				timestopped = loc.timestopped
				tS = 0
			if(timestopped && !dist_travelled)
				timestopped = 0
				tS = 1
			while((loc.timestopped || timestopped) && dist_travelled)
				sleep(3)
			if(error < 0)
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					. = 0
					break

				src.Move(step, dy)
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

				src.Move(step, dx)
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
		while(src && target &&((((src.y < target.y && dy == NORTH) || (src.y > target.y && dy == SOUTH)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(timestopped)
				sleep(1)
				continue
			if(error < 0)
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					. = 0
					break

				src.Move(step, dx)
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

				src.Move(step, dy)
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
	if(isobj(src))
		src.throw_impact(get_turf(src), speed, user)

/atom/movable/change_area(oldarea, newarea)
	areaMaster = newarea
	..()

//Overlays
/atom/movable/overlay
	var/atom/master = null
	anchored = 1

/atom/movable/overlay/New()
	. = ..()
	verbs.len = 0

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
/atom/movable/proc/addHear()
	flags |= HEAR
	getFromPool(/mob/virtualhearer, src)

/atom/movable/proc/removeHear()
	flags &= ~HEAR
	for(var/mob/virtualhearer/VH in virtualhearers)
		if(VH.attached == src)
			returnToPool(VH)

//Can it be moved by a shuttle?
/atom/movable/proc/can_shuttle_move(var/datum/shuttle/S)
	return 1

/atom/movable/proc/Process_Spacemove(check_drift)
	var/dense_object = 0
	for(var/turf/turf in oview(1,src))
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

	sleep(5)

	if(can_apply_inertia() && (src.loc == start))
		if(!inertia_dir)
			return //inertia_dir = last_move

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
	density = 0
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
	density = init_density
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

/atom/movable/proc/make_invisible(var/source_define, var/time, var/include_clothing)	//Makes things practically invisible, not actually invisible. Alpha is set to 1.
	return invisibility || alpha <= 1	//already invisible

/atom/movable/proc/break_all_tethers()	//Breaks all tethers
	if(current_tethers)
		for(var/datum/tether/T in current_tethers)
			T.break_tether()

/atom/movable/proc/on_tether_broken(atom/movable/other_end)	//To allow for code based on when a tether with a specific thing is broken
	return
