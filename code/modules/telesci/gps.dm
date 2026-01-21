var/list/GPS_list = list()
var/list/SPS_list = list()
var/list/all_GPS_list = list()

// Helper procs to safely get world offsets for virtual z-levels
/proc/get_world_x_offset(var/vz_id)
	if(vz_id > 0 && vz_id <= WORLD_X_OFFSET.len)
		return WORLD_X_OFFSET["[vz_id]"]
	return 0

/proc/get_world_y_offset(var/vz_id)
	if(vz_id > 0 && vz_id <= WORLD_Y_OFFSET.len)
		return WORLD_Y_OFFSET["[vz_id]"]
	return 0

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
	var/view_all = FALSE

/obj/item/device/gps/proc/get_gps_list()
	return GPS_list

/obj/item/device/gps/proc/update_name()
	name = "[base_name] ([gpstag])"

/obj/item/device/gps/New()
	..()
	gps_list = get_gps_list()
	gpstag = "[base_tag][gps_list.len]"
	gps_list += src
	all_GPS_list += src
	update_name()
	update_icon()

/obj/item/device/gps/Destroy()
	gps_list -= src
	all_GPS_list -= src
	..()

/obj/item/device/gps/update_icon()
	overlays.Cut()
	if(emped)
		overlays += image(icon, "[istype(src,/obj/item/device/gps/secure/command) && Holiday == APRIL_FOOLS_DAY ? "af-" : ""]emp")
		return
	if(transmitting)
		overlays += image(icon, "[istype(src,/obj/item/device/gps/secure/command) && Holiday == APRIL_FOOLS_DAY ? "af-" : ""]working")

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
	if(user.client.prefs.get_pref(/datum/preference_setting/toggle/tgui_fancy))
		tgui_interact(user)
	else
		ui_interact(user)

/obj/item/device/gps/examine(mob/user)
	if(Adjacent(user) || isobserver(user))
		attack_self(user)
	else
		..()

/obj/item/device/gps/AltClick(mob/user)
	if(!(user) || !isliving(user)) //BS12 EDIT
		return FALSE
	if(user.incapacitated() || !Adjacent(user))
		return FALSE
	transmitting = TRUE
	update_icon()

/obj/item/device/gps/proc/get_location_name()
	var/turf/device_turf = get_turf(src)
	var/area/device_area = get_area(src)
	var/datum/virtual_z/vz = device_turf?.get_virtual_z()
	if (emped)
		return "ERROR"
	else if(!device_turf || !device_area)
		return "UNKNOWN"
	else if(!vz || !vz.gps_allowed)
		return "SIGNAL JAMMED"
	else
		return "[format_text(device_area.name)] ([device_turf.vx() - get_world_x_offset(vz.id)], [device_turf.vy() - get_world_y_offset(vz.id)], [vz.id])"

// Begin tgui
/obj/item/device/gps/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Gps")
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
	var/turf/device_turf = get_turf(src)
	var/datum/virtual_z/vz = device_turf?.get_virtual_z()
	if(!emped && transmitting && vz?.gps_allowed)
		var/list/ui_list
		if(view_all)
			ui_list = all_GPS_list
		else
			ui_list = gps_list
		for(var/obj/item/device/gps/other in ui_list)
			if(!other.transmitting || other == src || istype(other,/obj/item/device/gps/planetary))
				continue
			var/list/device_data = list()
			device_data["tag"] = other.gpstag
			device_data["location_text"] = other.get_location_name()
			devices += list(device_data)
	data["devices"] = devices
	return data

/obj/item/device/gps/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("turn_on")
			if(emped || transmitting || !Adjacent(usr) || usr.incapacitated())
				return FALSE
			transmitting = TRUE
			update_icon()
			SStgui.try_update_ui(ui.user, src, ui)
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
				SStgui.try_update_ui(ui.user, src, ui)
			return TRUE
		if("toggle_refresh")
			autorefreshing = !autorefreshing
			SStgui.try_update_ui(ui.user, src, ui)
			return TRUE
// end tgui

