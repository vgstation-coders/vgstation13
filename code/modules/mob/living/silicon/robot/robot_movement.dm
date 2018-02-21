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

 //No longer needed, but I'll leave it here incase we plan to re-use it.
/mob/living/silicon/robot/movement_tally_multiplier()
	. = ..()
	if(is_component_functioning("power cell") && cell)
		if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
			. *= CYBORG_MOBILITY_MODULE_MODIFIER
		if(src.cell.charge <= 0)
			. += CYBORG_NO_CHARGE_SLOWDOWN
	else
		. += CYBORG_NO_CELL_SLOWDOWN
