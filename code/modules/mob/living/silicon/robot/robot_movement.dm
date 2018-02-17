/mob/living/silicon/robot/Process_Spaceslipping(var/prob_slip = 5)
	if(module && module.no_slip) //	The magic of magnets.
		return FALSE
	..()

/mob/living/silicon/robot/CheckSlip()
	return ((module && module.no_slip)? -1 : 0)

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
	if(is_component_functioning("power cell") && cell)
		if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
			. *= SILICON_MOBILITY_MODULE_SPEED_MODIFIER
		if(cell.charge <= 0)
			. *= SILICON_NO_CHARGE_SLOWDOWN
		else
			if(module)
				. *= module.speed_modifier
	else
		. *= SILICON_NO_CELL_SLOWDOWN

/mob/living/silicon/robot/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	if(..())
		if(istype(NewLoc, /turf/unsimulated/floor/asteroid) && istype(module, /obj/item/weapon/robot_module/miner))
			var/obj/item/weapon/storage/bag/ore/ore_bag = locate(/obj/item/weapon/storage/bag/ore) in get_all_slots() //find it in our modules
			if(ore_bag)
				var/atom/newloc = NewLoc //NewLoc isn't actually typecast
				for(var/obj/item/weapon/ore/ore in newloc.contents)
					ore_bag.preattack(NewLoc, src, 1) //collects everything
					break