// Begin NanoUI
/obj/item/device/gps/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	var/data[0]
	if(emped)
		data["emped"] = TRUE
	data["transmitting"] = transmitting
	data["gpstag"] = gpstag
	data["autorefresh"] = autorefreshing
	data["location_text"] = get_location_name()
	var/list/devices = list()
	var/turf/device_turf = get_turf(src)
	var/datum/virtual_z/vz = device_turf?.get_virtual_z()
	if(!emped && transmitting && vz?.gps_allowed)
		var/list/ui_list
		if(view_all)
			ui_list = all_GPS_list
		else
			ui_list = gps_list
		for(var/D in ui_list)
			var/obj/item/device/gps/G = D
			if(G.transmitting && src != G && !istype(G,/obj/item/device/gps/planetary))
				var/device_data[0]
				device_data["tag"] = G.gpstag
				device_data["location_text"] = G.get_location_name()
				devices += list(device_data)
	data["devices"] = devices

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "gps.tmpl", "[src]", 530, 600)
		ui.set_initial_data(data)
		ui.open()
	ui.set_auto_update(autorefreshing)

/obj/item/device/gps/Topic(href, href_list)
	if(..())
		return FALSE
	if(href_list["turn_on"])
		if(emped || transmitting || !Adjacent(usr) || usr.incapacitated())
			return FALSE
		transmitting = TRUE
		update_icon()
		return TRUE
	if(href_list["tag"])
		if(isobserver(usr))
			to_chat(usr, "No way.")
			return FALSE
		if(!builtin && (usr.get_active_hand() != src || usr.incapacitated())) //no silicons allowed
			to_chat(usr, "<span class = 'caution'>You need to have the GPS in your hand to do that!</span>")
			return TRUE

		var/a = sanitize(input("Please enter desired tag.", name, gpstag) as text|null)

		if(!builtin && (usr.get_active_hand() != src || usr.incapacitated())) //second check in case some chucklefuck drops the GPS while typing the tag
			to_chat(usr, "<span class = 'caution'>The GPS needs to be kept in your active hand!</span>")
			return TRUE
		if(!a) //what a check
			return TRUE
		if(length(a) > 5)
			to_chat(usr, "<span class = 'caution'>The tag must have a maximum of five characters!</span>")
		else
			gpstag = a
			update_name()
		return TRUE
	if(href_list["toggle_refresh"])
		autorefreshing = !autorefreshing
		return TRUE
// End NanoUI
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
	send_signal(wearer, src, "SPS [gpstag]: Code Red", TRUE)

/obj/item/device/gps/secure/get_gps_list()
	return SPS_list

/obj/item/device/gps/secure/stripped(mob/wearer, mob/stripper)
	if(!transmitting)
		return
	. = ..()
	send_signal(wearer, src, "SPS [gpstag]: Code Yellow", FALSE, view_all)

/obj/item/device/gps/secure/proc/send_signal(var/mob/wearer, var/obj/item/device/gps/secure/SPS, var/code, var/isdead, var/iscommand = FALSE, var/stfu)
	var/turf/signal_turf = get_turf(SPS)
	var/datum/virtual_z/signal_vz = signal_turf?.get_virtual_z()
	if(!signal_turf || !signal_vz)
		return
	var/x0 = signal_turf.vx() - get_world_x_offset(signal_vz.id)
	var/y0 = signal_turf.vy() - get_world_y_offset(signal_vz.id)
	var/z0 = signal_vz.id
	var/alerttype = code
	var/alertarea = get_area(SPS)
	var/alerttime = worldtime2text()
	var/verbose = TRUE
	var/boop = FALSE
	var/transmission_data = "[alerttype] - [alerttime] - [alertarea] ([x0],[y0],[z0])"
	for(var/obj/machinery/computer/security_alerts/receiver in security_alerts_computers)
		if(receiver && !receiver.stat)
			receiver.receive_alert(alerttype, transmission_data, verbose)
			boop = TRUE
	if(iscommand)
		for(var/obj/item/device/gps/secure/otherSPS in SPS_list)
			if(otherSPS.transmitting)
				otherSPS.say("Alert. [alerttype]")
				playsound(otherSPS,'sound/machines/radioboop.ogg',40,1)

	if(boop && !stfu)
		deathsound(isdead)

