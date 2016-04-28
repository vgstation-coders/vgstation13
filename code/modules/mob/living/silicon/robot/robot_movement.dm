/mob/living/silicon/robot/Process_Spacemove()
	if(module)
		for(var/obj/item/weapon/tank/jetpack/J in module.modules)
			if(J && istype(J, /obj/item/weapon/tank/jetpack))
				if(J.allow_thrust(0.01))	return 1
	if(..())	return 1
	return 0

 //No longer needed, but I'll leave it here incase we plan to re-use it.
mob/living/silicon/robot/movement_delay()

	var/tally = 0

	if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
		tally -= 2 // JESUS FUCKING CHRIST WHY

	for(var/obj/item/borg/upgrade/vtec/V in contents)
		if(V && istype(V, /obj/item/borg/upgrade/vtec))
			tally -= 4

	if(istype(loc,/turf/simulated/floor))
		var/turf/simulated/floor/T = loc
		if(T.material=="phazon")
			tally -= 2 // Phazon floors make us go fast

	if(modtype == "Standard")
		tally -= 0
	if(modtype == "Service")
		tally -= 0
	if(modtype == "Miner")
		tally -= 0
	if(modtype == "Medical")
		tally -= 2
	if(modtype == "Security")
		tally -= 1
	if(modtype == "Engineering")
		tally -= 1
	if(modtype == "Janitor")
		tally -= 0
	if(modtype == "Combat")
		tally -= 4
	if(modtype == "Sanic")
		tally -= 8
	speed = tally

	return tally+config.robot_delay

/mob/living/silicon/robot/Move(atom/newloc)
	if(..())
		if(istype(newloc, /turf/unsimulated/floor/asteroid) && istype(module, /obj/item/weapon/robot_module/miner))
			var/obj/item/weapon/storage/bag/ore/ore_bag = locate(/obj/item/weapon/storage/bag/ore) in get_all_slots() //find it in our modules
			if(ore_bag)
				for(var/obj/item/weapon/ore/ore in newloc.contents)
					ore_bag.preattack(newloc, src, 1) //collects everything
					break
