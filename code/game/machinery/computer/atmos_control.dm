#define ACA_SCREEN_DETAILSVIEW 1
#define ACA_SCREEN_ADMINPANEL 2

var/global/list/atmos_controllers = list()
/obj/item/weapon/circuitboard/atmoscontrol
	name = "\improper Central Atmospherics Computer Circuitboard"
	build_path = /obj/machinery/computer/atmoscontrol

/obj/machinery/computer/atmoscontrol
	name = "\improper Central Atmospherics Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "tank"
	density = 1
	anchored = 1.0
	circuit = "/obj/item/weapon/circuitboard/atmoscontrol"
	var/obj/machinery/alarm/current
	var/list/filter=null
	var/obj/item/weapon/card/id/log_in_id = null //the ID that's currently logged in
	var/screen = ACA_SCREEN_DETAILSVIEW //the current screen in the UI
	var/datum/airalarm_preset/selected_preset = null //stores the preset settings while they're being edited
	machine_flags = EMAGGABLE

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/atmoscontrol/New()
	..()
	atmos_controllers += src
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

/obj/machinery/computer/atmoscontrol/gas_chamber
	name = "\improper Gas Chamber Atmospherics Computer"
	filter=list(
		/area/security/gas_chamber
	)

/obj/machinery/computer/atmoscontrol/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return interact(user)

/obj/machinery/computer/atmoscontrol/attack_paw(var/mob/user as mob)
	return interact(user)

/obj/machinery/computer/atmoscontrol/attack_hand(mob/user)
	if(..())
		return
	return interact(user)

/obj/machinery/computer/atmoscontrol/attackby(var/obj/item/I as obj, var/mob/user as mob)
	if(istype(I, /obj/item/weapon/card/emag))
		return //lazy hackfix for the UI opening and not updating when using an emag with the UI closed
	return ..()

/obj/machinery/computer/atmoscontrol/interact(mob/user)
	return ui_interact(user)

/obj/machinery/computer/atmoscontrol/emag_act(var/mob/user as mob, var/obj/item/weapon/card/E as obj)
	if(!emagged)
		emagged = 1
		spark(src, 1, FALSE)
		user.visible_message("<span class='warning'>\The [user] swipes \a [E] through \the [src], causing the screen to flash!</span>",\
			"<span class='warning'>You swipe \the [E] through \the [src], the screen flashing as you gain full control.</span>",\
			"You hear the swipe of a card through a reader, and an electronic warble.")
		nanomanager.update_uis(src)
	return 1

//largely copypasted from air alarms
/obj/machinery/computer/atmoscontrol/proc/set_threshold(var/list/thresholds, var/threshold_name, var/index, var/value)
	if (value<0)
		thresholds[index] = -1.0
	else if (threshold_name=="temperature" && value>5000)
		thresholds[index] = 5000
	else if (threshold_name=="pressure" && value>50*ONE_ATMOSPHERE)
		thresholds[index] = 50*ONE_ATMOSPHERE
	else if (threshold_name!="temperature" && threshold_name!="pressure" && value>200)
		thresholds[index] = 200
	else
		value = round(value,0.01)
		thresholds[index] = value
	//blegh
	if(index == 1)
		if(thresholds[1] > thresholds[2])
			thresholds[2] = thresholds[1]
		if(thresholds[1] > thresholds[3])
			thresholds[3] = thresholds[1]
		if(thresholds[1] > thresholds[4])
			thresholds[4] = thresholds[1]
	if(index == 2)
		if(thresholds[1] > thresholds[2])
			thresholds[1] = thresholds[2]
		if(thresholds[2] > thresholds[3])
			thresholds[3] = thresholds[2]
		if(thresholds[2] > thresholds[4])
			thresholds[4] = thresholds[2]
	if(index == 3)
		if(thresholds[1] > thresholds[3])
			thresholds[1] = thresholds[3]
		if(thresholds[2] > thresholds[3])
			thresholds[2] = thresholds[3]
		if(thresholds[3] > thresholds[4])
			thresholds[4] = thresholds[3]
	if(index == 4)
		if(thresholds[1] > thresholds[4])
			thresholds[1] = thresholds[4]
		if(thresholds[2] > thresholds[4])
			thresholds[2] = thresholds[4]
		if(thresholds[3] > thresholds[4])
			thresholds[3] = thresholds[4]

