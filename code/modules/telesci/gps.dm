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
	spawn(30 SECONDS)
		emped = FALSE
		update_icon()

/obj/item/device/gps/attack_self(mob/user)
	ui_interact(user)

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


/obj/item/device/gps/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	var/data[0]
	if(emped)
		data["emped"] = TRUE
	data["transmitting"] = transmitting
	data["gpstag"] = gpstag
	data["autorefresh"] = autorefreshing
	data["location_text"] = get_location_name()
	var/list/devices = list()
	for(var/D in gps_list)
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

		var/a = input("Please enter desired tag.", name, gpstag) as text|null
		if(!a) //what a check
			return TRUE

		if(!builtin && (usr.get_active_hand() != src || usr.incapacitated())) //second check in case some chucklefuck drops the GPS while typing the tag
			to_chat(usr, "<span class = 'caution'>The GPS needs to be kept in your active hand!</span>")
			return TRUE
		a = strict_ascii(a)
		if(length(a) < 4 || length(a) > 5)
			to_chat(usr, "<span class = 'caution'>The tag must be between four and five characters long!</span>")
		else
			gpstag = a
			update_name()
		return TRUE
	if(href_list["toggle_refresh"])
		autorefreshing = !autorefreshing
		return TRUE
	if(..())
		return FALSE

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
	desc = "A secure channel SPS. If it is transmitting its signal, it will announce the position of the wearer if killed or stripped off to other SPS devices."
	icon_state = "sps"
	base_tag = "SEC"

/obj/item/device/gps/secure/get_gps_list()
	return SPS_list

/obj/item/device/gps/secure/OnMobDeath(mob/wearer)
	if(!transmitting)
		return

	var/channel_index = 0
	var/sps_index = gps_list.Find(src)
	for(var/E in gps_list)
		var/obj/item/device/gps/secure/S = E //No idea why casting it like this makes it work better instead of just defining it in the for each
		S.announce(wearer, src, "has detected the death of their wearer", sps_index, DEATHSOUND_CHANNEL + channel_index, dead = TRUE)
		channel_index++

/obj/item/device/gps/secure/stripped(mob/wearer, mob/stripper)
	if(!transmitting)
		return
	. = ..()
	var/sps_index = gps_list.Find(src)
	var/channel_index = 0
	for(var/E in gps_list)
		var/obj/item/device/gps/secure/S = E
		S.announce(wearer, src, "has been stripped from their wearer", sps_index, DEATHSOUND_CHANNEL + channel_index)
		channel_index++

var/list/deathsound = list('sound/items/die1.wav', 'sound/items/die2.wav', 'sound/items/die3.wav','sound/items/die4.wav')

/obj/item/device/gps/secure/proc/announce(var/mob/wearer, var/obj/item/device/gps/secure/SPS, var/reason,var/num,var/sound_channel,var/dead=FALSE)
	var/turf/pos = get_turf(SPS)
	deathsound(pos,dead,num,sound_channel)
	var/mob/living/L = get_holder_of_type(src, /mob/living/)
	if(L)
		L.show_message("\icon[src] [gpstag] beeps: <span class='danger'>Warning! SPS '[SPS.gpstag]' [reason] at [get_area(SPS)] ([pos.x-WORLD_X_OFFSET[pos.z]], [pos.y-WORLD_Y_OFFSET[pos.z]], [pos.z]).</span>", MESSAGE_HEAR)
	else if(isturf(loc))
		visible_message("\icon[src] [gpstag] beeps: <span class='danger'>Warning! SPS '[SPS.gpstag]' [reason] at [get_area(SPS)] ([pos.x-WORLD_X_OFFSET[pos.z]], [pos.y-WORLD_Y_OFFSET[pos.z]], [pos.z]).</span>")

/proc/SPS_black_market_alert(var/reason)
	var/channel_index = 0
	for(var/E in SPS_list)
		var/obj/item/device/gps/secure/S = E
		S.black_market_announce(reason, DEATHSOUND_CHANNEL + channel_index)
		channel_index++
		
/obj/item/device/gps/secure/proc/black_market_announce(var/reason, var/sound_channel) 
	blackmarket_message(sound_channel)
	var/mob/living/L = get_holder_of_type(src, /mob/living/)
	if(L)
		L.show_message("\icon[src] [gpstag] beeps: <span class='danger'>Warning! [reason]", MESSAGE_HEAR)
	else if(isturf(loc))
		visible_message("\icon[src] [gpstag] beeps: <span class='danger'>Warning! [reason]</span>")
		
var/const/DEATHSOUND_CHANNEL = 300

/obj/item/device/gps/secure/proc/blackmarket_message(var/sound_channel)
	playsound(src, 'sound/items/on3.wav',100, 0,channel = sound_channel,wait = TRUE)
	playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
	if(prob(50))
		playsound(src, 'sound/items/attention.wav',100, 0,channel = sound_channel,wait = TRUE)
		playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
	playsound(src, 'sound/items/investigateandreport.wav',100, 0,channel = sound_channel,wait = TRUE)
	playsound(src, 'sound/items/_comma.wav',100, 0,channel = sound_channel,wait = TRUE)
	playsound(src, 'sound/items/off2.wav',100, 0,channel = sound_channel,wait = TRUE)

/obj/item/device/gps/secure/proc/deathsound(var/turf/pos,var/dead=FALSE,num,var/sound_channel)
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
			playnum(gps_list.Find(src),sound_channel,src)
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
