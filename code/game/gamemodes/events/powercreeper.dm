#define POWER_PER_FRUIT 500
#define MIN_SPREAD_CHANCE 15
#define MAX_SPREAD_CHANCE 40
#define ATTACK_CHANCE 35
#define LEAVES_CHANCE 20

#define CANGROW 2
#define CANZAP 4

//the actual powercreeper obj
/obj/structure/cable/powercreeper
	name = "powercreeper"
	desc = "A strange alien fruit that passively generates electricity. Best not to touch it."
	icon = 'icons/obj/structures/powercreeper.dmi'
	icon_state = "neutral"
	level = LEVEL_ABOVE_FLOOR
	plane = ABOVE_TURF_PLANE
	pass_flags = PASSTABLE | PASSGRILLE | PASSGIRDER | PASSMACHINE
	slowdown_modifier = 2
	autoignition_temperature = AUTOIGNITION_PAPER
	var/add_state = "_bare"
	var/grown = 0
	var/growdirs = 0
	var/zapdirs = 0

/obj/structure/cable/powercreeper/New(loc, growdir, packet_override)
	//did we get created by a packet?
	var/anim_length = 0
	if(packet_override)
		flick("creation_packet", src)
		anim_length = 39
		add_state = ""
	else
		//are we growing from another powercreeper?
		if(growdir)
			if(prob(LEAVES_CHANCE))
				add_state = ""
			icon_state = initial(icon_state) + add_state
			dir = growdir
			flick("growing[add_state]", src)
			anim_length = 18
		else
			//we just kinda spawned i guess
			flick("creation", src)
			add_state = ""
			anim_length = 20
	spawn(anim_length)
		grown = 1

	//basic cable stuff, this gets done in the cable stack logic, so i needed to copy paste it over, oh well
	var/datum/powernet/PN = getFromPool(/datum/powernet)
	PN.add_cable(src)
	for(var/dir in cardinal)
		mergeConnectedNetworks(dir)   //Merge the powernet with adjacents powernets
	mergeConnectedNetworksOnTurf() //Merge the powernet with on turf powernets
	getViableNeighbours()
	updateNeighbours()
	. = ..()
	//we are processing
	processing_objects.Add(src)
	set_light(1, 15, LIGHT_COLOR_RED)

/obj/structure/cable/powercreeper/Destroy()
	processing_objects.Remove(src)
	updateNeighbours(TRUE)
	..()

/obj/structure/cable/powercreeper/process()
	if(gcDestroyed)
		return

	//check if our tile is burning, if so die
	if(on_fire || loc.on_fire)
		die()
		return

	//we only want to interact with stuff as soon as our growing animation finishes
	if(grown)
		var/datum/gas_mixture/environment
		if(isturf(loc))
			var/turf/T = loc
			environment = T.return_air()
		//add power to powernet through converting atmospheric heat to power
		add_avail(-(environment.add_thermal_energy(max(environment.get_thermal_energy_change(T0C),-POWER_PER_FRUIT*10)/10)))
		if(growdirs)
			var/grow_chance = Clamp(MIN_SPREAD_CHANCE + (powernet.avail/1000), MIN_SPREAD_CHANCE, MAX_SPREAD_CHANCE)
			if(prob(grow_chance))
				var/chosen_dir = pick(cardinal)
				if(growdirs & chosen_dir)
					var/turf/target_turf = get_step(src, chosen_dir)
					if(isViableGrow(target_turf) & CANGROW)
						new /obj/structure/cable/powercreeper(target_turf, get_dir(src, target_turf))
					growdirs &= ~chosen_dir

		if(zapdirs && prob(ATTACK_CHANCE))
			for(var/chosen_dir in cardinal)
				if(zapdirs & chosen_dir)
					var/turf/T = get_step(src, chosen_dir)
					try_electrocution_turf(T, chosen_dir)

/obj/structure/cable/powercreeper/Crossed(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	.=..()
	if(isliving(mover))
		try_electrocution(mover)

/obj/structure/cable/powercreeper/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover, /obj/item/projectile/ion))
		return 0
	return ..()

/obj/structure/cable/powercreeper/update_icon()
	return

/obj/structure/cable/powercreeper/hide(i)
	return

/obj/structure/cable/powercreeper/emp_act(severity)
	die()

