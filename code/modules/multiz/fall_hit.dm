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
	if(get_gravity() > 0.5)
		visible_message("\The [src] falls from above and slams into \the [hit_atom]!", "You hear something slam into \the [hit_atom].")
	else
		visible_message("\The [src] drops from above onto \the [hit_atom]!", "You hear something drop onto \the [hit_atom].")
	for(var/atom/movable/AM in hit_atom.contents)
		AM.fall_act(src)
	zs_fallen = 0

// Take damage from falling and hitting the ground
/mob/living/fall_impact(var/turf/landing)
	var/gravity = get_gravity()
	var/total_brute_loss = 0
	if(gravity > 0.5)
		visible_message("<span class='warning'>\The [src] falls from above and slams into \the [landing]!</span>", \
			"<span class='danger'>You fall off and hit \the [landing]!</span>", \
			"You hear something slam into \the [landing].")
		if(gravity > 0.667)
			for(var/atom/movable/AM in landing.contents)
				AM.fall_act(src)
			playsound(loc, "sound/effects/pl_fallpain.ogg", 25, 1, -1)
			// Bases at ten and scales with the number of Z levels fallen
			// Because wounds heal rather quickly, 10 should be enough to discourage jumping off 1 ledge but not be enough to ruin you, at least for the first time.
			var/damage = ((10 * min(zs_fallen,5)) * gravity)
			var/old_brute_loss = getBruteLoss()
			apply_damage(rand(0, damage), BRUTE, LIMB_HEAD)
			apply_damage(rand(0, damage), BRUTE, LIMB_CHEST)
			apply_damage(rand(0, damage), BRUTE, LIMB_LEFT_LEG)
			apply_damage(rand(0, damage), BRUTE, LIMB_RIGHT_LEG)
			apply_damage(rand(0, damage), BRUTE, LIMB_LEFT_ARM)
			apply_damage(rand(0, damage), BRUTE, LIMB_RIGHT_ARM)
			total_brute_loss = getBruteLoss() - old_brute_loss
			if(mind && mind.suiciding)
				adjustBruteLoss(max(0,175 - total_brute_loss)) // Makes the act look real
				total_brute_loss = getBruteLoss() - old_brute_loss
			log_debug("[src] has taken [total_brute_loss] damage after falling [zs_fallen] z levels with a gravity of [gravity] Gs!")
		AdjustKnockdown((3 * min(zs_fallen,10)) * gravity)
	else
		visible_message("\The [src] drops from above and onto \the [landing].", \
			"You fall off and land on the \the [landing].", \
			"You hear something drop onto \the [landing].")
	zs_fallen = 0

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
	var/gravity = get_gravity()
	if(gravity > 0.25)
		// Tell the pilot that they just dropped down with a superheavy mecha.
		if(occupant)
			to_chat(occupant, "<span class='warning'>\The [src] crashed down onto \the [hit_atom]!</span>")

		if(gravity > 0.5)
			var/damage = ((10 * min(zs_fallen,5)) * gravity)
			// Anything on the same tile as the landing tile is gonna have a bad day.
			for(var/mob/living/L in hit_atom.contents)
				visible_message("<span class='danger'>\The [src] crushes \the [L] as it lands on them!</span>")
				L.fall_act(src)

			// Now to hurt the mech.
			take_damage(rand(damage, 3*damage))

			// And hurt the floor.
			if(istype(hit_atom, /turf/simulated/floor))
				var/turf/simulated/floor/ground = hit_atom
				ground.break_tile()
	else
		// Tell the pilot that they just plopped lightly onto the low-gravity ground with a superheavy mecha.
		if(occupant)
			to_chat(occupant, "<span class='warning'>\The [src] softly drops down onto \the [hit_atom]!</span>")
	zs_fallen = 0

/obj/machinery/power/supermatter/fall_impact(var/atom/hit_atom)
	..()
	Bumped(hit_atom)

var/global/list/non_items = list(/obj/machinery,/obj/structure)

// Opposite of fall_impact, called when something is dropped on someone
/atom/movable/proc/fall_act(var/atom/hitting_atom)
	return

/mob/living/fall_act(var/atom/hitting_atom)
	var/gravity = get_gravity()
	if(ismecha(hitting_atom))
		var/damage = ((10 * min(hitting_atom.zs_fallen,5)) * gravity)
		adjustBruteLoss(rand(3*damage, 5*damage))
		AdjustKnockdown(damage / 2)
	else if(isitem(hitting_atom))
		var/obj/item/I = hitting_atom
		var/damage = (((I.throwforce * min(hitting_atom.zs_fallen,5)) * gravity) * I.w_class)
		adjustBruteLoss(rand(damage, 2*damage))
		AdjustKnockdown(((2 * min(hitting_atom.zs_fallen,5)) * gravity) * I.w_class)
		if(I.w_class == W_CLASS_GIANT)
			gib()
	else if(is_type_in_list(hitting_atom,non_items))
		var/damage = ((3 * min(hitting_atom.zs_fallen,5)) * gravity)
		if(hitting_atom.density)
			damage *= 3
		adjustBruteLoss(rand(damage, 2*damage))
		AdjustKnockdown(damage / 2)
