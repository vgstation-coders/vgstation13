#define POWER_PER_FRUIT 500
#define MIN_SPREAD_CHANCE 15
#define MAX_SPREAD_CHANCE 50
#define ATTACK_CHANCE 35

//the actual powercreeper obj
/obj/structure/cable/powercreeper
	name = "powercreeper"
	desc = "A strange alien fruit that passively generates electricity. Best not to touch it."
	icon = 'icons/obj/lighting.dmi' //TODO
	icon_state = "glowshroomf" //TODO
	level = LEVEL_ABOVE_FLOOR
	plane = ABOVE_HUMAN_PLANE
	pass_flags = PASSTABLE | PASSGRILLE | PASSGIRDER | PASSMACHINE

/obj/structure/cable/powercreeper/New(loc)
	var/datum/powernet/PN = getFromPool(/datum/powernet)
	PN.add_cable(src)

	for(var/dir in cardinal)
		mergeConnectedNetworks(dir)   //Merge the powernet with adjacents powernets
	mergeConnectedNetworksOnTurf() //Merge the powernet with on turf powernets

	processing_objects += src
	. = ..()

/obj/structure/cable/powercreeper/Destroy()
	processing_objects -= src
	..()

/obj/structure/cable/powercreeper/process()
	//add power to powernet
	add_avail(POWER_PER_FRUIT)

	//spread - copypasta from spreading_growth.dm
	var/chance = MIN_SPREAD_CHANCE + (powernet.avail / 1000) //two powercreeper plants raise chance by 1
	chance = chance > MAX_SPREAD_CHANCE ? MAX_SPREAD_CHANCE : chance
	if(prob(chance))
		sleep(rand(3,5))
		if(!gcDestroyed)
			var/list/neighbours = getViableNeighbours()
			if(neighbours.len)
				var/turf/target_turf = pick(neighbours)
				var/obj/structure/cable/powercreeper/child = new(get_turf(src))
				spawn(1) // This should do a little bit of animation.
					child.forceMove(target_turf)

	//if there is a person caught in the vines, burn em a bit
	//electrocute people who aren't insulated
	for(var/mob/living/M in range(1, get_turf(src)))
		if(prob(ATTACK_CHANCE))
			try_electrocution(M)

/obj/structure/cable/powercreeper/update_icon()
	return

/obj/structure/cable/powercreeper/hide(i)
	return

/obj/structure/cable/powercreeper/proc/try_electrocution(var/mob/living/M)
	if(!istype(M))
		return 0
	if(!electrocute_mob(M, powernet, src))
		M.apply_damage(10, BURN)
		return 0
	return 1

/obj/structure/cable/powercreeper/proc/getViableNeighbours()
	. = list()
	var/turf/T
	for(var/dir in cardinal)
		T = get_step(src, dir)
		if(locate(/obj/structure/cable/powercreeper) in T)
			continue
		if((T.density == 1) || T.has_dense_content())
			continue
	
		. += T

/obj/structure/cable/powercreeper/get_connections(powernetless_only = 0)
	. = list()
	var/turf/T

	for(var/dir in cardinal) //only connects to cardinal directions
		T = get_step(src, dir)
		if(T)
			. += power_list(T, src, turn(dir, 180), powernetless_only)

/obj/structure/cable/powercreeper/hasDir(var/dir)
	return (dir in cardinal)

/obj/structure/cable/powercreeper/attackby(obj/item/W, mob/user)
	. = ..()
	if(W.is_hot())
		to_chat(user, "<span class='warning'>You burn away \the [src]")
		visible_message("[user] burns away \the [src]", "You hear some burning")
		qdel(src)
	else if(W.is_sharp()) //cut it away, also try to shock the user
		if(!try_electrocution(user))
			to_chat(user, "<span class='warning'>You cut away \the [src]")
			visible_message("[user] cuts away \the [src]", "You hear a cutting sound")
			qdel(src)

#undef POWER_PER_FRUIT
#undef MIN_SPREAD_CHANCE
#undef MAX_SPREAD_CHANCE
#undef ATTACK_CHANCE