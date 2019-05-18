/obj/machinery/atmospherics/binary/passive_gate
	//Essentially a one-way check valve.
	//If input is higher pressure than output, works to equalize the pressure. If output is higher pressure than input, does nothing.
	icon = 'icons/obj/atmospherics/passive_gate.dmi'
	icon_state = "intact_off"

	name = "Passive gate"
	desc = "A one-way gas valve that does not require power"

	var/open = FALSE

	var/frequency = 0
	var/id_tag = null
	var/datum/radio_frequency/radio_connection
	machine_flags = MULTITOOL_MENU

/obj/machinery/atmospherics/binary/passive_gate/New()
	..()
	air1.volume = 1000

/obj/machinery/atmospherics/binary/passive_gate/update_icon()
	icon_state = "intact_[open?("on"):("off")]"
	..()

/obj/machinery/atmospherics/binary/passive_gate/proc/open()
	if(open)
		return 0
	open = TRUE
	update_icon()
	return 1

/obj/machinery/atmospherics/binary/passive_gate/proc/close()
	if(!open)
		return 0
	open = FALSE
	update_icon()
	return 1

/obj/machinery/atmospherics/binary/passive_gate/process()
	. = ..()
	if(!open)
		return

	var/output_starting_pressure = air2.return_pressure()
	var/input_starting_pressure = air1.return_pressure()
	//var/pressure_delta = min(10000, abs(environment_pressure - air_contents.return_pressure()))
	var/pressure_delta = min(10000, input_starting_pressure - output_starting_pressure)

	if((air1.temperature > 0 || air2.temperature > 0) && pressure_delta > 0.5)
		//Figure out how much gas to transfer to equalize the pressure.
		var/air_temperature = (air1.temperature > 0) ? air1.temperature : air2.temperature
		var/output_volume = air2.volume + (network2 ? network2.volume : 0)
		//get the number of moles that would have to be transfered to bring sink to the target pressure
		var/transfer_moles = (pressure_delta * output_volume) / (air_temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		if(network1)
			network1.update = 1
		if(network2)
			network2.update = 1

	return 1

//Radio remote control


/obj/machinery/atmospherics/binary/passive_gate/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/binary/passive_gate/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id_tag,
		"device" = "AGP",
		"power" = open,
		"sigtype" = "status"
	)

	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	return 1

/obj/machinery/atmospherics/binary/passive_gate/initialize()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/binary/passive_gate/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
		return 0

	var/state_changed = 0
	switch(signal.data["command"])
		if("gate_open")
			if(!open)
				open()
				state_changed = 1

		if("gate_close")
			if(open)
				close()
				state_changed = 1

		if("gate_set")
			if(signal.data["state"])
				if(!open)
					open()
					state_changed = 1
			else
				if(open)
					close()
					state_changed = 1

		if("gate_toggle")
			if(open)
				close()
			else
				open()
			state_changed = 1

		if("status")
			spawn(2)
				broadcast_status()

	if(state_changed)
		investigation_log(I_ATMOS,"was [open ? "opened" : "closed"] by a signal")

/obj/machinery/atmospherics/binary/passive_gate/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/atmospherics/binary/passive_gate/attack_hand(mob/user as mob)
	toggle_status(user)

/obj/machinery/atmospherics/binary/passive_gate/npc_tamper_act(mob/living/L)
	if (src.open)
		src.close()
	else
		src.open()
	investigation_log(I_ATMOS,"was [open ? "opened" : "closed"] by [key_name(L)]")

	src.update_icon()

/obj/machinery/atmospherics/binary/passive_gate/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag","set_id")]</a></li>
	</ul>
	"}

/obj/machinery/atmospherics/binary/passive_gate/Topic(href, href_list)
	if(..())
		return

	if(!issilicon(usr))
		if(!istype(usr.get_active_hand(), /obj/item/device/multitool))
			return

	if("set_id" in href_list)
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, id_tag) as null|text),1,MAX_MESSAGE_LEN)
		if(newid)
			id_tag = newid
			initialize()
	if("set_freq" in href_list)
		var/newfreq=frequency
		if(href_list["set_freq"]!="-1")
			newfreq=text2num(href_list["set_freq"])
		else
			newfreq = input(usr, "Specify a new frequency (GHz). Decimals assigned automatically.", src, frequency) as null|num
		if(newfreq)
			if(findtext(num2text(newfreq), "."))
				newfreq *= 10 // shift the decimal one place
			if(newfreq < 10000)
				frequency = newfreq
				initialize()

	update_multitool_menu(usr)

/obj/machinery/atmospherics/binary/passive_gate/toggle_status(var/mob/user)
	if(!src.allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	if(isobserver(user) && !canGhostWrite(user,src,"toggles"))
		to_chat(user, "<span class='warning'>Nope.</span>")
		return
	src.add_fingerprint(usr)
	if (src.open)
		src.close()
	else
		src.open()
