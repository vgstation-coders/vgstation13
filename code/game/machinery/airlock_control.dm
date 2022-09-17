#define AIRLOCK_CONTROL_RANGE 8
#define RADIO_FILTER_EXPLANATION {"Set the radio filter.
3 is for signalers
4 is for machinery (emitters, etc)
6 is for airlocks (default)"}


// This code allows for airlocks to be controlled externally by setting an id_tag and comm frequency (disables ID access)
/obj/machinery/door/airlock
	var/frequency
	var/shockedby = list()
	var/datum/radio_frequency/radio_connection

/obj/machinery/door/airlock/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption)
		return

	if(id_tag != signal.data["tag"] || !signal.data["command"])
		return

	switch(signal.data["command"])
		if("cycle")
			if(density)
				open(1)
			else
				close(1)

		if("open")
			open(1)

		if("close")
			close(1)

		if("unlock")
			locked = 0
			playsound(loc, "sound/machines/door_unbolt.ogg", 50, 1, -1)
			update_icon()

		if("lock")
			locked = 1
			playsound(loc, "sound/machines/door_bolt.ogg", 50, 1, -1)
			update_icon()

		if("toggle_lock")
			toggle_bolts()
			sleep(2)
			update_icon()

		if("secure_cycle")
			if(density)
				if(locked)
					locked = 0
					playsound(loc, "sound/machines/door_unbolt.ogg", 50, 1, -1)
					update_icon()
					sleep(2)
				open(1)

				locked = 1
				playsound(loc, "sound/machines/door_bolt.ogg", 50, 1, -1)
				update_icon()
			else
				if(locked)
					locked = 0
					playsound(loc, "sound/machines/door_unbolt.ogg", 50, 1, -1)
				close(1)

				locked = 1
				playsound(loc, "sound/machines/door_bolt.ogg", 50, 1, -1)
				sleep(2)
				update_icon()

		if("secure_open")
			if(locked)
				locked = 0
				playsound(loc, "sound/machines/door_unbolt.ogg", 50, 1, -1)
				update_icon()
				sleep(2)
			open(1)

			locked = 1
			playsound(loc, "sound/machines/door_bolt.ogg", 50, 1, -1)
			update_icon()

		if("secure_close")
			if(locked)
				locked = 0
				playsound(loc, "sound/machines/door_unbolt.ogg", 50, 1, -1)
			close(1)

			locked = 1
			playsound(loc, "sound/machines/door_bolt.ogg", 50, 1, -1)
			sleep(2)
			update_icon()

	send_status()


/obj/machinery/door/airlock/proc/send_status()
	if(radio_connection)
		var/datum/signal/signal = new /datum/signal
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = id_tag
		signal.data["timestamp"] = world.time

		signal.data["door_status"] = density?("closed"):("open")
		signal.data["lock_status"] = locked?("locked"):("unlocked")

		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)


/obj/machinery/door/airlock/open(surpress_send)
	. = ..()
	if(!surpress_send)
		send_status()


/obj/machinery/door/airlock/close(surpress_send)
	. = ..()
	if(!surpress_send)
		send_status()


/obj/machinery/door/airlock/Bumped(atom/AM)
	..(AM)
	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if(density && radio_connection && mecha.occupant && (src.allowed(mecha.occupant) || src.check_access_list(mecha.operation_req_access)))
			var/datum/signal/signal = new /datum/signal
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = id_tag
			signal.data["timestamp"] = world.time

			signal.data["door_status"] = density?("closed"):("open")
			signal.data["lock_status"] = locked?("locked"):("unlocked")

			signal.data["bumped_with_access"] = 1

			radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	return

/obj/machinery/door/airlock/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	if(new_frequency)
		frequency = new_frequency
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)


/obj/machinery/door/airlock/initialize()
	if (!radio_controller)
		return
	if(frequency)
		set_frequency(frequency)

	update_icon()


/obj/machinery/door/airlock/New()
	..()

	if(ticker && ticker.current_state == GAME_STATE_PLAYING)
		initialize()

/obj/machinery/airlock_sensor
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_sensor_off"
	name = "airlock sensor"

	anchored = 1
	power_channel = ENVIRON


	var/master_tag
	var/frequency = 1449
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1
	var/alert = 0

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

	machine_flags = MULTITOOL_MENU


/obj/machinery/airlock_sensor/update_icon()
	if(on)
		if(alert)
			icon_state = "airlock_sensor_alert"
		else
			icon_state = "airlock_sensor_standby"
	else
		icon_state = "airlock_sensor_off"

/obj/machinery/airlock_sensor/attack_hand(mob/user)
	if(..())
		return
	var/datum/signal/signal = new /datum/signal
	signal.transmission_method = 1 //radio signal
	signal.data["tag"] = master_tag
	signal.data["command"] = command
	playsound(src,'sound/misc/click.ogg',30,0,-1)
	radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	flick("airlock_sensor_cycle", src)

/obj/machinery/airlock_sensor/process()
	if(on)
		var/datum/signal/signal = new /datum/signal
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = id_tag
		signal.data["timestamp"] = world.time

		var/datum/gas_mixture/air_sample = return_air()

		var/pressure = round(air_sample.return_pressure(),0.1)
		alert = (pressure < ONE_ATMOSPHERE*0.8)

		signal.data["pressure"] = pressure

		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)

	update_icon()

/obj/machinery/airlock_sensor/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)

/obj/machinery/airlock_sensor/initialize()
	if (!radio_controller)
		return
	set_frequency(frequency)

