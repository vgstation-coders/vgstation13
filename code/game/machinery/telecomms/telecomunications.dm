/*
	Hello, friends, this is Doohl from sexylands. You may be wondering what this
	monstrous code file is. Sit down, boys and girls, while I tell you the tale.


	The machines defined in this file were designed to be compatible with any radio
	signals, provided they use subspace transmission. Currently they are only used for
	headsets, but they can eventually be outfitted for real COMPUTER networks. This
	is just a skeleton, ladies and gentlemen.

	Look at radio.dm for the prequel to this code.
*/

var/global/list/obj/machinery/telecomms/telecomms_list = list()

/obj/machinery/telecomms
	var/list/links = list() // list of machines this machine is linked to
	var/traffic = 0 // value increases as traffic increases
	var/netspeed = 5 // how much traffic to lose per tick (50 gigabytes/second * netspeed)
	var/list/autolinkers = list() // list of text/number values to link with
	var/id = "NULL" // identification string
	var/network = "NULL" // the network of the machinery

	var/list/freq_listening = list() // list of frequencies to tune into: if none, will listen to all

	var/machinetype = 0 // just a hacky way of preventing alike machines from pairing
	var/toggled = 1 	// Is it toggled on
	var/on = 1
	var/delay = 10 // how many process() ticks to delay per heat
	var/heating_power = 40000 // how much heat to transfer to the environment
	var/long_range_link = 0	// Can you link it across Z levels or on the otherside of the map? (Relay & Hub)
	var/hide = 0				// Is it a hidden machine?
	var/listening_level = 0	// 0 = auto set in New() - this is the z level that the machine is listening to.

/obj/machinery/telecomms/proc/relay_information(datum/signal/signal, filter, copysig, amount = 20)
	// relay signal to all linked machinery that are of type [filter]. If signal has been sent [amount] times, stop sending
#ifdef SAY_DEBUG
	var/mob/mob = signal.data["mob"]
	var/datum/language/language = signal.data["language"]
	var/langname = (language ? language.name : "No language")
#endif
	say_testing(mob, "[src] relay_information start, language [langname]")
	if(!on)
		return
	var/send_count = 0

	//signal.data["slow"] += rand(0, round((100-integrity))) // apply some lag based on integrity

	// Apply some lag based on traffic rates
	var/netlag = round(traffic / 50)
	//if(netlag > signal.data["slow"])
	//	signal.data["slow"] = netlag

// Loop through all linked machines and send the signal or copy.
	for(var/obj/machinery/telecomms/machine in links)
		if(!machine.loc)
			world.log << "DEBUG: telecomms machine has null loc: [machine.name]"
			continue
		if(filter && !istype( machine, text2path(filter) ))
			continue
		if(!machine.on)
			continue
		if(amount && send_count >= amount)
			break
		if(machine.loc.z != listening_level)
			if(long_range_link == 0 && machine.long_range_link == 0)
				continue
		// If we're sending a copy, be sure to create the copy for EACH machine and paste the data
		var/datum/signal/copy = new()
		if(copysig)

			copy.transmission_method = 2
			copy.frequency = signal.frequency
			// Copy the main data contents! Workaround for some nasty bug where the actual array memory is copied and not its contents.
			copy.data = list(
				"mob" = signal.data["mob"],
				"language" = signal.data["language"],
				"mobtype" = signal.data["mobtype"],
				"realname" = signal.data["realname"],
				"name" = signal.data["name"],
				"job" = signal.data["job"],
				"key" = signal.data["key"],
				"vmask" = signal.data["vmask"],
				"compression" = signal.data["compression"],
				"message" = signal.data["message"],
				"radio" = signal.data["radio"],
				//"slow" = signal.data["slow"],
				"traffic" = signal.data["traffic"],
				"type" = signal.data["type"],
				"server" = signal.data["server"],
				"reject" = signal.data["reject"],
				"level" = signal.data["level"],
				"lquote" = signal.data["lquote"],
				"rquote" = signal.data["rquote"],
				"message_classes" = signal.data["message_classes"],
				"wrapper_classes" = signal.data["wrapper_classes"]
			)

			// Keep the "original" signal constant
			if(!signal.data["original"])
				copy.data["original"] = signal
			else
				copy.data["original"] = signal.data["original"]

		else
			copy = null


		send_count++
		if(machine.is_freq_listening(signal))
			machine.traffic++

		if(copysig && copy)
			machine.receive_information(copy, src)
		else
			machine.receive_information(signal, src)


	if(send_count > 0 && is_freq_listening(signal))
		traffic++

	return send_count

