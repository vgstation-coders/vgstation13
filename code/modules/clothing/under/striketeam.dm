var/list/deathsquad_uniforms = list()

var/list/holomap_cache = list()

/obj/item/clothing/under/deathsquad
	name = "deathsquad holosuit"
	desc = "A state-of-the-art suit featuring an holographic map of the area, to help the squad coordinate their efforts."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/altsuits.dmi', "right_hand" = 'icons/mob/in-hand/right/altsuits.dmi')
	icon_state = "deathsquad"
	item_state = "deathsquad"
	_color = "deathsquad"
	flags = FPRINT  | ONESIZEFITSALL
	action_button_name = "Toggle Holomap"

/obj/item/clothing/under/deathsquad/New()
	..()
	deathsquad_uniforms += src

/obj/item/clothing/under/deathsquad/Destroy()
	deathsquad_uniforms -= src

	for(var/cacheIcon in holomap_cache)
		if(findtext(cacheIcon, "\ref[src]"))
			holomap_cache -= cacheIcon
	..()

/obj/item/clothing/under/deathsquad/ui_action_click()
	togglemap()

/obj/item/clothing/under/deathsquad/process()
	update_holomap()

/obj/item/clothing/under/proc/togglemap()
	if(usr.isUnconscious())
		return

	if(!ishuman(usr))
		to_chat(usr, "<span class='warning'>Only humanoids can wear this suit</span>")
		return

	var/mob/living/carbon/human/H = usr

	if(H.get_item_by_slot(slot_w_uniform) != src)
		to_chat(H, "<span class='warning'>You need to wear the suit first</span>")
		return

	if(src.holomap_activated)
		deactivate_holomap()
		to_chat(H, "<span class='notice'>You disable the holomap.</span>")
	else
		holomap_activated = 1
		activator = H
		processing_objects.Add(src)
		process()
		to_chat(H, "<span class='notice'>You enable the holomap.</span>")

#define HOLOMAP_ERROR	0
#define HOLOMAP_YOU		1
#define HOLOMAP_OTHER	2
#define HOLOMAP_DEAD	3

/obj/item/clothing/under/proc/update_holomap()

/obj/item/clothing/under/deathsquad/update_holomap()
	var/turf/T = get_turf(src)
	if(!T)//nullspace begone!
		return

	if((activator.get_item_by_slot(slot_w_uniform) != src) || (!activator.client) || (holoMiniMaps[T.z] == null))
		deactivate_holomap()
		return

	activator.client.images -= holomap_images

	holomap_images.len = 0

	var/image/bgmap
	var/holomap_bgmap

	if(T.z == map.zCentcomm)
		holomap_bgmap = "deathsquad_background_\ref[src]_[map.zCentcomm]"

		if(!(holomap_bgmap in holomap_cache))
			holomap_cache[holomap_bgmap] = image(centcommMiniMaps[HOLOMAP_FILTER_DEATHSQUAD])
	else
		holomap_bgmap = "deathsquad_background_\ref[src]_[T.z]"

		if(!(holomap_bgmap in holomap_cache))
			holomap_cache[holomap_bgmap] = image(holoMiniMaps[T.z])

	bgmap = holomap_cache[holomap_bgmap]
	bgmap.plane = HUD_PLANE
	bgmap.layer = HUD_BASE_LAYER
	bgmap.color = "#0B74B4"
	bgmap.loc = activator.hud_used.holomap_obj

	if(!bgmap.pixel_x)
		bgmap.pixel_x = -1*T.x + activator.client.view*WORLD_ICON_SIZE + 16*(WORLD_ICON_SIZE/32)

	if(!bgmap.pixel_y)
		bgmap.pixel_y = -1*T.y + activator.client.view*WORLD_ICON_SIZE + 17*(WORLD_ICON_SIZE/32)

	animate(bgmap,pixel_x = -1*T.x + activator.client.view*WORLD_ICON_SIZE + 16*(WORLD_ICON_SIZE/32), pixel_y = -1*T.y + activator.client.view*WORLD_ICON_SIZE + 17*(WORLD_ICON_SIZE/32), time = 5, easing = LINEAR_EASING)
	holomap_images += bgmap

	for(var/obj/item/clothing/under/deathsquad/D in deathsquad_uniforms)
		var/mob_indicator = HOLOMAP_ERROR
		var/turf/TD = get_turf(D)
		if(D == src)
			mob_indicator = HOLOMAP_YOU
		else if((TD.z == T.z) && ishuman(D.loc))
			var/mob/living/carbon/human/H = D.loc
			if(H.get_item_by_slot(slot_w_uniform) == D)
				if(H.isDead())
					mob_indicator = HOLOMAP_DEAD
				else
					mob_indicator = HOLOMAP_OTHER
			else
				continue

		if(mob_indicator != HOLOMAP_ERROR)

			var/holomap_marker = "deathsquad_\ref[src]_\ref[D]_[mob_indicator]"

			if(!(holomap_marker in holomap_cache))
				holomap_cache[holomap_marker] = image('icons/holomap_markers.dmi',"ds[mob_indicator]")

			var/image/I = holomap_cache[holomap_marker]
			I.plane = HUD_PLANE
			if(mob_indicator == HOLOMAP_YOU)
				I.layer = HUD_ABOVE_ITEM_LAYER
			else
				I.layer = HUD_ITEM_LAYER
			I.loc = activator.hud_used.holomap_obj

			if(!I.pixel_x || !I.pixel_y)
				I.pixel_x = TD.x - T.x + activator.client.view*WORLD_ICON_SIZE + 8*(WORLD_ICON_SIZE/32)
				I.pixel_y = TD.y - T.y + activator.client.view*WORLD_ICON_SIZE + 9*(WORLD_ICON_SIZE/32)

			animate(I,alpha = 255, pixel_x = TD.x - T.x + activator.client.view*WORLD_ICON_SIZE + 8*(WORLD_ICON_SIZE/32), pixel_y = TD.y - T.y + activator.client.view*WORLD_ICON_SIZE + 9*(WORLD_ICON_SIZE/32), time = 5, loop = -1, easing = LINEAR_EASING)
			animate(alpha = 255, time = 8, loop = -1, easing = SINE_EASING)
			animate(alpha = 0, time = 5, easing = SINE_EASING)
			animate(alpha = 255, time = 2, easing = SINE_EASING)
			holomap_images += I

	activator.client.images |= holomap_images

#undef HOLOMAP_ERROR
#undef HOLOMAP_YOU
#undef HOLOMAP_OTHER
#undef HOLOMAP_DEAD

/obj/item/clothing/under/proc/deactivate_holomap()
	holomap_activated = 0
	if(activator.client)
		activator.client.images -= holomap_images
	activator = null

	for(var/image/I in holomap_images)
		animate(I)

	holomap_images.len = 0
	processing_objects.Remove(src)
