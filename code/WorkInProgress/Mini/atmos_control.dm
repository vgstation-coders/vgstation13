var/global/list/atmos_controllers = list()
/obj/item/weapon/circuitboard/atmoscontrol
	name = "\improper Central Atmospherics Computer Circuitboard"
	build_path = /obj/machinery/computer/atmoscontrol

/datum/design/atmoscontrol
	name = "Circuit Design (Central Atmosherics Computer)"
	desc = "Allows for the construction of circuit boards used to build an Atmos Control Console."
	id = "atmoscontrol"
	req_tech = list(Tc_PROGRAMMING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/atmoscontrol

/obj/machinery/computer/atmoscontrol
	name = "\improper Central Atmospherics Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "tank"
	density = 1
	anchored = 1.0
	circuit = "/obj/item/weapon/circuitboard/atmoscontrol"
	var/obj/machinery/alarm/current
	var/list/filter=null
	var/overridden = 0 //not set yet, can't think of a good way to do it
	req_one_access = list(access_ce)

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/atmoscontrol/New()
	..()
	atmos_controllers |= src
/obj/machinery/computer/atmoscontrol/Destroy()
	atmos_controllers -= src
	..()

/obj/machinery/computer/atmoscontrol/xeno
	name = "\improper Xenobiology Atmospherics Computer"
	filter=list(
		/area/science/xenobiology/specimen_1,
		/area/science/xenobiology/specimen_2,
		/area/science/xenobiology/specimen_3,
		/area/science/xenobiology/specimen_4,
		/area/science/xenobiology/specimen_5,
		/area/science/xenobiology/specimen_6
	)
	req_one_access = list(access_xenobiology,access_ce)


/obj/machinery/computer/atmoscontrol/gas_chamber
	name = "\improper Gas Chamber Atmospherics Computer"
	filter=list(
		/area/security/gas_chamber
	)
	req_one_access = list(access_ce,access_hos)


/obj/machinery/computer/atmoscontrol/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return interact(user)

/obj/machinery/computer/atmoscontrol/attack_paw(var/mob/user as mob)
	return interact(user)

/obj/machinery/computer/atmoscontrol/attack_hand(mob/user)
	if(..())
		return
	return interact(user)

/obj/machinery/computer/atmoscontrol/interact(mob/user)
	if(allowed(user))
		overridden = 1
	else if(!emagged)
		overridden = 0

	return ui_interact(user)


/obj/machinery/computer/atmoscontrol/attackby(var/obj/item/I as obj, var/mob/user as mob)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		user.visible_message("<span class='warning'>\The [user] swipes \a [I] through \the [src], causing the screen to flash!</span>",\
			"<span class='warning'>You swipe your [I] through \the [src], the screen flashing as you gain full control.</span>",\
			"You hear the swipe of a card through a reader, and an electronic warble.")
		emagged = 1
		overridden = 1
		return
	return ..()

/obj/machinery/computer/atmoscontrol/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if(user.client)
		var/datum/asset/simple/nanoui_maps/asset_datum = new
		send_asset_list(user.client, asset_datum.assets)

	var/list/data[0]
	data["alarm"]=null
	if(current)
		data += current.get_nano_data(user,TRUE)
		data["alarm"] = "\ref[current]"
		data["name"] = current.name
	else
		var/list/alarms=list()
		for(var/obj/machinery/alarm/alarm in sortNames(machines)) // removing sortAtom because nano updates it just enough for the lag to happen
			var/area/alarm_area = get_area(alarm)
			if(!is_in_filter(alarm_area.type))
				continue // NO ACCESS 4 U
			var/turf/pos = get_turf(alarm)
			var/list/alarm_data=list()
			alarm_data["ID"]="\ref[alarm]"
			alarm_data["danger"] = max(alarm.local_danger_level, alarm_area.atmosalm-1)
			alarm_data["name"] = "[alarm]"
			alarm_data["area"] = get_area(alarm)
			alarm_data["x"] = pos.x
			alarm_data["y"] = pos.y
			alarm_data["z"] = pos.z
			alarms+=list(alarm_data)
		data["alarms"]=alarms

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_control.tmpl", name, 900, 800)
		// adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "atmos_control_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "atmos_control_map_header.tmpl")
		ui.set_show_map(FALSE)
		ui.set_initial_data(data)
		ui.open()
	ui.set_auto_update(!!current)

/obj/machinery/computer/atmoscontrol/proc/is_in_filter(var/typepath)
	if(!filter)
		return 1 // YEP.  TOTALLY.
	return typepath in filter

//a bunch of this is copied from atmos alarms
/obj/machinery/computer/atmoscontrol/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()

	if(href_list["reset"])
		current = null
		return TRUE

	if(href_list["alarm"])
		current = locate(href_list["alarm"])
		return TRUE

	if(current)
		if(href_list["command"])
			var/device_id = href_list["id_tag"]
			switch(href_list["command"])
				if( "power",
					"adjust_external_pressure",
					"set_external_pressure",
					"checks",
					"co2_scrub",
					"tox_scrub",
					"n2o_scrub",
					"o2_scrub",
					"n2_scrub",
					"panic_siphon",
					"scrubbing")
					var/val
					if(href_list["val"])
						val=text2num(href_list["val"])
					else
						var/newval = input("Enter new value") as num|null
						if(isnull(newval))
							return
						if(href_list["command"]=="set_external_pressure")
							if(newval>1000+ONE_ATMOSPHERE)
								newval = 1000+ONE_ATMOSPHERE
							if(newval<0)
								newval = 0
						val = newval

					current.send_signal(device_id, list(href_list["command"] = val ) )

				if("set_threshold")
					var/env = href_list["env"]
					var/threshold = text2num(href_list["var"])
					var/list/selected = current.TLV[env]
					var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")
					var/newval = input("Enter [thresholds[threshold]] for [env]", "Alarm triggers", selected[threshold]) as num|null
					if (isnull(newval) || ..() || (current.locked && !issilicon(usr)))
						return 1
					current.set_threshold(env, threshold, newval, 1)
					return 1
		if(href_list["reset_thresholds"])
			current.apply_preset(1) //just apply the preset without cycling
			return 1

		if(href_list["screen"])
			current.screen = text2num(href_list["screen"])
			return 1

		if(href_list["atmos_alarm"])
			current.set_alarm(1)
			return 1

		if(href_list["atmos_reset"])
			current.set_alarm(0)
			return 1
		
		if(href_list["enable_override"])
			var/area/this_area = get_area(current)
			this_area.doors_overridden = 1
			this_area.UpdateFirelocks()
			current.update_icon()
			return 1
		
		if(href_list["disable_override"])
			var/area/this_area = get_area(current)
			this_area.doors_overridden = 0
			this_area.UpdateFirelocks()
			current.update_icon()
			return 1

		if(href_list["mode"])
			current.mode = text2num(href_list["mode"])
			current.apply_mode()
			return 1

		if(href_list["toggle_cycle_after_preset"])
			current.cycle_after_preset = !current.cycle_after_preset
			return 1

		if(href_list["preset"])
			if(href_list["preset"] in airalarm_presets)
				current.preset = href_list["preset"]
				current.apply_preset(!current.cycle_after_preset)
			return 1

		if(href_list["temperature"])
			var/list/selected = current.TLV["temperature"]
			var/max_temperature
			var/min_temperature
			if(!current.locked)
				max_temperature = MAX_TARGET_TEMPERATURE - T0C //these defines should come from code\game\machinery\alarm.dm
				min_temperature = MIN_TARGET_TEMPERATURE - T0C
			else
				max_temperature = selected[3] - T0C
				min_temperature = selected[2] - T0C
			var/input_temperature = input("What temperature (in C) would you like the system to target? (Capped between [min_temperature]C and [max_temperature]C).\n\nNote that the cooling unit in this air alarm can not go below [MIN_TEMPERATURE]C or above [MAX_TEMPERATURE]C by itself. ", "Thermostat Controls") as num|null
			if(input_temperature==null)
				return
			if(!input_temperature || input_temperature >= max_temperature || input_temperature <= min_temperature)
				to_chat(usr, "<span class='warning'>Temperature must be between [min_temperature]C and [max_temperature]C.</span>")
			else
				input_temperature = input_temperature + T0C
			current.set_temperature(input_temperature)
			return 1