/obj/machinery/telecomms/proc/relay_direct_information(datum/signal/signal, obj/machinery/telecomms/machine)
	// send signal directly to a machine
	machine.receive_information(signal, src)

/obj/machinery/telecomms/proc/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	// receive information from linked machinery
	..()

/obj/machinery/telecomms/proc/is_freq_listening(datum/signal/signal)
	// return 1 if found, 0 if not found
	if(!signal)
		return 0
	if((signal.frequency in freq_listening) || (!freq_listening.len))
		return 1
	else
		return 0


/obj/machinery/telecomms/New()
	telecomms_list += src
	..()

	update_name()

	//Set the listening_level if there's none.
	if(!listening_level)
		//Defaults to our Z level!
		var/turf/position = get_turf(src)
		listening_level = position.z

/obj/machinery/telecomms/initialize()
	if(autolinkers.len)
		// Links nearby machines
		if(!long_range_link)
			for(var/obj/machinery/telecomms/T in orange(20, src))
				add_link(T)
		else
			for(var/obj/machinery/telecomms/T in telecomms_list)
				add_link(T)


/obj/machinery/telecomms/Destroy()
	telecomms_list -= src
	..()

// Used in auto linking
/obj/machinery/telecomms/proc/add_link(var/obj/machinery/telecomms/T)
	var/turf/position = get_turf(src)
	var/turf/T_position = get_turf(T)
	if((position.z == T_position.z) || (src.long_range_link && T.long_range_link))
		if(src != T)
			for(var/x in autolinkers)
				if(x in T.autolinkers)
					links |= T
					break

/obj/machinery/telecomms/update_icon()
	overlays.Cut()
	if (on)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_off"

	if (panel_open)
		overlays += "[initial(icon_state)]_panel"

/obj/machinery/telecomms/proc/update_name()
	name = initial(name)

	if (id != "NULL")
		name += " ([id])"

/obj/machinery/telecomms/proc/update_power()
	if(toggled)
		if(stat & (BROKEN|NOPOWER|EMPED) || get_integrity() <= 0) // if powered, on. if not powered, off. if too damaged, off
			on = 0
		else
			on = 1
	else
		on = 0

/obj/machinery/telecomms/power_change()
	..()
	update_power_and_icon()

/obj/machinery/telecomms/proc/update_power_and_icon()
	update_power()
	update_icon()

/obj/machinery/telecomms/process()
	update_power()

	// Check heat and generate some
	checkheat()

	// Update the icon
	update_icon()

	if(traffic > 0)
		traffic -= netspeed

/obj/machinery/telecomms/emp_act(severity)
	if(prob(100/severity))
		if(!(stat & EMPED))
			stat |= EMPED
			update_power_and_icon()
			var/duration = (300 * 10)/severity
			spawn(rand(duration - 20, duration + 20)) // Takes a long time for the machines to reboot.
				stat &= ~EMPED
				update_power_and_icon()
	..()

/obj/machinery/telecomms/proc/checkheat()
	// Checks heat from the environment and applies any integrity damage
	var/datum/gas_mixture/environment = loc.return_air()
	if (environment.temperature > T20C + 20)
		set_integrity(max(0, get_integrity() - 1))
		if (get_integrity() <= 0)
			update_power()
	if(delay > 0)
		delay--
		return
	// If the machine is on, ready to produce heat, and has positive traffic, genn some heat
	if(on && traffic > 0)
		produce_heat()
		delay = initial(delay)

