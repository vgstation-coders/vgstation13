/obj/machinery/monkey_recycler
	name = "Monkey Recycler"
	desc = "A machine used for recycling dead monkeys into monkey cubes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = 1
	anchored = 1
	use_power = 1
	ghost_read = 0
	idle_power_usage = 5
	active_power_usage = 50
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	var/grinded = 0
	var/minimum_monkeys = 3 //How many do we need to grind?
	var/can_recycle_live = FALSE //Can we recycle a live monkey?

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
	minimum_monkeys = max(1,4 - (manipcount/2)) //Tier 1 = 3, Tier 2 = 2, Tier 3 = 1
	if(lasercount >= 3)
		can_recycle_live = TRUE

/obj/machinery/monkey_recycler/attackby(var/obj/item/O, var/mob/user)
	if(..())
		return 1
	process_monkey(O, user)

/obj/machinery/monkey_recycler/proc/process_monkey(var/obj/item/O, var/mob/user)
	if(istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		var/grabbed = G.affecting
		if(ismonkey(grabbed))
			var/mob/living/carbon/monkey/target = grabbed
			if(target.stat == CONSCIOUS && !can_recycle_live)
				to_chat(user, "<span class='warning'>The monkey is struggling far too much to put it in the recycler.</span>")
				return
			if(target.abiotic())
				to_chat(user, "<span class='warning'>The monkey may not have abiotic items on.</span>")
				return
			else
				user.drop_item(G, force_drop = 1)
				qdel(target)
				target = null
				to_chat(user, "<span class='notice'>You stuff the monkey in the machine.")
				playsound(src, 'sound/machines/juicer.ogg', 50, 1)
				use_power(500)
				src.grinded++
				to_chat(user, "<span class='notice'>The machine now has [grinded] monkeys worth of material stored.</span>")
		else
			to_chat(user, "<span class='warning'>The machine only accepts monkeys!</span>")
	else if(ismonkey(O))
		var/mob/living/carbon/monkey/target = O
		if(target.stat == CONSCIOUS && !can_recycle_live)
			to_chat(user, "<span class='warning'>The monkey is struggling far too much to put it in the recycler.</span>")
			return
		if(target.abiotic())
			to_chat(user, "<span class='warning'>The monkey may not have abiotic items on.</span>")
			return
		else
			qdel(target)
			to_chat(user, "<span class='notice'>You stuff the monkey in the machine.</span>")
			playsound(src, 'sound/machines/juicer.ogg', 50, 1)
			use_power(500)
			src.grinded++
			to_chat(user, "<span class='notice'>The machine now has [grinded] monkeys worth of material stored.</span>")

/obj/machinery/monkey_recycler/attack_hand(var/mob/user as mob)
	if(..())
		return 1
	if(grinded >= minimum_monkeys)
		to_chat(user, "<span class='notice'>The machine hisses loudly as it condenses the grinded monkey meat. After a moment, it dispenses a brand new monkey cube.</span>")
		playsound(src, 'sound/machines/hiss.ogg', 50, 1)
		grinded -= minimum_monkeys
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped(src.loc)
		to_chat(user, "<span class='notice'>The machine's display flashes that it has [grinded] monkeys worth of material left.</span>")
	else
		to_chat(user, "<span class='warning'>The machine needs at least 3 monkeys worth of material to produce a monkey cube. It only has [grinded].</span>")
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
