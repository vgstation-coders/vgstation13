/obj/machinery/computer/area_atmos
	name = "Area Atmos Computer"
	desc = "A computer used to control the stationary scrubbers and pumps in the area."
	icon_state = "area_atmos"
	circuit = "/obj/item/weapon/circuitboard/area_atmos"

	var/list/connectedscrubbers = new()

	var/range = 25

	light_color = LIGHT_COLOR_CYAN
	light_range_on = 2

	var/zone_text = "This computer is working on a wireless range, the range is currently limited to 25 meters."

/obj/machinery/computer/area_atmos/New()
	..()
	//So the scrubbers have time to spawn
	spawn(10)
		scanscrubbers()

/obj/machinery/computer/area_atmos/proc/scanscrubbers()
	connectedscrubbers = new()

	for(var/obj/machinery/portable_atmospherics/scrubber/huge/scrubber in range(range, src.loc))
		if(istype(scrubber))
			connectedscrubbers += scrubber

/obj/machinery/computer/area_atmos/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/area_atmos/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/area_atmos/attack_hand(var/mob/user as mob)
	scanscrubbers()
	return src.ui_interact(user)

/obj/machinery/computer/area_atmos/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/data[0]
	data["zone_text"] = zone_text
	var/list/scrubbers = list()
	if(connectedscrubbers.len)
		for(var/obj/machinery/portable_atmospherics/scrubber/huge/scrubber in connectedscrubbers)
			var/scrubber_info[0]
			scrubber_info["id"] = scrubber.id
			scrubber_info["full_name"] = scrubber.name
			scrubber_info["pressure"] = scrubber.air_contents.pressure
			scrubber_info["isOperating"] = scrubber.on
			scrubbers += list(scrubber_info)
	data["scrubbers"] = scrubbers


	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "area_atmos_computer.tmpl", "Area Atmos Computer", 300, 400)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/computer/area_atmos/Topic(href, href_list)
	if(..())
		return 0
	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1

	usr.set_machine(src)
	src.add_fingerprint(usr)

	// the template actually can send a {'refresh': 1} update, but
	// we don't give a shit because we do scanscrubbers() either way

	scanscrubbers()
	if(href_list["toggle"])
		var/scrubber_id = href_list["id"]
		for (var/obj/machinery/portable_atmospherics/scrubber/huge/scrubber in connectedscrubbers)
			if(scrubber.id == text2num(scrubber_id))
				if(validscrubber(scrubber))
					scrubber.on = scrubber.on ? 0 : 1
					scrubber.update_icon()
					return 1

/obj/machinery/computer/area_atmos/proc/validscrubber( var/obj/machinery/portable_atmospherics/scrubber/huge/scrubber as obj )
	if(!isobj(scrubber) || get_dist(scrubber.loc, src.loc) > src.range || scrubber.loc.z != src.loc.z)
		return 0

	return 1


/obj/machinery/computer/area_atmos/area
	zone_text = "This computer is working in a wired network limited to this area."

/obj/machinery/computer/area_atmos/area/validscrubber( var/obj/machinery/portable_atmospherics/scrubber/huge/scrubber as obj )
	if(!isobj(scrubber))
		return 0

	/*
	wow this is stupid, someone help me
	*/
	var/turf/T_src = get_turf(src)
	if(!T_src.loc)
		return 0
	var/area/A_src = T_src.loc

	var/turf/T_scrub = get_turf(scrubber)
	if(!T_scrub.loc)
		return 0
	var/area/A_scrub = T_scrub.loc

	if(A_scrub != A_src)
		return 0

	return 1

/obj/machinery/computer/area_atmos/area/scanscrubbers()
	connectedscrubbers = new()

	var/turf/T = get_turf(src)
	if(!T.loc)
		return
	var/area/A = get_area(T)
	for(var/obj/machinery/portable_atmospherics/scrubber/huge/scrubber in machines)
		var/turf/T2 = get_turf(scrubber)
		if(T2 && T2.loc)
			var/area/A2 = T2.loc
			if(istype(A2) && A2 == A )
				connectedscrubbers += scrubber
