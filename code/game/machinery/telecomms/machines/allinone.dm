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