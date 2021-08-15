/mob/verb/up()
	set name = "Move Upwards"
	set category = "IC"

	if(zMove(UP))
		to_chat(src, "<span class='notice'>You move upwards.</span>")

/mob/verb/down()
	set name = "Move Down"
	set category = "IC"

	if(zMove(DOWN))
		to_chat(src, "<span class='notice'>You move down.</span>")

/mob/proc/zMove(direction)
	//if(eyeobj) This probably belongs in AIMove
	//	return eyeobj.zMove(direction)
	if(!can_ztravel())
		to_chat(src, "<span class='warning'>You lack means of travel in that direction.</span>")
		return

	var/turf/start = loc
	if(!istype(start))
		to_chat(src, "<span class='notice'>You are unable to move from here.</span>")
		return 0

	var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
	if(!destination)
		to_chat(src, "<span class='notice'>There is nothing of interest in this direction.</span>")
		return 0

	if(!start.CanZPass(src, direction))
		to_chat(src, "<span class='warning'>\The [start] is in the way.</span>")
		return 0

	if(!destination.CanZPass(src, direction))
		to_chat(src, "<span class='warning'>\The [destination] blocks your way.</span>")
		return 0

	var/area/area = get_area(src)
	if(direction == UP && area.gravity)
		var/obj/structure/lattice/lattice = locate() in destination.contents
		if(lattice)
			var/pull_up_time = max(5 SECONDS + (src.movement_delay() * 10), 1)
			to_chat(src, "<span class='notice'>You grab \the [lattice] and start pulling yourself upward...</span>")
			destination.visible_message("<span class='notice'>You hear something climbing up \the [lattice].</span>")
			if(do_after(src, pull_up_time))
				to_chat(src, "<span class='notice'>You pull yourself up.</span>")
			else
				to_chat(src, "<span class='warning'>You gave up on pulling yourself up.</span>")
				return 0
		else
			to_chat(src, "<span class='warning'>Gravity stops you from moving upward.</span>")
			return 0

	for(var/atom/A in destination)
		if(!A.CanPass(src, start, 1.5, 0))
			to_chat(src, "<span class='warning'>\The [A] blocks you.</span>")
			return 0
	if(!Move(destination))
		return 0
	return 1

/mob/observer/zMove(direction)
	var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
	if(destination)
		forceMove(destination)
	else
		to_chat(src, "<span class='notice'>There is nothing of interest in this direction.</span>")

/mob/camera/zMove(direction)
	var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
	if(destination)
		forceMove(destination)
	else
		to_chat(src, "<span class='notice'>There is nothing of interest in this direction.</span>")

/mob/proc/can_ztravel()
	return 0

/mob/observer/can_ztravel()
	return 1

/mob/living/carbon/human/can_ztravel()
	if(incapacitated())
		return 0

	if(Process_Spacemove())
		return 1

/*  This would be really easy to implement but let's talk about if we WANT it.

	if(Check_Shoegrip())	//scaling hull with magboots
		for(var/turf/simulated/T in trange(1,src))
			if(T.density)
				return 1 */

/mob/living/silicon/robot/can_ztravel()
	if(incapacitated())
		return 0

	if(Process_Spacemove()) //Checks for active jetpack
		return 1

/* Same as above, hull scaling discussion pending

	for(var/turf/simulated/T in trange(1,src)) //Robots get "magboots"
		if(T.density)
			return 1*/

// TODO - Leshana Experimental

//Execution by grand piano!
/atom/movable/proc/get_fall_damage()
	return 42

//If atom stands under open space, it can prevent fall, or not
/atom/proc/can_prevent_fall(var/atom/movable/mover, var/turf/coming_from)
	return (!CanPass(mover, coming_from))

////////////////////////////



//FALLING STUFF

//Holds fall checks that should not be overriden by children
/atom/movable/proc/fall()
	if(!isturf(loc))
		return

	var/turf/below = GetBelow(src)
	if(!below)
		return

	var/turf/T = loc
	if(!T.CanZPass(src, DOWN) || !below.CanZPass(src, DOWN))
		return

	// No gravity in space, apparently.
	var/area/area = get_area(src)
	if(!area.gravity) //Polaris uses a proc, has_gravity(), for this
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
/atom/movable/lighting_overlay/can_fall()
	return FALSE

