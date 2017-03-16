/*
	The broadcaster sends processed messages to all radio devices in the game. They
	do not have to be headsets; intercoms and station-bounced radios suffice.

	They receive their message from a server after the message has been logged.
*/

var/list/recentmessages = list() // global list of recent messages broadcasted : used to circumvent massive radio spam
var/message_delay = 0 // To make sure restarting the recentmessages list is kept in sync

/obj/machinery/telecomms/broadcaster
	name = "subspace broadcaster"
	icon = 'icons/obj/machines/telecomms.dmi'
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