/obj/machinery/computer/atmoscontrol/proc/apply_preset(var/presetname)
	var/list/done_areas = list() //a little optimization to avoid needlessly repeating apply_mode()
	for(var/obj/machinery/alarm/alarm in machines)
		if(alarm.preset != presetname)
			continue
		if(alarm.rcon_setting == RCON_NO)
			continue //no messing with alarms with no remote control
		if(log_in_id)
			if(!emagged && !usr.hasFullAccess() && !alarm.check_access(log_in_id))
				continue //The logged in ID has no access to this card, and the user isn't an all-access user (eg. admin ghost, AI, etc.)
		else
			if(!emagged && !usr.hasFullAccess())
				continue
		var/area/alarm_area = get_area(alarm)
		if(alarm_area in done_areas)
			continue
		alarm.apply_preset(1, 1) //no cycle, propagate
		done_areas += alarm_area

//switches all air alarms from old preset to new preset
/obj/machinery/computer/atmoscontrol/proc/switch_preset(var/oldpreset, var/newpreset, var/no_cycle_after=1)
	if(!(newpreset in airalarm_presets))
		return

	var/list/done_areas = list() //a little optimization to avoid needlessly repeating apply_mode()
	for(var/obj/machinery/alarm/alarm in machines)
		if(alarm.preset != oldpreset)
			continue
		if(alarm.rcon_setting == RCON_NO)
			continue //no messing with alarms with no remote control
		if(log_in_id)
			if(!emagged && !usr.hasFullAccess() && !alarm.check_access(log_in_id))
				continue //The logged in ID has no access to this card, and the user isn't an all-access user (eg. admin ghost, AI, etc.)
		else
			if(!emagged && !usr.hasFullAccess())
				continue
		var/area/alarm_area = get_area(alarm)
		if(alarm_area in done_areas)
			continue
		alarm.preset = newpreset
		alarm.apply_preset(no_cycle_after, 1) //optionally cycle, propagate
		done_areas += alarm_area

/obj/machinery/computer/atmoscontrol/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if(user.client)
		var/datum/asset/simple/nanoui_maps/asset_datum = new
		send_asset_list(user.client, asset_datum.assets)

	var/list/data[0]
	data["alarm"]=null

	if(log_in_id)
		data["logged_in"] = TRUE
		data["login_name"] = log_in_id.registered_name + (log_in_id.assignment ? ", [log_in_id.assignment]" : null)
	else if(user.hasFullAccess())
		data["logged_in"] = TRUE
	else
		data["logged_in"] = FALSE

	if(emagged)
		data["logged_in"] = TRUE
		data["login_name"] = "Robert');DROP TABLE users;" //honk
	data["emagged"] = emagged

	if(current)
		data += current.get_nano_data(user,TRUE)
		data["alarm"] = "\ref[current]"
		data["name"] = current.name
	else
		var/list/alarms=list()
		for(var/obj/machinery/alarm/alarm in sortNames(machines)) // removing sortAtom because nano updates it just enough for the lag to happen
			if(log_in_id)
				if(!emagged && !user.hasFullAccess() && !alarm.check_access(log_in_id))
					continue //The logged in ID has no access to this card, and the user isn't an all-access user (eg. admin ghost, AI, etc.)
			else
				if(!emagged && !user.hasFullAccess())
					continue
			var/area/alarm_area = get_area(alarm)
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

	var/list/tmplist = list()
	for(var/preset in airalarm_presets) //this is a global list defined in alarm.dm
		var/datum/airalarm_preset/preset_datum = airalarm_presets[preset]
		tmplist[++tmplist.len] = list(
			"name" = preset_datum.name,
			"desc" = preset_datum.desc,
			"core" = preset_datum.core,
			"oxygen" = preset_datum.oxygen,
			"nitrogen" = preset_datum.nitrogen,
			"carbon_dioxide" = preset_datum.carbon_dioxide,
			"plasma" = preset_datum.plasma,
			"n2o" = preset_datum.n2o,
			"other" = preset_datum.other,
			"pressure" = preset_datum.pressure,
			"temperature" = preset_datum.temperature,
			"target_temperature" = preset_datum.target_temperature,
			"scrubbers_gases" = preset_datum.scrubbers_gases
		)
	data["presets"] = tmplist

	if(selected_preset)
		data["selected_preset"] = list(
			"name" = selected_preset.name,
			"desc" = selected_preset.desc,
			"core" = selected_preset.core,
			"oxygen" = selected_preset.oxygen,
			"nitrogen" = selected_preset.nitrogen,
			"carbon_dioxide" = selected_preset.carbon_dioxide,
			"plasma" = selected_preset.plasma,
			"n2o" = selected_preset.n2o,
			"other" = selected_preset.other,
			"pressure" = selected_preset.pressure,
			"temperature" = selected_preset.temperature,
			"target_temperature" = selected_preset.target_temperature,
			"scrubbers_gases" = selected_preset.scrubbers_gases
		)
		data["selected_preset_name"] = selected_preset.name
	else
		data["selected_preset"] = null
		data["selected_preset_name"] = null

	if(log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || user.hasFullAccess())
		data["admin_access"] = TRUE
	else
		data["admin_access"] = FALSE
		screen = ACA_SCREEN_DETAILSVIEW //this dumb hack stops unauthorized cards from seeing shit they shouldn't

	data["aca_screen"] = screen //aca_screen so we don't conflict with air alarms, which already use screen
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