/obj/machinery/airlock_sensor/New()
	..()

	if (ticker && ticker.current_state == GAME_STATE_PLAYING)
		initialize()

/obj/machinery/airlock_sensor/airlock_interior
	command = "cycle_interior"

/obj/machinery/airlock_sensor/airlock_exterior
	command = "cycle_exterior"

/obj/machinery/airlock_sensor/New(turf/loc, var/ndir, var/building=0)
	..()

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		dir = ndir

		//src.tdir = dir		// to fix Vars bug
		//dir = SOUTH

		pixel_x = (dir & 3)? 0 : (dir == 4 ? 24 * PIXEL_MULTIPLIER : -24 * PIXEL_MULTIPLIER)
		pixel_y = (dir & 3)? (dir ==1 ? 24 * PIXEL_MULTIPLIER: -24* PIXEL_MULTIPLIER) : 0

		//build=0
		//stat |= MAINT
		//src.update_icon()

/obj/machinery/airlock_sensor/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return {"
		<ul>
			<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[0]">Reset</a>)</li>
			[format_tag("ID Tag","id_tag")]
			[format_tag("Master ID Tag","master_tag")]
		</ul>"}

/obj/machinery/airlock_sensor/Topic(href,href_list)
	if(..())
		return 0

	if(!issilicon(usr))
		if(!istype(usr.get_active_hand(), /obj/item/device/multitool))
//			testing("Not silicon, not using a multitool.")
			return
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


/obj/machinery/airlock_sensor/attackby(var/obj/item/W, var/mob/user)
	. = ..()
	if(.)
		return .
	if(W.is_screwdriver(user))
		to_chat(user, "You begin to pry \the [src] off the wall...")
		if(do_after(user, src, 50))
			to_chat(user, "You successfully pry \the [src] off the wall.")
			new /obj/item/mounted/frame/airlock_sensor(get_turf(src))
			qdel(src)

/obj/machinery/access_button
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	name = "access button"
	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1449
	var/command = "cycle"
	var/customfilter = RADIO_AIRLOCK
	var/radiofilters = list(
							RADIO_CHAT,
							RADIO_ATMOSIA,
							RADIO_AIRLOCK
							)

	var/datum/radio_frequency/radio_connection

	var/on = 1

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0
	machine_flags = MULTITOOL_MENU

/obj/machinery/access_button/New(turf/loc, var/ndir, var/building=0)
	..()

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		dir = ndir

		//src.tdir = dir		// to fix Vars bug
		//dir = SOUTH

		pixel_x = (dir & 3)? 0 : (dir == 4 ? 24 * PIXEL_MULTIPLIER : -24 * PIXEL_MULTIPLIER)
		pixel_y = (dir & 3)? (dir ==1 ? 24 * PIXEL_MULTIPLIER : -24 * PIXEL_MULTIPLIER) : 0

		//build=0
		//stat |= MAINT
		//src.update_icon()


/obj/machinery/access_button/update_icon()
	if(on)
		icon_state = "access_button_standby"
	else
		icon_state = "access_button_off"


/obj/machinery/access_button/attack_hand(mob/user)
	add_fingerprint(usr)
	playsound(src,'sound/misc/click.ogg',30,0,-1)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		playsound(src, 'sound/machines/buzz-two.ogg', 20, 0, -1)

	else if(radio_connection)
		var/datum/signal/signal = new /datum/signal
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = master_tag
		signal.data["command"] = command

		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = customfilter)
	flick("access_button_cycle", src)


/obj/machinery/access_button/attackby(var/obj/item/W, var/mob/user)
	. = ..()
	if(.)
		return .
	if(W.is_screwdriver(user))
		to_chat(user, "You begin to pry \the [src] off the wall...")
		if(do_after(user, src, 50))
			to_chat(user, "You successfully pry \the [src] off the wall.")
			new /obj/item/mounted/frame/access_button(get_turf(src))
			qdel(src)

/obj/machinery/access_button/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, customfilter)


/obj/machinery/access_button/initialize()
	if (!radio_controller)
		return
	set_frequency(frequency)


/obj/machinery/access_button/New()
	..()

	if(ticker && ticker.current_state == GAME_STATE_PLAYING)
		initialize()

/obj/machinery/access_button/airlock_interior
	frequency = 1449
	command = "cycle_interior"

/obj/machinery/access_button/airlock_exterior
	frequency = 1449
	command = "cycle_exterior"



/obj/machinery/access_button/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return {"
		<ul>
			<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[0]">Reset</a>)</li>
			<li>[format_tag("Master ID Tag","master_tag")]</li>
			<li>[format_tag("Command","command")]</li>
			<li><b>Filter:</b> <a href="?src=\ref[src];set_filter=-1">[customfilter]</a></li>
		</ul>"}

/obj/machinery/access_button/Topic(href,href_list)
	if(..())
		return 1

	if(!issilicon(usr))
		if(!istype(usr.get_active_hand(), /obj/item/device/multitool))
//			testing("Not silicon, not using a multitool.")
			return

	var/obj/item/device/multitool/P = get_multitool(usr)
	if(P)
		if("set_filter" in href_list)
			var/newfilter = input(usr, RADIO_FILTER_EXPLANATION, "Radio Filter", customfilter) as null|anything in radiofilters
			if (newfilter)
				if(usr.incapacitated() || (!issilicon(usr) && !Adjacent(usr)))
					return
				customfilter = newfilter

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

#undef RADIO_FILTER_EXPLANATION
