/obj/procedural_generator
	name = "procedural generator"
	var/pooled = 0

/obj/procedural_generator/proc/deploy_generator(var/turf/T)
	return

/obj/procedural_generator/New(var/mapspawned = 1)
	..()
	if(mapspawned)
		deploy_generator(get_turf(src))
		if(pooled)
			returnToPool(src)
		else
			qdel(src)