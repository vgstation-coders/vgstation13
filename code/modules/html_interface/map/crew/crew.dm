/obj/machinery/computer/crew
	name = "Crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_state = "crew"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	circuit = "/obj/item/weapon/circuitboard/crew"

	light_color = LIGHT_COLOR_BLUE
	light_range_on = 2

	//for the holomap
	var/mob/activator
	var/list/holomap_images = list()
	var/holomap_color = "#0B74B4"
	var/holomap_filter //HOLOMAP_FILTER_CREW
	var/holomap_z = 1
	var/list/holomap_tooltips = list()

/obj/machinery/computer/crew/New()
	..()
	holomap_filter = !holomap_filter ? HOLOMAP_FILTER_CREW : holomap_filter

/obj/machinery/computer/crew/Destroy()
	deactivate_holomap()
	..()

/obj/machinery/computer/crew/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/crew/attack_hand(mob/user)
	/*. = ..()
	if(.)
		return
	if(stat & (BROKEN|NOPOWER))
		return*/
	togglemap(user)

/obj/machinery/computer/crew/update_icon()
	if(stat & BROKEN)
		icon_state = "crewb"
	else
		if(stat & NOPOWER)
			src.icon_state = "c_unpowered"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

/obj/machinery/computer/crew/proc/deactivate_holomap()
	if(activator && activator.client)
		activator.client.images -= holomap_images
	activator = null

	for(var/image/I in holomap_images)
		animate(I)

	holomap_images.len = 0
	holomap_tooltips.len = 0 //does this remove them?

//modified version of /obj/item/clothing/accessory/holomap_chip/proc/togglemap()
/obj/machinery/computer/crew/proc/togglemap(mob/user)
	if(user.isUnconscious())
		return

	if(activator)
		if(activator != user)
			to_chat(user, "<span class='notice'>Someone is already using the holomap.</span>")
			return
		deactivate_holomap()
		to_chat(user, "<span class='notice'>You disable the holomap.</span>")
	else
		activator = user
		process()
		to_chat(user, "<span class='notice'>You enable the holomap.</span>")

/obj/machinery/computer/crew/process()
	update_holomap()

/obj/machinery/computer/crew/proc/handle_sanity(var/turf/T)
	if((!activator) || (!activator.client) || (get_dist(activator.loc,src.loc) > 1) || (holoMiniMaps[T.z] == null))
		return FALSE
	return TRUE

