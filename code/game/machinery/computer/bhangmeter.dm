var/list/bhangmeters = list()
var/list/list/sensed_explosions = list()

/*
	/obj/machinery/computer/bhangmeter
	/datum/station_holomap/bhang
	/datum/sensed_explosion
*/

/obj/machinery/computer/bhangmeter
	name = "bhangmeter"
	desc = "Uses a tachyon-doppler array to measure explosions of all shapes and sizes, as well as detecting meteors on a collision course with the station."
	icon = 'icons/obj/computer.dmi'
	icon_state = "bhangmeter"
	circuit = "/obj/item/weapon/circuitboard/bhangmeter"

	light_color = "#FFD400"

	var/mob/watching_mob = null
	var/list/watching_mobs = list()
	var/list/watcher_maps = list()
	var/list/watcher_buttons = list()

	var/original_zLevel = 1	//zLevel on which the machine was initialized.
	var/forced_zLevel = 0	//can be set by mappers to override the Station Map's zLevel
							//only zLevels to have an actual map displayed are the Station, the Asteroid, and the Derelict.

	var/datum/station_holomap/bhang/holomap_datum

	var/announcement_cooldown = 5 SECONDS
	var/last_announcement = 0
	var/datum/sensed_explosion/last_announced_explosion

/obj/machinery/computer/bhangmeter/New()
	..()
	if (forced_zLevel)
		original_zLevel = forced_zLevel
	else
		original_zLevel = loc.z
	bhangmeters += src
	if(ticker && holomaps_initialized)
		initialize()

/obj/machinery/computer/bhangmeter/Destroy()
	bhangmeters -= src
	stopWatching()
	holomap_datum = null
	..()

/obj/machinery/computer/bhangmeter/initialize()
	var/turf/T
	if (forced_zLevel)
		var/turf/U = get_turf(src)
		T = locate(U.x,U.y,forced_zLevel)
		original_zLevel = forced_zLevel
	else
		T = get_turf(src)
		original_zLevel = T.z

	holomap_datum = new()
	holomap_datum.initialize_holomap(T)

/obj/machinery/computer/bhangmeter/process()
	. = ..()
	if (.)
		for (var/mob/M in watching_mobs)
			if (M.client)
				M.client.images -= watcher_maps["\ref[M]"]
				qdel(watcher_maps["\ref[M]"])
				watcher_maps["\ref[M]"] = image(holomap_datum.get_bhangmap())
				var/image/I = watcher_maps["\ref[M]"]
				I.loc = M.hud_used.holomap_obj
				M.client.images |= watcher_maps["\ref[M]"]
	else
		stopWatching()

/obj/machinery/computer/bhangmeter/say_quote(text)
	return "coldly states, [text]"

/obj/machinery/computer/bhangmeter/attack_hand(var/mob/user)
	. = ..()

	if (.)
		return

	if( (holoMiniMaps.len < user.loc.z) || (holoMiniMaps[user.loc.z] == null ))
		to_chat(user, "<span class='notice'>The holomap doesn't seem to be working.</span>")
		var/datum/browser/popup = new(user, "\ref[src]", name, 650, 300, src)
		popup.set_content(bhangmeterPanel())
		popup.open()
		return

	if(user in watching_mobs)
		stopWatching(user)
		return

	if(user.hud_used && user.hud_used.holomap_obj)
		watcher_maps["\ref[user]"] = image(holomap_datum.get_bhangmap())
		var/image/I = watcher_maps["\ref[user]"]
		I.loc = user.hud_used.holomap_obj
		I.alpha = 0
		animate(watcher_maps["\ref[user]"], alpha = 255, time = 5, easing = LINEAR_EASING)
		watching_mobs |= user
		user.client.images |= watcher_maps["\ref[user]"]
		user.register_event(/event/face, src, /obj/machinery/station_map/proc/checkPosition)
		to_chat(user, "<span class='notice'>A hologram of the station appears before your eyes.</span>")

		watcher_buttons["\ref[user]"] = new /obj/abstract/screen/interface(user.hud_used.holomap_obj,user,src,"Database",'icons/effects/64x32.dmi',"database",l="CENTER-0.5,CENTER-4")
		var/obj/abstract/screen/interface/button_database = watcher_buttons["\ref[user]"]
		button_database.name = "Database"
		button_database.alpha = 0
		animate(button_database, alpha = 255, time = 5, easing = LINEAR_EASING)
		user.client.screen += watcher_buttons["\ref[user]"]

/obj/machinery/computer/bhangmeter/attack_paw(var/mob/user)
	attack_hand(user)

/obj/machinery/computer/bhangmeter/attack_animal(var/mob/user)
	attack_hand(user)

/obj/machinery/computer/bhangmeter/attack_ghost(var/mob/user)
	attack_hand(user)

