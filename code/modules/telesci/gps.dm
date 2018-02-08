var/list/GPS_list = list()
var/list/SPS_list = list()

/obj/item/device/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016."
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

/obj/item/device/gps/proc/gen_id()
	return GPS_list.len

/obj/item/device/gps/proc/get_list()
	return GPS_list.Copy()

/obj/item/device/gps/proc/update_name()
	name = "[base_name] ([gpstag])"

/obj/item/device/gps/New()
	..()
	gpstag = "[base_tag][gen_id()]"
	update_name()
	overlays += image(icon = icon, icon_state = "working")
	handle_list()

/obj/item/device/gps/proc/handle_list()
	GPS_list.Add(src)

/obj/item/device/gps/Destroy()
	if(istype(src,/obj/item/device/gps/secure))
		SPS_list.Remove(src)
	else
		GPS_list.Remove(src)
	..()

/obj/item/device/gps/emp_act(severity)
	emped = 1
	overlays -= image(icon = icon, icon_state = "working")
	overlays += image(icon = icon, icon_state = "emp")
	spawn(30 SECONDS)
		emped = 0
		overlays -= image(icon = icon, icon_state = "emp")
		overlays += image(icon = icon, icon_state = "working")

/obj/item/device/gps/attack_self(mob/user)
	ui_interact(user)

/obj/item/device/gps/examine(mob/user)
	if (Adjacent(user) || isobserver(user))
		src.attack_self(user)
	else
		..()

/obj/item/device/gps/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	var/data[0]
	if(emped)
		data["emped"] = TRUE
	else
		data["gpstag"] = gpstag
		data["autorefresh"] = autorefreshing
		var/list/devices = list()
		for(var/D in get_list())
			var/device_data[0]
			var/turf/device_turf = get_turf(D)
			var/area/device_area = get_area(D)
			var/device_tag = null
			var/device_rip = null
			if(ispAI(D))
				var/mob/living/silicon/pai/P = D
				device_tag = P.ppstag
				device_rip = P.silence_time
			else
				var/obj/item/device/gps/G = D
				device_tag = G.gpstag
				device_rip = G.emped
			device_data["tag"] = device_tag
			if(device_rip)
				device_data["location_text"] = "ERROR"
			else if(!device_turf || !device_area)
				device_data["location_text"] = "UNKNOWN"
			else if(device_turf.z > WORLD_X_OFFSET.len)
				device_data["location_text"] = "[format_text(device_area.name)] (UNKNOWN, UNKNOWN, UNKNOWN)"
			else
				device_data["location_text"] = "[format_text(device_area.name)] ([device_turf.x-WORLD_X_OFFSET[device_turf.z]], [device_turf.y-WORLD_Y_OFFSET[device_turf.z]], [device_turf.z])"
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
		return 0

	if(href_list["tag"])
		if (isobserver(usr))
			to_chat(usr, "No way.")
			return 0
		if (usr.get_active_hand() != src || usr.stat) //no silicons allowed
			to_chat(usr, "<span class = 'caution'>You need to have the GPS in your hand to do that!</span>")
			return 1

		var/a = input("Please enter desired tag.", name, gpstag) as text|null
		if (!a) //what a check
			return 1

		if (usr.get_active_hand() != src || usr.stat) //second check in case some chucklefuck drops the GPS while typing the tag
			to_chat(usr, "<span class = 'caution'>The GPS needs to be kept in your active hand!</span>")
			return 1
		a = strict_ascii(a)
		if(length(a) < 4 || length(a) > 5)
			to_chat(usr, "<span class = 'caution'>The tag must be between four and five characters long!</span>")
		else
			gpstag = a
			update_name()
		return 1
	if(href_list["toggle_refresh"])
		autorefreshing = !autorefreshing
		return 1

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

/obj/item/device/gps/secure
	base_name = "secure positioning system"
	desc = "A secure channel SPS. It announces the position of the wearer if killed or stripped off."
	icon_state = "sps"
	base_tag = "SEC"

/obj/item/device/gps/secure/handle_list()
	SPS_list.Add(src)

/obj/item/device/gps/secure/gen_id()
	return SPS_list.len

/obj/item/device/gps/secure/get_list()
	return SPS_list.Copy()

/obj/item/device/gps/secure/OnMobDeath(mob/wearer)
	if(emped)
		return

	for(var/E in SPS_list)
		var/obj/item/device/gps/secure/S = E //No idea why casting it like this makes it work better instead of just defining it in the for each
		S.announce(wearer, src, "has detected the death of their wearer")

/obj/item/device/gps/secure/stripped(mob/wearer)
	if(emped)
		return
	. = ..()

	for(var/E in SPS_list)
		var/obj/item/device/gps/secure/S = E
		S.announce(wearer, src, "has been stripped from their wearer")

/obj/item/device/gps/secure/proc/announce(var/mob/wearer, var/obj/item/device/gps/secure/SPS, var/reason)
	var/turf/pos = get_turf(SPS)
	var/mob/living/L = get_holder_of_type(src, /mob/living/)
	if(L)
		L.show_message("\icon[src] [gpstag] beeps: <span class='danger'>Warning! SPS '[SPS.gpstag]' [reason] at [get_area(SPS)] ([pos.x-WORLD_X_OFFSET[pos.z]], [pos.y-WORLD_Y_OFFSET[pos.z]], [pos.z]).</span>", MESSAGE_HEAR)
	else if(isturf(src.loc))
		src.visible_message("\icon[src] [gpstag] beeps: <span class='danger'>Warning! SPS '[SPS.gpstag]' [reason] at [get_area(SPS)] ([pos.x-WORLD_X_OFFSET[pos.z]], [pos.y-WORLD_Y_OFFSET[pos.z]], [pos.z]).</span>")