/obj/item/device/gps/secure/proc/deathsound(var/dead=FALSE)
	var/list/deathsound = list('sound/items/die1.wav', 'sound/items/die2.wav', 'sound/items/die3.wav','sound/items/die4.wav')
	var/sound_channel = 300
	var/num = gps_list.Find(src)

	if(dead)
		playsound(src, pick(deathsound), 100, 0,channel = sound_channel,wait = TRUE)
	if(prob(75))
		playsound(src, 'sound/items/on3.wav',100, 0,channel = sound_channel,wait = TRUE)
		playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
		if(prob(50))
			playsound(src, 'sound/items/attention.wav',100, 0,channel = sound_channel,wait = TRUE)
			playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
		if(prob(25) && dead) // 25% chance if dead, 0% chance if stripped
			playsound(src, 'sound/items/unitdeserviced.wav',100, 0,channel = sound_channel,wait = TRUE)
			playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
		else if(prob(33) && dead) // 25% chance if dead, 0% chance if stripped
			var/turf/death_turf = get_turf(src)
			var/datum/virtual_z/death_vz = death_turf?.get_virtual_z()
			if(!death_turf || !death_vz)
				return
			playsound(src, 'sound/items/unitdownat.wav',100, 0,channel = sound_channel,wait = TRUE)
			playnum(death_turf.vx() - get_world_x_offset(death_vz.id),sound_channel,src)
			playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
			playnum(death_turf.vy() - get_world_y_offset(death_vz.id),sound_channel,src)
			playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
			playnum(death_vz.id,sound_channel,src)
			playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
		else if(prob(50)) 	// 25% chance if dead, 50% chance if stripped
			playsound(src, 'sound/items/lostbiosignalforunit.wav',100, 0,channel = sound_channel,wait = TRUE)
			playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
			playnum(num,sound_channel,src)
			playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
		else	// 25% chance if dead, 50% chance if stripped
			playsound(src, 'sound/items/allteamsrespondcode3.wav',100, 0,channel = sound_channel,wait = TRUE)
			playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
		if(prob(50))
			playsound(src, 'sound/items/investigateandreport.wav',100, 0,channel = sound_channel,wait = TRUE)
			playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
		playsound(src, 'sound/items/off2.wav',100, 0,channel = sound_channel,wait = TRUE)

var/list/nums_to_hl_num = list("1" = 'sound/items/one.wav', "2" = 'sound/items/two.wav', "3" = 'sound/items/three.wav',"4" = 'sound/items/four.wav',"5" = 'sound/items/five.wav',"6" = 'sound/items/six.wav',"7" = 'sound/items/seven.wav',"8" = 'sound/items/eight.wav',"9" = 'sound/items/nine.wav',"0" = 'sound/items/zero.wav')
/proc/playnum(var/num,var/sound_channel,var/source)
	var/list/splitnumber = list()
	if(num)
		var/base = round(log(10,num))
		for(var/n = 0 to base)
			splitnumber += num2text(num/(10**(base-n)) % 10)
	else splitnumber += "0"
	for(var/n in splitnumber)
		playsound(source, nums_to_hl_num[n], 100, 0, channel = sound_channel, wait = TRUE)

/obj/item/device/gps/secure/command
	base_name = "Command SPS"
	desc = "A secure channel SPS. Sounds an alarm if seperated from their wearer, be it by stripping or death. Shows all GPSes on station."
	icon_state = "sps-c"
	base_tag = "CMD"
	view_all = TRUE

/obj/item/device/gps/secure/command/New()
	..()
	if(Holiday == APRIL_FOOLS_DAY)
		icon_state = "af-sps-c"

/obj/item/device/gps/secure/command/OnMobDeath(mob/wearer)
	if(!transmitting)
		return
	send_signal(wearer, src, "SPS [gpstag]: Code Red", TRUE, TRUE)

/obj/item/device/gps/planetary
	base_name = "expedition tracker"
	desc = "A specialized GPS device designed for planetary exploration. Only tracks other devices on the same planet. Features an emergency distress beacon."
	icon_state = "gps-et"
	base_tag = "EXP"
	origin_tech = Tc_BLUESPACE + "=3;" + Tc_MAGNETS + "=3"
	var/beacon_cooldown = 0
	var/beacon_cooldown_time = 5 MINUTES
	var/beacon_active = FALSE
	var/beacon_activation_time = 0

