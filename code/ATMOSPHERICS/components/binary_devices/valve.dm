/obj/machinery/atmospherics/binary/valve
	icon = 'icons/obj/atmospherics/valve.dmi'
	icon_state = "hvalve0"

	name = "manual valve"
	desc = "A pipe valve."
	var/open = 0
	var/openDuringInit = 0

/obj/machinery/atmospherics/binary/valve/open
	open = 1
	icon_state = "hvalve1"

/obj/machinery/atmospherics/binary/valve/update_icon(var/adjacent_procd,var/animation)
	if(animation)
		flick("hvalve[src.open][!src.open]",src)
	else
		icon_state = "hvalve[open]"
	..()


/obj/machinery/atmospherics/binary/valve/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	..()

	if(open)
		if(reference == node1)
			if(node2)
				return node2.network_expand(new_network, src)
		else if(reference == node2)
			if(node1)
				return node1.network_expand(new_network, src)

	return null

/obj/machinery/atmospherics/binary/valve/proc/open()


	if(open)
		return 0

	open = 1
	update_icon()

	if(network1&&network2)
		network1.merge(network2)
		network2 = network1

	if(network1)
		network1.update = 1
	else if(network2)
		network2.update = 1

	return 1

/obj/machinery/atmospherics/binary/valve/proc/close()


	if(!open)
		return 0

	open = 0
	update_icon()

	if(network1)
		if(network1)
			returnToPool(network1)
	if(network2)
		if(network1)
			returnToPool(network2)

	build_network()

	return 1

/obj/machinery/atmospherics/binary/valve/proc/normalize_dir()
	if(dir==3)
		dir = 1
	else if(dir==12)
		dir = 4

/obj/machinery/atmospherics/binary/valve/attack_ai(mob/user as mob)
	return

/obj/machinery/atmospherics/binary/valve/attack_hand(mob/user as mob)
	if(isobserver(user) && !canGhostWrite(user,src,"toggles"))
		to_chat(user, "<span class='warning'>Nope.</span>")
		return
	src.add_fingerprint(usr)
	update_icon(0,1)
	sleep(10)
	if (src.open)
		src.close()
	else
		src.open()

	investigation_log(I_ATMOS,"was [open ? "opened" : "closed"] by [key_name(usr)]")

/obj/machinery/atmospherics/binary/valve/investigation_log(var/subject, var/message)
	activity_log += ..()

/obj/machinery/atmospherics/binary/valve/initialize()
	normalize_dir()

	findAllConnections(initialize_directions)

	build_network()

	if(openDuringInit)
		close()
		open()
		openDuringInit = 0

	else
		update_icon()

/obj/machinery/atmospherics/binary/valve/digital		// can be controlled by AI
	name = "digital valve"
	desc = "A digitally controlled valve."
	icon = 'icons/obj/atmospherics/digital_valve.dmi'
	var/frequency = 0
	var/id_tag = null
	var/datum/radio_frequency/radio_connection

	machine_flags = MULTITOOL_MENU

/obj/machinery/atmospherics/binary/valve/digital/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/atmospherics/binary/valve/digital/attack_hand(mob/user as mob)
	if(!src.allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	..()

//Radio remote control

/obj/machinery/atmospherics/binary/valve/digital/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/binary/valve/digital/initialize()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/binary/valve/digital/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag","set_id")]</a></li>
	</ul>
	"}

/obj/machinery/atmospherics/binary/valve/digital/Topic(href, href_list)
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

/obj/machinery/atmospherics/binary/valve/digital/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
		return 0

	var/state_changed=0
	switch(signal.data["command"])
		if("valve_open")
			if(!open)
				open()
				state_changed=1

		if("valve_close")
			if(open)
				close()
				state_changed=1

		if("valve_set")
			if(signal.data["state"])
				if(!open)
					open()
					state_changed=1
			else
				if(open)
					close()
					state_changed=1

		if("valve_toggle")
			if(open)
				close()
			else
				open()
			state_changed=1
	if(state_changed)
		investigation_log(I_ATMOS,"was [(open ? "opened" : "closed")] by a signal")

/obj/machinery/atmospherics/binary/valve/npc_tamper_act(mob/living/L)
	if(open)
		close()
	else
		open()
	investigation_log(I_ATMOS,"was [(open ? "opened" : "closed")] by [key_name(L)]")
