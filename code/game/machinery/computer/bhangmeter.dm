var/list/bhangmeters = list()
var/list/sensed_explosions = list()

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

	var/original_zLevel = 1	//zLevel on which the station map was initialized.
	var/forced_zLevel = 0	//can be set by mappers to override the Station Map's zLevel
	var/bogus = 0			//set to 1 when you initialize the station map on a zLevel that doesn't have its own icon formatted for use by station holomaps.
							//currently, the only supported zLevels are the Station, the Asteroid, and the Derelict.

	var/datum/station_holomap/bhang/holomap_datum

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
	return PROCESS_KILL

/obj/machinery/computer/bhangmeter/say_quote(text)
	return "coldly states, [text]"

/obj/machinery/computer/bhangmeter/attack_hand(var/mob/user)
	if(isliving(user) && anchored && !(stat & (FORCEDISABLE|NOPOWER|BROKEN)))
		if( (holoMiniMaps.len < user.loc.z) || (holoMiniMaps[user.loc.z] == null ))
			to_chat(user, "<span class='notice'>It doesn't seem to be working.</span>")
			return
		if(user in watching_mobs)
			stopWatching(user)
		else
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
				to_chat(user, "<span class='notice'>Get detailed info: <a href ='?src=\ref[src];database=1'>\[BHANGMETER DATABASE\]</a></span>")

/obj/machinery/computer/bhangmeter/attack_paw(var/mob/user)
	attack_hand(user)

/obj/machinery/computer/bhangmeter/attack_animal(var/mob/user)
	attack_hand(user)

/obj/machinery/computer/bhangmeter/attack_ghost(var/mob/user)
	attack_hand(user)

/obj/machinery/computer/bhangmeter/Topic(href, href_list)
	..()
	if(usr.incapacitated())
		return
	if(!Adjacent(usr))
		to_chat(usr, "<span class='warning'>You are too far from \the [src].</span>")
		return
	if(href_list["database"])
		var/datum/browser/popup = new(usr, "\ref[src]", name, 600, 300, src)
		popup.set_content(bhangmeterPanel())
		popup.open()

/obj/machinery/computer/bhangmeter/proc/bhangmeterPanel()
	var/datum/zLevel/thisZ = map.zLevels[z]
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
		<th style="width:0.2%">Time</th>
		<th style="width:1%">Area</th>
		<th style="width:0.2%">Epicenter</th>
		<th style="width:1%">Range (Dev/Heavy/Light)</th>
		<th style="width:0.3%">Temp. Disp.</th>
		</tr>
		"}
	for (var/datum/sensed_explosion/SE in sensed_explosions["z[z]"])
		dat += {"<tr>
				<td style="text-align:center">[SE.time]</td>
				<td style="text-align:center">[SE.area.name]</td>
				<td style="text-align:center">([SE.x],[SE.y],[SE.z])</td>
				"}
		if (SE.cap)
			dat += {"<td style="text-align:center">[round(SE.cap*0.25)] / [round(SE.cap*0.5)] / [round(SE.cap)]</td>"}
		else
			dat += {"<td style="text-align:center">[SE.dev] / [SE.heavy] / [SE.light]</td>"}
		dat += {"<td style="text-align:center">[SE.delay] sec</td></tr>"}
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
			user.unregister_event(/event/face, src, /obj/machinery/station_map/proc/checkPosition)
			animate(watcher_maps["\ref[user]"], alpha = 0, time = 5, easing = LINEAR_EASING)

			watching_mobs -= user

/obj/machinery/computer/bhangmeter/proc/announce(var/datum/sensed_explosion/SE)
	if(stat & (FORCEDISABLE|NOPOWER|BROKEN))
		return
	if (SE.z != z)
		return
	if (SE.cap)
		say("Explosive disturbance detected - Epicenter at: [SE.area.name] ([SE.x-WORLD_X_OFFSET[SE.z]],[SE.y-WORLD_Y_OFFSET[SE.z]], [SE.z]). \[Theoretical Results\] Epicenter radius: [round(SE.cap*0.25)]. Outer radius: [round(SE.cap*0.5)]. Shockwave radius: [round(SE.cap)]. Temporal displacement of tachyons: [SE.delay] second\s.")
	else
		say("Explosive disturbance detected - Epicenter at: [SE.area.name] ([SE.x-WORLD_X_OFFSET[SE.z]],[SE.y-WORLD_Y_OFFSET[SE.z]], [SE.z]). Epicenter radius: [SE.dev]. Outer radius: [SE.heavy]. Shockwave radius: [SE.light]. Temporal displacement of tachyons: [SE.delay] second\s.")


///////////////////////////////////////////////////////////////////////////////////////////////

/datum/station_holomap/bhang

/datum/station_holomap/bhang/initialize_holomap(var/turf/T, var/isAI=null, var/mob/user=null, var/cursor_icon = "bloodstone-here")
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
	return base_map

///////////////////////////////////////////////////////////////////////////////////////////////

#define BHANGMAP_COLOR_DEVASTATION	"#FF0000"
#define BHANGMAP_COLOR_HEAVY		"#FF5300"
#define BHANGMAP_COLOR_LIGHT		"#FF8800"

/datum/sensed_explosion
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

/datum/sensed_explosion/Destroy()
	sensed_explosions["z[z]"] -= src
	..()

/datum/sensed_explosion/proc/ready(var/took)
	set waitfor = 0

	delay = took

	if ((dev > -1) || (heavy > -1) || (light > 2))//we only announce notable explosions
		for(var/obj/machinery/computer/bhangmeter/bhangmeter in bhangmeters)
			bhangmeter.announce(src)

	spawn()
		while(alpha > 0)
			sleep(60 SECONDS)
			alpha -= 50

/datum/sensed_explosion/proc/paint(var/turf/T,var/severity)
	if (!T)
		return
	var/icon/bhangmap = extraMiniMaps["[HOLOMAP_EXTRA_BHANGMAP]_[T.z]"]
	var/previous_color = bhangmap.GetPixel(T.x,T.y,null)
	var/previous_intensity = 4
	switch(previous_color)
		if (BHANGMAP_COLOR_DEVASTATION)
			previous_intensity = 1
		if (BHANGMAP_COLOR_HEAVY)
			previous_intensity = 2
		if (BHANGMAP_COLOR_LIGHT)
			previous_intensity = 3

	var/draw_on_mainmap = TRUE
	if (previous_intensity <= severity)
		draw_on_mainmap = FALSE

	var/new_color = BHANGMAP_COLOR_DEVASTATION
	switch(severity)
		if (1)
			new_color = BHANGMAP_COLOR_DEVASTATION
		if (2)
			new_color = BHANGMAP_COLOR_HEAVY
		if (3)
			new_color = BHANGMAP_COLOR_LIGHT

	if(map.holomap_offset_x.len >= z)
		explosion_icon.DrawBox(new_color, min(T.x+map.holomap_offset_x[z],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(T.y+map.holomap_offset_y[z],((2 * world.view + 1)*WORLD_ICON_SIZE)))
		if (draw_on_mainmap)
			bhangmap.DrawBox(new_color, min(T.x+map.holomap_offset_x[z],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(T.y+map.holomap_offset_y[z],((2 * world.view + 1)*WORLD_ICON_SIZE)))
	else
		explosion_icon.DrawBox(new_color, T.x, T.y)
		if (draw_on_mainmap)
			bhangmap.DrawBox(new_color, T.x, T.y)

#undef BHANGMAP_COLOR_DEVASTATION
#undef BHANGMAP_COLOR_HEAVY
#undef BHANGMAP_COLOR_LIGHT