/obj/machinery/telecomms/proc/produce_heat()
	if(!heating_power)
		return

	if(~stat & (NOPOWER|BROKEN)) //Blatently stolen from space heater.
		var/turf/simulated/L = loc
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()
			var/transfer_moles = 0.25 * env.total_moles()

			var/datum/gas_mixture/removed = L.remove_air(transfer_moles)
			
			if(removed)
				var/heat_capacity = removed.heat_capacity() || 1 // Prevent division by zero.
				removed.temperature += heating_power/heat_capacity
				L.assume_air(removed)
				
				use_power(heating_power)
/**

	Here is the big, bad function that broadcasts a message given the appropriate
	parameters.

	@param M:
		Reference to the mob/speaker, stored in signal.data["mob"]

	@param vmask:
		Boolean value if the mob is "hiding" its identity via voice mask, stored in
		signal.data["vmask"]

	@param vmessage:
		If specified, will display this as the message; such as "chimpering"
		for monkies if the mob is not understood. Stored in signal.data["vmessage"].

	@param radio:
		Reference to the radio broadcasting the message, stored in signal.data["radio"]

	@param message:
		The actual string message to display to mobs who understood mob M. Stored in
		signal.data["message"]

	@param name:
		The name to display when a mob receives the message. signal.data["name"]

	@param job:
		The name job to display for the AI when it receives the message. signal.data["job"]

	@param realname:
		The "real" name associated with the mob. signal.data["realname"]

	@param vname:
		If specified, will use this name when mob M is not understood. signal.data["vname"]

	@param data:
		If specified:
				1 -- Will only broadcast to intercoms
				2 -- Will only broadcast to intercoms and station-bounced radios
				3 -- Broadcast to syndicate frequency
				4 -- AI can't track down this person. Useful for imitation broadcasts where you can't find the actual mob

	@param compression:
		If 0, the signal is audible
		If nonzero, the signal may be partially inaudible or just complete gibberish.

	@param level:
		The list of Z levels that the sending radio is broadcasting to. Having 0 in the list broadcasts on all levels

	@param freq
		The frequency of the signal

**/

/* Old, for records.
/proc/Broadcast_Message(var/atom/movable/AM, var/datum/language/speaking,
						var/vmask, var/obj/item/device/radio/radio,
						var/message, var/name, var/job, var/realname,
						var/data, var/compression, var/list/level, var/freq)
*/
/proc/Broadcast_Message(
		var/datum/speech/speech, // Most everything is now in here.
		var/vmask,               // voice mask (bool)
		var/data,                // ???
		var/compression,         // Level of compression
		var/list/level)          // z-levels that can hear us
#ifdef SAY_DEBUG
	if(speech.speaker)
		say_testing(speech.speaker, "broadcast_message start - Sending \"[html_encode(speech.message)]\" to [speech.frequency]")
