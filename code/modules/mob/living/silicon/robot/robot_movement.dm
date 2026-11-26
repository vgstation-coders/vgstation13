/mob/living/silicon/robot/Process_Spaceslipping(var/prob_slip = 5)
	if(HAS_MODULE_QUIRK(src, MODULE_HAS_MAGPULSE)) //	The magic of magnets.
		return FALSE
	..()

/mob/living/silicon/robot/CheckSlip(slip_on_walking = FALSE, overlay_type = TURF_WET_WATER, slip_on_magbooties = FALSE)
	return ((HAS_MODULE_QUIRK(src, MODULE_HAS_MAGPULSE))? SLIP_HAS_MAGBOOTS : FALSE)

/mob/living/silicon/robot/ApplySlip(var/obj/effect/overlay/puddle/P)

	if (P.wet != TURF_WET_WATER)
		return FALSE

	if(Slip(5,3))
		//Don't step forward as a robot, we're not slipping just glitching.
		visible_message("<span class='warning'>[src] short circuits on the water!</span>", \
					"<span class='warning'>You short circuit on the water!</span>")
		return TRUE

/mob/living/silicon/robot/Process_Spacemove(var/check_drift = FALSE)
	if(module)
		for(var/obj/item/weapon/tank/jetpack/J in module.modules)
			if(J && istype(J, /obj/item/weapon/tank/jetpack))
				if(((!check_drift) || (check_drift && J.stabilization_on)) && (J.allow_thrust(0.01, src)))
					inertia_dir = FALSE
					return TRUE
				if((!check_drift && J.allow_thrust(0.01)))
					return TRUE
	if(..())
		return TRUE
	return FALSE

/mob/living/silicon/robot/movement_tally_multiplier()
	. = ..()
	if(is_component_functioning("power cell") && get_cell())
		// REALTIMEOFDAY keeps counting across midnight; world.timeofday wraps to 0,
		// which made these checks see a negative elapsed time and slow the borg for
		// the rest of the day.
		var/current_time = REALTIMEOFDAY
		if(last_tase_time && (current_time - last_tase_time) < SILICON_TASER_SLOWDOWN_DURATION)
			. *= SILICON_TASER_SLOWDOWN_MULTIPLIER
		if(last_high_damage_taken_time && (current_time - last_high_damage_taken_time) < SILICON_HIGH_DAMAGE_SLOWDOWN_DURATION)
			. *= SILICON_HIGH_DAMAGE_SLOWDOWN_MULTIPLIER
		if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
			. *= SILICON_MOBILITY_MODULE_SPEED_MODIFIER
		var/low_movement_speed_trigger = get_percentage_power_for_movement()
		var/cellcharge = get_cell_charge(src)
		if(cellcharge <= low_movement_speed_trigger) //25% of the cell OR 25% of a normal cell, whatever is lower
			if(cellcharge <= 0)
				. *= SILICON_NO_CELL_SLOWDOWN
			else
				//This should be +1.4 at the trigger point and +2 at maximum
				. += SILI_LOW_SLOW + 0.6*(low_movement_speed_trigger-cellcharge)/low_movement_speed_trigger
		else
			if(module)
				. *= module.speed_modifier
	else
		. *= SILICON_NO_CELL_SLOWDOWN
