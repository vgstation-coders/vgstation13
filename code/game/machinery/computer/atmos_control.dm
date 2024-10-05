#define ACA_SCREEN_DETAILSVIEW 1
#define ACA_SCREEN_ADMINPANEL 2
#define ACA_SCREEN_BSCAPVIEW 3

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
	var/datum/airalarm_configuration/preset/selected_preset = null //stores the preset settings while they're being edited
	machine_flags = EMAGGABLE | SCREWTOGGLE | WRENCHMOVE | FIXED2WORK

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


/obj/machinery/computer/atmoscontrol/attack_paw(var/mob/user as mob)
	return interact(user)

/obj/machinery/computer/atmoscontrol/attack_hand(mob/user)
	if(..())
		return
	return interact(user)

/obj/machinery/computer/atmoscontrol/attackby(var/obj/item/I as obj, var/mob/user as mob)
	if(isEmag(I))
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

// TODO: unify this with /obj/machinery/alarm/proc/set_threshold
/obj/machinery/computer/atmoscontrol/proc/set_threshold(var/datum/airalarm_threshold/threshold, var/threshold_name, var/index, var/value)
	if (value < 0)
		value = -1.0
	else if (threshold_name=="temperature" && value>5000)
		value = 5000
	else if (threshold_name=="pressure" && value>50*ONE_ATMOSPHERE)
		value = 50*ONE_ATMOSPHERE
	else if (threshold_name!="temperature" && threshold_name!="pressure" && value>200)
		value = 200
	else
		value = round(value,0.01)
	threshold.adjust_threshold(value, index)

/obj/machinery/computer/atmoscontrol/proc/apply_preset(var/presetname)
	var/list/done_areas = list() //a little optimization to avoid needlessly repeating apply_mode()
	for(var/obj/machinery/alarm/alarm in air_alarms)
		if(alarm.preset_key != presetname)
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
		if(alarm.preset_key != oldpreset)
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
		alarm.preset_key = newpreset
		alarm.apply_preset(no_cycle_after, 1) //optionally cycle, propagate
		done_areas += alarm_area

/obj/machinery/computer/atmoscontrol/proc/mass_set_mode(var/mode)
	if(!mode)
		return

	var/list/done_areas = list() //a little optimization to avoid needlessly repeating apply_mode()
	for(var/obj/machinery/alarm/alarm in air_alarms)
		if(alarm.mode == mode)
			continue
		if(alarm.rcon_setting == RCON_NO)
			continue //no messing with alarms with no remote control
		if(! ( emagged || usr.hasFullAccess() || (log_in_id&&(alarm.check_access(log_in_id)))))
			continue
		var/area/alarm_area = get_area(alarm)
		if(alarm_area in done_areas)
			continue
		alarm.mode = mode
		alarm.apply_mode()
		done_areas += alarm_area