#endif

	// Cut down on the message sizes.
	speech.message = copytext(speech.message, 1, MAX_BROADCAST_LEN)

	if(!speech.message)
		return

	var/list/radios = list()

	var/atom/movable/virtualspeaker/virt = new(null)
	virt.name = speech.name
	virt.job = speech.job
	//virt.languages = AM.languages
	virt.source = speech.speaker
	virt.faketrack = (data == 4) ? 1 : 0
	virt.radio = speech.radio

	if (compression > 0)
		speech.message = Gibberish(speech.message, compression + 40)

	switch (data)
		if (1) // broadcast only to intercom devices
			for (var/obj/item/device/radio/intercom/R in all_radios["[speech.frequency]"])
				if (R && R.receive_range(speech.frequency, level) > -1)
					radios += R
		if (2) // broadcast only to intercoms and station-bounced radios
			for (var/obj/item/device/radio/R in all_radios["[speech.frequency]"])
				if (istype(R, /obj/item/device/radio/headset))
					continue

				if (R && R.receive_range(speech.frequency, level) > -1)
					radios += R
		else // broadcast to ALL radio devices
			for (var/obj/item/device/radio/R in all_radios["[speech.frequency]"])
				if (R && R.receive_range(speech.frequency, level) > -1)
					radios += R

			/*
			 * Syndicate radios use magic that allows them to hear everything.
			 * This was already the case, now it just doesn't need the allinone anymore.
			 * Solves annoying bugs that aren't worth solving.
			 */
			if (num2text(speech.frequency) in radiochannelsreverse)
				for (var/obj/item/device/radio/R in all_radios["[SYND_FREQ]"])
					if (R && R.receive_range(SYND_FREQ, list(R.z)) > -1)
						radios |= R

	// get a list of mobs who can hear from the radios we collected and observers
	var/list/listeners = get_mobs_in_radio_ranges(radios) | observers

	radios = null

	// TODO: Review this usage.
	var/rendered = virt.render_speech(speech) // always call this on the virtualspeaker to advoid issues
	//var/listeners_sent = 0
	for (var/atom/movable/listener in listeners)
		if (listener)
			//listeners_sent++
			listener.Hear(speech, rendered)

	if (length(listeners))
		listeners = null

			// --- This following recording is intended for research and feedback in the use of department radio channels ---

		var/enc_message = speech.speaker.say_quote("\"[speech.message]\"") // Does not need to be html_encoded - N3X
		var/blackbox_msg = "[speech.speaker] [enc_message]"

		if(istype(blackbox))
			switch(speech.frequency)
				if(1459)
					blackbox.msg_common += blackbox_msg
				if(1351)
					blackbox.msg_science += blackbox_msg
				if(1353)
					blackbox.msg_command += blackbox_msg
				if(1355)
					blackbox.msg_medical += blackbox_msg
				if(1357)
					blackbox.msg_engineering += blackbox_msg
				if(1359)
					blackbox.msg_security += blackbox_msg
				if(1441)
					blackbox.msg_deathsquad += blackbox_msg
				if(1345)
					blackbox.msg_ert += blackbox_msg
				if(1213)
					blackbox.msg_syndicate += blackbox_msg
				if(1349)
					blackbox.msg_service += blackbox_msg
				if(1347)
					blackbox.msg_cargo += blackbox_msg
				else
					blackbox.messages += blackbox_msg
#ifdef SAY_DEBUG
	if(speech.speaker)
		say_testing(speech.speaker, "Broadcast_Message finished with [listeners ? listeners.len : 0] listener\s getting our message, [speech.message] lang = [speech.language ? speech.language.name : "none"]")
#endif

	spawn(50)
		qdel(virt)