// Mechas are anchored, so we need to override.
/obj/mecha/can_fall()
	return TRUE

/obj/item/pipe/can_fall()
	. = ..()

	if(anchored)
		return FALSE

	var/turf/below = GetBelow(src)
	if((locate(/obj/structure/disposalpipe/up) in below) || (locate(/obj/machinery/atmospherics/pipe/zpipe/up) in below))
		return FALSE

/mob/living/simple_animal/parrot/can_fall() // Poly can fly.
	return FALSE

/mob/living/simple_animal/hostile/carp/can_fall() // So can carp apparently.
	return FALSE

/obj/structure/bed/chair/vehicle/firebird/can_fall() // And the firebird, obligatory.
	return FALSE

/obj/structure/bed/chair/vehicle/adminbus/can_fall() // And the sacred bus
	return FALSE

/mob/can_fall() // Obviously, flight stops falling
	if(flying)
		return FALSE

/mob/proc/stop_flying(var/anim = 1) // So flying mobs fall right after they stop
	flying = 0
	fall()

/mob/living/carbon/human/can_fall() // Jetpacks help too
	if(flying)
		return FALSE
	if(istype(back, /obj/item/weapon/tank/jetpack))
		var/obj/item/weapon/tank/jetpack/J = back
		if(!lying && (J.allow_thrust(0.01, src)))
			return FALSE
	return TRUE

// Check if this atom prevents things standing on it from falling. Return TRUE to allow the fall.
/obj/proc/CanFallThru(atom/movable/mover as mob|obj, turf/target as turf)
	return TRUE

// Things that prevent objects standing on them from falling into turf below
/obj/structure/catwalk/CanFallThru(atom/movable/mover as mob|obj, turf/target as turf)
	if(target.z < z)
		return FALSE // TODO - Technically should be density = 1 and flags |= ON_BORDER
	if(!isturf(mover.loc))
		return FALSE // Only let loose floor items fall. No more snatching things off people's hands.
	else
		return TRUE

// So you'll slam when falling onto a catwalk
/obj/structure/catwalk/CheckFall(var/atom/movable/falling_atom)
	return falling_atom.fall_impact(src)

/obj/structure/lattice/CanFallThru(atom/movable/mover as mob|obj, turf/target as turf)
	if(target.z >= z)
		return TRUE // We don't block sideways or upward movement.
	else if(istype(mover) && mover.checkpass(PASSGRILLE))
		return TRUE // Anything small enough to pass a grille will pass a lattice
	if(!isturf(mover.loc))
		return FALSE // Only let loose floor items fall. No more snatching things off people's hands.
	else
		return FALSE // TODO - Technically should be density = 1 and flags |= ON_BORDER

// So you'll slam when falling onto a grille
/obj/structure/lattice/CheckFall(var/atom/movable/falling_atom)
	if(istype(falling_atom) && falling_atom.checkpass(PASSGRILLE))
		return FALSE
	return falling_atom.fall_impact(src)

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
		SM.Consume(src)

	// See if something in turf below prevents us from falling into it.
	for(var/atom/A in landing)
		if(!A.CanPass(src, src.loc, 1, 0))
			return FALSE
	
	// TODO - Stairs should operate thru a different mechanism, not falling, to allow side-bumping.

	// Now lets move there!
	if(!Move(landing))
		return 1
		
	var/obj/structure/stairs/down_stairs = locate(/obj/structure/stairs) in landing
	// Detect if we made a silent landing.
	if(down_stairs)
		if(src.dir == down_stairs.dir)
			// This is hackish but whatever.
			var/turf/target = get_step(GetBelow(src), down_stairs.dir)
			var/turf/source = loc
			if(target.Enter(src, source))
				src.loc = target
				target.Entered(src, source)
				if(isliving(src))
					var/mob/living/L = src
					if(L.pulling)
						L.pulling.forceMove(target)
		return 1

	if(isopenspace(oldloc))
		oldloc.visible_message("\The [src] falls down through \the [oldloc]!", "You hear something falling through the air.")

	// If the turf has density, we give it first dibs
	if (landing.density && landing.CheckFall(src))
		return

	// First hit objects in the turf!
	for(var/atom/movable/A in landing)
		if(A != src && A.CheckFall(src))
			return

	// If none of them stopped us, then hit the turf itself
	landing.CheckFall(src)

