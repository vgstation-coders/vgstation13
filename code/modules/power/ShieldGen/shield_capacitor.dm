//---------- shield capacitor
//pulls energy out of a power net and charges an adjacent generator

/obj/machinery/shield_capacitor
	name = "\improper Starscreen shield capacitor"
	desc = "Charges Starscreen shield generators."
	icon = 'icons/effects/shielding.dmi'
	icon_state = "capacitor"
	req_one_access = list(access_security, access_engine_minor) // For locking/unlocking controls
	density = 1
	anchored = TRUE
	use_power = MACHINE_POWER_USE_NONE
	machine_flags = EMAGGABLE | SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	verb_rotates = TRUE
	alt_click_rotates = TRUE
	var/stored_charge = 0
	var/time_since_fail = 100
	var/max_charge = 10000000
	var/max_charge_rate = 10000000
	var/min_charge_rate = 1
	var/locked = FALSE
	var/charge_rate = 100
	var/datum/power_connection/consumer/cable/power_connection = null

/obj/machinery/shield_capacitor/New()
	..()
	power_connection = new(src)

	component_parts = newlist(
		/obj/item/weapon/circuitboard/shield_cap,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/subspace/filter,
		/obj/item/weapon/stock_parts/subspace/treatment,
		/obj/item/weapon/stock_parts/subspace/analyzer,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/shield_capacitor/Destroy()
	if(power_connection)
		QDEL_NULL(power_connection)
	. = ..()

/obj/machinery/shield_capacitor/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/capacitor/Ca in component_parts)
		T += Ca.rating - 1
		max_charge = (initial(max_charge)+(T * 10000000))
		max_charge_rate = (initial(max_charge_rate)+(T * 10000000))

/obj/machinery/shield_capacitor/proc/toggle_lock(var/mob/user)
	locked = !locked
	if(user)
		to_chat(user, "\The [src]'s controls are now [locked ? "locked" : "unlocked"].")
	nanomanager.update_uis(src)

/obj/machinery/shield_capacitor/emag_act(var/mob/user)
	if(prob(75))
		toggle_lock(user)
		spark(src, 5)
		return 1
	else
		if(user)
			to_chat(user, "You fail to hack \the [src]'s controls.")
	playsound(src, 'sound/effects/sparks4.ogg', 75, 1)

/obj/machinery/shield_capacitor/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	for(var/obj/machinery/shield_gen/gen in range(1, src))
		if(!anchored && gen.owned_capacitor == src)
			gen.owned_capacitor = null
			break
		else if(anchored && !gen.owned_capacitor)
			gen.find_capacitor()
	nanomanager.update_uis(src)

/obj/machinery/shield_capacitor/attackby(var/obj/item/W, var/mob/user)
	if(..())
		return 1
	else if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(check_access(W))
			toggle_lock(user)
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/machinery/shield_capacitor/attack_hand(var/mob/user)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/machinery/shield_capacitor/proc/has_cable()
	var/turf/T = get_turf(src)
	return anchored && ((power_connection && power_connection.cable) || (T && T.get_cable_node()))

/obj/machinery/shield_capacitor/ui_interact(var/mob/user, var/ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	var/data[0]
	data["locked"] = locked && !issilicon(user) && !isAdminGhost(user)
	data["active"] = power_connection.connected
	data["cable"] = has_cable()
	data["stability"] = time_since_fail > 2
	data["charge"] = stored_charge / 1000
	data["charge_percentage"] = 100 * stored_charge / max_charge
	data["min_charge"] = 0
	data["max_charge"] = max_charge / 1000
	data["charge_rate"] = charge_rate / 1000
	data["min_charge_rate"] = min_charge_rate / 1000
	data["max_charge_rate"] = max_charge_rate / 1000

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "shield_capacitor.tmpl", name, 480, 250)
		ui.set_initial_data(data)
		ui.set_auto_update(TRUE)
		ui.open()

/obj/machinery/shield_capacitor/process()
	var/to_drain = charge_rate
	if(power_connection.connected)
		if(power_connection.get_surplus() > 0)
			to_drain = min(to_drain,power_connection.get_surplus())
			if(stored_charge + charge_rate > max_charge)
				to_drain = max_charge - stored_charge
			power_connection.add_load(to_drain)
			stored_charge += to_drain
		else
			power_connection.disconnect()

	time_since_fail++
	if(stored_charge < to_drain * 1.5)
		time_since_fail = 0

/obj/machinery/shield_capacitor/Topic(href, href_list[])
	if(..())
		return 0
	if(href_list["toggle_active"])
		toggle_connection()
	if(href_list["set_charge_rate"])
		charge_rate = clamp(round(input(usr,"Set new charge rate ([min_charge_rate/1000]-[max_charge_rate/1000])","Charge rate",charge_rate/1000),0.001), min_charge_rate/1000, max_charge_rate/1000) * 1000
	if(href_list["adjust_charge_rate"])
		charge_rate = clamp(charge_rate + (text2num(href_list["adjust_charge_rate"])*1000), min_charge_rate, max_charge_rate)
	return 1

/obj/machinery/shield_capacitor/proc/toggle_connection()
	if(!power_connection.connected)
		power_connection.connect()
	else
		power_connection.disconnect()

/obj/machinery/shield_capacitor/kick_act()
	..()
	if(stat & (FORCEDISABLE|NOPOWER|BROKEN))
		power_connection.disconnect()
		return
	if(prob(50))
		toggle_connection()
