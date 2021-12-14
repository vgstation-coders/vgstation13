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

	lighting_flags = FOLLOW_PIXEL_OFFSET
	light_color = "#64C864"
	light_power_on = 1
	light_range_on = 2

	machine_flags = SCREWTOGGLE | FIXED2WORK | CROWDESTROY

	layer = ABOVE_WINDOW_LAYER

	var/mob/watching_mob = null
	var/image/small_station_map = null
	var/image/floor_markings = null
	var/image/panel = null

	var/original_zLevel = 1	//zLevel on which the station map was initialized.
	var/bogus = 0			//set to 1 when you initialize the station map on a zLevel that doesn't have its own icon formatted for use by station holomaps.
							//currently, the only supported zLevels are the Station, the Asteroid, and the Derelict.

	var/datum/station_holomap/holomap_datum

/obj/machinery/station_map/New()
	..()
	holomap_datum = new()
	original_zLevel = loc.z
	station_holomaps += src
	flow_flags |= ON_BORDER
	component_parts = 0
	if(ticker && holomaps_initialized)
		initialize()

/obj/machinery/station_map/Destroy()
	station_holomaps -= src
	stopWatching()
	holomap_datum = null
	..()

/obj/machinery/station_map/crowbarDestroy(mob/user, obj/item/tool/crowbar/C)
	user.visible_message(	"[user] begins to pry out \the [src] from the wall.",
							"You begin to pry out \the [src] from the wall...")
	if(do_after(user, src, 40))
		user.visible_message(	"[user] detaches \the [src] from the wall.",
								"You detach \the [src] from the wall.")
		C.playtoolsound(src, 50)
		new /obj/item/mounted/frame/station_map(src.loc)

		for(var/obj/I in src)
			qdel(I)

		new /obj/item/weapon/circuitboard/station_map(src.loc)
		new /obj/item/stack/cable_coil(loc,5)
		new /obj/item/stack/sheet/glass/glass(loc,1)

		return 1
	return 0

/obj/machinery/station_map/initialize()
	bogus = 0
	var/turf/T = get_turf(src)
	original_zLevel = T.z
	if(!((HOLOMAP_EXTRA_STATIONMAP+"_[original_zLevel]") in extraMiniMaps))
		bogus = 1
		holomap_datum.initialize_holomap_bogus()
		update_icon()
		return

	holomap_datum.initialize_holomap(T)

	small_station_map = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH+"_[original_zLevel]"])
	small_station_map.plane = ABOVE_LIGHTING_PLANE
	small_station_map.layer = ABOVE_LIGHTING_LAYER

	floor_markings = image('icons/turf/overlays.dmi', "station_map")
	floor_markings.dir = dir
	floor_markings.plane = ABOVE_TURF_PLANE
	floor_markings.layer = DECAL_LAYER
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
			holomap_datum.station_map.loc = user.hud_used.holomap_obj
			holomap_datum.station_map.alpha = 0
			animate(holomap_datum.station_map, alpha = 255, time = 5, easing = LINEAR_EASING)
			watching_mob = user
			flick("station_map_activate", src)
			watching_mob.client.images |= holomap_datum.station_map
			watching_mob.register_event(/event/face, src, /obj/machinery/station_map/proc/checkPosition)
			if(bogus)
				to_chat(user, "<span class='warning'>The holomap failed to initialize. This area of space cannot be mapped.</span>")
			else
				to_chat(user, "<span class='notice'>A hologram of the station appears before your eyes.</span>")

/obj/machinery/station_map/attack_paw(var/mob/user)
	src.attack_hand(user)

/obj/machinery/station_map/attack_animal(var/mob/user)
	src.attack_hand(user)

/obj/machinery/station_map/attack_ghost(var/mob/user)
	if(!can_spook())
		return FALSE
	add_hiddenprint(user)
	flick("station_map_activate", src)

/obj/machinery/station_map/attack_ai(var/mob/living/silicon/robot/user)
	user.station_holomap.toggleHolomap(user, isAI(user))

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
				M.client.images -= holomap_datum.station_map
		watching_mob.unregister_event(/event/face, src, /obj/machinery/station_map/proc/checkPosition)
	watching_mob = null
	animate(holomap_datum.station_map, alpha = 0, time = 5, easing = LINEAR_EASING)

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
			holomap_datum.station_map.overlays.len = 0
			holomap_datum.station_map.overlays |= holomap_datum.legend
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
			holomap_datum.station_map.overlays.len = 0
			if(map.holomap_offset_x.len >= original_zLevel)
				holomap_datum.cursor.pixel_x = (x-6+map.holomap_offset_x[original_zLevel])*PIXEL_MULTIPLIER
				holomap_datum.cursor.pixel_y = (y-6+map.holomap_offset_y[original_zLevel])*PIXEL_MULTIPLIER
			else
				holomap_datum.cursor.pixel_x = (x-6)*PIXEL_MULTIPLIER
				holomap_datum.cursor.pixel_y = (y-6)*PIXEL_MULTIPLIER
			holomap_datum.station_map.overlays |= holomap_datum.cursor
			holomap_datum.station_map.overlays |= holomap_datum.legend

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
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				qdel(src)
			else
				set_broken()
		if(3)
			if (prob(25))
				set_broken()

