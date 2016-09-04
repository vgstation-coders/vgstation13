
/obj/machinery/station_map
	name = "station holomap"
	desc = "Stand on top of it to spawn a virtual map of the station"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "station_map"
	anchored = 1
	density = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 10

	machine_flags = WRENCHMOVE | FIXED2WORK

	layer = ABOVE_WINDOW_LAYER

	var/mob/watching_mob = list()
	var/image/station_map = null
	var/image/small_station_map = null
	var/image/cursor = null

/obj/machinery/station_map/New()
	..()
	if(ticker)
		initialize()

/obj/machinery/station_map/Destroy()
	stopWatching()
	..()

/obj/machinery/station_map/initialize()
	station_map = image(extraMiniMaps["stationmapformated"])
	small_station_map = image(extraMiniMaps["stationmapsmall"])
	small_station_map.plane = LIGHTING_PLANE
	small_station_map.layer = ABOVE_LIGHTING_LAYER
	cursor = image('icons/12x12.dmi', "you")
	cursor.pixel_x = x-6
	cursor.pixel_y = y-6
	station_map.overlays |= cursor
	update_icon()

/obj/machinery/station_map/Crossed(atom/movable/O)
	..()
	if(watching_mob && (watching_mob != O))
		stopWatching()

	if(isliving(O) && anchored && !(stat & (NOPOWER|BROKEN)))
		var/mob/user = O
		if(user.hud_used && user.hud_used.holomap_obj)
			station_map.loc = user.hud_used.holomap_obj
			station_map.alpha = 0
			animate(station_map, alpha = 255, time = 5, easing = LINEAR_EASING)
			watching_mob = user
			flick("[icon_state]_activate", src)
			watching_mob.client.images |= station_map
			to_chat(user, "<span class='notice'>An hologram of the station appears before your eyes.</span>")

/obj/machinery/station_map/Uncrossed(atom/movable/O)
	if(watching_mob == O)
		stopWatching()
	..()

/obj/machinery/station_map/process()
	if((stat & (NOPOWER|BROKEN)) || !anchored)
		stopWatching()

	if(watching_mob && !(watching_mob in range(src,0)))
		stopWatching()

	update_icon()

/obj/machinery/station_map/proc/stopWatching()
	if(watching_mob && watching_mob.client)
		var/mob/M = watching_mob
		spawn(5)//we give it time to fade out
			M.client.images -= station_map
	watching_mob = null
	animate(station_map, alpha = 0, time = 5, easing = LINEAR_EASING)

/obj/machinery/station_map/update_icon()
	overlays.len = 0
	if(stat & BROKEN)
		icon_state = "station_mapb"
	else if((stat & NOPOWER) || !anchored)
		icon_state = "station_map0"
	else
		icon_state = "station_map"
		overlays |= small_station_map

		station_map.overlays.len = 0
		cursor.pixel_x = x-6
		cursor.pixel_y = y-6
		station_map.overlays |= cursor

/obj/machinery/station_map/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
			else
				stat |= BROKEN
		if(3.0)
			if (prob(25))
				stat |= BROKEN
	update_icon()
