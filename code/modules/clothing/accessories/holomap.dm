var/list/holomap_chips = list()

var/list/holomap_cache = list()

/obj/item/clothing/accessory/holomap_chip
	name = "holomap chip"
	desc = "A device meant to be attached on a jumpsuit, granting a certain degree of situational awareness."
	icon_state = "holochip"
	accessory_exclusion = HOLOMAP

	var/destroyed = 0

	//Holomap stuff
	var/mob/living/carbon/human/activator = null
	var/list/holomap_images = list()
	var/marker_prefix = "erts"
	var/holomap_color = null
	var/holomap_filter = HOLOMAP_FILTER_ERT


/obj/item/clothing/accessory/holomap_chip/deathsquad
	name = "deathsquad holomap chip"
	icon_state = "holochip_ds"
	marker_prefix = "ds"
	holomap_filter = HOLOMAP_FILTER_DEATHSQUAD
	holomap_color = "#0B74B4"


/obj/item/clothing/accessory/holomap_chip/operative
	name = "nuclear operative holomap chip"
	icon_state = "holochip_op"
	marker_prefix = "op"
	holomap_filter = HOLOMAP_FILTER_NUKEOPS
	holomap_color = "#13B40B"


/obj/item/clothing/accessory/holomap_chip/New()
	..()
	holomap_chips += src


