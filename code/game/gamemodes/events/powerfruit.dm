//the actual powerfruit obj
#define POWER_PER_FRUIT 500
#define SPREAD_CHANCE 15
#define ATTACK_CHANCE 15

/obj/structure/cable/powerfruit
	name = "powerfruit"
	desc = "A strange alien fruit that passively generates electricity. Best not to touch it."
	icon = 'icons/obj/lighting.dmi' //TODO
	icon_state = "glowshroomf" //TODO
	level = LEVEL_ABOVE_FLOOR
	plane = ABOVE_HUMAN_PLANE
	pass_flags = PASSTABLE | PASSGRILLE | PASSGIRDER | PASSMACHINE

/obj/structure/cable/powerfruit/New(loc)
	var/datum/powernet/PN = getFromPool(/datum/powernet)
	PN.add_cable(src)

	for(var/dir in cardinal)
		mergeConnectedNetworks(dir)   //Merge the powernet with adjacents powernets
	mergeConnectedNetworksOnTurf() //Merge the powernet with on turf powernets

	processing_objects += src
	. = ..()

/obj/structure/cable/powerfruit/Destroy()
	processing_objects -= src
	..()

/obj/structure/cable/powerfruit/process()
	//add power to powernet
	add_avail(POWER_PER_FRUIT)

	//spread - copypasta from spreading_growth.dm
	if(prob(SPREAD_CHANCE))
		var/list/neighbors = getViableNeighbours()
		sleep(rand(3,5))
		if(!(gcDestroyed || !neighbors.len))
			var/turf/target_turf = pick(neighbors)
			var/obj/structure/cable/powerfruit/child = new(get_turf(src))
			neighbors -= target_turf
			spawn(1) // This should do a little bit of animation.
				child.forceMove(target_turf)

	//if there is a person caught in the vines, burn em a bit
	//electrocute people who aren't insulated
	for(var/mob/living/M in range(1, get_turf(src)))
		if(prob(ATTACK_CHANCE))
			if(!electrocute_mob(M, powernet, src))
				M.apply_damage(10, BURN)

/obj/structure/cable/powerfruit/update_icon()
	return

/obj/structure/cable/powerfruit/hide(i)
	return

/obj/structure/cable/powerfruit/proc/getViableNeighbours()
	. = list()
	var/turf/T
	for(var/dir in cardinal)
		T = get_step(src, dir)
		if(locate(/obj/structure/cable/powerfruit) in T)
			continue
		if(istype(T, /turf/simulated/wall))
			continue
	
		. += T

/obj/structure/cable/powerfruit/get_connections(powernetless_only = 0)
	. = list()
	var/turf/T

	for(var/dir in cardinal) //only connects to cardinal directions
		T = get_step(src, dir)
		if(T)
			. += power_list(T, src, turn(dir, 180), powernetless_only)

/obj/structure/cable/powerfruit/hasDir(var/dir)
	return (dir in cardinal)

/obj/structure/cable/powerfruit/attackby(obj/item/W, mob/user)
	. = ..()
	if(W.is_hot())
		to_chat(user, "<span class='warning'>You burn away \the [src]")
		visible_message("[user] burns away \the [src]", "You hear some burning")
		qdel(src)

#undef POWER_PER_FRUIT
#undef SPREAD_CHANCE
#undef MAX_SPREAD