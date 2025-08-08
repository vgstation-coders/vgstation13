/obj/machinery/meter
	name = "meter"
	desc = "A gas flow meter."
	icon = 'icons/obj/meter.dmi'
	icon_state = "meterX"
	var/obj/machinery/atmospherics/pipe/target = null
	var/target_layer = PIPING_LAYER_DEFAULT
	anchored = 1.0
	power_channel = ENVIRON
	var/frequency = 1439

	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 2
	active_power_usage = 4
	machine_flags = MULTITOOL_MENU

	var/list/metrics_monitored = list("pressure", "temperature", GAS_OXYGEN, GAS_PLASMA, GAS_NITROGEN, GAS_CARBON)

/obj/machinery/meter/New(newloc, new_target, freq, id)
	..(newloc)
	src.target = new_target
	if(target)
		setAttachLayer(target.piping_layer)
	if (freq != null)
		frequency = freq
	if (id != null)
		id_tag = id
	return 1

/obj/machinery/meter/initialize()
	if (!target)
		for(var/obj/machinery/atmospherics/pipe/pipe in src.loc)
			if(pipe.piping_layer == target_layer)
				target = pipe
				break
		if(target)
			setAttachLayer(target.piping_layer)

/obj/machinery/meter/proc/setAttachLayer(var/new_layer)
	target_layer = new_layer
	src.pixel_x = (new_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
	src.pixel_y = (new_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y

/obj/machinery/meter/process()
	if(!target)
		icon_state = "meterX"
		// Pop the meter off when the pipe we're attached to croaks.
		new /obj/item/pipe_meter(src.loc)
		spawn(0) qdel(src)
		return PROCESS_KILL

	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		icon_state = "meter0"
		return 0

	use_power(5)

	var/datum/gas_mixture/environment = target.return_air()
	if(!environment)
		icon_state = "meterX"
		// Pop the meter off when the environment we're attached to croaks.
		new /obj/item/pipe_meter(src.loc)
		spawn(0) qdel(src)
		return PROCESS_KILL

	var/env_pressure = environment.return_pressure()
	if(env_pressure <= 0.15*ONE_ATMOSPHERE)
		icon_state = "meter0"
	else if(env_pressure <= 1.8*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*0.3) + 0.5)
		icon_state = "meter1_[val]"
	else if(env_pressure <= 30*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5)-0.35) + 1
		icon_state = "meter2_[val]"
	else if(env_pressure <= 59*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5) - 6) + 1
		icon_state = "meter3_[val]"
	else
		icon_state = "meter4"

	if(id_tag && frequency)
		var/datum/radio_frequency/radio_connection = radio_controller.return_frequency(frequency)

		if(!radio_connection)
			return

		var/datum/signal/signal = new /datum/signal
		signal.source = src
		signal.transmission_method = 1
		signal.data = list(
			"tag" = id_tag,
			"device" = "AM",
			"sigtype" = "status"
		)

		signal.data["timestamp"] = world.time

		var/total_moles = environment.total_moles
		for(var/metric in metrics_monitored)
			if(metric == "pressure")
				signal.data["pressure"] = round(environment.return_pressure(), 0.1)
			if(metric == "temperature")
				signal.data["temperature"] = round(environment.temperature, 0.1)
			else if(metric in XGM.gases)
				signal.data[metric] = total_moles ? round(100 * environment[metric] / total_moles, 0.1) : 0
		for(var/gas_ID in XGM.gases)
			if(!signal.data[gas_ID])
				signal.data[gas_ID] = 0

		radio_connection.post_signal(src, signal)

/obj/machinery/meter/proc/status()
	var/t = ""
	if (src.target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			t += "The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [environment.temperature_kelvin_pretty()]K ([environment.temperature_celsius_pretty()]&deg;C)"
		else
			t += "The sensor error light is blinking."
	else
		t += "The connect error light is blinking."
	return t

/obj/machinery/meter/examine(mob/user)
	..()
	attack_hand(user)

/obj/machinery/meter/attack_ghost(var/mob/user)
	attack_hand(user)

// Why the FUCK was this Click()?
/obj/machinery/meter/attack_hand(var/mob/user)
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return 1

	var/t = null
	if (get_dist(usr, src) <= user.client.view || istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/dead))
		t += status()
	else
		to_chat(usr, "<span class='notice'><B>You are too far away.</B></span>")
		return 1

	to_chat(usr, t)
	return 1

/obj/machinery/meter/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	var/dat = {"
	<b>Main</b>
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[initial(frequency)]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag")]</li>
		<li>Monitor Pressure: <a href="?src=\ref[src];toggle_monitoring=pressure">[is_monitoring("pressure") ? "Yes" : "No"]</a>
		<li>Monitor Temperature: <a href="?src=\ref[src];toggle_monitoring=temperature">[is_monitoring("temperature") ? "Yes" : "No"]</a>"}

	for(var/gas_ID in XGM.gases)
		var/datum/gas/gas_datum = XGM.gases[gas_ID]
		dat += {"<li>Monitor [gas_datum.name] Concentration: <a href="?src=\ref[src];toggle_monitoring=[gas_ID]">[is_monitoring(gas_ID) ? "Yes" : "No"]</a>"}
	dat += "</ul>"
	return dat

/obj/machinery/meter/multitool_topic(var/mob/user, var/list/href_list, var/obj/item/device/multitool/P)
	. = ..()
	if(.)
		return .

	if("toggle_monitoring" in href_list)
		var/toggle_target = href_list["toggle_monitoring"]
		if((toggle_target in XGM.gases) || toggle_target == "pressure" || toggle_target == "temperature")
			toggle_monitoring(toggle_target)
		return MT_UPDATE

/obj/machinery/meter/proc/add_monitoring(var/input)
	metrics_monitored |= input

/obj/machinery/meter/proc/remove_monitoring(var/input)
	metrics_monitored -= input

/obj/machinery/meter/proc/toggle_monitoring(var/input)
	if(!metrics_monitored.Remove(input))
		metrics_monitored += input

/obj/machinery/meter/proc/is_monitoring(var/input)
	return metrics_monitored.Find(input)

/obj/machinery/meter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(!W.is_wrench(user))
		return ..()

	W.playtoolsound(src, 50)
	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
	if (do_after(user, src, 40))
		user.visible_message( \
			"[user] unfastens \the [src].</span>", \
			"<span class='notice'>You have unfastened \the [src].</span>", \
			"You hear ratchet.")
		new /obj/item/pipe_meter(src.loc)
		qdel(src)

// TURF METER - REPORTS A TILE'S AIR CONTENTS

/obj/machinery/meter/turf/New()
	..()
	src.target = loc
	return 1


/obj/machinery/meter/turf/initialize()
	if (!target)
		src.target = loc

/obj/machinery/meter/turf/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	return