//Portable holomaps, used by Ghosts, Silicons, and PDA (using the Station Holomap app)
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

	var/datum/station_holomap/holomap_datum

	var/bogus = 0
	var/lastZ
	var/prevent_close = 0

/obj/item/device/station_map/New()
	..()
	holomap_datum = new()
	lastZ = map.zMainStation

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
		bogus = 0
		if(!((HOLOMAP_EXTRA_STATIONMAP+"_[T.z]") in extraMiniMaps))
			bogus = 1
			holomap_datum.initialize_holomap_bogus()
		else
			holomap_datum.initialize_holomap(T, isAI, user)

		holomap_datum.station_map.loc = user.hud_used.holomap_obj
		holomap_datum.station_map.alpha = 0
		animate(holomap_datum.station_map, alpha = 255, time = 5, easing = LINEAR_EASING)

		user.client.images |= holomap_datum.station_map
		if (iscarbon(user))
			var/mob/living/carbon/C = user
			C.displayed_holomap = src

		if(bogus)
			to_chat(user, "<span class='warning'>The holomap failed to initialize. This area of space cannot be mapped.</span>")
		else
			to_chat(user, "<span class='notice'>A hologram of the station appears before your eyes.</span>")

/obj/item/device/station_map/proc/update_holomap()
	if (!watching_mob || !watching_mob.client || !watching_mob.hud_used)
		return
	watching_mob.client.images -= holomap_datum.station_map
	holomap_datum.station_map.overlays.len = 0
	var/turf/T = get_turf(src)
	if (lastZ != T.z)
		lastZ = T.z
		bogus = 0
		if(!((HOLOMAP_EXTRA_STATIONMAP+"_[T.z]") in extraMiniMaps))
			holomap_datum.initialize_holomap_bogus()
			bogus = 1
		else
			holomap_datum.station_map = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAP+"_[T.z]"])
	if (!bogus)
		if (isAI(watching_mob))
			T = get_turf(watching_mob.client.eye)
		if(map.holomap_offset_x.len >= T.z)
			holomap_datum.cursor.pixel_x = (T.x-6+map.holomap_offset_x[T.z])*PIXEL_MULTIPLIER
			holomap_datum.cursor.pixel_y = (T.y-6+map.holomap_offset_y[T.z])*PIXEL_MULTIPLIER
		else
			holomap_datum.cursor.pixel_x = (T.x-6)*PIXEL_MULTIPLIER
			holomap_datum.cursor.pixel_y = (T.y-6)*PIXEL_MULTIPLIER
		holomap_datum.station_map.overlays += holomap_datum.cursor
		holomap_datum.station_map.overlays += holomap_datum.legend
	watching_mob.client.images += holomap_datum.station_map
	holomap_datum.station_map.loc = watching_mob.hud_used.holomap_obj

/obj/item/device/station_map/Destroy()
	stopWatching()
	holomap_datum = null
	..()

/obj/item/device/station_map/dropped(mob/user)
	stopWatching()

/obj/item/device/station_map/proc/stopWatching()
	if (prevent_close)
		return
	if(watching_mob)
		if(watching_mob.client)
			var/mob/M = watching_mob
			spawn(5)//we give it time to fade out
				if (iscarbon(watching_mob))
					var/mob/living/carbon/C = watching_mob
					C.displayed_holomap = null
				M.client.images -= holomap_datum.station_map
	watching_mob = null
	if(holomap_datum && holomap_datum.station_map)//sanity check to prevent runtime when silicons get destroyed.
		animate(holomap_datum.station_map, alpha = 0, time = 5, easing = LINEAR_EASING)

//Holomap datum, for initialization
/datum/station_holomap
	var/image/station_map
	var/image/cursor
	var/image/legend

/datum/station_holomap/proc/initialize_holomap(var/turf/T, var/isAI=null, var/mob/user=null)
	station_map = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAP+"_[T.z]"])
	station_map.overlays.len = 0
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

