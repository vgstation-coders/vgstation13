/obj/machinery/cell_charger
	name = "cell charger"
	desc = "Charges power cells, drains power."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger0"
	icon_state_open = "ccharger_open"
	anchored = 1
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 10
	active_power_usage = 10 //Power is already drained to charge batteries
	power_channel = EQUIP
	var/obj/item/weapon/cell/charging = null
	var/transfer_rate = 1500 //How much power do we output every process tick ?
	var/transfer_efficiency = 0.7 //How much power ends up in the battery in percentage ?
	var/transfer_rate_coeff = 1 //What is the quality of the parts that transfer energy (capacitators) ?
	var/transfer_efficiency_bonus = 0 //What is the efficiency "bonus" (additive to percentage) from the parts used (scanning module) ?
	var/chargelevel = -1
	var/has_beeped = FALSE

	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | CROWDESTROY | EMAGGABLE

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/oneuse/emag
	)

/obj/machinery/cell_charger/get_cell()
	return charging

/obj/machinery/cell_charger/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/cell_charger,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor
	)
	RefreshParts()

/obj/machinery/cell_charger/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/SM in component_parts)
		T = (SM.rating - 1)*0.1 //There is one scanning module. Level 1 changes nothing (70 %), level 2 transfers 80 % of power, level 3 90 %
	transfer_efficiency_bonus = T
	T = 0
	for(var/obj/item/weapon/stock_parts/capacitor/CA in component_parts)
		T += CA.rating //Two capacitors, every upgrade rank acts as a direct multiplier (up to 3 times base for two Level 3 Capacitors)
	transfer_rate_coeff = T/2
	T = 0


/obj/machinery/cell_charger/proc/updateicon()
	icon_state = "ccharger[charging ? 1 : 0]"

	if(charging && !(stat & (BROKEN|NOPOWER|FORCEDISABLE)) )
		var/newlevel = 	round(charging.percent() * 4.0 / 99)
//		to_chat(world, "nl: [newlevel]")

		if(chargelevel != newlevel)
			overlays.len = 0
			overlays += image(icon = icon, icon_state = "ccharger-o[newlevel]")
			chargelevel = newlevel
	else
		overlays.len = 0

/obj/machinery/cell_charger/examine(mob/user)
	..()
	to_chat(user, "There's [charging ? "a" : "no"] cell in the charger.")
	if(charging)
		to_chat(user, "Current charge: [round(charging.percent() )]%")

/obj/machinery/cell_charger/attackby(obj/item/weapon/W, mob/user)
	if(stat & BROKEN)
		return

	if(..())
		return 1
	if(istype(W, /obj/item/weapon/cell) && anchored)
		if(charging)
			to_chat(user, "<span class='warning'>There is already a cell in [src].</span>")
			return
		else
			var/area/this_area = get_area(src)
			if(this_area.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				to_chat(user, "<span class='warning'>[src] blinks red as you try to insert the cell!</span>")
				return

			if(user.drop_item(W, src))
				charging = W
				has_beeped = FALSE
				user.visible_message("<span class='notice'>[user] inserts a cell into [src].</span>", "<span class='notice'>You insert a cell into [src].</span>")
				chargelevel = -1
		updateicon()

/obj/machinery/cell_charger/emag_act(mob/user)
	if(!emagged)
		emagged = 1 //Congratulations, you've done it
		user.visible_message("<span class='warning'>[user] swipes a card into \the [src]'s charging port.</span>", \
		"<span class='warning'>You hear fizzling coming from \the [src] and a wire turns red hot as you swipe the electromagnetic card. Better not use it anymore.</span>")

/obj/machinery/cell_charger/emag_ai(mob/living/silicon/ai/A)
	if(!emagged)
		emagged = 1
		to_chat(A, "<span class='warning'>You short out the [src].</span>")

/obj/machinery/cell_charger/attack_robot(mob/user as mob)
	if(isMoMMI(user) && Adjacent(user)) //To be able to remove cells from the charger
		return attack_hand(user)

/obj/machinery/cell_charger/attack_hand(mob/user)
	if(charging)
		if(emagged)
			spark(src, 5)
			spawn(15)
				explosion(src.loc, -1, 1, 3, adminlog = 0, whodunnit = user) //Overload
				qdel(src) //It exploded, rip
			return
		usr.put_in_hands(charging)
		charging.add_fingerprint(user)
		charging.updateicon()
		src.charging = null
		user.visible_message("<span class='notice'>[user] removes the cell from [src].</span>", "<span class='notice'>You remove the cell from [src].</span>")
		chargelevel = -1
		updateicon()

/obj/machinery/cell_charger/wrenchAnchor(var/mob/user, var/obj/item/I)
	if(charging)
		to_chat(user, "<span class='warning'>Remove the cell first!</span>")
		return FALSE
	. = ..()

/obj/machinery/cell_charger/emp_act(severity)
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		return
	if(charging)
		charging.emp_act(severity)
	..(severity)


/obj/machinery/cell_charger/process()
//	to_chat(world, "ccpt [charging] [stat]")
	if(!charging || (stat & (BROKEN|NOPOWER|FORCEDISABLE)) || !anchored)
		return

	if(charging.give(transfer_rate*transfer_rate_coeff * (transfer_efficiency+transfer_efficiency_bonus) * (emagged ? 0.25 : 1)))//Inefficiency (Joule effect + other shenanigans)  //Lose most of it if emagged
		use_power(transfer_rate * transfer_rate_coeff * (emagged ? 10 : 1))  //Drain all the power if emagged
		if(has_beeped) //It's charging again
			has_beeped = FALSE
	if(round(charging.percent() >= 100)&&!has_beeped)
		playsound(src, 'sound/machines/charge_finish.ogg', 50)
		has_beeped = TRUE

	updateicon()

//Emergency Charger
//craftable by combining an APC frame, metal rod, cables, and wirecutter
/datum/construction/reversible/crank_charger
	result = /obj/item/device/crank_charger
	steps = list(
					//1
					list(Co_DESC="The cabling is messily strewn throughout.",
						Co_NEXTSTEP = list(Co_KEY=/obj/item/tool/screwdriver,
							Co_START_MSG = "{USER} begin{s} adjusting the wiring in {HOLDER}...",
							Co_VIS_MSG = "{USER} adjust{s} the wiring in {HOLDER}.",
							Co_DELAY = 50),
						Co_BACKSTEP = list(Co_KEY=/obj/item/tool/wirecutters,
					 		Co_VIS_MSG = "{USER} remove{s} the cables from {HOLDER}.")
						),
					//2
					list(Co_DESC="The metal rod is attached.",
						Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/cable_coil,
							Co_VIS_MSG = "{USER} add{s} the cables to {HOLDER}.",
							Co_AMOUNT = 5),
						Co_BACKSTEP = list(Co_KEY=/obj/item/tool/weldingtool,
					 		Co_VIS_MSG = "{USER} remove{s} the rod from {HOLDER}.",
							Co_AMOUNT = 3,
					 		Co_START_MSG = "{USER} begin{s} slicing through {HOLDER}'s metal rod...",
					 		Co_DELAY = 30)
						),
					//3
					list(Co_DESC="The frame is ready to use.",
						Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/rods,
							Co_VIS_MSG = "{USER} add{s} the rod onto {HOLDER}.",
							Co_AMOUNT = 1)
						)
					)
