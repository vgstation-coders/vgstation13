#define TELECOMMS_MAX_INTEGRITY 100

/obj/machinery/telecomms
	var/temp = "" // output message
	machine_flags = MULTITOOL_MENU | SCREWTOGGLE | CROWDESTROY

/obj/item/weapon/circuitboard/telecomms
	var/integrity = TELECOMMS_MAX_INTEGRITY

/obj/machinery/telecomms/proc/get_integrity()
	var/obj/item/weapon/circuitboard/telecomms/C = locate() in component_parts
	if(istype(C))
		return C.integrity
	. = TELECOMMS_MAX_INTEGRITY // If there's no circuitboard (allinone.dm) just treat it as maximum integrity

/obj/machinery/telecomms/proc/set_integrity(var/new_integrity)
	var/obj/item/weapon/circuitboard/telecomms/C = locate() in component_parts
	if (!istype(C))
		return
	C.integrity = Clamp(new_integrity, 0, TELECOMMS_MAX_INTEGRITY)

/obj/item/weapon/circuitboard/telecomms/attackby(var/obj/item/W, var/mob/user, var/params)
	if(issolder(W))
		if(integrity >= TELECOMMS_MAX_INTEGRITY)
			to_chat(user, "It's not damaged.")
			return
		var/obj/item/weapon/solder/S = W
		if (!S.remove_fuel(2, user))
			to_chat(user, "You need more fuel.")
			return
		playsound(user, 'sound/items/Welder.ogg', 100, 1)
		integrity = TELECOMMS_MAX_INTEGRITY
		to_chat(user, "<span class='notice'>You repair the damaged internals of \the [src].</span>")
		updateUsrDialog()
		return 1

/obj/machinery/telecomms/attackby(var/obj/item/W, var/mob/user)
	. = ..()
	if(.)
		return
	if(issolder(W))
		. = TRUE
		if(!panel_open)
			to_chat(user, "You need to open the maintenance panel first!")
			return
		var/obj/item/weapon/circuitboard/telecomms/C = locate() in component_parts
		if(istype(C))
			C.attackby(W, user)
	update_power_and_icon()

/obj/machinery/telecomms/attack_hand(var/mob/user)
	update_multitool_menu(user)

/obj/machinery/telecomms/proc/formatInput(var/label, var/varname, var/input)
	var/value = vars[varname] ||  "-----"
	return "<b>[label]:</b> <a href=\"?src=\ref[src];input=[varname]\">[value]</a>"

