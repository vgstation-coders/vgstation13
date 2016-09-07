var/list/station_holomaps = list()

/obj/machinery/station_map
	name = "station holomap"
	desc = "A virtual map of the surrounding station."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "station_map"
	anchored = 1
	density = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 10
	dir = NORTH

	use_auto_lights = 1
	light_color = "#64C864"
	light_power_on = 1
	light_range_on = 2

	machine_flags = SCREWTOGGLE | FIXED2WORK | CROWDESTROY

	layer = ABOVE_WINDOW_LAYER

	var/mob/watching_mob = null
	var/image/station_map = null
	var/image/small_station_map = null
	var/image/floor_markings = null
	var/image/panel = null
	var/image/cursor = null
	var/image/legend = null

	var/original_zLevel = 1
	var/bogus = 0

/obj/machinery/station_map/New()
	..()
	original_zLevel = loc.z
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
	bogus = 0
	original_zLevel = loc.z
	if(!(HOLOMAP_EXTRA_STATIONMAP+"_[original_zLevel]" in extraMiniMaps))
		bogus = 1
		station_map = image('icons/480x480.dmi', "stationmap")
		legend = image('icons/effects/64x64.dmi', "notfound")
		legend.pixel_x = 7*WORLD_ICON_SIZE
		legend.pixel_y = 7*WORLD_ICON_SIZE
		update_icon()
		return

	station_map = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAP+"_[original_zLevel]"])
	small_station_map = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH+"_[original_zLevel]"])
	small_station_map.plane = LIGHTING_PLANE
	small_station_map.layer = ABOVE_LIGHTING_LAYER
	cursor = image('icons/holomap_markers.dmi', "you")
	if(map.holomap_offset_x.len >= original_zLevel)
		cursor.pixel_x = (x-6+map.holomap_offset_x[original_zLevel])*PIXEL_MULTIPLIER
		cursor.pixel_y = (y-6+map.holomap_offset_y[original_zLevel])*PIXEL_MULTIPLIER
	else
		cursor.pixel_x = (x-6)*PIXEL_MULTIPLIER
		cursor.pixel_y = (y-6)*PIXEL_MULTIPLIER
	legend = image('icons/effects/64x64.dmi', "legend")
	legend.pixel_x = 3*WORLD_ICON_SIZE
	legend.pixel_y = 3*WORLD_ICON_SIZE
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
			flick("station_map_activate", src)
			watching_mob.client.images |= station_map
			watching_mob.callOnFace |= "\ref[src]"
			watching_mob.callOnFace["\ref[src]"] = "checkPosition"
			if(bogus)
				to_chat(user, "<span class='warning'>The holomap failed to initialize. This area of space cannot be mapped.</span>")
			else
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

/obj/machinery/station_map/power_change()
	. = ..()
	update_icon()

/obj/machinery/station_map/proc/set_broken()
	stat |= BROKEN
	update_icon()

/obj/machinery/station_map/update_icon()
	overlays.len = 0
	if(stat & BROKEN)
		icon_state = "station_mapb"
	else if((stat & NOPOWER) || !anchored)
		icon_state = "station_map0"
	else
		icon_state = "station_map"

		if(bogus)
			station_map.overlays.len = 0
			station_map.overlays |= legend
		else
			switch(dir)
				if(NORTH)
					small_station_map.icon = extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH+"_[original_zLevel]"]
				if(SOUTH)
					small_station_map.icon = extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_SOUTH+"_[original_zLevel]"]
				if(EAST)
					small_station_map.icon = extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_EAST+"_[original_zLevel]"]
				if(WEST)
					small_station_map.icon = extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_WEST+"_[original_zLevel]"]

			overlays |= small_station_map
			station_map.overlays.len = 0
			cursor.pixel_x = (x-6)*PIXEL_MULTIPLIER
			cursor.pixel_y = (y-6)*PIXEL_MULTIPLIER
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

	if(floor_markings)
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
				set_broken()
		if(3.0)
			if (prob(25))
				set_broken()

//Portable holomaps, currently AI/Borg/MoMMI only
/obj/item/device/station_map
	name					= "portable station holomap"
	desc					= "A virtual map of the surrounding station."
	icon_state				= "station_map"
	flags					= FPRINT
	siemens_coefficient		= 1
	force					= 5.0
	w_class					= 2.0
	throwforce				= 5.0
	throw_range				= 15
	throw_speed				= 3
	starting_materials		= list(MAT_IRON = 50, MAT_GLASS = 20)
	w_type					= RECYK_ELECTRONIC
	melt_temperature		= MELTPOINT_SILICON
	origin_tech				= Tc_MAGNETS + "=2;" + Tc_PROGRAMMING + "=2"

	var/mob/watching_mob = null
	var/image/station_map = null
	var/image/cursor = null
	var/image/legend = null

/obj/item/device/station_map/attack_self(var/mob/user)
	toggleHolomap(user)

/obj/item/device/station_map/proc/toggleHolomap(var/mob/user,var/isAI=0)
	if(watching_mob)
		if(watching_mob == user)
			stopWatching()
			return
		else
			stopWatching()

	if(user.hud_used && user.hud_used.holomap_obj)
		watching_mob = user
		var/turf/T = get_turf(user)
		var/bogus = 0
		if(!(HOLOMAP_EXTRA_STATIONMAP+"_[T.z]" in extraMiniMaps))
			bogus = 1
			station_map = image('icons/480x480.dmi', "stationmap")
			legend = image('icons/effects/64x64.dmi', "notfound")
			legend.pixel_x = 7*WORLD_ICON_SIZE
			legend.pixel_y = 7*WORLD_ICON_SIZE
			station_map.overlays |= legend
		else
			station_map = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAP+"_[T.z]"])
			cursor = image('icons/holomap_markers.dmi', "you")
			if(isAI)
				T = get_turf(user.client.eye)
			if(map.holomap_offset_x.len >= T.z)
				cursor.pixel_x = (T.x-6+map.holomap_offset_x[T.z])*PIXEL_MULTIPLIER
				cursor.pixel_y = (T.y-6+map.holomap_offset_y[T.z])*PIXEL_MULTIPLIER
			else
				cursor.pixel_x = (T.x-6)*PIXEL_MULTIPLIER
				cursor.pixel_y = (T.y-6)*PIXEL_MULTIPLIER
			legend = image('icons/effects/64x64.dmi', "legend")
			legend.pixel_x = 3*WORLD_ICON_SIZE
			legend.pixel_y = 3*WORLD_ICON_SIZE
			station_map.overlays |= cursor
			station_map.overlays |= legend

		station_map.loc = user.hud_used.holomap_obj
		station_map.alpha = 0
		animate(station_map, alpha = 255, time = 5, easing = LINEAR_EASING)

		user.client.images |= station_map

		if(bogus)
			to_chat(user, "<span class='warning'>The holomap failed to initialize. This area of space cannot be mapped.</span>")
		else
			to_chat(user, "<span class='notice'>An hologram of the station appears before your eyes.</span>")

/obj/item/device/station_map/Destroy()
	stopWatching()
	..()

/obj/item/device/station_map/dropped(mob/user)
	stopWatching()

/obj/item/device/station_map/proc/stopWatching()
	if(watching_mob)
		if(watching_mob.client)
			var/mob/M = watching_mob
			spawn(5)//we give it time to fade out
				M.client.images -= station_map
	watching_mob = null
	animate(station_map, alpha = 0, time = 5, easing = LINEAR_EASING)
