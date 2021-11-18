/obj/item/weapon/implant/tracking
	name = "tracking implant"
	desc = "Track with this."
	var/id = 1

/obj/item/weapon/implant/tracking/New()
	..()
	tracking_implants += src

/obj/item/weapon/implant/tracking/Destroy()
	tracking_implants -= src
	..()

/obj/item/weapon/implant/tracking/get_data()
	return {"<b>Implant Specifications:</b><BR>
<b>Name:</b> Tracking Beacon<BR>
<b>Life:</b> 10 minutes after death of host<BR>
<b>Important Notes:</b> None<BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Continuously transmits low power signal. Useful for tracking.<BR>
<b>Special Features:</b><BR>
<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
a malfunction occurs thereby securing safety of subject. The implant will melt and
disintegrate into bio-safe elements.<BR>
<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
circuitry. As a result neurotoxins can cause massive damage.<HR>
Implant Specifics:<BR>"}

/obj/item/weapon/implant/tracking/emp_act(severity)
	if (malfunction)	//no, dawg, you can't malfunction while you are malfunctioning
		return
	malfunction = IMPLANT_MALFUNCTION_TEMPORARY

	var/delay = 20
	switch(severity)
		if(1)
			if(prob(60))
				meltdown()
				return
			else
				delay = rand(5 MINUTES, 15 MINUTES)
		if(2)
			delay = rand(5 MINUTES, 15 MINUTES)

	spawn(delay)
		malfunction--


var/list/locator_holomap_cache = list()


/obj/item/device/locator_holomap
	name = "tracker holomap"
	desc = "Used to track those with locater implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator_map"
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	starting_materials = list(MAT_IRON = 400)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_MAGNETS + "=1"

	var/mob/watching_mob = null

	var/datum/tracker_holomap/holomap_datum

	var/bogus = 0
	var/lastZ

/obj/item/device/locator_holomap/New()
	..()
	holomap_datum = new()
	lastZ = map.zMainStation


/obj/item/device/locator_holomap/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/device/locator_holomap/attack_self(var/mob/user)
	toggleHolomap(user)

/obj/item/device/locator_holomap/process()
	update_holomap()

/obj/item/device/locator_holomap/proc/toggleHolomap(var/mob/user,var/isAI=0)
	if(watching_mob)
		if(watching_mob == user)
			stopWatching()
			return
		else
			stopWatching()

	if(user.hud_used && user.hud_used.holomap_obj)
		processing_objects.Add(src)
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

/obj/item/device/locator_holomap/proc/update_holomap()
	if (!watching_mob || !watching_mob.client || !watching_mob.hud_used)
		return
	watching_mob.client.images -= holomap_datum.station_map
	watching_mob.client.images -= holomap_datum.markers
	holomap_datum.station_map.overlays.len = 0
	var/turf/T = get_turf(src)
	var/force_snap_markers = FALSE
	if (lastZ != T.z)
		lastZ = T.z
		force_snap_markers = TRUE
		bogus = 0
		if(!((HOLOMAP_EXTRA_STATIONMAP+"_[T.z]") in extraMiniMaps))
			holomap_datum.initialize_holomap_bogus()
			bogus = 1
		else
			var/holomap_bgmap = "locator_\ref[src]_\ref[watching_mob]_[T.z]"
			if(!(holomap_bgmap in holomap_cache))
				holomap_datum.station_map = image('icons/480x480.dmi', "stationmap_red")
				holomap_datum.station_map.plane = HUD_PLANE
				holomap_datum.station_map.layer = HUD_BASE_LAYER
				holomap_cache[holomap_bgmap] = holomap_datum.station_map
			holomap_datum.station_map = holomap_cache[holomap_bgmap]
			holomap_datum.station_map.overlays.len = 0
		if(T.z == map.zMainStation || T.z == map.zAsteroid || T.z == map.zDerelict)
			holomap_datum.station_outline = image(holoMiniMaps[T.z])
			holomap_datum.station_outline.color = "#FFDEDE"
			holomap_datum.station_outline.alpha = 200
			holomap_datum.station_areas = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPAREAS+"_[T.z]"])
			holomap_datum.station_areas.alpha = 150
	if (!bogus)
		holomap_datum.station_map.overlays += holomap_datum.station_areas
		holomap_datum.station_map.overlays += holomap_datum.station_outline
		if(map.holomap_offset_x.len >= T.z)
			holomap_datum.cursor.pixel_x = (T.x-8+map.holomap_offset_x[T.z])*PIXEL_MULTIPLIER
			holomap_datum.cursor.pixel_y = (T.y-8+map.holomap_offset_y[T.z])*PIXEL_MULTIPLIER
		else
			holomap_datum.cursor.pixel_x = (T.x-8)*PIXEL_MULTIPLIER
			holomap_datum.cursor.pixel_y = (T.y-8)*PIXEL_MULTIPLIER
		holomap_datum.station_map.overlays += holomap_datum.cursor

		//now let's add markers for all the implanted people
		for(var/obj/item/weapon/implant/tracking/implant in tracking_implants)
			if (!implant.loc || istype(implant.loc,/obj/item/weapon/implantcase))
				continue
			var/turf/TU = get_turf(implant)
			if(!TU)
				continue
			if(TU.z != T.z)
				continue
			if (implant.malfunction == IMPLANT_MALFUNCTION_PERMANENT)
				continue
			var/mob/M
			var/marker_state = "tracker"
			if (implant.malfunction == IMPLANT_MALFUNCTION_TEMPORARY)
				marker_state = "tracker-malfunction"
			if (implant.loc != implant.imp_in)
				marker_state = "tracker-dead"
			else
				M = implant.loc
				if (istype(M) && M.isDead())
					marker_state = "tracker-dead"

			var/holomap_marker = "marker_\ref[src]_\ref[implant]_[marker_state]"

			if(!(holomap_marker in holomap_cache))
				holomap_cache[holomap_marker] = image('icons/holomap_markers.dmi',"[marker_state]")

			var/image/I = holomap_cache[holomap_marker]
			I.plane = HUD_PLANE
			I.layer = HUD_ITEM_LAYER
			I.loc = watching_mob.hud_used.holomap_obj

			handle_marker(I,TU,force_snap_markers)

			holomap_datum.markers |= I//adding to the list of markers so we can remove them in bulk when we update or turn off the holomap

			watching_mob.client.images += I

	watching_mob.client.images += holomap_datum.station_map

	holomap_datum.station_map.loc = watching_mob.hud_used.holomap_obj


