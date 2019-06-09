/obj/machinery/atmospherics/binary/dp_vent_pump
	icon = 'icons/obj/atmospherics/dp_vent_pump.dmi'
	icon_state = "off"

	//node2 is output port
	//node1 is input port

	name = "Dual Port Air Vent"
	desc = "Has a valve and pump attached to it. There are two ports."

	level = 1

	var/pump_direction = 1 //0 = siphoning, 1 = blowing

	var/external_pressure_bound = ONE_ATMOSPHERE
	var/input_pressure_min = 0
	var/output_pressure_max = 0

	var/pressure_checks = 1
	//1: Do not pass external_pressure_bound
	//2: Do not pass input_pressure_min
	//4: Do not pass output_pressure_max

	var/frequency = 0
	var/id_tag = null
	var/datum/radio_frequency/radio_connection

	machine_flags = MULTITOOL_MENU

/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume
	name = "Large Dual Port Air Vent"

/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume/New()
	..()

	air1.volume = 2500
	air2.volume = 2500

/obj/machinery/atmospherics/binary/dp_vent_pump/update_icon()
	if(on)
		if(pump_direction)
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]out"
		else
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
	else
		icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
		on = 0

	return

/obj/machinery/atmospherics/binary/dp_vent_pump/hide(var/i) //to make the little pipe section invisible, the icon changes.
	if(on)
		if(pump_direction)
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]out"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
	else
		icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
		on = 0
	return

/obj/machinery/atmospherics/binary/dp_vent_pump/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
		<li>[format_tag("ID Tag", "id_tag", "set_id")]</a></li>
	</ul>
	"}

/obj/machinery/atmospherics/binary/dp_vent_pump/process()
	. = ..()

	if(!on)
		return

	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_delta = get_pressure_delta(environment)
	if(pressure_delta > 0.5)
		if(pump_direction) //internal -> external
			if(node1 && (environment.temperature || air1.temperature))
				var/air_temperature = (air1.temperature > 0) ? air1.temperature : environment.temperature
				var/transfer_moles = (pressure_delta * environment.volume) / (air_temperature * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = air1.remove(transfer_moles)
				loc.assume_air(removed)

				if(network1)
					network1.update = 1
		
		else //external -> internal
			if(node2 && (environment.temperature || air2.temperature))
				var/air_temperature = (environment.temperature > 0) ? environment.temperature : air2.temperature
				var/output_volume = air2.volume + (network2 ? network2.volume : 0)
				var/transfer_moles = (pressure_delta * output_volume) / (air_temperature * R_IDEAL_GAS_EQUATION)
				//limit flow rate from turfs
				transfer_moles = min(transfer_moles, environment.total_moles*air2.volume/environment.volume)
				var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
				if(isnull(removed)) //in space
					return
				air2.merge(removed)

				if(network2)
					network2.update = 1
	return 1

/obj/machinery/atmospherics/binary/dp_vent_pump/proc/get_pressure_delta(datum/gas_mixture/environment)
	var/pressure_delta = 10000 //why is this 10000? whatever
	var/environment_pressure = environment.return_pressure()

	if(pump_direction) //internal -> external
		if(pressure_checks & 1)
			pressure_delta = min(pressure_delta, external_pressure_bound - environment_pressure) //increasing the pressure here
		if(pressure_checks & 2)
			pressure_delta = min(pressure_delta, air1.return_pressure() - input_pressure_min) //decreasing the pressure here
	else //external -> internal
		if(pressure_checks & 1)
			pressure_delta = min(pressure_delta, environment_pressure - external_pressure_bound) //decreasing the pressure here
		if(pressure_checks & 2)
			pressure_delta = min(pressure_delta, output_pressure_max - air2.return_pressure()) //increasing the pressure here

	return pressure_delta

//Radio remote control

/obj/machinery/atmospherics/binary/dp_vent_pump/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/binary/dp_vent_pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id_tag,
		"device" = "ADVP",
		"power" = on,
		"direction" = pump_direction,
		"checks" = pressure_checks,
		"input" = input_pressure_min,
		"output" = output_pressure_max,
		"external" = external_pressure_bound,
		"sigtype" = "status"
	)
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	return 1

/obj/machinery/atmospherics/binary/dp_vent_pump/initialize()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/binary/dp_vent_pump/receive_signal(datum/signal/signal)

	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return 0

	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("direction" in signal.data)
		pump_direction = text2num(signal.data["direction"])

	if("checks" in signal.data)
		pressure_checks = text2num(signal.data["checks"])

	if("set_input_pressure" in signal.data)
		input_pressure_min = Clamp(text2num(signal.data["set_input_pressure"]), 0, ONE_ATMOSPHERE * 50)

	if("set_output_pressure" in signal.data)
		output_pressure_max = Clamp(text2num(signal.data["set_output_pressure"]), 0, ONE_ATMOSPHERE * 50)

	if("set_external_pressure" in signal.data)
		external_pressure_bound = Clamp(text2num(signal.data["set_external_pressure"]), 0, ONE_ATMOSPHERE * 50)

	if("status" in signal.data)
		spawn(2)
			broadcast_status()
		return //do not update_icon
	spawn(2)
		broadcast_status()
	update_icon()

/obj/machinery/atmospherics/binary/dp_vent_pump/attackby(var/obj/item/W as obj, var/mob/user as mob)
	return ..()

/obj/machinery/atmospherics/binary/dp_vent_pump/interact(var/mob/user)
	update_multitool_menu(user)

/obj/machinery/atmospherics/binary/dp_vent_pump/canClone(var/obj/O)
	return istype(O, /obj/machinery/atmospherics/binary/dp_vent_pump)

/obj/machinery/atmospherics/binary/dp_vent_pump/clone(var/obj/machinery/atmospherics/binary/dp_vent_pump/O)
	id_tag = O.id_tag
	set_frequency(O.frequency)
	return 1

/obj/machinery/atmospherics/binary/dp_vent_pump/toggle_status(var/mob/user)
	return FALSE
