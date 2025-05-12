// A fun toy for Paramedics

/obj/item/device/pcmc
	name = "Portable Crew Monitoring Computer"
	desc = "A breakthrough of technology. Easily shows all detected suit sensors, and can filter to only injuries."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pcmc"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/pcmc.dmi', "right_hand" = 'icons/mob/in-hand/right/pcmc.dmi')
	item_state = "pcmc"
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	slot_flags = SLOT_BELT
	mech_flags = MECH_SCAN_FAIL
	force = 8
	throwforce = 15
	throw_range = 4
	attack_verb = list("bricks")
	var/emped = FALSE
	var/autorefreshing = FALSE
	var/transmitting = FALSE
	var/injuryonly = FALSE
	var/fullmode = TRUE

/obj/item/device/pcmc/New()
	..()
	update_icon()

/obj/item/device/pcmc/Destroy()
	..()

/obj/item/device/pcmc/update_icon()
	overlays.Cut()
	if(emped)
		overlays += image(icon, "pcmcemp")
		return
	if(transmitting)
		overlays += image(icon, "pcmcon")

/obj/item/device/pcmc/emp_act(severity)
	emped = TRUE
	transmitting = FALSE
	set_light(0)
	update_icon()
	SStgui.update_uis(src)
	spawn(120 SECONDS)
		emped = FALSE
		update_icon()
		SStgui.update_uis(src)

/obj/item/device/pcmc/attack_self(mob/user)
	tgui_interact(user)

/obj/item/device/pcmc/examine(mob/user)
	if(Adjacent(user) || isobserver(user))
		attack_self(user)
	else
		..()

/obj/item/device/pcmc/proc/get_location_name()
	var/turf/device_turf = get_turf(src)
	var/area/device_area = get_area(src)
	if (emped)
		return "ERROR"
	else if(!device_turf || !device_area)
		return "UNKNOWN"
	else if(device_turf.z > WORLD_X_OFFSET.len)
		return "[format_text(device_area.name)] (UNKNOWN, UNKNOWN, UNKNOWN)"
	else
		return "[format_text(device_area.name)] ([device_turf.x-WORLD_X_OFFSET[device_turf.z]], [device_turf.y-WORLD_Y_OFFSET[device_turf.z]], [device_turf.z])"


