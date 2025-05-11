/obj/machinery/atmospherics/trinary/filter
	icon = 'icons/obj/atmospherics/filter.dmi'
	icon_state = "hintact_off"
	name = "Gas filter"
	default_colour = "#b70000"
	mirror = /obj/machinery/atmospherics/trinary/filter/mirrored

	var/on = 0
	var/temp = null // -- TLE

	var/target_pressure = ONE_ATMOSPHERE

	// What gas is being filtered. Null indicates nothing.
	var/filtered_gas = GAS_PLASMA

	frequency = 0
	var/datum/radio_frequency/radio_connection

	ex_node_offset = 5

/obj/machinery/atmospherics/trinary/filter/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/trinary/filter/New()
	if(ticker && ticker.current_state == GAME_STATE_PLAYING)
		initialize()
	..()

/obj/machinery/atmospherics/trinary/filter/update_icon()
	if(stat & NOPOWER)
		icon_state = "hintact_off"
	else if(stat & FORCEDISABLE)
		icon_state = "hintact_malflocked"
	else if(node2 && node3 && node1)
		icon_state = "hintact_[on?("on"):("off")]"
	else
		icon_state = "hintact_off"
		on = 0
	..()

/obj/machinery/atmospherics/trinary/filter/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		on = !on
		update_icon()

/obj/machinery/atmospherics/trinary/filter/process()
	. = ..()
	if(!on)
		return

	var/output_starting_pressure = air3.return_pressure()
	var/pressure_delta = target_pressure - output_starting_pressure
	var/filtered_pressure_delta = target_pressure - air2.return_pressure()

	if(pressure_delta > 0.01 && filtered_pressure_delta > 0.01 && (air1.temperature > 0 || air3.temperature > 0))
		//Figure out how much gas to transfer to meet the target pressure.
		var/air_temperature = (air1.temperature > 0) ? air1.temperature : air3.temperature
		var/output_volume = air3.volume + (network3 ? network3.volume : 0)
		//get the number of moles that would have to be transfered to bring sink to the target pressure
		var/transfer_moles = (pressure_delta * output_volume) / (air_temperature * R_IDEAL_GAS_EQUATION)
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)

		if(!removed)
			return
		var/datum/gas_mixture/filtered_out = new
		filtered_out.temperature = removed.temperature

		#define FILTER(g) filtered_out.adjust_gas((g), removed[g])
		if(filtered_gas != null)
			FILTER(filtered_gas)

		removed.subtract(filtered_out)
		#undef FILTER

		air2.merge(filtered_out)
		air3.merge(removed)

		if(network2)
			network2.update = 1
		if(network3)
			network3.update = 1
		if(network1)
			network1.update = 1

	return 1

/obj/machinery/atmospherics/trinary/filter/initialize()
	if (!radio_controller)
		return
	set_frequency(frequency)
	..()


/obj/machinery/atmospherics/trinary/filter/attack_hand(user as mob) // -- TLE
	if(..())
		return

	if(!src.allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	var/dat
	var/current_filter_name
	if(filtered_gas == null)
		current_filter_name = "Nothing"
	else
		var/datum/gas/gas_datum = XGM.gases[filtered_gas]
		current_filter_name = gas_datum.name

	dat += {"<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"On":"Off"]</a><br>
			<b>Filtering: </b>[current_filter_name]<br><HR>
			<h4>Set Filter Type:</h4>"}

	for(var/gas_ID in XGM.gases)
		var/datum/gas/gas_datum = XGM.gases[gas_ID]
		dat += "<A href='?src=\ref[src];filterset=" + gas_ID + "'>" + gas_datum.name + "</A><BR>"

	dat += "<A href='?src=\ref[src];filterset=nothing'>Nothing</A><BR>"

	dat += {"<HR><B>Desirable output pressure:</B>
			[src.target_pressure]kPa | <a href='?src=\ref[src];set_press=1'>Change</a>
			"}
/*
		user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD>[dat]","window=atmo_filter")
		onclose(user, "atmo_filter")
		return

	if (src.temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];temp=1'>Clear Screen</A>", src.temp, src)
	//else
	//	src.on != src.on
*/
	user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_filter")
	onclose(user, "atmo_filter")
	return

/obj/machinery/atmospherics/trinary/filter/Topic(href, href_list) // -- TLE
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["filterset"])
		if(href_list["filterset"] == "nothing")
			filtered_gas = null
		else
			filtered_gas = href_list["filterset"]
	if (href_list["temp"])
		src.temp = null
	if(href_list["set_press"])
		var/new_pressure = input(usr,"Enter new output pressure (0-4500kPa)","Pressure control",src.target_pressure) as num
		src.target_pressure = max(0, min(4500, new_pressure))
	if(href_list["power"])
		on=!on
	src.update_icon()
	src.updateUsrDialog()
/*
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.attack_hand(M)
*/
	return


/obj/machinery/atmospherics/trinary/filter/mirrored
	icon_state = "hintactm_off"
	pipe_flags = IS_MIRROR

/obj/machinery/atmospherics/trinary/filter/mirrored/update_icon(var/adjacent_procd)
	..(adjacent_procd)
	if(stat & NOPOWER)
		icon_state = "hintactm_off"
	else if(stat & FORCEDISABLE)
		icon_state = "hintactm_malflocked"
	else if(!(node2 && node3 && node1))
		on = 0
	icon_state = "hintactm_[on?("on"):("off")]"
