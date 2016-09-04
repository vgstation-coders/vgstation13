var/list/station_holomaps = list()

/obj/machinery/station_map
	name = "station holomap"
	desc = "A virtual map of the station."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "station_map"
	anchored = 1
	density = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 10
	dir = NORTH

	machine_flags = SCREWTOGGLE | FIXED2WORK | CROWDESTROY

	layer = ABOVE_WINDOW_LAYER

	var/mob/watching_mob = null
	var/image/station_map = null
	var/image/small_station_map = null
	var/image/floor_markings = null
	var/image/panel = null
	var/image/cursor = null
	var/image/legend = null

/obj/machinery/station_map/New()
	..()
	station_holomaps += src
	flags |= ON_BORDER
	component_parts = 0
	if(ticker && holomaps_initialized)
		initialize()

/obj/machinery/station_map/Destroy()
	station_holomaps -= src
	stopWatching()
	..()

/obj/machinery/station_map/crowbarDestroy(mob/user)
	user.visible_message(	"[user] begins to pry out \the [src] from the wall.",
							"You begin to pry out \the [src] from the wall...")
	if(do_after(user, src, 40))
		user.visible_message(	"[user] detaches \the [src] from the wall.",
								"You detach \the [src] from the wall.")
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
		new /obj/item/mounted/frame/station_map(src.loc)

		for(var/obj/I in src)
			qdel(I)

		new /obj/item/weapon/circuitboard/station_map(src.loc)
		new /obj/item/stack/cable_coil(loc,5)
		new /obj/item/stack/sheet/glass/glass(loc,1)

		return 1
	return -1

/obj/machinery/station_map/initialize()
	station_map = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAP])
	small_station_map = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH])
	small_station_map.plane = LIGHTING_PLANE
	small_station_map.layer = ABOVE_LIGHTING_LAYER
	cursor = image('icons/12x12.dmi', "you")
	cursor.pixel_x = x-6
	cursor.pixel_y = y-6
	legend = image('icons/effects/64x64.dmi', "legend")
	legend.pixel_x = 96
	legend.pixel_y = 96
	floor_markings = image('icons/turf/overlays.dmi', "station_map")
	floor_markings.dir = dir
	floor_markings.plane = ABOVE_TURF_PLANE
	floor_markings.layer = DECAL_LAYER
	station_map.overlays |= cursor
	station_map.overlays |= legend
	update_icon()

/obj/machinery/station_map/attack_hand(var/mob/user)
	if(watching_mob && (watching_mob != user))
		to_chat(user, "<span class='warning'>Someone else is currently watching the holomap.</span>")
		return

	if(user.loc != loc)
		to_chat(user, "<span class='warning'>You need to stand in front of \the [src].</span>")
		return

	if(isliving(user) && anchored && !(stat & (NOPOWER|BROKEN)))
		if(user.hud_used && user.hud_used.holomap_obj)
			station_map.loc = user.hud_used.holomap_obj
			station_map.alpha = 0
			animate(station_map, alpha = 255, time = 5, easing = LINEAR_EASING)
			watching_mob = user
			flick("[icon_state]_activate", src)
			watching_mob.client.images |= station_map
			watching_mob.callOnFace |= "\ref[src]"
			watching_mob.callOnFace["\ref[src]"] = "checkPosition"
			to_chat(user, "<span class='notice'>An hologram of the station appears before your eyes.</span>")

/obj/machinery/station_map/attack_paw(var/mob/user)
	src.attack_hand(user)

/obj/machinery/station_map/attack_animal(var/mob/user)
	src.attack_hand(user)

/obj/machinery/station_map/attack_ai(var/mob/user)
	return//TODO: Give AIs their own holomap

/obj/machinery/station_map/process()
	if((stat & (NOPOWER|BROKEN)) || !anchored)
		stopWatching()

	checkPosition()

	update_icon()

/obj/machinery/station_map/proc/checkPosition()
	if(!watching_mob || (watching_mob.loc != loc) || (dir != watching_mob.dir))
		stopWatching()

/obj/machinery/station_map/proc/stopWatching()
	if(watching_mob)
		if(watching_mob.client)
			var/mob/M = watching_mob
			spawn(5)//we give it time to fade out
				M.client.images -= station_map
		watching_mob.callOnFace -= "\ref[src]"
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

		switch(dir)
			if(NORTH)
				small_station_map.icon = extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH]
			if(SOUTH)
				small_station_map.icon = extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_SOUTH]
			if(EAST)
				small_station_map.icon = extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_EAST]
			if(WEST)
				small_station_map.icon = extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_WEST]

		overlays |= small_station_map
		station_map.overlays.len = 0
		cursor.pixel_x = x-6
		cursor.pixel_y = y-6
		if(z == map.zMainStation)
			station_map.overlays |= cursor
		station_map.overlays |= legend

	switch(dir)
		if(NORTH)
			pixel_x = 0
			pixel_y = WORLD_ICON_SIZE
		if(SOUTH)
			pixel_x = 0
			pixel_y = -1*WORLD_ICON_SIZE
		if(EAST)
			pixel_x = WORLD_ICON_SIZE
			pixel_y = 0
		if(WEST)
			pixel_x = -1*WORLD_ICON_SIZE
			pixel_y = 0

	floor_markings.dir = dir
	floor_markings.pixel_x = -1*pixel_x
	floor_markings.pixel_y = -1*pixel_y
	overlays |= floor_markings

	if(panel_open)
		overlays |= "station_map-panel"
	else
		overlays -= "station_map-panel"

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