/obj/machinery/computer/crew/proc/addCrewToHolomap(var/turf/T)
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.iscorpse)
			continue

		addCrewMarker(T,get_turf(H),H)

		// z == 0 means mob is inside object, check is they are wearing a uniform
		if((H.z == 0 || H.z == holomap_z) && istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = H.w_uniform

			if (U.has_sensor && U.sensor_mode)
				var/tuf/pos = H.z == 0 || U.sensor_mode == 3 ? get_turf(H) : null

				// Special case: If the mob is inside an object confirm the z-level on turf level.
				/*if (H.z == 0 && (!pos || pos.z != z))
					continue

				I = H.wear_id ? H.wear_id.GetID() : null

				if (I)
					name = I.registered_name
					assignment = I.assignment
				else
					name = "<i>Unknown</i>"
					assignment = ""

				if (U.sensor_mode >= 1)
					life_status = H.stat //CONSCIOUS, UNCONSCIOUS, DEAD

				if (U.sensor_mode >= 2)
					dam1 = round(H.getOxyLoss(),1)
					dam2 = round(H.getToxLoss(),1)
					dam3 = round(H.getFireLoss(),1)
					dam4 = round(H.getBruteLoss(),1)
				else
					dam1 = null
					dam2 = null
					dam3 = null
					dam4 = null*/

/image/tooltip
	var/title
	var/content
	var/mob/activator

/image/tooltip/proc/setInfo(var/T, var/C, var/mob/A)
	title = T
	content = C
	activator = A

//this method might mess with other tooltips
/image/tooltip/MouseEntered(location,control,params)
	to_chat(activator, "mouseentered");
	openToolTip(activator, src, null, title, content)

/image/tooltip/MouseExited(location,control,params)
	to_chat(activator, "mouseexited");
	closeToolTip(activator)

/obj/machinery/computer/crew/proc/addCrewMarker(var/turf/T, var/turf/TU, var/mob/M)
	var/mob_indicator = 2 //HOLOMAP_OTHER
	var/holomap_marker = "marker_\ref[M]_ert_[mob_indicator]"

	if(!(holomap_marker in holomap_cache))
		holomap_cache[holomap_marker] = new /image/tooltip('icons/holomap_markers.dmi',"ert[mob_indicator]")

	var/image/tooltip/I = holomap_cache[holomap_marker]
	I.plane = HUD_PLANE
	I.layer = HUD_ITEM_LAYER
	I.loc = activator.hud_used.holomap_obj

	I.setInfo("a test","lorem ipsum", activator)

	//if a new marker is created, we immediately set its offset instead of letting animate() take care of it, so it doesn't slide accross the screen.

	//if a new marker is created, we immediately set its offset instead of letting animate() take care of it, so it doesn't slide accross the screen.
	if(!I.pixel_x || !I.pixel_y)
		I.pixel_x = TU.x - T.x + activator.client.view*WORLD_ICON_SIZE + 8*(WORLD_ICON_SIZE/32)
		I.pixel_y = TU.y - T.y + activator.client.view*WORLD_ICON_SIZE + 9*(WORLD_ICON_SIZE/32)
	animate(I,alpha = 255, pixel_x = TU.x - T.x + activator.client.view*WORLD_ICON_SIZE + 8*(WORLD_ICON_SIZE/32), pixel_y = TU.y - T.y + activator.client.view*WORLD_ICON_SIZE + 9*(WORLD_ICON_SIZE/32), time = 5, loop = -1, easing = LINEAR_EASING)
	animate(alpha = 255, time = 8, loop = -1, easing = SINE_EASING)
	animate(alpha = 0, time = 5, easing = SINE_EASING)
	animate(alpha = 255, time = 2, easing = SINE_EASING)

	holomap_images += I

//modified version of /obj/item/clothing/accessory/holomap_chip/proc/update_holomap()
/obj/machinery/computer/crew/proc/update_holomap()
	var/turf/T = get_turf(src)
	if(!T)//nullspace begone!
		return

	if(!handle_sanity(T))
		deactivate_holomap()
		return

	activator.client.images -= holomap_images

	holomap_images.len = 0

	var/image/bgmap
	var/holomap_bgmap

	if(T.z == map.zCentcomm)
		holomap_bgmap = "background_\ref[src]_[map.zCentcomm]"

		if(!(holomap_bgmap in holomap_cache))
			holomap_cache[holomap_bgmap] = image(centcommMiniMaps["[holomap_filter]"])
	else
		holomap_bgmap = "background_\ref[src]_[T.z]"

		if(!(holomap_bgmap in holomap_cache))
			holomap_cache[holomap_bgmap] = image(holoMiniMaps[T.z])

	bgmap = holomap_cache[holomap_bgmap]
	bgmap.plane = HUD_PLANE
	bgmap.layer = HUD_BASE_LAYER
	bgmap.color = holomap_color
	bgmap.loc = activator.hud_used.holomap_obj
	bgmap.overlays.len = 0

	//Prevents the map background from sliding across the screen when the map is enabled for the first time.
	if(!bgmap.pixel_x)
		bgmap.pixel_x = -1*T.x + activator.client.view*WORLD_ICON_SIZE + 16*(WORLD_ICON_SIZE/32)
	if(!bgmap.pixel_y)
		bgmap.pixel_y = -1*T.y + activator.client.view*WORLD_ICON_SIZE + 17*(WORLD_ICON_SIZE/32)

	for(var/marker in holomap_markers)
		var/datum/holomap_marker/holomarker = holomap_markers[marker]
		if(holomarker.z == T.z && holomarker.filter & holomap_filter)
			var/image/markerImage = image(holomarker.icon,holomarker.id)
			markerImage.plane = FLOAT_PLANE
			markerImage.layer = FLOAT_LAYER
			if(map.holomap_offset_x.len >= T.z)
				markerImage.pixel_x = holomarker.x+holomarker.offset_x+map.holomap_offset_x[T.z]
				markerImage.pixel_y = holomarker.y+holomarker.offset_y+map.holomap_offset_y[T.z]
			else
				markerImage.pixel_x = holomarker.x+holomarker.offset_x
				markerImage.pixel_y = holomarker.y+holomarker.offset_y
			markerImage.appearance_flags = RESET_COLOR
			bgmap.overlays += markerImage

	if(map.holomap_offset_x.len >= T.z)
		animate(bgmap,pixel_x = -1*T.x - map.holomap_offset_x[T.z] + activator.client.view*WORLD_ICON_SIZE + 16*(WORLD_ICON_SIZE/32), pixel_y = -1*T.y - map.holomap_offset_y[T.z] + activator.client.view*WORLD_ICON_SIZE + 17*(WORLD_ICON_SIZE/32), time = 5, easing = LINEAR_EASING)
	else
		animate(bgmap,pixel_x = -1*T.x + activator.client.view*WORLD_ICON_SIZE + 16*(WORLD_ICON_SIZE/32), pixel_y = -1*T.y + activator.client.view*WORLD_ICON_SIZE + 17*(WORLD_ICON_SIZE/32), time = 5, easing = LINEAR_EASING)

	holomap_images += bgmap

	addCrewToHolomap(T)

	activator.client.images |= holomap_images