/obj/item/device/pcmc/proc/get_crew()
	//looping though carbons
	var/list/crewlist = list()
	for(var/mob/living/carbon/human/H in mob_list)
		//Check if they're a map-spawned corpse vs an actual player corpse
		if(H.iscorpse)
			continue
		//No ability to see Centcomm's level
		var/datum/zLevel/L = get_z_level(H)
		if(istype(L, /datum/zLevel/centcomm))
			continue

		var/name
		var/assignment
		var/life_status
		var/list/damage = list()
		damage["oxygen"] = ""
		damage["toxin"] = ""
		damage["burn"] = ""
		damage["brute"] = ""
		var/player_area
		var/see_x = "?"
		var/see_y = "?"
		var/see_z = "?"

		// z == 0 means mob is inside object, check is they are wearing a uniform
		if(istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = H.w_uniform

			if (U.has_sensor && U.sensor_mode)
				var/turf/pos = H.z == 0 || U.sensor_mode == 3 ? get_turf(H) : null

				// Special case: If the mob is inside an object confirm the z-level on turf level.
				if (H.z == 0 && !pos)
					continue

				var/obj/item/weapon/card/id/I = H.wear_id ? H.wear_id.GetID() : null

				if (I)
					name = I.registered_name
					assignment = I.assignment
				else
					name = "Unknown"
					assignment = ""

				if (U.sensor_mode >= 2)
					damage["oxygen"] = round(H.getOxyLoss(),1)
					damage["toxin"] = round(H.getToxLoss(),1)
					damage["burn"] = round(H.getFireLoss(),1)
					damage["brute"] = round(H.getBruteLoss(),1)

				//Sensors are at least binary if you are in this block
				life_status = H.stat //CONSCIOUS, UNCONSCIOUS, DEAD
				//Crit is only when their damage exceeds their max health
				if (life_status == UNCONSCIOUS)
					//show critical if sensors are 2 or higher, only.
					if (U.sensor_mode == 1)
						life_status = CONSCIOUS
					//show critical if they are actually hurt, not just sleeping
					else if (U.sensor_mode >= 2 && H.health > config.health_threshold_crit)
						life_status = CONSCIOUS

				if(pos)
					player_area = format_text(get_area(H).name)
					see_x = pos.x - WORLD_X_OFFSET[pos.z]
					see_y = pos.y - WORLD_Y_OFFSET[pos.z]
					see_z = pos.z
				else
					see_x = "?"
					see_y = "?"
					see_z = "?"
					player_area = "UNKNOWN"

				//paramedic special version records only injured people
				if(injuryonly)
					switch(U.sensor_mode)
						if(2 to 3)
							if(H.health == H.maxHealth)
								continue
						if(1)
							if(life_status == CONSCIOUS)
								continue

				var/list/data = list()
				data["name"] = name
				data["assignment"] = assignment
				data["vitals"] = life_status
				data["damage"] = damage
				if(U.sensor_mode >= 3)
					data["location_text"] = "[format_text(player_area)] ([see_x], [see_y], [see_z])"
				else
					data["location_text"] = ""
				data["sensor"] = U.sensor_mode
				data["count"] = crewlist.len + 1
				crewlist += list(data)
	return crewlist

// Begin tgui
/obj/item/device/pcmc/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PCMC")
		ui.open()
	ui.set_autoupdate(autorefreshing)

/obj/item/device/pcmc/ui_data()
	var/list/data = list()
	var/list/detectedcrew = list()
	data["itemtitle"] = name
	data["emped"] = emped
	data["transmitting"] = transmitting
	data["autorefresh"] = autorefreshing
	data["location_text"] = get_location_name()
	detectedcrew = get_crew()
	data["detectedcrew"] = detectedcrew
	data["detected"] = detectedcrew.len ? 1 : 0
	data["injurymode"] = injuryonly
	data["fullmode"] = fullmode
	return data

/obj/item/device/pcmc/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("turn_on")
			if(emped || transmitting || !Adjacent(usr) || usr.incapacitated())
				return FALSE
			transmitting = TRUE
			set_light(1)
			update_icon()
			return TRUE
		if("turn_off")
			if(emped || !transmitting || !Adjacent(usr) || usr.incapacitated())
				return FALSE
			transmitting = FALSE
			set_light(0)
			update_icon()
			return TRUE
		if("toggle_refresh")
			autorefreshing = !autorefreshing
			return TRUE
		if("toggle_injury")
			if(fullmode)
				injuryonly = !injuryonly
				return TRUE
			else
				return FALSE
// end tgui

/obj/item/device/pcmc/paramed
	name = "Vito-tron"
	desc = "A breakthrough of technology. Lists detected suit sensors. A warning label reads, \"Do not use in areas with heavy electromagnetic interference.\""
	icon = 'icons/obj/pda.dmi'
	icon_state = "pcmc"
	item_state = "pcmc"
	fullmode = FALSE

/obj/item/device/pcmc/paramed/New()
	..()
	name = pick("Vito-tron",
				"Trauma Buddy",
				"Treatment Notice System",
				"Trauma Relief and Alert Companion",
				"The Hurt Detector",
				"The Harmcorder",
				"Physiological and Respiration Real-time Analyzer",
				"Injury-o-Meter",
				"CareMonitor",
				"Advanced Vital Observer Interface Device",
				"Portable Alertness and Response Administrator",
				"Crew Resource and Injury Monitoring Equipment",
				"Medical Information and Positioning System",
				"Emergency Response PDA",
				"Harm Origin Gadget",
				"Mobile Injury Locating Device",
				"Portable Injury Detector",
				"Crew Monitoring Console Monitoring Console",
				"Suit Sensor-Sensor",
				"Crew Monitoring Device",
				"Baby Monitor",
				"Life-Alert")