/obj/machinery/computer/bhangmeter/interface_act(var/mob/i_user,var/action)
	if(action == "Database")
		var/datum/browser/popup = new(i_user, "\ref[src]", name, 650, 300, src)
		popup.set_content(bhangmeterPanel())
		popup.open()

/obj/machinery/computer/bhangmeter/proc/bhangmeterPanel()
	if (!original_zLevel)
		original_zLevel = z
	var/datum/zLevel/thisZ = map.zLevels[original_zLevel]
	var/dat = {"<html>
		<head>
		<style>
		table,h2 {
		font-family: Arial, Helvetica, sans-serif;
		border-collapse: collapse;
		}
		td, th {
		border: 1px solid #dddddd;
		padding: 1px;
		}
		tr:nth-child(even) {
		background-color: #888888;
		}
		</style>
		</head>
		<body>
		<h2 style="text-align:center">Bhangmeter Database ([thisZ.name])</h2>
		<table>
		<tr>
		<th style="width:0.2%">#</th>
		<th style="width:0.2%">Time</th>
		<th style="width:1%">Area</th>
		<th style="width:0.2%">Epicenter</th>
		<th style="width:1%">Range (Dev/Heavy/Light)</th>
		<th style="width:0.3%">Temp. Disp.</th>
		</tr>
		"}
	var/sensed_list = ""
	for (var/datum/sensed_explosion/SE in sensed_explosions["z[z]"])
		var/SE_dat = {"<tr>
				<td style="text-align:center">[SE.ID]</td>
				<td style="text-align:center">[SE.time]</td>
				<td style="text-align:center">[SE.area.name]</td>
				<td style="text-align:center">([SE.x],[SE.y],[SE.z])</td>
				"}
		if (SE.cap)
			SE_dat += {"<td style="text-align:center"><b>!![round(SE.cap*0.25)]  /  [round(SE.cap*0.5)]  /  [round(SE.cap)]!!</b></td>"}
		else
			SE_dat += {"<td style="text-align:center">[SE.dev] / [SE.heavy] / [SE.light]</td>"}
		SE_dat += {"<td style="text-align:center">[SE.delay] sec</td></tr>"}
		sensed_list = SE_dat + sensed_list
	dat += sensed_list
	return dat

/obj/machinery/computer/bhangmeter/proc/checkPosition()
	for(var/mob/M in watching_mobs)
		if(get_dist(src,M) > 1)
			stopWatching(M)

/obj/machinery/computer/bhangmeter/proc/stopWatching(var/mob/user)
	if(!user)
		for(var/mob/M in watching_mobs)
			if(M.client)
				spawn(5)//we give it time to fade out
					M.client.images -= watcher_maps["\ref[M]"]
					qdel(watcher_maps["\ref[M]"])
				M.client.screen -= watcher_buttons["\ref[M]"]
				qdel(watcher_buttons["\ref[M]"])
				M.unregister_event(/event/face, src, /obj/machinery/station_map/proc/checkPosition)
				animate(watcher_maps["\ref[M]"], alpha = 0, time = 5, easing = LINEAR_EASING)

		watching_mobs = list()
	else
		if(user.client)
			spawn(5)//we give it time to fade out
				if(!(user in watching_mobs))
					user.client.images -= watcher_maps["\ref[user]"]
					qdel(watcher_maps["\ref[user]"])
					watcher_maps -= "\ref[user]"
			user.client.screen -= watcher_buttons["\ref[user]"]
			qdel(watcher_buttons["\ref[user]"])
			user.unregister_event(/event/face, src, /obj/machinery/station_map/proc/checkPosition)
			animate(watcher_maps["\ref[user]"], alpha = 0, time = 5, easing = LINEAR_EASING)

			watching_mobs -= user

/obj/machinery/computer/bhangmeter/proc/announce_explosion(var/datum/sensed_explosion/SE)
	if(stat & (FORCEDISABLE|NOPOWER|BROKEN))
		return
	if (SE.z != original_zLevel)
		return
	if (last_announced_explosion && (world.time < (last_announcement + announcement_cooldown)))
		var/new_score = SE.dev * 4 + SE.heavy * 2 + SE.light
		var/old_score = last_announced_explosion.dev * 4 + last_announced_explosion.heavy * 2 + last_announced_explosion.light
		if (old_score >= new_score)
			return//We add a delay between announcements, unless the new explosion is larger than the last one.
	last_announcement = world.time
	last_announced_explosion = SE
	if (SE.cap)
		say("Explosive disturbance detected - Epicenter at: [SE.area.name] ([SE.x-WORLD_X_OFFSET[SE.z]],[SE.y-WORLD_Y_OFFSET[SE.z]], [SE.z]). \[Theoretical Results\] Epicenter radius: [round(SE.cap*0.25)]. Outer radius: [round(SE.cap*0.5)]. Shockwave radius: [round(SE.cap)]. Temporal displacement of tachyons: [SE.delay] second\s.")
	else
		say("Explosive disturbance detected - Epicenter at: [SE.area.name] ([SE.x-WORLD_X_OFFSET[SE.z]],[SE.y-WORLD_Y_OFFSET[SE.z]], [SE.z]). Epicenter radius: [SE.dev]. Outer radius: [SE.heavy]. Shockwave radius: [SE.light]. Temporal displacement of tachyons: [SE.delay] second\s.")


/obj/machinery/computer/bhangmeter/proc/announce_meteors(var/datum/meteor_warning/MW)
	if(stat & (FORCEDISABLE|NOPOWER|BROKEN))
		return
	if (original_zLevel != map.zMainStation)
		return

	say("[MW.name], containing [MW.num] objects up to [MW.size] size and incoming from the [MW.dir], will strike in [MW.delay/10] seconds.")


///////////////////////////////////////////////////////////////////////////////////////////////

/datum/station_holomap/bhang

/datum/station_holomap/bhang/initialize_holomap(var/turf/T, var/isAI=null, var/mob/user=null, var/cursor_icon = null)
	z = T.z
	station_map = image(extraMiniMaps["[HOLOMAP_EXTRA_BHANGBASEMAP]_[z]"])

/datum/station_holomap/bhang/proc/get_bhangmap()
	var/image/base_map = image(station_map)
	var/image/bhang_map = image(extraMiniMaps["[HOLOMAP_EXTRA_BHANGMAP]_[z]"])
	bhang_map.alpha = 128
	base_map.overlays += bhang_map
	for (var/datum/sensed_explosion/SE in sensed_explosions["z[z]"])
		if (SE.alpha > 0)
			var/image/explosion = image(SE.explosion_icon)
			explosion.alpha = SE.alpha
			base_map.overlays += explosion
	if (z == map.zMainStation)
		for (var/datum/meteor_warning/MW in meteor_warnings)
			base_map.overlays += MW.display
	return base_map

///////////////////////////////////////////////////////////////////////////////////////////////

#define BHANGMAP_COLOR_DEVASTATION	"#FF0000"
#define BHANGMAP_COLOR_HEAVY		"#FF5300"
#define BHANGMAP_COLOR_LIGHT		"#FF8800"

/datum/sensed_explosion
	var/ID
	var/x
	var/y
	var/z
	var/time
	var/dev
	var/heavy
	var/light
	var/delay
	var/area/area
	var/cap

	var/icon/explosion_icon
	var/alpha = 250

/datum/sensed_explosion/New(xPos, yPos, zLevel, devastation_range, heavy_impact_range, light_impact_range, overcap)
	..()
	x = xPos
	y = yPos
	z = zLevel
	time = worldtime2text()
	dev = devastation_range
	heavy = heavy_impact_range
	light = light_impact_range
	area = get_area(locate(x,y,z))
	cap = overcap

	explosion_icon = icon('icons/480x480.dmi', "blank")
	sensed_explosions["z[z]"] += src
	ID = "[z]-[add_zero(sensed_explosions["z[z]"].len,3)]"

/datum/sensed_explosion/Destroy()
	sensed_explosions["z[z]"] -= src
	..()

/datum/sensed_explosion/proc/ready(var/took)
	set waitfor = 0

	delay = took

	if ((dev > -1) || (heavy > -1) || (light > 2))//we only announce notable explosions
		for(var/obj/machinery/computer/bhangmeter/bhangmeter in bhangmeters)
			bhangmeter.announce_explosion(src)

	spawn()
		while(alpha > 0)
			sleep(60 SECONDS)
			alpha -= 50

/datum/sensed_explosion/proc/paint(var/turf/T,var/severity)
	if (!T)
		return
	if (!holomaps_initialized)
		return
	var/icon/bhangmap = extraMiniMaps["[HOLOMAP_EXTRA_BHANGMAP]_[T.z]"]

	var/color = BHANGMAP_COLOR_DEVASTATION
	switch(severity)
		if (1)
			color = BHANGMAP_COLOR_DEVASTATION
		if (2)
			color = BHANGMAP_COLOR_HEAVY
		if (3)
			color = BHANGMAP_COLOR_LIGHT

	if(map.holomap_offset_x.len >= z)
		explosion_icon.DrawBox(color, min(T.x+map.holomap_offset_x[z],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(T.y+map.holomap_offset_y[z],((2 * world.view + 1)*WORLD_ICON_SIZE)))
		bhangmap.DrawBox(color, min(T.x+map.holomap_offset_x[z],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(T.y+map.holomap_offset_y[z],((2 * world.view + 1)*WORLD_ICON_SIZE)))
	else
		explosion_icon.DrawBox(color, T.x, T.y)
		bhangmap.DrawBox(color, T.x, T.y)

#undef BHANGMAP_COLOR_DEVASTATION
#undef BHANGMAP_COLOR_HEAVY
#undef BHANGMAP_COLOR_LIGHT
