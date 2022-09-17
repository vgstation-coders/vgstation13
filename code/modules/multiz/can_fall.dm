// Mechas are anchored, so we need to override.
/obj/mecha/can_fall()
	return TRUE

/obj/mecha/working/clarke/can_fall()
	return FALSE

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

/mob/living/silicon/robot/can_fall() // Jetpacks help too
	if(flying)
		return FALSE
	if(module)
		for(var/obj/item/weapon/tank/jetpack/J in module.modules)
			if(J && istype(J, /obj/item/weapon/tank/jetpack))
				if(J.allow_thrust(0.01, src))
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
	else if(istype(mover) && mover.checkpass(pass_flags_self))
		return TRUE // Anything small enough to pass a grille will pass a lattice
	if(!isturf(mover.loc))
		return FALSE // Only let loose floor items fall. No more snatching things off people's hands.
	else
		return FALSE // TODO - Technically should be density = 1 and flags |= ON_BORDER

// So you'll slam when falling onto a grille
/obj/structure/lattice/CheckFall(var/atom/movable/falling_atom)
	if(istype(falling_atom) && falling_atom.checkpass(pass_flags_self))
		return FALSE
	return falling_atom.fall_impact(src)