/obj/machinery/computer/atmoscontrol/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	//if(user.client)
	//	var/datum/asset/simple/nanoui_maps/asset_datum = new
	//	send_asset_list(user.client, asset_datum.assets)

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
		for(var/obj/machinery/alarm/alarm in sortNames(air_alarms)) // removing sortAtom because nano updates it just enough for the lag to happen
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
		var/datum/airalarm_configuration/preset/preset_datum = airalarm_presets[preset]
		tmplist[++tmplist.len] = preset_datum.nanoui_preset_data()
	data["presets"] = tmplist

	if(selected_preset)
		data["selected_preset"] = selected_preset.nanoui_preset_data()
		data["selected_preset_name"] = selected_preset.name
	else
		data["selected_preset"] = null
		data["selected_preset_name"] = null

	if(log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || user.hasFullAccess())
		data["admin_access"] = TRUE
	else
		data["admin_access"] = FALSE
		if(screen == ACA_SCREEN_ADMINPANEL)
			screen = ACA_SCREEN_DETAILSVIEW //this dumb hack stops unauthorized cards from seeing shit they shouldn't

	data["aca_screen"] = screen //aca_screen so we don't conflict with air alarms, which already use screen

	var/list/gas_datums=list()
	for(var/gas_id in XGM.gases)
		var/datum/gas/gas_datum = XGM.gases[gas_id]
		var/list/datum_data = list()
		datum_data["id"] = gas_id
		datum_data["name"] = gas_datum.name
		datum_data["short_name"] = gas_datum.short_name || gas_datum.name
		gas_datums += list(datum_data)
	data["gas_datums"]=gas_datums
	if(bspipe_list.len>0)
		data["bspipe_exist"] = TRUE
	var/list/bspipes=list()
	for(var/obj/machinery/atmospherics/unary/cap/bluespace/bscap in bspipe_list)
		var/list/pipe_data = list()
		pipe_data["name"] = bscap.name
		pipe_data["x"] = bscap.x - WORLD_X_OFFSET[bscap.z]
		pipe_data["y"] = bscap.y - WORLD_Y_OFFSET[bscap.z]
		pipe_data["z"] = bscap.z
		bspipes += list(pipe_data)
	data["bspipes"]=bspipes

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
		screen = ACA_SCREEN_DETAILSVIEW
		if(log_in_id || emagged)
			return 1
		var/mob/M = usr
		var/obj/item/weapon/card/id/I = M.get_active_hand()
		if (istype(I, /obj/item/device/pda))
			var/obj/item/device/pda/pda = I
			I = pda.id
		emag_check(I,M)
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
		var/datum/airalarm_configuration/preset/select = airalarm_presets[href_list["select_preset"]]
		selected_preset = select.deep_preset_copy() // We make a copy to be edited locally.
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
		if(selected_preset)
			selected_preset = selected_preset.deep_preset_copy()
		else
			var/datum/airalarm_configuration/preset/human = airalarm_presets["Human"]
			selected_preset = human.deep_preset_copy()
		selected_preset.name = name
		selected_preset.desc = desc
		selected_preset.core = FALSE
		airalarm_presets[name] = selected_preset.deep_preset_copy()
		return 1

	if(href_list["save_preset_setting"])
		if(!(log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || usr.hasFullAccess()))
			return 1
		var/name = selected_preset.name
		airalarm_presets[name] = selected_preset.deep_preset_copy()
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
		if(newname in airalarm_presets)
			to_chat(usr, "<span class='warning'>Preset with that name already exists.</span>")
			return 1
		var/newdesc = trimcenter(trim(stripped_input(usr,"Enter the description for the preset (max 50 characters).", "Preset name",""),1,50))
		if(!newdesc || newdesc == "")
			to_chat(usr, "<span class='warning'>Invalid description.</span>")
			return 1
		//add the fresh preset to the list first
		var/datum/airalarm_configuration/preset/new_preset = selected_preset.deep_preset_copy()
		new_preset.name = newname
		new_preset.desc = newdesc
		airalarm_presets[newname] = new_preset

		//transfer all the alarms from old preset to new preset
		var/oldname = selected_preset.name
		switch_preset(oldname, newname)
		//delete the old preset and set the new one as selected
		selected_preset = new_preset.deep_preset_copy()
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
		var/datum/airalarm_configuration/preset/human_preset = airalarm_presets["Human"]
		selected_preset = human_preset.deep_preset_copy()
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
				selected_preset = new /datum/airalarm_configuration/preset/human
			if("Vox")
				selected_preset = new /datum/airalarm_configuration/preset/vox
			if("Coldroom")
				selected_preset = new /datum/airalarm_configuration/preset/coldroom
			if("Plasmaman")
				selected_preset = new /datum/airalarm_configuration/preset/plasmaman
			if("Fire Suppression")
				selected_preset = new /datum/airalarm_configuration/preset/fire_suppression
		return 1

	if(href_list["apply_preset_batch"])
		if(!(log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || usr.hasFullAccess()))
			return 1
		//save preset
		var/newname = selected_preset.name
		airalarm_presets[newname] = selected_preset.deep_preset_copy()
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
		if(href_list["set_preset_setting"] == "target_temperature")
			var/max_temperature = MAX_TARGET_TEMPERATURE - T0C //these defines should come from code\game\machinery\alarm.dm
			var/min_temperature = MIN_TARGET_TEMPERATURE - T0C
			var/input_temperature = input("What temperature (in C) would you like the system to target? (Capped between [min_temperature]C and [max_temperature]C).\n\nNote that the cooling unit in this air alarm can not go below [MIN_TEMPERATURE - T0C]C or above [MAX_TEMPERATURE - T0C]C by itself. ", "Thermostat Controls") as num|null
			if(input_temperature==null)
				return 1
			input_temperature = round(clamp(input_temperature, min_temperature, max_temperature) + T0C, 0.01)
			selected_preset.target_temperature = input_temperature
			return 1
		else if(href_list["set_preset_setting"] == "scrubbed_gases")
			var/gas = href_list["gas"]
			if(gas)
				// This "toggle" isn't greatest for performance... but it should only occur once per user input.
				if(!selected_preset.scrubbed_gases.Remove(gas))
					selected_preset.scrubbed_gases += gas
			return 1
		else
			//this could be better...
			var/datum/airalarm_threshold/selected = null
			var/target_name = href_list["set_preset_setting"]
			if(target_name in selected_preset.gas_thresholds)
				selected = selected_preset.gas_thresholds[target_name]
			else
				switch(href_list["set_preset_setting"])
					if("other")
						selected = selected_preset.other_gas_threshold
					if("pressure")
						selected = selected_preset.pressure_threshold
					if("temperature")
						selected = selected_preset.temperature_threshold
			if(selected == null)
				return 1
			var/env = href_list["set_preset_setting"]
			var/index = text2num(href_list["index"])
			var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")
			var/newval = input("Enter [thresholds[index]] for [env]", "Alarm triggers", selected.get_index(index)) as num|null
			if (isnull(newval))
				return 1
			set_threshold(selected, href_list["set_preset_setting"], index, newval)
			return 1

	if(href_list["set_mass_mode"])
		if(!(log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || usr.hasFullAccess()))
			return 1

		var/list/scrubmodes = list(
		"SCRUBBING MODE" = AALARM_MODE_SCRUBBING,
		"REPLACEMENT MODE" = AALARM_MODE_REPLACEMENT,
		"PANIC SIPHON MODE" = AALARM_MODE_PANIC,
		"AIR CYCLE MODE" = AALARM_MODE_CYCLE,
		"FILL MODE" = AALARM_MODE_FILL,
		"OFF MODE" = AALARM_MODE_OFF
		)
		var/choice = input("Select the scrubber-mode you wish to set all air alarms to.\n\nAll air alarms will be set to this mode.", "Select mode", null) as null|anything in scrubmodes
		if(choice)
			var/newmode = scrubmodes[choice]
			var/areyouforreal = alert(usr, "Are you sure you wish to change the mode of every air alarm to [choice]?",,"Yes", "No") == "Yes" ? 1 : 0
			if(areyouforreal && ((log_in_id && (access_ce in log_in_id.GetAccess()) || emagged || usr.hasFullAccess())))
				if(!usr.incapacitated() && (Adjacent(usr) || issilicon(usr)) && !(stat & (FORCEDISABLE|NOPOWER) && usr.dexterity_check()))
					mass_set_mode(newmode)




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
			var/command = href_list["command"]
			if(command in XGM.gases)
				var/val=text2num(href_list["val"])
				current.send_signal(device_id, list(command+"_scrub" = val ))
			else
				switch(href_list["command"])
					if( "power",
						"set_external_pressure",
						"set_internal_pressure",
						"checks",
						"panic_siphon",
						"scrubbing",
						"direction")
						var/val
						if(href_list["val"])
							val=text2num(href_list["val"])
						else
							var/newval = input("Enter new value") as num|null
							if(isnull(newval))
								return 1
							if(href_list["command"]=="set_external_pressure")
								newval = clamp(newval, 0, 1000+ONE_ATMOSPHERE)
							val = newval

						current.send_signal(device_id, list(href_list["command"] = val ) )

					if("set_threshold")
						var/env = href_list["env"]
						var/threshold = text2num(href_list["var"])
						var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")
						var/newval = input("Enter [thresholds[threshold]] for [env]", "Alarm triggers", 0) as num|null
						if (isnull(newval))
							return 1
						current.set_threshold(env, threshold, newval, 1)
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

		if(href_list["enable_override"])
			if(current.rcon_setting == RCON_NO)
				return 1
			var/area/this_area = get_area(current)
			this_area.doors_overridden = TRUE
			this_area.UpdateFirelocks()
			current.update_icon()
			return 1

		if(href_list["disable_override"])
			if(current.rcon_setting == RCON_NO)
				return 1
			var/area/this_area = get_area(current)
			this_area.doors_overridden = FALSE
			this_area.UpdateFirelocks()
			current.update_icon()
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
				current.preset_key = href_list["preset"]
				current.apply_preset(!current.cycle_after_preset)
			return 1

		if(href_list["auto_suppress"])
			current.auto_suppress = !current.auto_suppress
			return 1

		if(href_list["temperature"])
			if(current.rcon_setting == RCON_NO)
				return 1
			var/datum/airalarm_threshold/temperature_threshold = current.config.temperature_threshold
			var/max_temperature
			var/min_temperature
			if(!current.locked)
				max_temperature = MAX_TARGET_TEMPERATURE - T0C //these defines should come from code\game\machinery\alarm.dm
				min_temperature = MIN_TARGET_TEMPERATURE - T0C
			else
				max_temperature = temperature_threshold.max_1() - T0C
				min_temperature = temperature_threshold.min_1() - T0C
			var/input_temperature = input("What temperature (in C) would you like the system to target? (Capped between [min_temperature]C and [max_temperature]C).\n\nNote that the cooling unit in this air alarm can not go below [MIN_TEMPERATURE - T0C]C or above [MAX_TEMPERATURE - T0C]C by itself. ", "Thermostat Controls") as num|null
			if(input_temperature==null)
				return 1
			input_temperature = round(clamp(input_temperature, min_temperature, max_temperature) + T0C, 0.01)
			current.set_temperature(input_temperature)
			return 1

#undef ACA_SCREEN_DETAILSVIEW
#undef ACA_SCREEN_ADMINPANEL
#undef ACA_SCREEN_BSCAPVIEW
