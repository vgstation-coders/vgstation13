/obj/machinery/monkey_recycler
	name = "Animal Recycler"
	desc = "A machine used for recycling dead animals into animal cubes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = 1
	anchored = 1
	use_power = MACHINE_POWER_USE_IDLE
	ghost_read = 0
	idle_power_usage = 5
	active_power_usage = 50
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EMAGGABLE
	var/minimum_animals = 3 //How many do we need to grind?
	var/list/grinded = list(/mob/living/carbon/monkey = 0) //How many of each type are grinded?
	var/can_recycle_live = FALSE //Can we recycle a live mob?
	var/list/datum/body_archive/ref_body_archives = list() //Body archives of all processed mobs

/obj/machinery/monkey_recycler/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/monkey_recycler,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser
	)

	RefreshParts()

/obj/machinery/monkey_recycler/RefreshParts()
	var/manipcount = 0
	var/lasercount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			manipcount += SP.rating
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser))
			lasercount += SP.rating
	minimum_animals = max(1,4 - (manipcount/2)) //Tier 1 = 3, Tier 2 = 2, Tier 3 = 1
	if(lasercount >= 3)
		can_recycle_live = TRUE

/obj/machinery/monkey_recycler/attackby(var/obj/item/O, var/mob/user)
	if(..())
		return 1
	process_monkey(O, user)

/obj/machinery/monkey_recycler/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if(isliving(AM))
		var/mob/living/target = AM
		if(target.stat == CONSCIOUS && !can_recycle_live)
			return FALSE
		if((target.key || target.ckey) && !emagged)
			return FALSE
		if(target.abiotic())
			return FALSE
		else
			var/ourtype = target.type
			for(var/datum/body_archive/archive in body_archives)
				if(archive.key == target.key)
					ref_body_archives.Add(archive)
			qdel(target)
			playsound(src, 'sound/machines/juicer.ogg', 50, 1)
			use_power(500)
			src.grinded[ourtype]++
			visible_message("<span class='notice'>The machine now has [grinded[ourtype]] worth of material stored for this animal.</span>")
			return TRUE
	return FALSE

/obj/machinery/monkey_recycler/proc/process_monkey(var/obj/item/O, var/mob/user)
	if(istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		var/grabbed = G.affecting
		if(isliving(grabbed))
			var/mob/living/target = grabbed
			if((target.key || target.ckey) && !emagged)
				to_chat(user, "<span class='warning'>\the [target] is too sapient for the recycler.</span>")
				return
			if(target.stat == CONSCIOUS && !can_recycle_live)
				to_chat(user, "<span class='warning'>\the [target] is struggling far too much to put it in the recycler.</span>")
				return
			if(target.abiotic())
				to_chat(user, "<span class='warning'>\the [target] may not have abiotic items on.</span>")
				return
			else
				user.drop_item(G, force_drop = 1)
				var/ourtype = target.type
				QDEL_NULL(target)
				to_chat(user, "<span class='notice'>You stuff \the [target] in the machine.")
				playsound(src, 'sound/machines/juicer.ogg', 50, 1)
				use_power(500)
				src.grinded[ourtype]++
				to_chat(user, "<span class='notice'>The machine now has [grinded[ourtype]] animals worth of material of this type stored.</span>")
		else
			to_chat(user, "<span class='warning'>The machine only accepts animals!</span>")
	else if(isliving(O))
		var/mob/living/target = O
		if((target.key || target.ckey) && !emagged)
			to_chat(user, "<span class='warning'>\the [target] is too sapient for the recycler.</span>")
			return
		if(target.stat == CONSCIOUS && !can_recycle_live)
			to_chat(user, "<span class='warning'>\the [target] is struggling far too much to put it in the recycler.</span>")
			return
		if(target.abiotic())
			to_chat(user, "<span class='warning'>\the [target] may not have abiotic items on.</span>")
			return
		else
			var/ourtype = target.type
			QDEL_NULL(target)
			to_chat(user, "<span class='notice'>You stuff \the [target] in the machine.</span>")
			playsound(src, 'sound/machines/juicer.ogg', 50, 1)
			use_power(500)
			src.grinded[ourtype]++
			to_chat(user, "<span class='notice'>The machine now has [grinded[ourtype]] animals worth of material of this type stored.</span>")

/obj/machinery/monkey_recycler/attack_hand(var/mob/user as mob)
	if(..())
		return 1
	var/list/enough_of_types = list()
	for(var/grindtype in grinded)
		if(grinded[grindtype] >= minimum_animals)
			enough_of_types += grindtype
			enough_of_types[grindtype] = grinded[grindtype]
	if(enough_of_types.len)
		var/pickedtype = pick(enough_of_types)
		to_chat(user, "<span class='notice'>The machine hisses loudly as it condenses the grinded animal meat. After a moment, it dispenses a brand new animal cube.</span>")
		playsound(src, 'sound/machines/hiss.ogg', 50, 1)
		grinded[pickedtype] -= minimum_animals
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/MW = new(src.loc)
		if(ref_body_archives.len)
			for(var/datum/body_archive/BA in ref_body_archives)
				if(BA.mob_type == pickedtype)
					var/mob/living/temp_M = new pickedtype
					var/mob/living/M = temp_M.actually_reset_body(archive = BA, our_mind = get_mind_by_key(BA.key))
					M.forceMove(MW)
					MW.contained_mob = M
					MW.name = "[MW] cube"
					ref_body_archives.Remove(BA)
					qdel(temp_M)
					break
		else
			var/mob/living/MW_mob = new pickedtype(MW)
			MW.contained_mob = MW_mob
			MW.name = "[MW_mob] cube"
		to_chat(user, "<span class='notice'>The machine's display flashes that it has [grinded[pickedtype]] animals worth of material of this type left.</span>")
	else
		to_chat(user, "<span class='warning'>The machine needs at least [minimum_animals] same type animal\s worth of material to produce an animal cube.</span>")
	return

/obj/machinery/monkey_recycler/MouseDropTo(atom/movable/O as mob|obj, mob/user as mob) //copypasted from sleepers
	if(!ismob(O))
		return
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc) || !user.Adjacent(O))
		return
	if(user.incapacitated() || user.lying)
		return
	if(O.anchored || !Adjacent(user) || !user.Adjacent(src) || user.contents.Find(src))
		return
	if(!ishigherbeing(user) && !isrobot(user))
		return
	add_fingerprint(user)
	process_monkey(O,user)
