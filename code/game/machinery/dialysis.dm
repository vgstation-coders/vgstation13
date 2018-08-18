/obj/machinery/dialysis
	name = "dialysis machine"
	desc = "A machine used to purge reagents from the blood. Simply connect a person to it, turn it on, and wait for the ping."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "rand_machine_1"
	idle_power_usage = 150
	active_power_usage = 450
	anchored = 1
	density = 1
	var/list/connections = list()
	var/max_connections = 1
	var/reagent_removal_rate = 5

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE

/obj/machinery/dialysis/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/dialysis,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/dialysis/RefreshParts()
	var/lasercount = 1
	var/manipcount = 1
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser))
			lasercount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			manipcount += SP.rating-1
	max_connections = initial(max_connections) * manipcount
	reagent_removal_rate = initial(reagent_removal_rate) * lasercount

/obj/machinery/dialysis/Destroy()
	connections.Cut()
	..()

/obj/machinery/dialysis/MouseDropFrom(over_object, src_location, over_location)
	if(usr.incapacitated())
		return ..()
	if(isanimal(usr))
		return ..()
	if(!usr.Adjacent(src))
		return ..()

	if(connections.Remove(over_object))
		visible_message("[over_object] is detached from \the [src]")
		return

	if(ismob(over_object) && Adjacent(over_object))
		if(ishuman(over_object))
			var/mob/living/carbon/human/H = over_object
			if(H.species && (H.species.chem_flags & NO_INJECT))
				H.visible_message("<span class='warning'>[usr] struggles to place the IV into [H] but fails.</span>","<span class='notice'>[usr] tries to place the IV into your arm but is unable to.</span>")
				return

		if(connections.len >= max_connections)
			to_chat(usr, "<span class = 'notice'>\The [src] has too many connections. Disconnect something.</span>")
			return
		visible_message("[usr] attaches \the [src] to \the [over_object].")
		connections.Add(over_object)

/obj/machinery/dialysis/process()
	if(connections.len)
		use_power = 2
	else
		use_power = 1
		return
	for(var/mob/M in connections)
		if(!Adjacent(M) || !isturf(M.loc))
			to_chat(M, "<span class = 'warning'>You disconnect from \the [src]</span>")
			connections.Remove(M)
			continue
		if(!M.reagents.remove_any(reagent_removal_rate))
			if(prob(35))
				visible_message("<span class = 'warning'>\The [src] beeps loudly!</span>")
				playsound(src, 'sound/machines/twobeep.ogg', 100, 1)
			continue
		M.AdjustDizzy(5*reagent_removal_rate)
		M.nutrition = max(M.nutrition-10, 0)