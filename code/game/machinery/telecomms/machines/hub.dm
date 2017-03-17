/*
	The HUB idles until it receives information. It then passes on that information
	depending on where it came from.

	This is the heart of the Telecommunications Network, sending information where it
	is needed. It mainly receives information from long-distance Relays and then sends
	that information to be processed. Afterwards it gets the uncompressed information
	from Servers/Buses and sends that back to the relay, to then be broadcasted.
*/

/obj/machinery/telecomms/hub
	name = "telecommunication hub"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "hub"
	desc = "A mighty piece of hardware used to send/receive massive amounts of data."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 80
	machinetype = 7
	heating_power = 40
	long_range_link = 1
	netspeed = 40

/obj/machinery/telecomms/hub/New()
	..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/telecomms/hub,
		/obj/item/weapon/stock_parts/subspace/filter,
		/obj/item/weapon/stock_parts/subspace/filter,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator
	)

	RefreshParts()

/obj/machinery/telecomms/hub/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	if(is_freq_listening(signal))
		if(istype(machine_from, /obj/machinery/telecomms/receiver))
			//If the signal is compressed, send it to the bus.
			relay_information(signal, "/obj/machinery/telecomms/bus", 1) // ideally relay the copied information to bus units
		else
			// Get a list of relays that we're linked to, then send the signal to their levels.
			relay_information(signal, "/obj/machinery/telecomms/relay", 1)
			relay_information(signal, "/obj/machinery/telecomms/broadcaster", 1) // Send it to a broadcaster.