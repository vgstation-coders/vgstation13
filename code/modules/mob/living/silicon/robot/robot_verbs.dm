/mob/living/silicon/robot/verb/Namepick()
	set category = "Robot Commands"

	if (appearance_isbanned(src))
		var/banreason = appearance_isbanned(M)
		to_chat(src, "<span class='warning'>You have been appearance banned for the reason: [banreason]. You cannot change your name.</span>")
		return

	if(incapacitated())
		return

	if(!namepick_uses)
		to_chat(src, "<span class='warning'>You cannot choose your name any more.<span>")
		return FALSE
	namepick_uses--

	var/newname
	for(var/i = 1 to 3)
		newname = trimcenter(trim(stripped_input(src,"You are a [braintype]. Enter a name, or leave blank for the default name.", "Name change [4-i] [0-i != 1 ? "tries":"try"] left",""),1,MAX_NAME_LEN))
		if(newname == null)
			if(alert(src,"Are you sure you want the default name?",,"Yes","No") == "Yes")
				break
		else
			if(alert(src,"Do you really want the name:\n[newname]?",,"Yes","No") == "Yes")
				break

	custom_name = newname
	updatename()
	updateicon()
	if(newname)
		to_chat(src, "<span class='warning'>You have changed your name to [newname]. You can change your name [namepick_uses] more times.<span>")
	else
		to_chat(src, "<span class='warning'>You have reset your name. You can change your name [namepick_uses] more times.<span>")

/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"

	if(isDead() || !is_component_functioning("comms"))
		return

	robot_alerts()

// this verb lets cyborgs see the stations manifest
/mob/living/silicon/robot/verb/cmd_station_manifest()
	set category = "Robot Commands"
	set name = "Show Station Manifest"

	if(!is_component_functioning("comms"))
		return

	show_station_manifest()

/mob/living/silicon/robot/verb/toggle_station_map()
	set category = "Robot Commands"
	set name = "Toggle Station Holomap"
	set desc = "Toggle station holomap on your screen"

	if(isUnconscious())
		return

	station_holomap.toggleHolomap(src)

/mob/living/silicon/robot/verb/self_diagnosis_verb()
	set category = "Robot Commands"
	set name = "Self Diagnosis"

	if(!can_diagnose())
		to_chat(src, "<span class='warning'>Your self-diagnosis component isn't functioning.</span>")
		return

	var/dat = self_diagnosis()
	var/datum/browser/popup = new(src, "\ref[src]-robotdiagnosis", "Self diagnosis", 730, 270)
	popup.set_content(dat)
	popup.open()

/mob/living/silicon/robot/verb/toggle_component()
	set category = "Robot Commands"
	set name = "Toggle Component"
	set desc = "Toggle a component, conserving power."

	if(isDead())
		return

	var/list/installed_components = list()
	for(var/V in components)
		if(V == "power cell")
			continue
		var/datum/robot_component/C = components[V]
		if(C.installed)
			installed_components += V

	var/toggle = input(src, "Which component do you want to toggle?", "Toggle Component") as null|anything in installed_components
	if(!toggle)
		return

	if(toggle == "camera" && incapacitated())
		to_chat(src, "<span class='warning'>You can't do that while you're incapacitated.</span>")
		return

	var/datum/robot_component/C = components[toggle]
	if(C.toggled)
		C.toggled = FALSE
		to_chat(src, "<span class='warning'>You disable [C.name].</span>")
	else
		C.toggled = TRUE
		to_chat(src, "<span class='warning'>You enable [C.name].</span>")

/mob/living/silicon/robot/verb/unlock_own_cover()
	set category = "Robot Commands"
	set name = "Unlock Cover"
	set desc = "Unlocks your own cover if it is locked. You can not lock it again. A human will have to lock it for you."

	if(!isDead() && locked)
		switch(alert("You can not lock your cover again, are you sure?\n      (You can still ask for a human to lock it)", "Unlock Own Cover", "Yes", "No"))
			if("Yes")
				locked = FALSE
				updateicon()
				to_chat(usr, "You unlock your cover.")

/mob/living/silicon/robot/verb/sensor_mode()
	set name = "Set Sensor Augmentation"
	set category = "Robot Commands"

	if(incapacitated())
		return

	if(!istype(module) || !istype(module.sensor_augs) || !module.sensor_augs.len)
		to_chat(src, "<span class='warning'>No Sensor Augmentations located or no module has been equipped.</span>")
		return
	var/sensor_type
	if(module.sensor_augs.len == 2) // Only one choice so toggle between it.
		if(!sensor_mode)
			sensor_type = module.sensor_augs[1]
		else
			sensor_type = "Disable"
	else
		sensor_type = input("Please select sensor type.", "Sensor Integration", null) as null|anything in module.sensor_augs
	if(sensor_type)
		switch(sensor_type)
			if("Security")
				sensor_mode = SEC_HUD
				to_chat(src, "<span class='notice'>Security records overlay enabled.</span>")
			if("Medical")
				sensor_mode = MED_HUD
				to_chat(src, "<span class='notice'>Life signs monitor overlay enabled.</span>")
			if("Light Amplification")
				sensor_mode = NIGHT
				to_chat(src, "<span class='notice'>Light amplification mode enabled.</span>")
			if("Mesons")
				var/area/A = get_area(src)
				if(A.flags & NO_MESONS)
					to_chat(src, "<span class = 'warning'>Unable to initialize Meson Vision. Probable cause: [pick("Atmospheric anomaly","Poor boot paramater","Bulb burn-out")]</span>")
				else
					sensor_mode = MESON_VISION
					to_chat(src, "<span class='notice'>Meson Vision augmentation enabled.</span>")
			if("Thermal")
				sensor_mode = THERMAL_VISION
				to_chat(src, "<span class='notice'>Thermal Optics augmentation enabled.</span>")
			if("Disable")
				sensor_mode = 0
				to_chat(src, "<span class='notice'>Sensor augmentations disabled.</span>")
		handle_sensor_modes()
		update_sight_hud()
