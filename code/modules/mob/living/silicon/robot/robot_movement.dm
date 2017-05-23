/mob/living/silicon/robot/Process_Spacemove(var/check_drift = 0)
	if(module)
		for(var/obj/item/weapon/tank/jetpack/J in module.modules)
			if(J && istype(J, /obj/item/weapon/tank/jetpack))
				if(((!check_drift) || (check_drift && J.stabilization_on)) && (J.allow_thrust(0.01, src)))
					inertia_dir = 0
					return 1
				if((!check_drift && J.allow_thrust(0.01)))
					return 1
	if(..())
		return 1
	return 0

 //No longer needed, but I'll leave it here incase we plan to re-use it.
/mob/living/silicon/robot/movement_tally_multiplier()
	. = ..()
	if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
		. *= 0.75

/mob/living/silicon/robot/Move(atom/newloc)
	if(..())
		if(istype(newloc, /turf/unsimulated/floor/asteroid) && istype(module, /obj/item/weapon/robot_module/miner))
			var/obj/item/weapon/storage/bag/ore/ore_bag = locate(/obj/item/weapon/storage/bag/ore) in get_all_slots() //find it in our modules
			if(ore_bag)
				for(var/obj/item/weapon/ore/ore in newloc.contents)
					ore_bag.preattack(newloc, src, 1) //collects everything
					break
