/obj/machinery/cell_charger
	name = "cell charger"
	desc = "It charges power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 60
	power_channel = EQUIP
	circuit = /obj/item/circuitboard/machine/cell_charger
	var/obj/item/stock_parts/cell/charging = null
	var/chargelevel = -1
	var/charge_rate = 500

/obj/machinery/cell_charger/proc/updateicon()
	cut_overlays()
	if(charging)
		add_overlay(image(charging.icon, charging.icon_state))
		add_overlay("ccharger-on")
		if(!(stat & (BROKEN|NOPOWER)))
			var/newlevel = 	round(charging.percent() * 4 / 100)
			chargelevel = newlevel
			add_overlay("ccharger-o[newlevel]")

/obj/machinery/cell_charger/examine(mob/user)
	..()
	to_chat(user, "There's [charging ? "a" : "no"] cell in the charger.")
	if(charging)
		to_chat(user, "Current charge: [round(charging.percent(), 1)]%.")

/obj/machinery/cell_charger/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell) && !panel_open)
		if(stat & BROKEN)
			to_chat(user, "<span class='warning'>[src] is broken!</span>")
			return
		if(!anchored)
			to_chat(user, "<span class='warning'>[src] isn't attached to the ground!</span>")
			return
		if(charging)
			to_chat(user, "<span class='warning'>There is already a cell in the charger!</span>")
			return
		else
			var/area/a = loc.loc // Gets our locations location, like a dream within a dream
			if(!isarea(a))
				return
			if(a.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				to_chat(user, "<span class='warning'>[src] blinks red as you try to insert the cell!</span>")
				return
			if(!user.transferItemToLoc(W,src))
				return

			charging = W
			user.visible_message("[user] inserts a cell into [src].", "<span class='notice'>You insert a cell into [src].</span>")
			chargelevel = -1
			updateicon()
	else 
		if(!charging && default_deconstruction_screwdriver(user, icon_state, icon_state, W))
			return
		if(default_deconstruction_crowbar(W))
			return
		if(!charging && default_unfasten_wrench(user, W))
			return
		return ..()

/obj/machinery/cell_charger/deconstruct()
	if(charging)
		charging.forceMove(drop_location())
	return ..()

/obj/machinery/cell_charger/Destroy()
	QDEL_NULL(charging)
	return ..()

/obj/machinery/cell_charger/proc/removecell()
	charging.update_icon()
	charging = null
	chargelevel = -1
	updateicon()

/obj/machinery/cell_charger/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!charging)
		return

	user.put_in_hands(charging)
	charging.add_fingerprint(user)

	user.visible_message("[user] removes [charging] from [src].", "<span class='notice'>You remove [charging] from [src].</span>")

	removecell()

/obj/machinery/cell_charger/attack_tk(mob/user)
	if(!charging)
		return

	charging.forceMove(loc)
	to_chat(user, "<span class='notice'>You telekinetically remove [charging] from [src].</span>")

	removecell()

/obj/machinery/cell_charger/attack_ai(mob/user)
	return

/obj/machinery/cell_charger/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return

	if(charging)
		charging.emp_act(severity)

	..(severity)

/obj/machinery/cell_charger/RefreshParts()
	charge_rate = 500
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		charge_rate *= C.rating

/obj/machinery/cell_charger/process()
	if(!charging || !anchored || (stat & (BROKEN|NOPOWER)))
		return

	if(charging.percent() >= 100)
		return
	use_power(charge_rate)
	charging.give(charge_rate)	//this is 2558, efficient batteries exist

	updateicon()
 