/obj/item/device/gps/planetary/get_location_name()
	var/turf/device_turf = get_turf(src)
	var/area/device_area = get_area(src)
	if(emped)
		return "ERROR"
	else if(!device_turf || !device_area)
		return "UNKNOWN"
	else if(!device_turf.planet)
		return "NOT ON PLANET"
	else
		// coordinates are relative to each vlevel
		var/datum/virtual_z/vz = device_turf.get_virtual_z()
		if(!istype(vz))
			return "[format_text(device_area.name)] (UNKNOWN)"
		var/planet_name = vz.planet ? vz.planet.planet_name : "Unknown Planet"
		return "[format_text(device_area.name)] ([planet_name]: [device_turf.vx() - get_world_x_offset(vz.id)], [device_turf.vy() - get_world_y_offset(vz.id)], [vz.id])"

/obj/item/device/gps/planetary/ui_data()
	var/list/data = list()
	data["emped"] = emped
	data["transmitting"] = transmitting
	data["gpstag"] = gpstag
	data["autorefresh"] = autorefreshing
	data["location_text"] = get_location_name()
	data["beacon_active"] = beacon_active
	data["beacon_ready"] = (world.time >= beacon_cooldown)
	data["beacon_cooldown"] = max(0, round((beacon_cooldown - world.time) / 10))
	data["beacon_time_remaining"] = beacon_active ? max(0, round((beacon_cooldown - world.time) / 10)) : 0
	var/list/devices = list()
	var/turf/device_turf = get_turf(src)

	// Only show other devices if we're on a planet and transmitting
	if(!emped && transmitting && device_turf?.planet)
		var/datum/virtual_z/vz = device_turf.get_virtual_z()
		if(istype(vz))
			// Always show docking ports on this planet
			for(var/obj/docking_port/destination/planet_surface/port in all_docking_ports)
				var/turf/port_turf = get_turf(port)
				var/datum/virtual_z/port_vz = port_turf.get_virtual_z()
				if(!port_vz)
					continue
				if(port_vz == vz)
					var/planet_name = vz.planet ? vz.planet.planet_name : "Unknown Planet"
					var/list/device_data = list()
					device_data["tag"] = "DOCK"
					device_data["location_text"] = "[port.areaname] ([planet_name]: [port_turf.vx() - get_world_x_offset(port_vz.id)], [port_turf.vy() - get_world_y_offset(port_vz.id)], [port_vz.id])"
					devices += list(device_data)

			// Only show other planetary GPSes on the same planet
			for(var/obj/item/device/gps/planetary/other in gps_list)
				if(!other.transmitting || other == src)
					continue
				var/turf/other_turf = get_turf(other)
				if(!other_turf?.planet)
					continue
				var/datum/virtual_z/other_vz = other_turf.get_virtual_z()
				if(other_vz == vz)
					var/list/device_data = list()
					device_data["tag"] = other.gpstag
					device_data["location_text"] = other.get_location_name()
					devices += list(device_data)
	data["devices"] = devices
	return data

/obj/item/device/gps/planetary/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("distress_beacon")
			if(world.time < beacon_cooldown)
				to_chat(usr, "<span class='warning'>The distress beacon is still recharging!</span>")
				return FALSE
			if(emped)
				to_chat(usr, "<span class='warning'>The GPS is experiencing electromagnetic interference!</span>")
				return FALSE
			var/turf/device_turf = get_turf(src)
			if(!device_turf?.planet)
				to_chat(usr, "<span class='warning'>The distress beacon only works on planet surfaces!</span>")
				return FALSE

			// planet information
			var/datum/virtual_z/vz = device_turf.get_virtual_z()
			if(!istype(vz))
				to_chat(usr, "<span class='warning'>Unable to determine location!</span>")
				return FALSE

			var/planet_name = vz.planet ? vz.planet.planet_name : "Unknown Planet"
			var/area/device_area = get_area(src)

			// station-wide announcement
			command_alert("Emergency distress beacon activated by GPS unit [gpstag] on planet [planet_name]. Location: [format_text(device_area.name)] ([device_turf.vx() - get_world_x_offset(vz.id)], [device_turf.vy() - get_world_y_offset(vz.id)], [vz.id])", "Planetary Distress Beacon Activated")

			// cooldown
			beacon_cooldown = world.time + beacon_cooldown_time
			beacon_active = TRUE
			beacon_activation_time = world.time

			to_chat(usr, "<span class='notice'>Distress beacon activated! A station-wide alert has been sent.</span>")
			playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 1)

			return TRUE
		if("cancel_beacon")
			if(!beacon_active)
				to_chat(usr, "<span class='warning'>No beacon is currently active!</span>")
				return FALSE

			beacon_active = FALSE
			to_chat(usr, "<span class='notice'>Distress beacon cancelled.</span>")
			return TRUE
	return FALSE