/obj/item/clothing/accessory/holomap_chip/Destroy()
	holomap_chips -= src

	var/turf/last_turf = get_turf(src)
	if(istype(loc, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = loc
		if(U && ishuman(U.loc))
			var/mob/living/carbon/human/H = U.loc
			if(H.get_item_by_slot(slot_w_uniform) == U)
				if(H && last_turf)
					var/obj/item/clothing/accessory/holomap_chip/destroyed/D = new(last_turf)
					D.marker_prefix = marker_prefix
					D.holomap_filter = holomap_filter

	deactivate_holomap()

	for(var/cacheIcon in holomap_cache)
		if(findtext(cacheIcon, "\ref[src]"))
			holomap_cache -= cacheIcon
	..()


/obj/item/clothing/accessory/holomap_chip/can_attach_to(obj/item/clothing/C)
	return (istype(C, /obj/item/clothing/under) && !C.action_button_name)


/obj/item/clothing/accessory/holomap_chip/on_attached(obj/item/clothing/C)
	..()
	attached_to.action_button_name = "Toggle Holomap"


/obj/item/clothing/accessory/holomap_chip/on_removed(mob/user as mob)
	attached_to.action_button_name = null
	deactivate_holomap()
	..()


/obj/item/clothing/accessory/holomap_chip/proc/togglemap()
	if(usr.isUnconscious())
		return

	if(!attached_to)
		return

	if(!ishuman(usr))
		to_chat(usr, "<span class='warning'>Only humanoids can use this device</span>")
		return

	var/mob/living/carbon/human/H = usr

	if(!istype(loc))
		to_chat(H, "<span class='warning'>This device needs to be set on a uniform first.</span>")

	if(H.get_item_by_slot(slot_w_uniform) != attached_to)
		to_chat(H, "<span class='warning'>You need to wear the suit first</span>")
		return

	if(activator)
		deactivate_holomap()
		to_chat(H, "<span class='notice'>You disable the holomap.</span>")
	else
		activator = H
		processing_objects.Add(src)
		process()
		to_chat(H, "<span class='notice'>You enable the holomap.</span>")



#define HOLOMAP_ERROR	0
#define HOLOMAP_YOU		1
#define HOLOMAP_OTHER	2
#define HOLOMAP_DEAD	3

/obj/item/clothing/accessory/holomap_chip/proc/update_holomap()
	var/turf/T = get_turf(src)
	if(!T)//nullspace begone!
		return

	if((!attached_to) || (!activator) || (activator.get_item_by_slot(slot_w_uniform) != attached_to) || (!activator.client) || (holoMiniMaps[T.z] == null))
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
				markerImage.pixel_x = holomarker.x+holomarker.pixel_x+map.holomap_offset_x[T.z]
				markerImage.pixel_y = holomarker.y+holomarker.pixel_y+map.holomap_offset_y[T.z]
			else
				markerImage.pixel_x = holomarker.x+holomarker.pixel_x
				markerImage.pixel_y = holomarker.y+holomarker.pixel_y
			markerImage.appearance_flags = RESET_COLOR
			bgmap.overlays += markerImage

	animate(bgmap,pixel_x = -1*T.x + activator.client.view*WORLD_ICON_SIZE + 16*(WORLD_ICON_SIZE/32), pixel_y = -1*T.y + activator.client.view*WORLD_ICON_SIZE + 17*(WORLD_ICON_SIZE/32), time = 5, easing = LINEAR_EASING)
	holomap_images += bgmap

	for(var/obj/item/clothing/accessory/holomap_chip/HC in holomap_chips)
		if(HC.holomap_filter != holomap_filter)
			continue
		var/obj/item/clothing/under/U = HC.attached_to
		var/mob_indicator = HOLOMAP_ERROR
		var/turf/TU = get_turf(HC)
		if(!TU)
			continue
		if(HC == src)
			mob_indicator = HOLOMAP_YOU
		else if(istype(HC, /obj/item/clothing/accessory/holomap_chip/destroyed))
			mob_indicator = HOLOMAP_DEAD
		else if(U && (TU.z == T.z) && ishuman(U.loc))
			var/mob/living/carbon/human/H = U.loc
			if(H.get_item_by_slot(slot_w_uniform) == U)
				if(H.isDead())
					mob_indicator = HOLOMAP_DEAD
				else
					mob_indicator = HOLOMAP_OTHER
			else
				continue
		else
			continue

		if(mob_indicator != HOLOMAP_ERROR)

			var/holomap_marker = "marker_\ref[src]_\ref[HC]_[mob_indicator]"

			if(!(holomap_marker in holomap_cache))
				holomap_cache[holomap_marker] = image('icons/holomap_markers.dmi',"[marker_prefix][mob_indicator]")

			var/image/I = holomap_cache[holomap_marker]
			I.plane = HUD_PLANE
			if(mob_indicator == HOLOMAP_YOU)
				I.layer = HUD_ABOVE_ITEM_LAYER
			else
				I.layer = HUD_ITEM_LAYER
			I.loc = activator.hud_used.holomap_obj

			//if a new marker is created, we immediately set its offset instead of letting animate() take care of it, so it doesn't slide accross the screen.
			if(!I.pixel_x || !I.pixel_y)
				I.pixel_x = TU.x - T.x + activator.client.view*WORLD_ICON_SIZE + 8*(WORLD_ICON_SIZE/32)
				I.pixel_y = TU.y - T.y + activator.client.view*WORLD_ICON_SIZE + 9*(WORLD_ICON_SIZE/32)

			animate(I,alpha = 255, pixel_x = TU.x - T.x + activator.client.view*WORLD_ICON_SIZE + 8*(WORLD_ICON_SIZE/32), pixel_y = TU.y - T.y + activator.client.view*WORLD_ICON_SIZE + 9*(WORLD_ICON_SIZE/32), time = 5, loop = -1, easing = LINEAR_EASING)
			animate(alpha = 255, time = 8, loop = -1, easing = SINE_EASING)
			animate(alpha = 0, time = 5, easing = SINE_EASING)
			animate(alpha = 255, time = 2, easing = SINE_EASING)
			holomap_images += I

	activator.client.images |= holomap_images

#undef HOLOMAP_ERROR
#undef HOLOMAP_YOU
#undef HOLOMAP_OTHER
#undef HOLOMAP_DEAD


/obj/item/clothing/accessory/holomap_chip/proc/deactivate_holomap()
	if(activator && activator.client)
		activator.client.images -= holomap_images
	activator = null

	for(var/image/I in holomap_images)
		animate(I)

	holomap_images.len = 0
	processing_objects.Remove(src)


/obj/item/clothing/accessory/holomap_chip/process()
	update_holomap()

//Allows players who got gibbed/annihilated to appear as dead on their allies' holomaps for a minute.
/obj/item/clothing/accessory/holomap_chip/destroyed
	invisibility = 101
	anchored = 1
	flags = INVULNERABLE

/obj/item/clothing/accessory/holomap_chip/destroyed/can_attach_to(obj/item/clothing/C)
	return 0

/obj/item/clothing/accessory/holomap_chip/destroyed/togglemap()
	return

/obj/item/clothing/accessory/holomap_chip/destroyed/singularity_pull()
	return //we are eternal

/obj/item/clothing/accessory/holomap_chip/destroyed/singularity_act()
	return //we are eternal

/obj/item/clothing/accessory/holomap_chip/destroyed/ex_act()
	return //we are eternal

/obj/item/clothing/accessory/holomap_chip/destroyed/cultify()
	return //we are eternal

/obj/item/clothing/accessory/holomap_chip/destroyed/New()
	..()
	spawn(600)
		qdel(src)