/datum/station_holomap/proc/initialize_holomap_bogus()
	station_map = image('icons/480x480.dmi', "stationmap")
	legend = image('icons/effects/64x64.dmi', "notfound")
	legend.pixel_x = 7*WORLD_ICON_SIZE
	legend.pixel_y = 7*WORLD_ICON_SIZE
	station_map.overlays |= legend

/obj/machinery/station_map/strategic
	name = "strategic station holomap"
	density = 1
	machine_flags = null
	icon = 'icons/obj/stationobjs_64x64.dmi'
	pixel_x = -1*WORLD_ICON_SIZE/2
	pixel_y = -1*WORLD_ICON_SIZE/2

	var/list/watching_mobs = list()
	var/list/watcher_maps = list()

/obj/machinery/station_map/strategic/New()
	..()
	holomap_datum = new /datum/station_holomap/strategic()
	original_zLevel = map.zMainStation
	if(ticker && holomaps_initialized)
		initialize()

/obj/machinery/station_map/strategic/initialize()
	holomap_datum.initialize_holomap()

	small_station_map = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH+"_[map.zMainStation]"])
	small_station_map.plane = ABOVE_LIGHTING_PLANE
	small_station_map.layer = ABOVE_LIGHTING_LAYER

	update_icon()

/obj/machinery/station_map/strategic/attack_hand(var/mob/user)
	if(isliving(user) && anchored && !(stat & (NOPOWER|BROKEN)))
		if( (holoMiniMaps.len < user.loc.z) || (holoMiniMaps[user.loc.z] == null ))
			to_chat(user, "<span class='notice'>It doesn't seem to be working.</span>")
			return
		if(user in watching_mobs)
			stopWatching(user)
		else
			if(user.hud_used && user.hud_used.holomap_obj)
				if(!("\ref[user]" in watcher_maps))
					watcher_maps["\ref[user]"] = image(holomap_datum.station_map)
				var/image/I = watcher_maps["\ref[user]"]
				I.loc = user.hud_used.holomap_obj
				I.alpha = 0
				animate(watcher_maps["\ref[user]"], alpha = 255, time = 5, easing = LINEAR_EASING)
				watching_mobs |= user
				user.client.images |= watcher_maps["\ref[user]"]
				user.register_event(/event/face, src, /obj/machinery/station_map/proc/checkPosition)
				to_chat(user, "<span class='notice'>A hologram of the station appears before your eyes.</span>")


/obj/machinery/station_map/strategic/checkPosition()
	for(var/mob/M in watching_mobs)
		if(get_dist(src,M) > 1)
			stopWatching(M)

/obj/machinery/station_map/strategic/stopWatching(var/mob/user)
	if(!user)
		for(var/mob/M in watching_mobs)
			if(M.client)
				spawn(5)//we give it time to fade out
					M.client.images -= watcher_maps["\ref[M]"]
				M.unregister_event(/event/face, src, /obj/machinery/station_map/proc/checkPosition)
				animate(watcher_maps["\ref[M]"], alpha = 0, time = 5, easing = LINEAR_EASING)

		watching_mobs = list()
	else
		if(user.client)
			spawn(5)//we give it time to fade out
				if(!(user in watching_mobs))
					user.client.images -= watcher_maps["\ref[user]"]
					watcher_maps -= "\ref[user]"
			user.unregister_event(/event/face, src, /obj/machinery/station_map/proc/checkPosition)
			animate(watcher_maps["\ref[user]"], alpha = 0, time = 5, easing = LINEAR_EASING)

			watching_mobs -= user

/obj/machinery/station_map/strategic/update_icon()
	overlays.len = 0
	if(!(stat & (NOPOWER|BROKEN)))
		if(!small_station_map)
			small_station_map = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH+"_[map.zMainStation]"])
			small_station_map.plane = ABOVE_LIGHTING_PLANE
			small_station_map.layer = ABOVE_LIGHTING_LAYER
		small_station_map.icon = extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH+"_[map.zMainStation]"]
		small_station_map.pixel_x = WORLD_ICON_SIZE/2
		small_station_map.pixel_y = 5*PIXEL_MULTIPLIER+WORLD_ICON_SIZE/2
		overlays |= small_station_map

/datum/station_holomap/strategic/initialize_holomap(var/turf/T, var/isAI=null, var/mob/user=null)
	station_map = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAP_STRATEGIC])
	legend = image('icons/effects/64x64.dmi', "strategic")
	legend.pixel_x = 3*WORLD_ICON_SIZE
	legend.pixel_y = 3*WORLD_ICON_SIZE
	station_map.overlays |= legend
