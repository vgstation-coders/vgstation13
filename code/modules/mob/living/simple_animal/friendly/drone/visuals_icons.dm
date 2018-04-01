
/////////////////
//DRONE VISUALS//
/////////////////
//Drone overlays
//Drone visuals


/mob/living/simple_animal/drone/proc/apply_overlay(cache_index)
	if((. = drone_overlays[cache_index]))
		add_overlay(.)


/mob/living/simple_animal/drone/proc/remove_overlay(cache_index)
	var/I = drone_overlays[cache_index]
	if(I)
		cut_overlay(I)
		drone_overlays[cache_index] = null


/mob/living/simple_animal/drone/update_inv_hands()
	remove_overlay(DRONE_HANDS_LAYER)
	var/list/hands_overlays = list()

	var/obj/item/l_hand = get_item_for_held_index(1)
	var/obj/item/r_hand = get_item_for_held_index(2)

	var/y_shift = getItemPixelShiftY()

	if(r_hand)

		var/r_state = r_hand.item_state
		if(!r_state)
			r_state = r_hand.icon_state

		var/mutable_appearance/r_hand_overlay = r_hand.build_worn_icon(state = r_state, default_layer = DRONE_HANDS_LAYER, default_icon_file = r_hand.righthand_file, isinhands = TRUE)
		if(y_shift)
			r_hand_overlay.pixel_y += y_shift

		hands_overlays += r_hand_overlay

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.layer = ABOVE_HUD_LAYER
			r_hand.plane = ABOVE_HUD_PLANE
			r_hand.screen_loc = ui_hand_position(get_held_index_of_item(r_hand))
			client.screen |= r_hand

	if(l_hand)

		var/l_state = l_hand.item_state
		if(!l_state)
			l_state = l_hand.icon_state

		var/mutable_appearance/l_hand_overlay = l_hand.build_worn_icon(state = l_state, default_layer = DRONE_HANDS_LAYER, default_icon_file = l_hand.lefthand_file, isinhands = TRUE)
		if(y_shift)
			l_hand_overlay.pixel_y += y_shift

		hands_overlays += l_hand_overlay

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.layer = ABOVE_HUD_LAYER
			l_hand.plane = ABOVE_HUD_PLANE
			l_hand.screen_loc = ui_hand_position(get_held_index_of_item(l_hand))
			client.screen |= l_hand


	if(hands_overlays.len)
		drone_overlays[DRONE_HANDS_LAYER] = hands_overlays
	apply_overlay(DRONE_HANDS_LAYER)


/mob/living/simple_animal/drone/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used && hud_used.hud_shown)
		internal_storage.screen_loc = ui_drone_storage
		client.screen += internal_storage


/mob/living/simple_animal/drone/update_inv_head()
	remove_overlay(DRONE_HEAD_LAYER)

	if(head)
		if(client && hud_used && hud_used.hud_shown)
			head.screen_loc = ui_drone_head
			client.screen += head
		var/used_head_icon = 'icons/mob/head.dmi'
		if(istype(head, /obj/item/clothing/mask))
			used_head_icon = 'icons/mob/mask.dmi'
		var/mutable_appearance/head_overlay = head.build_worn_icon(state = head.icon_state, default_layer = DRONE_HEAD_LAYER, default_icon_file = used_head_icon)
		head_overlay.pixel_y -= 15

		drone_overlays[DRONE_HEAD_LAYER] = head_overlay

	apply_overlay(DRONE_HEAD_LAYER)

/mob/living/simple_animal/drone/update_inv_wear_mask()
	update_inv_head()

/mob/living/simple_animal/drone/regenerate_icons()
	// Drones only have 4 slots, which in this specific instance
	// is a small blessing.
	update_inv_hands()
	update_inv_head()
	update_inv_internal_storage()


/mob/living/simple_animal/drone/proc/pickVisualAppearence()
	picked = FALSE
	var/appearence = input("Choose your appearence!", "Appearence", "Maintenance Drone") in list("Maintenance Drone", "Repair Drone", "Scout Drone")
	switch(appearence)
		if("Maintenance Drone")
			visualAppearence = MAINTDRONE
			colour = input("Choose your colour!", "Colour", "grey") in list("grey", "blue", "red", "green", "pink", "orange")
			icon_state = "[visualAppearence]_[colour]"
			icon_living = "[visualAppearence]_[colour]"
			icon_dead = "[visualAppearence]_dead"

		if("Repair Drone")
			visualAppearence = REPAIRDRONE
			icon_state = visualAppearence
			icon_living = visualAppearence
			icon_dead = "[visualAppearence]_dead"

		if("Scout Drone")
			visualAppearence = SCOUTDRONE
			icon_state = visualAppearence
			icon_living = visualAppearence
			icon_dead = "[visualAppearence]_dead"

		else
			return

	picked = TRUE



/mob/living/simple_animal/drone/proc/getItemPixelShiftY()
	switch(visualAppearence)
		if(MAINTDRONE)
			. = 0
		if(REPAIRDRONE,SCOUTDRONE,CLOCKDRONE)
			. = -6

/mob/living/simple_animal/drone/proc/updateSeeStaticMobs()
	if(!client)
		return

	for(var/i in staticOverlays)
		client.images.Remove(i)
		staticOverlays.Remove(i)
	staticOverlays.len = 0

	if(seeStatic)
		for(var/i in GLOB.mob_living_list)
			var/mob/living/L = i
			if(isdrone(L))
				continue
			var/image/chosen
			if(staticChoice in L.staticOverlays)
				chosen = L.staticOverlays[staticChoice]
			else
				chosen = L.staticOverlays["static"]
			staticOverlays |= chosen
			client.images |= chosen


/mob/living/simple_animal/drone/generateStaticOverlay()
	return
