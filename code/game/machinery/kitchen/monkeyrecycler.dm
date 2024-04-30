/obj/machinery/monkey_recycler
	name = "\improper Animal Recycler"
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
		desc = "A machine used for recycling animals into animal cubes."

/obj/machinery/monkey_recycler/attackby(var/obj/item/O, var/mob/user)
	if(..())
		return 1
	process_monkey(O, user)

/obj/machinery/monkey_recycler/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	return process_monkey(AM)

/obj/machinery/monkey_recycler/emag_act(mob/user)
	. = ..()
	emagged = 1

/obj/machinery/monkey_recycler/proc/process_monkey(var/obj/item/O, var/mob/user)
	var/mob/living/target = O
	var/failmsg
	if(istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		target = G.affecting
	else if(istype(O, /obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = O
		target = H.stored_mob
	if(istype(target))
		if((target.key || target.ckey) && !emagged)
			failmsg = "\the [target] is too sapient for \the [src]."
		else if(target.stat == CONSCIOUS && !can_recycle_live)
			failmsg = "\the [target] is struggling far too much to put it in \the [src]."
		else if(target.abiotic(1))
			failmsg = "\the [target] may not have abiotic items on in \the [src]."
		else
			if(user) // necessary line, or else the holder or grab could be spammed to abuse this for more monkey cubes
				user.drop_item(O,force_drop = 1)
			var/ourtype = target.type
			if(target.key && emagged)
				for(var/datum/body_archive/archive in body_archives)
					if(archive && archive.key == target.key)
						ref_body_archives.Add(archive)
			qdel(target)
			if(user)
				to_chat(user, "<span class='notice'>You stuff \the [target] in the machine.</span>")
			playsound(src, 'sound/machines/juicer.ogg', 50, 1)
			use_power(500)
			src.grinded[ourtype]++
			if(user)
				to_chat(user, "<span class='notice'>\the [src] now has [grinded[ourtype]] animals worth of material of this type stored.</span>")
			else
				visible_message("<span class='notice'>\the [src] now has [grinded[ourtype]] animals worth of material of this type stored.</span>")
			return TRUE
	else
		failmsg = "\the [src] only accepts animals!"
	if(failmsg)
		failmsg = "<span class='warning'>[failmsg]</span>"
		if(user)
			to_chat(user, failmsg)
	return FALSE

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
				if(BA && BA.mob_type == pickedtype)
					var/mob/living/temp_M = new pickedtype
					var/mob/living/M = temp_M.actually_reset_body(archive = BA, our_mind = get_mind_by_key(BA.key))
					M.forceMove(MW)
					MW.contained_mob = M
					MW.name = "[M] cube"
					ref_body_archives.Remove(BA)
					qdel(temp_M)
					break
		else
			var/mob/living/MW_mob = pickedtype
			MW.contained_mob = pickedtype
			MW.name = "[initial(MW_mob.name)] cube"
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
