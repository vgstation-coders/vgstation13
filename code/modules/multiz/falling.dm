
////////////////////////////

//FALLING STUFF

//If atom stands under open space, it can prevent fall, or not
/atom/proc/can_prevent_fall(var/atom/movable/mover, var/turf/coming_from)
	return (!Cross(mover, coming_from))

/atom/proc/get_gravity()
	var/area/A = get_area(src)
	if(istype(A))
		return A.gravity

	return 1

/atom
	var/fall_lock = FALSE // Stops fall() being called during gravity spawn delay
	var/zs_fallen = 0 // Gets reset if it hits something, for fall damage

//Holds fall checks that should not be overriden by children
/atom/movable/proc/fall()
	if(fall_lock)
		return

	if(!isturf(loc))
		return

	var/turf/below = GetBelow(src)
	if(!below)
		return

	var/turf/bottom = null
	var/depth = 0
	for(bottom = GetBelow(src); isopenspace(bottom); bottom = GetBelow(bottom))
		depth++
		if(depth > config.multiz_bottom_cap) // To stop getting caught on this in infinite loops
			break

	if(istype(bottom,/turf/space))
		return

	var/turf/T = loc
	if(!T.CanZPass(src, DOWN) || !below.CanZPass(src, DOWN))
		return

	var/obj/structure/stairs/down_stairs = locate(/obj/structure/stairs) in below
	// Detect stairs below and traverse down them.
	if(down_stairs && down_stairs.dir == GetOppositeDir(dir))
		Move(below)
		if(isliving(src))
			var/mob/living/L = src
			if(L.pulling)
				L.pulling.Move(below)
		return
	
	var/gravity = get_gravity()
	// No gravity in space, apparently.
	if(!gravity) //Polaris uses a proc, has_gravity(), for this
		return
	fall_lock = TRUE
	spawn(4 / gravity) // Now we use a delay of 4 ticks divided by the gravity.
		fall_lock = FALSE

		// We're in a new loc most likely, so check all this again
		below = GetBelow(src)
		if(!below)
			return

		bottom = null
		depth = 0
		for(bottom = GetBelow(src); isopenspace(bottom); bottom = GetBelow(bottom))
			depth++
			if(depth > config.multiz_bottom_cap) // To stop getting caught on this in infinite loops
				break

		if(istype(bottom,/turf/space))
			return
		T = loc
		if(!T.CanZPass(src, DOWN) || !below.CanZPass(src, DOWN))
			return

		down_stairs = locate(/obj/structure/stairs) in below
		if(down_stairs && down_stairs.dir == GetOppositeDir(dir))
			Move(below)
			if(isliving(src))
				var/mob/living/L = src
				if(L.pulling)
					L.pulling.Move(below)
			return

		gravity = get_gravity()
		if(!gravity)
			return

		/*if(throwing)  This was causing odd behavior where things wouldn't stop.
			return*/

		if(can_fall())
			// We spawn here to let the current move operation complete before we start falling. fall() is normally called from
			// Entered() which is part of Move(), by spawn()ing we let that complete.  But we want to preserve if we were in client movement
			// or normal movement so other move behavior can continue.
			var/mob/M = src
			var/is_client_moving = (ismob(M) && M.client && M.client.moving)
			spawn(0)
				if(is_client_moving) M.client.moving = 1
				handle_fall(below)
				if(is_client_moving) M.client.moving = 0
			// TODO - handle fall on damage!

//For children to override
/atom/movable/proc/can_fall()
	if(anchored)
		return FALSE
	return TRUE

/obj/effect/can_fall()
	return FALSE

/obj/effect/decal/cleanable/can_fall()
	return TRUE

// These didn't fall anyways but better to nip this now just incase.
/atom/movable/light/can_fall()
	return FALSE

// Function handling going over open spaces, pre-extension to normal throw hit checks
/atom/movable/hit_check(var/speed, mob/user)
	if(isopenspace(get_turf(src)))
		src.fall()
	. = ..()

// Actually process the falling movement and impacts.
/atom/movable/proc/handle_fall(var/turf/landing)
	var/turf/oldloc = loc

	// Check if there is anything in our turf we are standing on to prevent falling.
	for(var/obj/O in loc)
		if(!O.CanFallThru(src, landing))
			return FALSE

	// Supermatter dusting things falling on them
	var/obj/machinery/power/supermatter/SM = locate(/obj/machinery/power/supermatter) in landing
	if(SM)
		forceMove(SM.loc)
		SM.Consume(src)

	// See if something in turf below prevents us from falling into it.
	for(var/atom/A in landing)
		if(!A.Cross(src, src.loc, 1, 0))
			return FALSE

	// Now lets move there!
	if(!Move(landing))
		return 1

	if(isopenspace(oldloc))
		oldloc.visible_message("\The [src] falls down through \the [oldloc]!", "You hear something falling through the air.")

	zs_fallen++

	// If the turf has density, we give it first dibs
	if (landing.density && landing.CheckFall(src))
		return

	// First hit objects in the turf!
	for(var/atom/movable/A in landing)
		if(A != src && A.CheckFall(src))
			return

	// If none of them stopped us, then hit the turf itself
	landing.CheckFall(src)
