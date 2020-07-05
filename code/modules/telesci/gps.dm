var/list/GPS_list = list()
var/list/SPS_list = list()

/obj/item/device/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016. Needs to be activated before it can start transmitting."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = W_CLASS_SMALL
	flags = FPRINT
	slot_flags = SLOT_BELT
	origin_tech = Tc_BLUESPACE + "=2;" + Tc_MAGNETS + "=2"
	var/base_name = "global positioning system"
	var/base_tag = "COM"
	var/gpstag = "COM0"
	var/emped = FALSE
	var/autorefreshing = FALSE
	var/builtin = FALSE
	var/transmitting = FALSE
	var/list/gps_list // Set in New to be either global.GPS_list or global.SPS_list

/obj/item/device/gps/proc/get_gps_list()
	return GPS_list

/obj/item/device/gps/proc/update_name()
	name = "[base_name] ([gpstag])"

/obj/item/device/gps/New()
	..()
	gps_list = get_gps_list()
	gpstag = "[base_tag][gps_list.len]"
	gps_list += src
	update_name()
	update_icon()

/obj/item/device/gps/Destroy()
	gps_list -= src
	..()

/obj/item/device/gps/update_icon()
	overlays.Cut()
	if(emped)
		overlays += image(icon, "emp")
		return
	if(transmitting)
		overlays += image(icon, "working")

/obj/item/device/gps/emp_act(severity)
	emped = TRUE
	transmitting = FALSE
	update_icon()
	SStgui.update_uis(src)
	spawn(30 SECONDS)
		emped = FALSE
		update_icon()
		SStgui.update_uis(src)

/obj/item/device/gps/attack_self(mob/user)
	tgui_interact(user)

/obj/item/device/gps/examine(mob/user)
	if(Adjacent(user) || isobserver(user))
		attack_self(user)
	else
		..()

/obj/item/device/gps/proc/get_location_name()
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


/obj/item/device/gps/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = global.adjacent_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Gps", name, 500, 500, master_ui, state)
		ui.open()
	ui.set_autoupdate(autorefreshing)

/obj/item/device/gps/ui_data()
	var/list/data = list()
	data["emped"] = emped
	data["transmitting"] = transmitting
	data["gpstag"] = gpstag
	data["autorefresh"] = autorefreshing
	data["location_text"] = get_location_name()
	var/list/devices = list()
	if(!emped && transmitting)
		for(var/obj/item/device/gps/other in gps_list)
			if(!other.transmitting || other == src)
				continue
			var/list/device_data = list()
			device_data["tag"] = other.gpstag
			device_data["location_text"] = other.get_location_name()
			devices += list(device_data)
	data["devices"] = devices
	return data

/obj/item/device/gps/ui_act(action, list/params)
	if(..())
		return
	switch(action)
		if("turn_on")
			if(emped || transmitting || !Adjacent(usr) || usr.incapacitated())
				return FALSE
			transmitting = TRUE
			update_icon()
			return TRUE
		if("set_tag")
			if(isobserver(usr))
				to_chat(usr, "No way.")
				return FALSE
			if(!builtin && (usr.get_active_hand() != src || usr.incapacitated())) //no silicons allowed
				to_chat(usr, "<span class='caution'>You need to have the GPS in your hand to do that!</span>")
				return TRUE
			var/new_tag = params["new_tag"]
			if(!new_tag)
				return TRUE
			if(length(new_tag) > 5)
				to_chat(usr, "<span class='caution'>The tag must have a maximum of five characters!</span>")
			else
				gpstag = new_tag
				update_name()
			return TRUE
		if("toggle_refresh")
			autorefreshing = !autorefreshing
			return TRUE

/obj/item/device/gps/science
	icon_state = "gps-s"
	base_tag = "SCI"

/obj/item/device/gps/engineering
	icon_state = "gps-e"
	base_tag = "ENG"

/obj/item/device/gps/paramedic
	icon_state = "gps-p"
	base_tag = "PMD"

/obj/item/device/gps/mining
	desc = "A more rugged looking GPS device. Useful for finding miners. Or their corpses."
	icon_state = "gps-m"
	base_tag = "MIN"

/obj/item/device/gps/cyborg
	desc = "A mining cyborg internal positioning system. Used as a recovery beacon for damaged silicons, or a collaboration tool for mining teams."
	icon_state = "gps-b"
	base_tag = "BORG"
	builtin = TRUE
	transmitting = TRUE

/obj/item/device/gps/pai
	base_name = "pAI positioning system"
	icon_state = "gps-b"
	base_tag = "PAI"
	builtin = TRUE
	transmitting = TRUE

/obj/item/device/gps/secure
	base_name = "secure positioning system"
	desc = "A secure channel SPS. Sounds an alarm if seperated from their wearer, be it by stripping or death."
	icon_state = "sps"
	base_tag = "SEC"

/obj/item/device/gps/secure/OnMobDeath(mob/wearer)
	if(!transmitting)
		return
	send_signal(wearer, src, "SPS [gpstag]: Code Red")

/obj/item/device/gps/secure/get_gps_list()
	return SPS_list

/obj/item/device/gps/secure/stripped(mob/wearer, mob/stripper)
	if(!transmitting)
		return
	. = ..()
	send_signal(wearer, src, "SPS [gpstag]: Code Yellow")

/obj/item/device/gps/secure/proc/send_signal(var/mob/wearer, var/obj/item/device/gps/secure/SPS, var/code)
	var/boop = FALSE
	var/turf/pos = get_turf(SPS)
	var/x0 = pos.x-WORLD_X_OFFSET[pos.z]
	var/y0 = pos.x-WORLD_Y_OFFSET[pos.z]
	var/z0 = pos.z
	var/alerttype = code
	var/alertarea = get_area(SPS)
	var/alerttime = worldtime2text()
	var/verbose = TRUE
	var/transmission_data = "[alerttype] - [alerttime] - [alertarea] ([x0],[y0],[z0])"
	for(var/obj/machinery/computer/security_alerts/receiver in security_alerts_computers)
		if(receiver && !receiver.stat)
			receiver.receive_alert(alerttype, transmission_data, verbose)
			boop = TRUE
	if (boop)
		playsound(src,'sound/machines/radioboop.ogg',40,1)