/obj/structure/cable/powercreeper/proc/die()
	grown = 0 //we can't attack or spread anymore
	do_flick(src, "death[add_state]", 13)
	qdel(src)

/obj/structure/cable/powercreeper/proc/try_electrocution_turf(var/turf/T, var/checkdir)
	var/success = 0
	flick("attacking[add_state]",src)
	for(var/mob/living/M in T)
		success = 1
		try_electrocution(M)
	if(!success)
		zapdirs &= ~checkdir
		return 0

/obj/structure/cable/powercreeper/proc/try_electrocution(var/mob/living/M)
	if(!istype(M) || M.isDead())
		return 0
	Beam(M, "lighting", 'icons/obj/zap.dmi', 5, 2)
	playsound(src,'sound/weapons/electriczap.ogg',50, 1) //we still want a sound
	return electrocute_mob(M, powernet, src)

/obj/structure/cable/powercreeper/proc/getViableNeighbours()
	for(var/dir in cardinal)
		var/turf/T = get_step(src, dir)
		var/result = isViableGrow(T)
		if(result & CANGROW)
			growdirs |= dir
		if(result & CANZAP)
			zapdirs |= dir

/obj/structure/cable/powercreeper/proc/isViableGrow(var/turf/T)
	if(!T.has_gravity())
		return CANZAP
	if(!T.Adjacent(src))
		return 0
	var/obj/structure/cable/powercreeper/PC = locate(/obj/structure/cable/powercreeper) in T
	if(PC && PC != src)
		return CANZAP
	if(T.density == 1)
		return 0
	if(T.has_dense_content())
		return CANZAP
	return CANGROW|CANZAP


/obj/structure/cable/powercreeper/proc/updateNeighbours(var/dying = FALSE)
	for(var/dir in cardinal)
		var/turf/T = get_step(src, dir)
		var/obj/structure/cable/powercreeper/P = locate() in T
		if(P)
			if(dying)
				P.growdirs |= get_dir(P, src)
			else
				P.growdirs &= ~get_dir(P, src)
		if(dying)
			T.on_density_change.Remove(src)
		else
			T.on_density_change.Add(src, "proxDensityChange")

/obj/structure/cable/powercreeper/proc/proxDensityChange(var/list/args)
	var/turf/T = args["atom"]
	if(get_dist(T, src) <= 1)
		var/Adir = get_dir(src, T)
		if(Adir in cardinal)
			var/result = isViableGrow(T)
			if(result & CANGROW)
				growdirs |= Adir
			if(result & CANZAP)
				zapdirs |= Adir
			if(!result)
				growdirs &= ~Adir
				zapdirs &= ~Adir

/obj/structure/cable/powercreeper/get_connections(powernetless_only = 0)
	. = list()
	var/turf/T

	for(var/dir in cardinal) //only connects to cardinal directions
		T = get_step(src, dir)
		if(T)
			. += power_list(T, src, turn(dir, 180), powernetless_only)

obj/structure/cable/powercreeper/mergeConnectedNetworks(var/direction)
	var/turf/TB = get_step(src, direction)

	for(var/obj/structure/cable/C in TB)
		if(!C)
			continue
		if(src == C)
			continue
		if(!C.powernet) // if the matching cable somehow got no powernet, make him one (should not happen for cables)
			var/datum/powernet/newPN = getFromPool(/datum/powernet/)
			newPN.add_cable(C)
		if(powernet) // if we already have a powernet, then merge the two powernets
			merge_powernets(powernet,C.powernet)
		else
			C.powernet.add_cable(src) // else, we simply connect to the matching cable powernet


/obj/structure/cable/powercreeper/hasDir(var/dir)
	return (dir in cardinal)

/obj/structure/cable/powercreeper/attackby(obj/item/W, mob/user)
	if(W.is_hot())
		to_chat(user, "<span class='warning'>You burn away \the [src]")
		visible_message("[user] burns away \the [src]", "You hear some burning")
		die()
	else if(!try_electrocution(user)) //cut it away, also try to shock the user
		if(W.is_sharp())
			to_chat(user, "<span class='warning'>You cut away \the [src]")
			visible_message("[user] cuts away \the [src]", "You hear a cutting sound")
			die()

#undef POWER_PER_FRUIT
#undef MIN_SPREAD_CHANCE
#undef MAX_SPREAD_CHANCE
#undef ATTACK_CHANCE