/* Obsolete, RIP
/proc/Broadcast_SimpleMessage(var/source, var/frequency, var/text, var/data, var/mob/M, var/compression, var/level)


  /* ###### Prepare the radio connection ###### */

	if(!M)
		var/mob/living/carbon/human/H = new
		M = H

	var/datum/radio_frequency/connection = radio_controller.return_frequency(frequency)

	var/display_freq = connection.frequency

	var/list/receive = list()


	// --- Broadcast only to intercom devices ---

	if(data == 1)
		for (var/obj/item/device/radio/intercom/R in connection.devices["[RADIO_CHAT]"])
			var/turf/position = get_turf(R)
			if(position && position.z == level)
				receive |= R.send_hear(display_freq, level)


	// --- Broadcast only to intercoms and station-bounced radios ---

	else if(data == 2)
		for (var/obj/item/device/radio/R in connection.devices["[RADIO_CHAT]"])

			if(istype(R, /obj/item/device/radio/headset))
				continue
			var/turf/position = get_turf(R)
			if(position && position.z == level)
				receive |= R.send_hear(display_freq)


	// --- Broadcast to syndicate radio! ---

	else if(data == 3)
		var/datum/radio_frequency/syndicateconnection = radio_controller.return_frequency(SYND_FREQ)

		for (var/obj/item/device/radio/R in syndicateconnection.devices["[RADIO_CHAT]"])
			var/turf/position = get_turf(R)
			if(position && position.z == level)
				receive |= R.send_hear(SYND_FREQ)


	// --- Broadcast to ALL radio devices ---

	else
		for (var/obj/item/device/radio/R in connection.devices["[RADIO_CHAT]"])
			var/turf/position = get_turf(R)
			if(position && position.z == level)
				receive |= R.send_hear(display_freq)


  /* ###### Organize the receivers into categories for displaying the message ###### */

	// Understood the message:
	var/list/heard_normal 	= list() // normal message

	// Did not understand the message:
	var/list/heard_garbled	= list() // garbled message (ie "f*c* **u, **i*er!")
	var/list/heard_gibberish= list() // completely screwed over message (ie "F%! (O*# *#!<>&**%!")

	for (var/mob/R in receive)

	  /* --- Loop through the receivers and categorize them --- */

		if (R.client && !(R.client.prefs.toggles & CHAT_RADIO)) //Adminning with 80 people on can be fun when you're trying to talk and all you can hear is radios.
			continue


		// --- Check for compression ---
		if(compression > 0)

			heard_gibberish += R
			continue

		// --- Can understand the speech ---

		if (R.say_understands(M))

			heard_normal += R

		// --- Can't understand the speech ---

		else
			// - Just display a garbled message -

			heard_garbled += R


  /* ###### Begin formatting and sending the message ###### */
	if (length(heard_normal) || length(heard_garbled) || length(heard_gibberish))

	  /* --- Some miscellaneous variables to format the string output --- */
		var/part_a = "<span class='radio'><span class='name'>" // goes in the actual output
		var/freq_text // the name of the channel

		// --- Set the name of the channel ---
		switch(display_freq)

			if(SYND_FREQ)
				freq_text = "#unkn"
			if(COMM_FREQ)
				freq_text = "Command"
			if(1351)
				freq_text = "Science"
			if(1355)
				freq_text = "Medical"
			if(1357)
				freq_text = "Engineering"
			if(1359)
				freq_text = "Security"
