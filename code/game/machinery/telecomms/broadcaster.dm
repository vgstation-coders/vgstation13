//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
	The broadcaster sends processed messages to all radio devices in the game. They
	do not have to be headsets; intercoms and station-bounced radios suffice.

	They receive their message from a server after the message has been logged.
*/

var/list/recentmessages = list() // global list of recent messages broadcasted : used to circumvent massive radio spam
var/message_delay = 0 // To make sure restarting the recentmessages list is kept in sync

/obj/machinery/telecomms/broadcaster
	name = "Subspace Broadcaster"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "broadcaster"
	desc = "A dish-shaped machine used to broadcast processed subspace signals."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 25
	machinetype = 5
	heatgen = 0
	delay = 7
	circuitboard = "/obj/item/weapon/circuitboard/telecomms/broadcaster"

/obj/machinery/telecomms/broadcaster/receive_information(var/datum/signal/signal, var/obj/machinery/telecomms/machine_from)
	// Don't broadcast rejected signals
	if(signal.data["reject"])
		return

	if(signal.data["message"])

		// Prevents massive radio spam
		signal.data["done"] = 1 // mark the signal as being broadcasted
		// Search for the original signal and mark it as done as well
		var/datum/signal/original = signal.data["original"]
		if(original)
			original.data["done"] = 1
			original.data["compression"] = signal.data["compression"]
			original.data["level"] = signal.data["level"]

		var/signal_message = "[signal.frequency]:[signal.data["message"]]:[signal.data["realname"]]"
		if(signal_message in recentmessages)
			return
		recentmessages.Add(signal_message)

		// This may be causing some performance issues. - N3X
		if(signal.data["slow"] > 0)
			sleep(signal.data["slow"]) // simulate the network lag if necessary

		signal.data["level"] |= listening_level

	   /** #### - Normal Broadcast - #### **/

		if(signal.data["type"] == 0)
			var/datum/speech/speech = getFromPool(/datum/speech)
			speech.from_signal(signal)
			/* ###### Broadcast a message using signal.data ###### */
			Broadcast_Message(speech, signal.data["vmask"], 0, signal.data["compression"], signal.data["level"])



	   /** #### - Simple Broadcast - #### **/

		if(signal.data["type"] == 1)
			/* ###### Broadcast a message using signal.data ###### */
			/*
			Broadcast_SimpleMessage(signal.data["name"], signal.frequency,
								  signal.data["message"],null, null,
								  signal.data["compression"], listening_level)
			*/
			var/datum/speech/speech = getFromPool(/datum/speech)
			speech.from_signal(signal)
			/* ###### Broadcast a message using signal.data ###### */
			Broadcast_Message(speech, signal.data["vmask"], null, signal.data["compression"], signal.data["level"])



	   /** #### - Artificial Broadcast - #### **/
	   			// (Imitates a mob)

		if(signal.data["type"] == 2)

			/* ###### Broadcast a message using signal.data ###### */
				// Parameter "data" as 4: AI can't track this person/mob
			var/datum/speech/speech = getFromPool(/datum/speech)
			speech.from_signal(signal)
			/* ###### Broadcast a message using signal.data ###### */
			Broadcast_Message(speech, signal.data["vmask"], 4, signal.data["compression"], signal.data["level"])


		if(!message_delay)
			message_delay = 1
			spawn(10)
				message_delay = 0
				recentmessages = list()

		/* --- Do a snazzy animation! --- */
		flick("broadcaster_send", src)

/obj/machinery/telecomms/broadcaster/Destroy()
	// In case message_delay is left on 1, otherwise it won't reset the list and people can't say the same thing twice anymore.
	if(message_delay)
		message_delay = 0
	..()


/*
	Basically just an empty shell for receiving and broadcasting radio messages. Not
	very flexible, but it gets the job done.
*/

/obj/machinery/telecomms/allinone
	name = "Telecommunications Mainframe"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "comm_server"
	desc = "A compact machine used for portable subspace telecommuniations processing."
	density = 1
	anchored = 1
	use_power = 0
	idle_power_usage = 0
	machinetype = 6
	heatgen = 0
	var/intercept = 0 // if nonzero, broadcasts all messages to syndicate channel

/obj/machinery/telecomms/allinone/receive_signal(datum/signal/signal)
#ifdef SAY_DEBUG
	var/mob/mob = signal.data["mob"]
	var/datum/language/language = signal.data["language"]
	var/langname = (language ? language.name : "No language")
	say_testing(mob, "[src] received radio signal from us, language [langname]")
#endif

	if(!on) // has to be on to receive messages
		return

	if(is_freq_listening(signal)) // detect subspace signals

		signal.data["done"] = 1 // mark the signal as being broadcasted
		signal.data["compression"] = 0

		// Search for the original signal and mark it as done as well
		var/datum/signal/original = signal.data["original"]
		if(original)
			original.data["done"] = 1

		if(signal.data["slow"] > 0)
			sleep(signal.data["slow"]) // simulate the network lag if necessary

		/* ###### Broadcast a message using signal.data ###### */


		if(signal.frequency == SYND_FREQ) // if syndicate broadcast, just
			var/datum/speech/speech = getFromPool(/datum/speech)
			speech.from_signal(signal)
			/* ###### Broadcast a message using signal.data ###### */
			Broadcast_Message(speech, signal.data["vmask"], 0, signal.data["compression"], list(0, z))
	else
		say_testing(mob, "[src] is not listening")
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

	var/atom/movable/virtualspeaker/virt = getFromPool(/atom/movable/virtualspeaker, null)
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
		returnToPool(virt)

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
			if(COMMON_FREQ)
				freq_text = "Common"
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
		else if (display_freq==COMMON_FREQ)
			part_a = "<span class='commonradio'><span class='name'>"

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
	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.transmission_method = 2 // 2 would be a subspace transmission.
	var/turf/pos = get_turf(src)

	// --- Finally, tag the actual signal with the appropriate values ---
	signal.data = list(
		"slow" = 0, // how much to sleep() before broadcasting - simulates net lag
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
