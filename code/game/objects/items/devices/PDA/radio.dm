/obj/item/radio/integrated
	name = "PDA radio module"
	desc = "An electronic radio system of nanotrasen origin."
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"
	var/obj/item/device/pda/hostpda = null

	var/on = 0 //Are we currently active?
	var/menu_message = ""

/obj/item/radio/integrated/Destroy()
	. = ..()
	hostpda = null

/obj/item/radio/integrated/Adjacent(var/atom/neighbor)
	return hostpda.Adjacent(neighbor)

/*
 *	Radio Cartridge, essentially a signaler.
 */


/obj/item/radio/integrated/signal
	var/frequency = 1457
	var/code = 30.0
	var/last_transmission
	var/datum/radio_frequency/radio_connection

/obj/item/radio/integrated/signal/New()
	..()
	if(ticker && ticker.current_state == GAME_STATE_PLAYING)
		initialize()

/obj/item/radio/integrated/signal/initialize()
	if (!radio_controller)
		return
	if (src.frequency < 1441 || src.frequency > 1489)
		src.frequency = sanitize_frequency(src.frequency)

	set_frequency(frequency)

/obj/item/radio/integrated/signal/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency)

/obj/item/radio/integrated/signal/proc/send_signal(message="ACTIVATE")


	if(last_transmission && world.time < (last_transmission + 5))
		return
	last_transmission = world.time

	investigation_log(I_WIRES, "used as signaler by [key_name(usr)] - [format_frequency(frequency)]/[code]")

	var/datum/signal/signal = new /datum/signal
	signal.source = src
	signal.encryption = code
	signal.data["message"] = message

	radio_connection.post_signal(src, signal)

	return

/obj/item/radio/integrated/signal/bot/Topic(href, href_list)
	if (..())
		return

	// -- Command for a bot, ideentified by name
	// Feature: NT is lazy and will just send the same signal to two bots if they have the same name
	if (href_list["bot"])
		// Sanity
		if (!href_list["command"])
			return
		var/mob/user = locate(href_list["user"])
		if (!user || user != usr)
			return

		log_astar_command("Sending [href_list["command"]] to [href_list["bot"]]")

		// Actual signal sent
		var/datum/signal/signal = new /datum/signal
		signal.source = src
		signal.transmission_method = 1
		signal.data["target"] = href_list["bot"]
		signal.data["command"] = href_list["command"]
		radio_connection.post_signal(src, signal)

		if (istype(loc.loc, /obj/item/device/pda))
			var/obj/item/device/pda/P = loc.loc
			P.attack_self(usr) // refresh

/obj/item/radio/integrated/signal/bot/beepsky
	frequency = 1447

/obj/item/radio/integrated/signal/bot/mule
	frequency = 1447

/obj/item/radio/integrated/signal/bot/janitor
	frequency = 1447

/obj/item/radio/integrated/signal/bot/medbot
	frequency = 1447

/obj/item/radio/integrated/signal/bot/floorbot
	frequency = 1447
