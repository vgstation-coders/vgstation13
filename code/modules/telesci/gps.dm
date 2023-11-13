var/list/GPS_list = list()
var/list/SPS_list = list()
var/list/all_GPS_list = list()

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
	if(user.client.prefs.tgui_fancy)
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
	if (emped)
		return "ERROR"
	else if(!device_turf || !device_area)
		return "UNKNOWN"
	else if(device_turf.z > WORLD_X_OFFSET.len)
		return "[format_text(device_area.name)] (UNKNOWN, UNKNOWN, UNKNOWN)"
	else
		return "[format_text(device_area.name)] ([device_turf.x-WORLD_X_OFFSET[device_turf.z]], [device_turf.y-WORLD_Y_OFFSET[device_turf.z]], [device_turf.z])"

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
	if(!emped && transmitting)
		var/list/ui_list
		if(view_all)
			ui_list = all_GPS_list
		else
			ui_list = gps_list
		for(var/obj/item/device/gps/other in ui_list)
			if(!other.transmitting || other == src)
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
	var/list/ui_list
	if(view_all)
		ui_list = all_GPS_list
	else
		ui_list = gps_list
	for(var/D in ui_list)
		var/obj/item/device/gps/G = D
		if(G.transmitting && src != G)
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
	var/turf/pos = get_turf(SPS)
	var/x0 = pos.x-WORLD_X_OFFSET[pos.z]
	var/y0 = pos.x-WORLD_Y_OFFSET[pos.z]
	var/z0 = pos.z
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
	var/turf/pos = get_turf(src)

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
			playsound(src, 'sound/items/unitdownat.wav',100, 0,channel = sound_channel,wait = TRUE)
			playnum(pos.x-WORLD_X_OFFSET[pos.z],sound_channel,src)
			playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
			playnum(pos.y-WORLD_Y_OFFSET[pos.z],sound_channel,src)
			playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
			playnum(pos.z,sound_channel,src)
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