/datum/construction/reversible/crank_charger/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/reversible/crank_charger/spawn_result(mob/user as mob)
	if(result)
//		testing("[user] finished a [result]!")

		new result(get_turf(holder))

		QDEL_NULL (holder)

	feedback_inc("crank_charger_created",1)

/obj/item/device/crank_charger
	name = "crank charger"
	desc = "A device which employs mechanical energy (i.e.: spinning the crank) to restore electrical energy to a power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "crankcharger"
	flags = FPRINT
	siemens_coefficient = 1
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_SILICON
	origin_tech = Tc_POWERSTORAGE + "=2"
	var/obj/item/weapon/cell/stored = null
	var/state = 0 //0 if up, 1 if down; only used for icons
	var/removablecell = TRUE

/obj/item/device/crank_charger/get_cell()
	return stored

/obj/item/device/crank_charger/update_icon()
	if(stored)
		icon_state = "crankcharger[state ? "-1" : "-0"]"
	else
		icon_state = "crankcharger"

/obj/item/device/crank_charger/examine(mob/user)
	..()
	if(stored)
		to_chat(user,"<span class='info'>The readout displays: [round(stored.charge/stored.maxcharge*100)]%.</span>")
	else
		to_chat(user,"<span class='info'>There is no cell loaded.</span>")

/obj/item/device/crank_charger/attackby(obj/item/W, mob/user)
	if(!stored && istype(W,/obj/item/weapon/cell) && user.drop_item(W,src))
		stored = W
		update_icon()
	else
		..()

/obj/item/device/crank_charger/attack_self(mob/user)
	var/mob/living/L = user
	if(stored)
		if(stored.charge<stored.maxcharge)
			L.delayNextAttack(1)
			stored.charge += 100 * L.get_strength()
			state = !state
			update_icon()
			stored.updateicon()
			playsound(src, 'sound/items/crank.ogg',50,1)
			if(stored.charge>stored.maxcharge)
				stored.charge = stored.maxcharge
	else
		to_chat(L,"<span class='warning'>There is no cell loaded!</span>")

/obj/item/device/crank_charger/attack_hand(mob/user)
	if(stored && removablecell && user.get_inactive_hand() == src)
		stored.updateicon()
		user.put_in_hands(stored)
		stored = null
		update_icon()
	else
		..()

/obj/item/device/crank_charger/Destroy()
	if(stored)
		QDEL_NULL(stored)
	..()

/obj/item/device/crank_charger/generous
	name = "generous crank"
	desc = "Uses reverse-engineered ninja power glove technology to transfer energy wirelessly at short range into objects that can be recharged."
	icon_state = "crankcharger-0"
	removablecell = FALSE
	var/list/forbidden_targets = list(/obj/item/weapon/gun)
	var/last_charged

/obj/item/device/crank_charger/generous/New()
	..()
	processing_objects += src
	stored = new /obj/item/weapon/cell/empty(src)

/obj/item/device/crank_charger/generous/Destroy()
	processing_objects -= src
	..()

/obj/item/device/crank_charger/generous/attack_self(mob/user)
	..()
	last_charged = world.time

/obj/item/device/crank_charger/generous/afterattack(var/atom/target, var/mob/user)
	..()
	if(is_type_in_list(target,forbidden_targets))
		to_chat(user,"<span class='warning'>The generous crank isn't compatible with that.</span>")
		return
	var/obj/item/weapon/cell/C = target.get_cell()
	if(istype(C))
		if(!stored.charge)
			to_chat(user,"<span class='warning'>The loaded cell has no charge.</span>")
			return
		var/transfer = min(C.maxcharge - C.charge,stored.charge)
		if(!transfer) //since we already ruled out no charge here, if min() = 0 that means the diff is 0
			to_chat(user,"<span class='good'>That already has full charge!</span>")
			return
		playsound(src, pick(lightning_sound), 25, 1, "vary" = 0)
		stored.use(transfer)
		C.give(transfer)

/obj/item/device/crank_charger/generous/process()
	if(stored && world.time > last_charged + 4 SECONDS) //After 2 ticks, start draining
		stored.use(100) //remove a single crank per tick
