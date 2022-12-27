
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
	var/z_velocity = 0 // Gets reset if it hits something, increases to max level determined by gravity

//Holds fall checks that should not be overriden by children
/atom/movable/proc/fall()
	if(fall_lock)
		return

	if(!isturf(loc))
		return

	if(!check_below())
		return

	var/gravity = get_gravity()
	// No gravity in space, apparently.
	if(!gravity) //Polaris uses a proc, has_gravity(), for this
		return

	fall_lock = TRUE
	spawn(abs(10/(max(z_velocity,gravity*2.5)))) // Now we use a delay of 1 second divided by z velocity, with no possible zero
		fall_lock = FALSE

		var/turf/target = z_velocity < 0 ? check_above() : check_below()
		// We're in a new loc most likely, so check all this again
		if(!target)
			if(z_velocity < 0)
				z_velocity *= -1 // ceiling hit, no funni actions for this that seem workable yet
				target = check_below()
				if(!target)
					return
			else
				return

		if(!get_gravity())
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
				handle_fall(target)
				if(is_client_moving) M.client.moving = 0
			// TODO - handle fall on damage!

/atom/movable/proc/check_below()
	var/turf/below = GetBelow(src)
	if(!below)
		return 0

	var/turf/bottom = null
	var/list/checked_belows = list()
	for(bottom = GetBelow(src); isopenspace(bottom); bottom = GetBelow(bottom))
		if(bottom.z in checked_belows) // To stop getting caught on this in infinite loops
			break
		checked_belows.Add(bottom.z)

	if(istype(bottom,/turf/space))
		return 0

	var/turf/T = loc
	if(!T.CanZPass(src, DOWN) || !below.CanZPass(src, DOWN))
		return 0

	var/obj/structure/stairs/down_stairs = locate(/obj/structure/stairs) in below
	// Detect stairs below and traverse down them.
	if(down_stairs && down_stairs.dir == GetOppositeDir(dir))
		Move(below)
		if(isliving(src))
			var/mob/living/L = src
			if(L.pulling)
				L.pulling.Move(below)
		return 0

	return below

/atom/movable/proc/check_above()
	var/turf/above = GetAbove(src)
	if(!above)
		return 0

	var/turf/T = loc
	if(!T.CanZPass(src, UP) || !above.CanZPass(src, UP))
		return 0

	return above

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
/atom/movable/lighting_overlay/can_fall()
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
			return

	// Supermatter dusting things falling on them
	var/obj/machinery/power/supermatter/SM = locate(/obj/machinery/power/supermatter) in landing
	if(SM)
		forceMove(SM.loc)
		SM.Consume(src)

	// See if something in turf below prevents us from falling into it.
	for(var/atom/A in landing)
		if(!A.Cross(src, src.loc, 1, 0))
			A.CheckFall(src)
			return

	// Now lets move there!
	if(!Move(landing))
		return 1

	if(isopenspace(oldloc))
		oldloc.visible_message("\The [src] falls down through \the [oldloc]!", "You hear something falling through the air.")

	var/gravity = get_gravity()
	// No gravity in space, apparently.
	if(!gravity) //Polaris uses a proc, has_gravity(), for this
		return

	// Velocity adjustment part goes here. TODO: Factor in air drag etc. eventually, maybe (or a more physics accurate formula)
	if(z_velocity < 0) // Going upwards? Add gravity to the negative value until zero is reached
		z_velocity += gravity
	else if(z_velocity < (5*gravity)) // Down? Tend it towards a max of 5*gravity, halfway to the remainder each step
		z_velocity += (((gravity*5)-z_velocity)/2)

	// If the turf has density, we give it first dibs
	if (landing.density && landing.CheckFall(src))
		return

	// First hit objects in the turf!
	for(var/atom/movable/A in landing)
		if(A != src && A.CheckFall(src))
			return

	// If none of them stopped us, then hit the turf itself
	landing.CheckFall(src)