//			if(1349)
//				freq_text = "Mining"
			if(1347)
				freq_text = "Supply"
			if(DJ_FREQ)
				freq_text = "DJ"
		//There's probably a way to use the list var of channels in code\game\communications.dm to make the dept channels non-hardcoded, but I wasn't in an experimentive mood. --NEO


		// --- If the frequency has not been assigned a name, just use the frequency as the name ---

		if(!freq_text)
			freq_text = format_frequency(display_freq)

		// --- Some more pre-message formatting ---

		var/part_b_extra = ""
		if(data == 3) // intercepted radio message
			part_b_extra = " <i>(Intercepted)</i>"

		// Create a radio headset for the sole purpose of using its icon
		var/obj/item/device/radio/headset/radio = new

		var/part_b = "</span><b> [bicon(radio)]\[[freq_text]\][part_b_extra]</b> <span class='message'>" // Tweaked for security headsets -- TLE
		var/part_c = "</span></span>"

		if (display_freq==SYND_FREQ)
			part_a = "<span class='syndradio'><span class='name'>"
		else if (display_freq==COMM_FREQ)
			part_a = "<span class='comradio'><span class='name'>"
		else if (display_freq==SCI_FREQ)
			part_a = "<span class='sciradio'><span class='name'>"
		else if (display_freq==MED_FREQ)
			part_a = "<span class='medradio'><span class='name'>"
		else if (display_freq==ENG_FREQ)
			part_a = "<span class='engradio'><span class='name'>"
		else if (display_freq==SEC_FREQ)
			part_a = "<span class='secradio'><span class='name'>"
		else if (display_freq==SERV_FREQ)
			part_a = "<span class='serradio'><span class='name'>"
		else if (display_freq==SUPP_FREQ)
			part_a = "<span class='supradio'><span class='name'>"
		else if (display_freq==DSQUAD_FREQ)
			part_a = "<span class='dsquadradio'><span class='name'>"
		else if (display_freq==RESTEAM_FREQ)
			part_a = "<span class='dsquadradio'><span class='name'>"
		else if (display_freq==AIPRIV_FREQ)
			part_a = "<span class='aiprivradio'><span class='name'>"
		else if (display_freq==DJ_FREQ)
			part_a = "<span class='djradio'><span class='name'>"

		// --- This following recording is intended for research and feedback in the use of department radio channels ---

		var/part_blackbox_b = "</span><b> \[[freq_text]\]</b> <span class='message'>" // Tweaked for security headsets -- TLE
		var/blackbox_msg = "[part_a][source][part_blackbox_b]\"[text]\"[part_c]"
		//var/blackbox_admin_msg = "[part_a][M.name] (Real name: [M.real_name])[part_blackbox_b][quotedmsg][part_c]"

		//BR.messages_admin += blackbox_admin_msg
		if(istype(blackbox))
			switch(display_freq)
				if(1459)
					blackbox.msg_common += blackbox_msg
				if(1351)
					blackbox.msg_science += blackbox_msg
				if(1353)
					blackbox.msg_command += blackbox_msg
				if(1355)
					blackbox.msg_medical += blackbox_msg
				if(1357)
					blackbox.msg_engineering += blackbox_msg
				if(1359)
					blackbox.msg_security += blackbox_msg
				if(1441)
					blackbox.msg_deathsquad += blackbox_msg
				if(1345)
					blackbox.msg_ert += blackbox_msg
				if(1213)
					blackbox.msg_syndicate += blackbox_msg
				if(1349)
					blackbox.msg_service += blackbox_msg
				if(1347)
					blackbox.msg_cargo += blackbox_msg
				else
					blackbox.messages += blackbox_msg

		//End of research and feedback code.

	 /* ###### Send the message ###### */

		/* --- Process all the mobs that heard the voice normally (understood) --- */

		if (length(heard_normal))
			var/rendered = "[part_a][source][part_b]\"[text]\"[part_c]"

			for (var/mob/R in heard_normal)
				R.show_message(rendered, 2)

		/* --- Process all the mobs that heard a garbled voice (did not understand) --- */
			// Displays garbled message (ie "f*c* **u, **i*er!")

		if (length(heard_garbled))
			var/quotedmsg = "\"[stars(text)]\""
			var/rendered = "[part_a][source][part_b][quotedmsg][part_c]"

			for (var/mob/R in heard_garbled)
				R.show_message(rendered, 2)


		/* --- Complete gibberish. Usually happens when there's a compressed message --- */

		if (length(heard_gibberish))
			var/quotedmsg = "\"[Gibberish(text, compression + 50)]\""
			var/rendered = "[part_a][Gibberish(source, compression + 50)][part_b][quotedmsg][part_c]"

			for (var/mob/R in heard_gibberish)
				R.show_message(rendered, 2)
*/

//Use this to test if an obj can communicate with a Telecommunications Network

/atom/proc/test_telecomms()
	var/datum/signal/signal = src.telecomms_process()
	var/turf/position = get_turf(src)
	return (position.z in signal.data["level"] && signal.data["done"])

/atom/proc/telecomms_process()
	// First, we want to generate a new radio signal
	var/datum/signal/signal = new()
	signal.transmission_method = SIGNAL_SUBSPACE
	var/turf/pos = get_turf(src)

	// --- Finally, tag the actual signal with the appropriate values ---
	signal.data = list(
		//"slow" = 0, // how much to sleep() before broadcasting - simulates net lag
		"message" = "TEST",
		"compression" = rand(45, 50), // If the signal is compressed, compress our message too.
		"traffic" = 0, // dictates the total traffic sum that the signal went through
		"type" = 4, // determines what type of radio input it is: test broadcast
		"reject" = 0,
		"done" = 0,
		"level" = pos.z // The level it is being broadcasted at.
	)
	signal.frequency = 1459// Common channel

  //#### Sending the signal to all subspace receivers ####//
	for(var/obj/machinery/telecomms/receiver/R in telecomms_list)
		R.receive_signal(signal)

	sleep(rand(10,25))

	//world.log << "Level: [signal.data["level"]] - Done: [signal.data["done"]]"

	return signal