/obj/item/device/gps/planetary/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	var/data[0]
	if(emped)
		data["emped"] = TRUE
	data["transmitting"] = transmitting
	data["gpstag"] = gpstag
	data["autorefresh"] = autorefreshing
	data["location_text"] = get_location_name()
	data["beacon_active"] = beacon_active
	data["beacon_ready"] = (world.time >= beacon_cooldown)
	data["beacon_cooldown"] = max(0, round((beacon_cooldown - world.time) / 10))
	data["beacon_time_remaining"] = beacon_active ? max(0, round((beacon_cooldown - world.time) / 10)) : 0
	var/list/devices = list()
	var/turf/device_turf = get_turf(src)
	var/datum/virtual_z/vz = device_turf.get_virtual_z()

	if(istype(vz))
		for(var/obj/docking_port/destination/planet_surface/port in all_docking_ports)
			var/turf/port_turf = get_turf(port)
			if(!port_turf)
				continue
			var/datum/virtual_z/port_v = port_turf.get_virtual_z()
			if(!port_v)
				continue
			if(port_v == vz)
				var/planet_name = vz.planet ? vz.planet.planet_name : "Unknown Planet"
				var/device_data[0]
				device_data["tag"] = "DOCK"
				device_data["location_text"] = "[port.areaname] ([planet_name]: [port_turf.vx() - get_world_x_offset(port_v.id)], [port_turf.vy() - get_world_y_offset(port_v.id)], [port_v.id])"
				devices += list(device_data)

		for(var/D in gps_list)
			var/obj/item/device/gps/planetary/G = D
			if(!istype(G) || !G.transmitting || src == G)
				continue
			var/turf/other_turf = get_turf(G)
			if(!other_turf)
				continue
			var/datum/virtual_z/other_v = other_turf.get_virtual_z()
			if(!other_v)
				continue
			if(other_v == vz)
				var/device_data[0]
				device_data["tag"] = G.gpstag
				device_data["location_text"] = G.get_location_name()
				devices += list(device_data)
	data["devices"] = devices

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "gps.tmpl", "[src]", 530, 600)
		ui.set_initial_data(data)
		ui.open()
	ui.set_auto_update(autorefreshing)

/obj/item/device/gps/planetary/Topic(href, href_list)
	if(..())
		return FALSE
	if(href_list["distress_beacon"])
		if(world.time < beacon_cooldown)
			to_chat(usr, "<span class='warning'>The distress beacon is still recharging!</span>")
			return FALSE
		if(emped)
			to_chat(usr, "<span class='warning'>The GPS is experiencing electromagnetic interference!</span>")
			return FALSE
		var/turf/device_turf = get_turf(src)
		if(!device_turf?.planet)
			to_chat(usr, "<span class='warning'>The distress beacon only works on planetary surfaces!</span>")
			return FALSE

		var/datum/virtual_z/vz = device_turf.get_virtual_z()
		if(!istype(vz))
			to_chat(usr, "<span class='warning'>Unable to determine planetary location!</span>")
			return FALSE

		var/planet_name = vz.planet ? vz.planet.planet_name : "Unknown Planet"
		var/area/device_area = get_area(src)

		command_alert("Emergency distress beacon activated by GPS unit [gpstag] on planet [planet_name]. Location: [format_text(device_area.name)] ([device_turf.vx() - get_world_x_offset(vz.id)], [device_turf.vy() - get_world_y_offset(vz.id)], [vz.id])", "Planetary Distress Beacon Activated")

		beacon_cooldown = world.time + beacon_cooldown_time
		beacon_active = TRUE
		beacon_activation_time = world.time

		to_chat(usr, "<span class='notice'>Distress beacon activated! A station-wide alert has been sent.</span>")
		playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 1)

		return TRUE
	if(href_list["cancel_beacon"])
		if(!beacon_active)
			to_chat(usr, "<span class='warning'>No beacon is currently active!</span>")
			return FALSE

		beacon_active = FALSE
		to_chat(usr, "<span class='notice'>Distress beacon cancelled.</span>")
		return TRUE
	return FALSE
