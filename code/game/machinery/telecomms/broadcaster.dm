//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
	The broadcaster sends processed messages to all radio devices in the game. They
	do not have to be headsets; intercoms and station-bounced radios suffice.

	They receive their message from a server after the message has been logged.
*/

var/list/recentmessages = list() // global list of recent messages broadcasted : used to circumvent massive radio spam
var/message_delay = 0 // To make sure restarting the recentmessages list is kept in sync

/obj/machinery/telecomms/broadcaster
	name = "telecommunications subspace broadcaster"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcaster"
	moody_state = "overlay_broadcaster"
	desc = "A dish-shaped machine used to broadcast processed subspace signals."
	density = 1
	anchored = 1
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 25
	machinetype = 5
	delay = 7

	hack_abilities = list(
		/datum/malfhack_ability/fake_message,
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet
	)

/obj/machinery/telecomms/broadcaster/New()
	..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/telecomms/broadcaster,
		/obj/item/weapon/stock_parts/subspace/filter,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/subspace/crystal,
		/obj/item/weapon/stock_parts/micro_laser/high,
		/obj/item/weapon/stock_parts/micro_laser/high
	)

	RefreshParts()

/obj/machinery/telecomms/broadcaster/receive_information(var/datum/signal/signal, var/obj/machinery/telecomms/machine_from)
	// Don't broadcast rejected signals
	if(signal.data["reject"])
		return

	signal.data["traffic"] += 1 //Valid step point.

	if(signal.data["trace"])
		var/obj/machinery/computer/telecomms/monitor/M = signal.data["trace"]
		M.receive_trace(src, "None. The operation contained [signal.data["traffic"]] steps")


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
			var/datum/speech/speech = new /datum/speech
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
			var/datum/speech/speech = new /datum/speech
			speech.from_signal(signal)
			/* ###### Broadcast a message using signal.data ###### */
			Broadcast_Message(speech, signal.data["vmask"], null, signal.data["compression"], signal.data["level"])



	   /** #### - Artificial Broadcast - #### **/
	   			// (Imitates a mob)

		if(signal.data["type"] == 2)

			/* ###### Broadcast a message using signal.data ###### */
				// Parameter "data" as 4: AI can't track this person/mob
			var/datum/speech/speech = new /datum/speech
			speech.from_signal(signal)
			/* ###### Broadcast a message using signal.data ###### */
			Broadcast_Message(speech, signal.data["vmask"], 4, signal.data["compression"], signal.data["level"])


		if(!message_delay)
			message_delay = 1
			spawn(10)
				message_delay = 0
				recentmessages = list()

		/* --- Do a snazzy animation! --- */
		update_moody_light('icons/lighting/moody_lights.dmi', "overlay_broadcaster_send")
		spawn(22)
			update_moody_light('icons/lighting/moody_lights.dmi', moody_state)
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
	name = "telecommunications mainframe"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "server"
	desc = "A compact machine used for portable subspace telecommuniations processing."
	density = 1
	anchored = 1
	use_power = MACHINE_POWER_USE_NONE
	idle_power_usage = 0
	machinetype = 6
	heating_power = 0
	var/intercept = 0 // if nonzero, broadcasts all messages to syndicate channel
	var/syndi_allinone = 0
	var/raider_allinone = 0

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


		if(signal.frequency == SYND_FREQ && syndi_allinone == 1) // if syndicate broadcast, just
			var/datum/speech/speech = new /datum/speech
			speech.from_signal(signal)
			/* ###### Broadcast a message using signal.data ###### */
			Broadcast_Message(speech, signal.data["vmask"], 0, signal.data["compression"], list(0, z))

		if(signal.frequency == RAID_FREQ && raider_allinone == 1) // if raider broadcast, just
			var/datum/speech/speech = new /datum/speech
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
	/// Jamming code
	var/list/gibberish_radios = list() // list of radios that display disrupted messages
	var/jamming_severity = 0

	var/atom/movable/virtualspeaker/virt = new /atom/movable/virtualspeaker(null)
	virt.name = speech.name
	virt.job = speech.job
	//virt.languages = AM.languages
	virt.source = speech.speaker
	virt.radio = speech.radio

	if (compression > 0)
		speech.message = Gibberish(speech.message, compression + 40)

	switch (data)
		if (1) // broadcast only to intercom devices
			for (var/obj/item/device/radio/intercom/R in all_radios["[speech.frequency]"])
				if (R && R.receive_range(speech.frequency, level) > -1)
					jamming_severity = radio_jamming_severity(R)
					if (is_completely_jammed(jamming_severity))
						continue
					if (jamming_severity > 0)
						gibberish_radios += new /datum/jammed_radio_src(R, jamming_severity)
						continue
					radios += R
		if (2) // broadcast only to intercoms and station-bounced radios
			for (var/obj/item/device/radio/R in all_radios["[speech.frequency]"])
				if (istype(R, /obj/item/device/radio/headset))
					continue

				if (R && R.receive_range(speech.frequency, level) > -1)
					jamming_severity = radio_jamming_severity(R)
					if (is_completely_jammed(jamming_severity))
						continue
					if (jamming_severity > 0)
						gibberish_radios += new /datum/jammed_radio_src(R, jamming_severity)
						continue
					radios += R
		else // broadcast to ALL radio devices
			for (var/obj/item/device/radio/R in all_radios["[speech.frequency]"])
				if (R && R.receive_range(speech.frequency, level) > -1)
					jamming_severity = radio_jamming_severity(R)
					if (is_completely_jammed(jamming_severity))
						continue
					if (jamming_severity > 0)
						gibberish_radios += new /datum/jammed_radio_src(R, jamming_severity)
						continue
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
	var/list/gibberish_listeners = get_mobs_in_jammed_radio_ranges(gibberish_radios)
	radios = null
	gibberish_radios = null

	//Scramble messages if radio blackout is enabled
	if(malf_radio_blackout)
		speech.message = Gibberish(speech.message, 95)
	// TODO: Review this usage.
	var/rendered = virt.render_speech(speech) // always call this on the virtualspeaker to advoid issues
	for (var/atom/movable/listener in listeners)
		if (listener)
			listener.Hear(speech, rendered)

	// Note that a mob can hear both fine and fucked up version of the same message - this is intentional
	for (var/J in gibberish_listeners)
		var/datum/jammed_mob_dst/dst = gibberish_listeners[J]
		if (dst.attached)
			// everyone affected gets a fucked up version
			var/datum/speech/nu_speech = speech.clone()
			nu_speech.message = Gibberish(nu_speech.message, dst.severity)
			dst.attached.Hear(nu_speech, virt.render_speech(nu_speech))

	if (length(gibberish_listeners))
		gibberish_listeners = null


	if (length(listeners))
		listeners = null

			// --- This following recording is intended for research and feedback in the use of department radio channels ---

		var/enc_message = speech.speaker.say_quote("\"[speech.message]\"") // Does not need to be html_encoded - N3X
		var/blackbox_msg = "[speech.speaker] [enc_message]"

		if(istype(blackbox))
			if(speech.frequency == COMMON_FREQ)
				blackbox.msg_common += blackbox_msg
			if(speech.frequency == SCI_FREQ)
				blackbox.msg_science += blackbox_msg
			if(speech.frequency == COMM_FREQ)
				blackbox.msg_command += blackbox_msg
			if(speech.frequency == MED_FREQ)
				blackbox.msg_medical += blackbox_msg
			if(speech.frequency == ENG_FREQ)
				blackbox.msg_engineering += blackbox_msg
			if(speech.frequency == SEC_FREQ)
				blackbox.msg_security += blackbox_msg
			if(speech.frequency ==DSQUAD_FREQ)
				blackbox.msg_deathsquad += blackbox_msg
			if(speech.frequency == RESPONSE_FREQ)
				blackbox.msg_ert += blackbox_msg
			if(speech.frequency == SYND_FREQ)
				blackbox.msg_syndicate += blackbox_msg
			if(speech.frequency == RAID_FREQ)
				blackbox.msg_raider += blackbox_msg
			if(speech.frequency == SER_FREQ)
				blackbox.msg_service += blackbox_msg
			if(speech.frequency == SUP_FREQ)
				blackbox.msg_cargo += blackbox_msg
			else
				blackbox.messages += blackbox_msg
#ifdef SAY_DEBUG
	if(speech.speaker)
		say_testing(speech.speaker, "Broadcast_Message finished with [listeners ? listeners.len : 0] listener\s getting our message, [speech.message] lang = [speech.language ? speech.language.name : "none"]")
#endif

	spawn(50)
		qdel(virt)

//Use this to test if an obj can communicate with a Telecommunications Network
/atom/proc/test_telecomms()
	var/datum/signal/signal = src.telecomms_process()
	var/turf/position = get_turf(src)
	return (position.z in signal.data["level"] && signal.data["done"])

/atom/proc/telecomms_process()
	// First, we want to generate a new radio signal
	var/datum/signal/signal = new /datum/signal
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
	signal.frequency = COMMON_FREQ// Common channel

  //#### Sending the signal to all subspace receivers ####//
	for(var/obj/machinery/telecomms/receiver/R in telecomms_list)
		R.receive_signal(signal)

	sleep(rand(10,25))

	//world.log << "Level: [signal.data["level"]] - Done: [signal.data["done"]]"

	return signal