// ## THE FALLING PROCS ###

// Called on everything that falling_atom might hit. Return 1 if you're handling it so handle_fall() will stop checking.
// If you're soft and break the fall gently, just return 1
// If the falling atom will hit you hard, call fall_impact() and return its result.
/atom/proc/CheckFall(var/atom/movable/falling_atom)
	if(density && !(flags & ON_BORDER))
		return falling_atom.fall_impact(src)

// By default all turfs are gonna let you hit them regardless of density.
/turf/CheckFall(var/atom/movable/falling_atom)
	return falling_atom.fall_impact(src)

// Obviously you can't really hit open space.
/turf/simulated/open/CheckFall(var/atom/movable/falling_atom)
	// Don't need to print this, the open space it falls into will print it for us!
	// visible_message("\The [falling_atom] falls from above through \the [src]!", "You hear a whoosh of displaced air.")
	return 0

// We return 1 without calling fall_impact in order to provide a soft landing. So nice.
// Note this really should never even get this far
/obj/structure/stairs/CheckFall(var/atom/movable/falling_atom)
	return 1

// Called by CheckFall when we actually hit something.  Oof
/atom/movable/proc/fall_impact(var/atom/hit_atom)
	visible_message("\The [src] falls from above and slams into \the [hit_atom]!", "You hear something slam into \the [hit_atom].")

// Take damage from falling and hitting the ground
/mob/living/carbon/human/fall_impact(var/turf/landing)
	visible_message("<span class='warning'>\The [src] falls from above and slams into \the [landing]!</span>", \
		"<span class='danger'>You fall off and hit \the [landing]!</span>", \
		"You hear something slam into \the [landing].")
	playsound(loc, "sound/effects/pl_fallpain.ogg", 25, 1, -1)
	var/damage = 15 // Because wounds heal rather quickly, 15 should be enough to discourage jumping off but not be enough to ruin you, at least for the first time.
	apply_damage(rand(0, damage), BRUTE, LIMB_HEAD)
	apply_damage(rand(0, damage), BRUTE, LIMB_CHEST)
	apply_damage(rand(0, damage), BRUTE, LIMB_LEFT_LEG)
	apply_damage(rand(0, damage), BRUTE, LIMB_RIGHT_LEG)
	apply_damage(rand(0, damage), BRUTE, LIMB_LEFT_ARM)
	apply_damage(rand(0, damage), BRUTE, LIMB_RIGHT_ARM)
	AdjustKnockdown(4)
	updatehealth()

/obj/mecha/handle_fall(var/turf/landing)
	// First things first, break any lattice
	var/obj/structure/lattice/lattice = locate(/obj/structure/lattice, loc)
	if(lattice)
		// Lattices seem a bit too flimsy to hold up a massive exosuit.
		lattice.visible_message("<span class='danger'>\The [lattice] collapses under the weight of \the [src]!</span>")
		qdel(lattice)

	// Then call parent to have us actually fall
	return ..()

/obj/mecha/fall_impact(var/atom/hit_atom)
	// Tell the pilot that they just dropped down with a superheavy mecha.
	if(occupant)
		to_chat(occupant, "<span class='warning'>\The [src] crashed down onto \the [hit_atom]!</span>")

	// Anything on the same tile as the landing tile is gonna have a bad day.
	for(var/mob/living/L in hit_atom.contents)
		L.visible_message("<span class='danger'>\The [src] crushes \the [L] as it lands on them!</span>")
		L.adjustBruteLoss(rand(70, 100))
		L.AdjustKnockdown(8)

	// Now to hurt the mech.
	take_damage(rand(15, 30))

	// And hurt the floor.
	if(istype(hit_atom, /turf/simulated/floor))
		var/turf/simulated/floor/ground = hit_atom
		ground.break_tile()