/obj/item/device/locator_holomap/proc/handle_marker(var/image/I,var/turf/TU,var/force_snap_markers = FALSE)
	//if a new marker is created, we immediately set its offset instead of letting animate() take care of it, so it doesn't slide accross the screen.
	if(force_snap_markers || !I.pixel_x || !I.pixel_y)
		I.pixel_x = (TU.x - 8)*(WORLD_ICON_SIZE/32)
		I.pixel_y = (TU.y - 8)*(WORLD_ICON_SIZE/32)
	animate(I,alpha = 255, pixel_x = (TU.x - 8)*(WORLD_ICON_SIZE/32), pixel_y = (TU.y - 8)*(WORLD_ICON_SIZE/32), time = 5, loop = -1, easing = LINEAR_EASING)
	animate(alpha = 255, time = 8, loop = -1, easing = SINE_EASING)
	animate(alpha = 0, time = 5, easing = SINE_EASING)
	animate(alpha = 255, time = 2, easing = SINE_EASING)


/obj/item/device/locator_holomap/Destroy()
	stopWatching()
	holomap_datum = null
	..()

/obj/item/device/locator_holomap/dropped(mob/user)
	stopWatching()

/obj/item/device/locator_holomap/proc/stopWatching()
	processing_objects.Remove(src)

	for(var/image/I in holomap_datum.markers)
		animate(I)

	if(watching_mob)
		if(watching_mob.client)
			var/mob/M = watching_mob
			M.client.images -= holomap_datum.markers
			spawn(5)//we give it time to fade out
				if (iscarbon(watching_mob))
					var/mob/living/carbon/C = watching_mob
					C.displayed_holomap = null
				M.client.images -= holomap_datum.station_map
	watching_mob = null
	holomap_datum.markers.len = 0
	if(holomap_datum && holomap_datum.station_map)
		animate(holomap_datum.station_map, alpha = 0, time = 5, easing = LINEAR_EASING)

/datum/tracker_holomap
	var/image/station_map
	var/image/station_outline
	var/image/station_areas
	var/image/cursor
	var/image/legend
	var/list/markers = list()

/datum/tracker_holomap/proc/initialize_holomap(var/turf/T, var/isAI=null, var/mob/user=null)
	var/holomap_bgmap = "locator_\ref[src]_\ref[user]_[T.z]"
	if(!(holomap_bgmap in holomap_cache))
		station_map = image('icons/480x480.dmi', "stationmap_red")
		station_map.plane = HUD_PLANE
		station_map.layer = HUD_BASE_LAYER
		holomap_cache[holomap_bgmap] = station_map
	station_map = holomap_cache[holomap_bgmap]
	station_map.overlays.len = 0
	if(T.z == map.zMainStation || T.z == map.zAsteroid || T.z == map.zDerelict)
		station_outline = image(holoMiniMaps[T.z])
		station_outline.color = "#FFDEDE"
		station_outline.alpha = 200
		station_areas = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPAREAS+"_[T.z]"])
		station_areas.alpha = 150
		station_map.overlays += station_areas
		station_map.overlays += station_outline
	cursor = image('icons/holomap_markers.dmi', "tracker-locator")
	cursor.plane = HUD_PLANE
	cursor.layer = HUD_ABOVE_ITEM_LAYER
	if(map.holomap_offset_x.len >= T.z)
		cursor.pixel_x = (T.x-8+map.holomap_offset_x[T.z])*PIXEL_MULTIPLIER
		cursor.pixel_y = (T.y-8+map.holomap_offset_y[T.z])*PIXEL_MULTIPLIER
	else
		cursor.pixel_x = (T.x-8)*PIXEL_MULTIPLIER
		cursor.pixel_y = (T.y-8)*PIXEL_MULTIPLIER

	station_map.overlays += cursor

/datum/tracker_holomap/proc/initialize_holomap_bogus()
	station_map = image('icons/480x480.dmi', "stationmap_red")
	legend = image('icons/effects/64x64.dmi', "notfound")
	legend.pixel_x = 7*WORLD_ICON_SIZE
	legend.pixel_y = 7*WORLD_ICON_SIZE
	station_map.overlays += legend
