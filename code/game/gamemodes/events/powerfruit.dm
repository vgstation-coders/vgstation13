//the actual powerfruit obj

/obj/effect/powerfruit
	name = "powerfruit"
	desc = "A strange alien fruit somehow creating power. How curious!"
	anchored = 1
	opacity = 0
	density = 0
	icon = 'icons/obj/lighting.dmi' //TODO
	icon_state = "glowshroomf" //TODO
	layer = BELOW_TABLE_LAYER
	var/datum/powerfruit_hive/hive = null

/obj/effect/powerfruit/proc/spread()
	var/list/neighbours = somehow find the neighbouring turfs

	for(var/turf/T in neighbours)
		if(istype(location, /turf/simulated/floor))
			var/turf/simulated/floor/F = location
			if(isnull(locate(/obj/effect/powerfruit) in F))
			 	//create new powerfruit per hive
				return 1 //spread successful
	return 0 //spread failed

/obj/effect/powerfruit/proc/findWire()
	//obj/structure/cable/

//the powerfruit hivemind datum, handling all the connected powerfruit
