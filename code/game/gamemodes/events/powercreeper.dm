#define POWER_PER_FRUIT 500
#define MIN_SPREAD_CHANCE 15
#define MAX_SPREAD_CHANCE 40
#define ATTACK_CHANCE 35

//the actual powercreeper obj
/obj/structure/cable/powercreeper
	name = "powercreeper"
	desc = "A strange alien fruit that passively generates electricity. Best not to touch it."
	icon = 'icons/obj/structures/powercreeper.dmi'
	icon_state = "neutral"
	level = LEVEL_ABOVE_FLOOR
	plane = ABOVE_HUMAN_PLANE
	pass_flags = PASSTABLE | PASSGRILLE | PASSGIRDER | PASSMACHINE
	slowdown_modifier = 2
	autoignition_temperature = AUTOIGNITION_PAPER
	var/grown = 0

/obj/structure/cable/powercreeper/New(loc, growdir, packet_override)
	//did we get created by a packet?
	if(packet_override)
		flick("creation_packet", src)
	else
		//are we growing from another powercreeper?
		if(growdir)
			dir = growdir
			flick("growing", src)
		else
			//we just kinda spawned i guess
			flick("creation", src)
	spawn(3 SECONDS) //should be enough for our animation to finish
		grown = 1

	//basic cable stuff, this gets done in the cable stack logic, so i needed to copy paste it over, oh well
	var/datum/powernet/PN = getFromPool(/datum/powernet)
	PN.add_cable(src)
	for(var/dir in cardinal)
		mergeConnectedNetworks(dir)   //Merge the powernet with adjacents powernets
	mergeConnectedNetworksOnTurf() //Merge the powernet with on turf powernets

	//we are processing
	processing_objects += src

	. = ..()

/obj/structure/cable/powercreeper/Destroy()
	//no longer processing
	processing_objects -= src

	..()

/obj/structure/cable/powercreeper/process()
	if(!gcDestroyed)
		return

	//check if our tile is burning, if so die
	if(on_fire || loc.on_fire)
		die()
		return

	//we only want to interact with stuff as soon as our growing animation finishes
	if(grown)
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
					new /obj/structure/cable/powercreeper(get_turf(target_turf), get_dir(src, target_turf))

		//if there is a person caught in the vines, burn em a bit
		//electrocute people who aren't insulated
		if(prob(ATTACK_CHANCE))
			flick("attacking",src)
			for(var/mob/living/M in range(1, get_turf(src)))
				try_electrocution(M)

/obj/structure/cable/powercreeper/update_icon()
	return

/obj/structure/cable/powercreeper/hide(i)
	return

/obj/structure/cable/powercreeper/emp_act(severity)
	die()

/obj/structure/cable/powercreeper/proc/die()
	//maybe some animation here later on idunno TODO
	qdel(src)

/obj/structure/cable/powercreeper/proc/try_electrocution(var/mob/living/M)
	if(!istype(M))
		return 0
	if(!electrocute_mob(M, powernet, src))
		M.apply_damage((powernet.avail / 3000), BURN) //one burn damage per 6 plants (keep in mind, this will also take the power from any connected powernet)
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
		die()
	else if(W.is_sharp()) //cut it away, also try to shock the user
		if(!try_electrocution(user))
			to_chat(user, "<span class='warning'>You cut away \the [src]")
			visible_message("[user] cuts away \the [src]", "You hear a cutting sound")
			die()

#undef POWER_PER_FRUIT
#undef MIN_SPREAD_CHANCE
#undef MAX_SPREAD_CHANCE
#undef ATTACK_CHANCE