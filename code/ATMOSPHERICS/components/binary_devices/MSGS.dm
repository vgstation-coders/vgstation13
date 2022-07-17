#define MSGS_ON					1
#define MSGS_INPUT				2

/obj/machinery/atmospherics/binary/msgs
	name = "\improper Magnetically Suspended Gas Storage Unit"
	desc = "Stores large quantities of gas in electro-magnetic suspension."
	icon = 'icons/obj/atmospherics/msgs.dmi'
	icon_state = "msgs"
	density = 1

	machine_flags = WRENCHMOVE | FIXED2WORK
	idle_power_usage = 1000					//This thing's serious

	var/internal_volume = 10000
	var/max_pressure = 10000

	var/target_pressure = 4500	//Output pressure.

	var/datum/gas_mixture/air				//Internal tank.

	var/tmp/update_flags
	var/tmp/last_pressure

/obj/machinery/atmospherics/binary/msgs/unanchored
	anchored = 0

/obj/machinery/atmospherics/binary/msgs/New()
	air = new
	air.volume = internal_volume

	return ..()

/obj/machinery/atmospherics/binary/msgs/Destroy()
	. = ..()

	air = null

/obj/machinery/atmospherics/binary/msgs/process()
	. = ..()
	if(stat & (NOPOWER | BROKEN | FORCEDISABLE))
		return

	//Output handling, stolen from pump code.
	var/output_starting_pressure = air2.return_pressure()

	if((target_pressure - output_starting_pressure) > 0.01)
		//No need to output gas if target is already reached!

		//Calculate necessary moles to transfer using PV=nRT
		if((air.total_moles() > 0) && (air.temperature > 0))
			var/pressure_delta = target_pressure - output_starting_pressure
			var/transfer_moles = pressure_delta * air2.volume / (air.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air.remove(transfer_moles)
			air2.merge(removed)

			if(network2)
				network2.update = 1

	//Input handling. Literally pump code again with the target pressure being the max pressure of the MSGS
	if(on)
		var/input_starting_pressure = air1.return_pressure()

		if((max_pressure - input_starting_pressure) > 0.01)
			//No need to output gas if target is already reached!

			//Calculate necessary moles to transfer using PV=nRT
			if((air1.total_moles() > 0) && (air1.temperature > 0))
				var/pressure_delta = max_pressure - input_starting_pressure
				var/transfer_moles = pressure_delta * air.volume / (air1.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas
				var/datum/gas_mixture/removed = air1.remove(transfer_moles)
				air.merge(removed)

				if(network1)
					network1.update = 1

	update_icon()

/obj/machinery/atmospherics/binary/msgs/ui_data()
	var/list/data = list()

	data["pressure"] = round(air.return_pressure(), 0.01)
	data["temperature"] = air.return_temperature()
	data["power"] = on
	data["targetPressure"] = target_pressure
	data["gases"] = list()
	var/static/list/display_gases = list(
		GAS_OXYGEN = "Oxygen",
		GAS_NITROGEN = "Nitrogen",
		GAS_CARBON = "Carbon Dioxide",
		GAS_PLASMA = "Plasma",
		GAS_SLEEPING = "Nitrous Oxide",
	)
	var/total_moles = air.total_moles
	for(var/gas in display_gases)
		data["gases"] += list(list(
			"name" = display_gases[gas],
			//Check if there's total moles to avoid divisions by zero.
			"percentage" = round(total_moles, 0.01) \
					? clamp(round(100 * air[gas] / total_moles, 0.1), 0, 100) \
					: 0
		))
	return data

/obj/machinery/atmospherics/binary/msgs/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_power")
			on = !on
			update_icon()
			return TRUE
		if("set_pressure")
			target_pressure = round(clamp(text2num(params["new_pressure"]), 0, 4500))
			update_icon()
			return TRUE

/obj/machinery/atmospherics/binary/msgs/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MSGS")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/atmospherics/binary/msgs/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	tgui_interact(user)

/obj/machinery/atmospherics/binary/msgs/attackby(obj/item/W, mob/user)
	. = ..()
	if(.)
		return
	if(istype(W, /obj/item/device/analyzer))
		var/obj/item/device/analyzer/A = W
		user.show_message(A.output_gas_scan(air, src, FALSE))

/obj/machinery/atmospherics/binary/msgs/power_change()
	. = ..()
	update_icon()

/obj/machinery/atmospherics/binary/msgs/update_icon()
	. = ..()

	var/update = 0
	if((update_flags & MSGS_INPUT) != on)
		update = 1

	if((update_flags & MSGS_ON) != !(stat & (NOPOWER | BROKEN | FORCEDISABLE)))
		update = 1

	var/pressure = air.return_pressure() // null ref error here.
	var/i = clamp(round(pressure / (max_pressure / 5)), 0, 5)
	if(i != last_pressure)
		update = 1

	if(!update)
		return

	overlays.Cut()
	if(node1)
		overlays += image(icon = icon, icon_state = "node-1")

	if(node2)
		overlays += image(icon = icon, icon_state = "node-2")

	if(!(stat & (NOPOWER | BROKEN | FORCEDISABLE)))

		overlays += image(icon = icon, icon_state = "o-[i]")

		overlays += image(icon = icon, icon_state = "p")

		if(on)
			overlays += image(icon = icon, icon_state = "i")

/obj/machinery/atmospherics/binary/msgs/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	if(anchored)
		if(dir & (NORTH|SOUTH))
			initialize_directions = NORTH|SOUTH
		else if(dir & (EAST|WEST))
			initialize_directions = EAST|WEST

		initialize()
		build_network()
		if (node1)
			node1.initialize()
			node1.build_network()
		if (node2)
			node2.initialize()
			node2.build_network()
	else
		if(node1)
			node1.disconnect(src)
			if(network1)
				qdel(network1)
		if(node2)
			node2.disconnect(src)
			if(network2)
				qdel(network2)

		node1 = null
		node2 = null

/obj/machinery/atmospherics/binary/msgs/verb/rotate_clockwise()
	set category = "Object"
	set name = "Rotate MSGS (Clockwise)"
	set src in view(1)

	if(usr.isUnconscious() || usr.restrained() || anchored)
		return

	src.dir = turn(src.dir, -90)


/obj/machinery/atmospherics/binary/msgs/verb/rotate_anticlockwise()
	set category = "Object"
	set name = "Rotate MSGS (Counter-clockwise)"
	set src in view(1)

	if(usr.isUnconscious() || usr.restrained() || anchored)
		return

	src.dir = turn(src.dir, 90)

/obj/machinery/atmospherics/binary/msgs/toggle_status(var/mob/user)
	return FALSE

#undef MSGS_ON
#undef MSGS_INPUT
