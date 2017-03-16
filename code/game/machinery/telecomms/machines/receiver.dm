/*
	The receiver idles and receives messages from subspace-compatible radio equipment;
	primarily headsets. They then just relay this information to all linked devices,
	which can would probably be network hubs.

	Link to Processor Units in case receiver can't send to bus units.
*/

/obj/machinery/telecomms/receiver
	name = "subspace receiver"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "receiver"
	desc = "This machine has a dish-like shape and green lights. It is designed to detect and process subspace radio activity."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 30
	machinetype = 1
	heatgen = 0
	circuitboard = "/obj/item/weapon/circuitboard/telecomms/receiver"

/obj/machinery/telecomms/receiver/receive_signal(datum/signal/signal)
#ifdef SAY_DEBUG
	var/mob/mob = signal.data["mob"]
	var/datum/language/language = signal.data["language"]
	var/langname = (language ? language.name : "No language")
	say_testing(mob, "[src] received radio signal from us, language [langname]")
#endif

	if(!on) // has to be on to receive messages
		return
	if(!signal)
		return
	if(!check_receive_level(signal))
		return
	say_testing(mob, "[src] is on, has signal, and receive is good")
	if(signal.transmission_method == 2)

		if(is_freq_listening(signal)) // detect subspace signals

			//Remove the level and then start adding levels that it is being broadcasted in.
			signal.data["level"] = list()

			var/can_send = relay_information(signal, "/obj/machinery/telecomms/hub") // ideally relay the copied information to relays
			if(!can_send)
				relay_information(signal, "/obj/machinery/telecomms/bus") // Send it to a bus instead, if it's linked to one
		else
			say_testing(mob, "[src] is not listening")
	else
		say_testing(mob, "bad transmission method")

/obj/machinery/telecomms/receiver/proc/check_receive_level(datum/signal/signal)


	if(signal.data["level"] != listening_level)
		for(var/obj/machinery/telecomms/hub/H in links)
			var/list/connected_levels = list()
			for(var/obj/machinery/telecomms/relay/R in H.links)
				if(R.can_receive(signal))
					connected_levels |= R.listening_level
			if(signal.data["level"] in connected_levels)
				return 1
		return 0
	return 1