/obj/machinery/telecomms/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	// You need a multitool to use this, or be silicon
	if(!issilicon(user))
		// istype returns false if the value is null
		if(!ismultitool(user.get_active_hand()))
			return

	if(stat & (BROKEN|NOPOWER))
		return

	var/dat

	dat = {"
		<p>[temp]</p>
		<p><b>Power Status:</b> <a href='?src=\ref[src];input=toggle'>[toggled ? "On" : "Off"]</a></p>
		<p><b>Integrity:</b> [Clamp(get_integrity(), 0, TELECOMMS_MAX_INTEGRITY)]%</p>
	"}
	if(on && toggled)
		dat += {"
			<p>[formatInput("Identification String","id","id")]</p>
			<p>[formatInput("Network","network","network")]</p>
			<p><b>Prefabrication:</b> [autolinkers.len ? "TRUE" : "FALSE"]</p>
		"}
		if(hide)
			dat += "<p><b>Shadow Link: ACTIVE</b></p>"

		//Show additional options for certain machines.
		dat += Options_Menu()

		dat += {"<h2>Linked Network Entities:</h2> <ol>"}
		var/i = 0
		for(var/obj/machinery/telecomms/T in links)
			i++
			if(T.hide && !src.hide)
				continue
			dat += "<li>\ref[T] [T.name] ([T.id])  <a href='?src=\ref[src];unlink=[i]'>\[X\]</a></li>"

		dat += {"</ol>
			<h2>Filtering Frequencies:</h2>"}
		i = 0
		if(length(freq_listening))
			dat += "<ul>"
			for(var/x in freq_listening)
				dat += "<li>[format_frequency(x)] GHz<a href='?src=\ref[src];delete=[x]'>\[X\]</a></li>"
			dat += "</ul>"
		else
			dat += "<li>NONE</li>"


		dat += {"<p><a href='?src=\ref[src];input=freq'>\[Add Filter\]</a></p>
			<hr />"}

	return dat

/obj/machinery/telecomms/canLink(var/obj/O)
	return istype(O,/obj/machinery/telecomms)

/obj/machinery/telecomms/isLinkedWith(var/obj/O)
	return O != null && O in links

/obj/machinery/telecomms/getLink(var/idx)
	return (idx >= 1 && idx <= links.len) ? links[idx] : null

// Off-Site Relays
//
// You are able to send/receive signals from the station's z level (changeable in the STATION_Z #define) if
// the relay is on the telecomm satellite (changable in the TELECOMM_Z #define)


/obj/machinery/telecomms/relay/proc/toggle_level()


	var/turf/position = get_turf(src)

	// Toggle on/off getting signals from the station or the current Z level
	if(src.listening_level == STATION_Z) // equals the station
		src.listening_level = position.z
		return 1
	else if(position.z == TELECOMM_Z)
		src.listening_level = STATION_Z
		return 1
	return 0

// Additional Options for certain machines. Use this when you want to add an option to a specific machine.
// Example of how to use below.

/obj/machinery/telecomms/proc/Options_Menu()
	return ""

/*
// Add an option to the processor to switch processing mode. (COMPRESS -> UNCOMPRESS or UNCOMPRESS -> COMPRESS)
/obj/machinery/telecomms/processor/Options_Menu()
	var/dat = "<br>Processing Mode: <A href='?src=\ref[src];process=1'>[process_mode ? "UNCOMPRESS" : "COMPRESS"]</a>"
	return dat
*/
// The topic for Additional Options. Use this for checking href links for your specific option.
// Example of how to use below.
/obj/machinery/telecomms/proc/Options_Topic(href, href_list)
	return

/*
/obj/machinery/telecomms/processor/Options_Topic(href, href_list)

	if(href_list["process"])
		temp = "<font color = #666633>-% Processing mode changed. %-</font color>"
		src.process_mode = !src.process_mode
*/

// RELAY

/obj/machinery/telecomms/relay/Options_Menu()
	var/dat = ""
	if(src.z == TELECOMM_Z)
		dat += "<br>Signal Locked to Station: <A href='?src=\ref[src];change_listening=1'>[listening_level == STATION_Z ? "TRUE" : "FALSE"]</a>"

	dat += {"<br>Broadcasting: <A href='?src=\ref[src];broadcast=1'>[broadcasting ? "YES" : "NO"]</a>
		<br>Receiving:    <A href='?src=\ref[src];receive=1'>[receiving ? "YES" : "NO"]</a>"}
	return dat

/obj/machinery/telecomms/relay/Options_Topic(href, href_list)

	if(href_list["receive"])
		receiving = !receiving
		temp = "<font color = #666633>-% Receiving mode changed. %-</font color>"
	if(href_list["broadcast"])
		broadcasting = !broadcasting
		temp = "<font color = #666633>-% Broadcasting mode changed. %-</font color>"
	if(href_list["change_listening"])
		//Lock to the station OR lock to the current position!
		//You need at least two receivers and two broadcasters for this to work, this includes the machine.
		var/result = toggle_level()
		if(result)
			temp = "<font color = #666633>-% [src]'s signal has been successfully changed.</font color>"
		else
			temp = "<font color = #666633>-% [src] could not lock it's signal onto the station. Two broadcasters or receivers required.</font color>"

// BUS

/obj/machinery/telecomms/bus/Options_Menu()
	var/dat = "<br>Change Signal Frequency: <A href='?src=\ref[src];change_freq=1'>[change_frequency ? "YES ([change_frequency])" : "NO"]</a>"
	return dat

/obj/machinery/telecomms/bus/Options_Topic(href, href_list)

	if(href_list["change_freq"])

		var/newfreq = input(usr, "Specify a new frequency for new signals to change to. Enter null to turn off frequency changing. Decimals assigned automatically.", src, network) as null|num
		if(canAccess(usr))
			if(newfreq)
				if(findtext(num2text(newfreq), "."))
					newfreq *= 10 // shift the decimal one place
				if(newfreq < 10000)
					change_frequency = newfreq
					temp = "<font color = #666633>-% New frequency to change to assigned: \"[newfreq] GHz\" %-</font color>"
			else
				change_frequency = 0
				temp = "<font color = #666633>-% Frequency changing deactivated %-</font color>"


/obj/machinery/telecomms/Topic(href, href_list)
	if(..())
		return

	if(!issilicon(usr))
		if(!istype(usr.get_active_hand(), /obj/item/device/multitool))
			return

	var/obj/item/device/multitool/P = get_multitool(usr)
	if(!istype(P))
//		testing("get_multitool returned [P].")
		return

	if(href_list["input"])
		switch(href_list["input"])

			if("toggle")
				src.toggled = !src.toggled
				temp = "<font color = #666633>-% [src] has been [src.toggled ? "activated" : "deactivated"].</font color>"
				update_power_and_icon()

			/*
			if("hide")
				src.hide = !hide
				temp = "<font color = #666633>-% Shadow Link has been [src.hide ? "activated" : "deactivated"].</font color>"
			*/

			if("id")
				var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID for this machine", src, id) as null|text),1,MAX_MESSAGE_LEN)
				if(newid && canAccess(usr))
					id = newid
					temp = "<font color = #666633>-% New ID assigned: \"[id]\" %-</font color>"

			if("network")
				var/newnet = reject_bad_text(input(usr, "Specify the new network for this machine. This will break all current links.", src, network) as null|text)
				if(newnet && canAccess(usr))

					if(length(newnet) > 15)
						temp = "<font color = #666633>-% Too many characters in new network tag (15 max) %-</font color>"

					else
						for(var/obj/machinery/telecomms/T in links)
							T.links.Remove(src)

						network = newnet
						links = list()
						temp = "<font color = #666633>-% New network tag assigned: \"[network]\" %-</font color>"


			if("freq")
				var/newfreq = input(usr, "Specify a new frequency to filter (GHz). Decimals assigned automatically.", src, network) as null|num
				if(newfreq && canAccess(usr))
					if(findtext(num2text(newfreq), "."))
						newfreq *= 10 // shift the decimal one place
					if(!(newfreq == SYND_FREQ || newfreq == RAID_FREQ || newfreq == REV_FREQ))
						if(!(newfreq in freq_listening) && newfreq < 10000)
							freq_listening.Add(newfreq)
							temp = "<font color = #666633>-% New frequency filter assigned: \"[newfreq] GHz\" %-</font color>"
					else
						temp = "<font color = #666633>-% Encryption key denied. %-</font color>"

	if(href_list["delete"])

		// changed the layout about to workaround a pesky runtime -- Doohl

		var/x = text2num(href_list["delete"])
		temp = "<font color = #666633>-% Removed frequency filter [x] %-</font color>"
		freq_listening.Remove(x)

	src.Options_Topic(href, href_list)
	usr.set_machine(src)
	updateUsrDialog()

// NOTE: A user won't be provided if unlinked by deletion!
/obj/machinery/telecomms/unlinkFrom(var/mob/user, var/obj/O)
	var/obj/machinery/telecomms/T=O
	if(O && O in links)
		if(T.links)
			T.links.Remove(src)
		links.Remove(O)
		. = 1
	else
		. = 0
	if(user) // This was a manual unlink, update the status display
		if(.)
			temp = "<font color = #666633>-% Removed \ref[T] [T.name] from linked entities. %-</font color>"
		else
			temp = "<font color = #666633>-% Unable to locate machine to unlink from, try again. %-</font color>"

/obj/machinery/telecomms/linkWith(var/mob/user, var/mob/O)
	if(O && O != src && istype(O, /obj/machinery/telecomms))
		var/obj/machinery/telecomms/T=O
		if(!(src in T.links))
			T.links.Add(src)

		if(!(T in src.links))
			src.links.Add(T)

		temp = "<font color = #666633>-% Successfully linked with \ref[O] [O.name] %-</font color>"
		return 1
	else if (O == src)
		temp = "<font color = #666633>-% This machine can't be linked with itself %-</font color>"
		return 0
	else
		temp = "<font color = #666633>-% Unable to acquire buffer %-</font color>"
		return 0

/obj/machinery/telecomms/proc/canAccess(var/mob/user)
	if(!issilicon(user) && !in_range(src, user))
		return FALSE
	return !user.incapacitated()

#undef TELECOMMS_MAX_INTEGRITY