//a bunch of this is copied from atmos alarms
/obj/machinery/computer/atmoscontrol/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["set_screen"])
		screen = href_list["set_screen"]
		return 1

	if(href_list["login"])
		if(log_in_id || emagged)
			return 1
		var/mob/M = usr
		var/obj/item/weapon/card/id/I = M.get_active_hand()
		if (istype(I, /obj/item/device/pda))
			var/obj/item/device/pda/pda = I
			I = pda.id
		if (istype(I,/obj/item/weapon/card/emag))
			emag_act(I, usr)
		if (I && istype(I))
			log_in_id = I
		return 1

	if(href_list["logout"])
		if(!emagged)
			log_in_id = null
		return 1

	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1

	if(href_list["reset"])
		current = null
		return 1

	if(href_list["alarm"])
		current = locate(href_list["alarm"])
		return 1

	if(href_list["select_preset"])
		if(!(log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || usr.hasFullAccess()))
			return 1
		selected_preset = new(airalarm_presets[href_list["select_preset"]]) //copy the existing preset for editing
		return 1

	if(href_list["add_preset"])
		if(!(log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || usr.hasFullAccess()))
			return 1
		var/name = trimcenter(trim(stripped_input(usr,"Enter the name for the preset (max 12 characters).", "Preset name",""),1,12))
		if(!name || name == "")
			to_chat(usr, "<span class='warning'>Invalid name.</span>")
			return 1
		if(name in airalarm_presets)
			to_chat(usr, "<span class='warning'>Preset with that name already exists.</span>")
			return 1
		var/desc = trimcenter(trim(stripped_input(usr,"Enter the description for the preset (max 50 characters).", "Preset name",""),1,50))
		if(!desc || desc == "")
			to_chat(usr, "<span class='warning'>Invalid description.</span>")
			return 1
		//use the settings from whatever was previously selected to add this new one, but make sure it's not core (ie. can be deleted)
		selected_preset = new(selected_preset, name, desc, FALSE)
		airalarm_presets[name] = new /datum/airalarm_preset(selected_preset) //we'll put a copy of 'er in instead of the real deal
		return 1

	if(href_list["save_preset_setting"])
		if(!(log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || usr.hasFullAccess()))
			return 1
		var/name = selected_preset.name
		airalarm_presets[name] = new /datum/airalarm_preset(selected_preset) //make a copy
		//re-apply preset on all air alarms that have it enabled
		apply_preset(name)
		to_chat(usr, "<span class='notice'>Preset saved and reapplied to alarms.</span>")
		return 1

	if(href_list["rename_preset"])
		if(!(log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || usr.hasFullAccess()))
			return 1
		//renames the currently selected preset
		if(selected_preset.core)
			to_chat(usr, "<span class='warning'>This preset cannot be renamed.</span>")
			return 1
		var/newname = trimcenter(trim(stripped_input(usr,"Enter the name for the preset (max 12 characters).", "Preset name",""),1,12))
		if(!newname || newname == "")
			to_chat(usr, "<span class='warning'>Invalid name.</span>")
			return 1
		var/newdesc = trimcenter(trim(stripped_input(usr,"Enter the description for the preset (max 50 characters).", "Preset name",""),1,50))
		if(!newdesc || newdesc == "")
			to_chat(usr, "<span class='warning'>Invalid description.</span>")
			return 1
		//add the fresh preset to the list first
		airalarm_presets[newname] = new /datum/airalarm_preset(selected_preset, newname, newdesc)
		//transfer all the alarms from old preset to new preset
		var/oldname = selected_preset.name
		switch_preset(oldname, newname)
		//delete the old preset and set the new one as selected
		selected_preset = new /datum/airalarm_preset(selected_preset, newname, newdesc)
		airalarm_presets.Remove(oldname)
		return 1

	if(href_list["delete_preset"])
		if(!(log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || usr.hasFullAccess()))
			return 1
		//deletes the currently selected preset if possible
		if(selected_preset.core)
			to_chat(usr, "<span class='warning'>This preset cannot be deleted.</span>")
			return 1
		//put every alarm that used to be on this preset to the Human preset
		var/oldname = selected_preset.name
		switch_preset(oldname, "Human")
		selected_preset = new /datum/airalarm_preset(airalarm_presets["Human"]) //set the current Human preset as active
		airalarm_presets.Remove(oldname)
		return 1

	if(href_list["reset_preset"])
		if(!(log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || usr.hasFullAccess()))
			return 1
		//resets the currently selected core preset
		if(!selected_preset.core)
			to_chat(usr, "<span class='warning'>This preset cannot be reset.</span>")
			return 1
		//this is some shitcode
		var/name = selected_preset.name
		switch(name)
			if("Human")
				selected_preset = new /datum/airalarm_preset/human
			if("Vox")
				selected_preset = new /datum/airalarm_preset/vox
			if("Coldroom")
				selected_preset = new /datum/airalarm_preset/coldroom
			if("Plasmaman")
				selected_preset = new /datum/airalarm_preset/plasmaman
		return 1

	if(href_list["apply_preset_batch"])
		if(!(log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || usr.hasFullAccess()))
			return 1
		//save preset
		var/newname = selected_preset.name
		airalarm_presets[newname] = new /datum/airalarm_preset(selected_preset) //make a copy
		var/oldname = input("Select the preset you want to switch over from.\n\nAll air alarms currently on this preset will be switched over to the [newname] preset.", "Select preset", newname) in airalarm_presets
		if(!oldname)
			to_chat(usr, "<span class='warning'>Invalid selection!</span>")
		var/no_cycle_after = alert(usr, "Cycle (remove air then refill) after switching?",,"Yes", "No") == "Yes" ? 0 : 1
		switch_preset(oldname, newname, no_cycle_after)
		to_chat(usr, "<span class='notice'>Preset batch applied.</span>")
		return 1

	if(href_list["set_preset_setting"])
		if(!(log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || usr.hasFullAccess()))
			return 1
		switch(href_list["set_preset_setting"])
			if("oxygen", "nitrogen", "carbon_dioxide", "plasma", "n2o", "other", "pressure", "temperature")
				//this could be better...
				var/selected = null
				switch(href_list["set_preset_setting"])
					if("oxygen")
						selected = selected_preset.oxygen
					if("nitrogen")
						selected = selected_preset.nitrogen
					if("carbon_dioxide")
						selected = selected_preset.carbon_dioxide
					if("plasma")
						selected = selected_preset.plasma
					if("n2o")
						selected = selected_preset.n2o
					if("other")
						selected = selected_preset.other
					if("pressure")
						selected = selected_preset.pressure
					if("temperature")
						selected = selected_preset.temperature
				if(selected == null)
					return 1 //this should never happen
				var/env = href_list["set_preset_setting"]
				var/index = text2num(href_list["index"])
				var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")
				var/newval = input("Enter [thresholds[index]] for [env]", "Alarm triggers", selected[index]) as num|null
				if (isnull(newval))
					return 1
				set_threshold(selected, href_list["set_preset_setting"], index, newval)
				return 1
			if("target_temperature")
				var/max_temperature = MAX_TARGET_TEMPERATURE - T0C //these defines should come from code\game\machinery\alarm.dm
				var/min_temperature = MIN_TARGET_TEMPERATURE - T0C
				var/input_temperature = input("What temperature (in C) would you like the system to target? (Capped between [min_temperature]C and [max_temperature]C).\n\nNote that the cooling unit in this air alarm can not go below [MIN_TEMPERATURE]C or above [MAX_TEMPERATURE]C by itself. ", "Thermostat Controls") as num|null
				if(input_temperature==null)
					return 1
				if(!input_temperature || input_temperature >= max_temperature || input_temperature <= min_temperature)
					to_chat(usr, "<span class='warning'>Temperature must be between [min_temperature]C and [max_temperature]C.</span>")
				else
					input_temperature = input_temperature + T0C
				selected_preset.target_temperature = input_temperature
				return 1
			if("scrubbers_gases")
				var/gas = href_list["gas"]
				if(gas && gas in selected_preset.scrubbers_gases)
					selected_preset.scrubbers_gases[gas] = !selected_preset.scrubbers_gases[gas] //toggle scrubbing for it
				return 1

	if(current)
		if(log_in_id)
			if(!emagged && !usr.hasFullAccess() && !current.check_access(log_in_id) && !issilicon(usr))
				return 1 //The logged in ID has no access to this card, and the user isn't an all-access user (eg. admin ghost, AI, etc.)
		else
			if(!emagged && !usr.hasFullAccess() && !issilicon(usr))
				return 1
		if(href_list["command"])
			if(current.rcon_setting == RCON_NO)
				return 1
			var/device_id = href_list["id_tag"]
			switch(href_list["command"])
				if( "power",
					"adjust_external_pressure",
					"set_external_pressure",
					"set_internal_pressure",
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
							return 1
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
					if (isnull(newval))
						return 1
					current.set_threshold(env, threshold, newval, 1)
					return 1
		if(href_list["reset_thresholds"])
			if(current.rcon_setting == RCON_NO)
				return 1
			current.apply_preset(1) //just apply the preset without cycling
			return 1

		if(href_list["screen"])
			current.screen = text2num(href_list["screen"])
			return 1

		if(href_list["atmos_alarm"])
			if(current.rcon_setting == RCON_NO)
				return 1
			current.set_alarm(1)
			return 1

		if(href_list["atmos_reset"])
			if(current.rcon_setting == RCON_NO)
				return 1
			current.set_alarm(0)
			return 1

		if(href_list["mode"])
			if(current.rcon_setting == RCON_NO)
				return 1
			current.mode = text2num(href_list["mode"])
			current.apply_mode()
			return 1

		if(href_list["toggle_cycle_after_preset"])
			if(current.rcon_setting == RCON_NO)
				return 1
			current.cycle_after_preset = !current.cycle_after_preset
			return 1

		if(href_list["preset"])
			if(current.rcon_setting == RCON_NO)
				return 1
			if(href_list["preset"] in airalarm_presets)
				current.preset = href_list["preset"]
				current.apply_preset(!current.cycle_after_preset)
			return 1

		if(href_list["temperature"])
			if(current.rcon_setting == RCON_NO)
				return 1
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
				return 1
			if(!input_temperature || input_temperature >= max_temperature || input_temperature <= min_temperature)
				to_chat(usr, "<span class='warning'>Temperature must be between [min_temperature]C and [max_temperature]C.</span>")
			else
				input_temperature = input_temperature + T0C
				current.set_temperature(input_temperature)
			return 1

#undef ACA_SCREEN_DETAILSVIEW
#undef ACA_SCREEN_ADMINPANEL
