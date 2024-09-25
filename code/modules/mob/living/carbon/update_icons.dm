/*
 * LOOK G-MA, I'VE JOINED CARBON PROCS THAT ARE IDENTICAL IN ALL CASES INTO ONE PROC, I'M BETTER THAN LIFE()
 * I thought about mob/living but silicons and simple_animals don't want this just yet.
 * Handles lying down and shrinking from DNA and viruses
 * IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
 */

#define SHRINK_SCALE_FACTOR 0.7

/mob/living/carbon/update_transform()
	var/matrix/final_transform = transform
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/animate = FALSE
	if(lying != lying_prev)
		animate = TRUE

		if(!lying) // lying to standing
			final_pixel_y += 6 * PIXEL_MULTIPLIER
			final_transform.Turn(-90)
		else //if(lying)
			if(!lying_prev) // standing to lying
				final_pixel_y -= 6 * PIXEL_MULTIPLIER
				final_transform.Turn(90)

		if(dir & (EAST | WEST)) // facing east or west
			final_dir = pick(NORTH, SOUTH) // so you fall on your side rather than your face or ass

		lying_prev = lying // so we don't try to animate until there's been another change.


	if(shrunken != shrunken_prev)
		animate = TRUE

		if(!shrunken)
			final_pixel_y += 4 * PIXEL_MULTIPLIER
			if(!lying)
				final_transform *= matrix().Scale(1, 1 / SHRINK_SCALE_FACTOR)
			else
				final_transform *= matrix().Scale(1 / SHRINK_SCALE_FACTOR, 1)
		else
			if(!shrunken_prev)
				final_pixel_y -= 4 * PIXEL_MULTIPLIER
				if(!lying)
					final_transform *= matrix().Scale(1, SHRINK_SCALE_FACTOR)
				else
					final_transform *= matrix().Scale(SHRINK_SCALE_FACTOR, 1)


		shrunken_prev = shrunken // so we don't try to animate until there's been another change.

	if(animate)
		animate(src, transform = final_transform, pixel_y = final_pixel_y, dir = final_dir, time = 2, easing = EASE_IN | EASE_OUT)

/mob/living/carbon/proc/remove_overlay(cache_index)
	var/I = overlays_standing[cache_index]
	if(I)
		overlays -= I
		overlays_standing[cache_index] = null

/mob/living/carbon/update_inv_r_hand(update_icons = TRUE)
	return update_inv_hand(GRASP_RIGHT_HAND, update_icons)

/mob/living/carbon/update_inv_l_hand(update_icons = TRUE)
	return update_inv_hand(GRASP_LEFT_HAND, update_icons)

/mob/living/carbon/update_inv_hand(index, update_icons = TRUE)
	remove_overlay("[HAND_LAYER]-[index]")
	var/obj/item/held_item = get_held_item_by_index(index)
	if(held_item && held_item.is_visible())
		var/t_state = held_item.item_state || held_item.icon_state
		var/t_inhand_state = held_item.inhand_states[get_direction_by_index(index)]
		var/mutable_appearance/hand_overlay = mutable_appearance(t_inhand_state, t_state, -HAND_LAYER)
		if(held_item.dynamic_overlay && held_item.dynamic_overlay["[HAND_LAYER]-[index]"])
			var/mutable_appearance/dyn_overlay = held_item.dynamic_overlay["[HAND_LAYER]-[index]"]
			hand_overlay.overlays += dyn_overlay
		hand_overlay.color = held_item.color
		overlays += overlays_standing["[HAND_LAYER]-[index]"] = hand_overlay
		held_item.screen_loc = get_held_item_ui_location(index, held_item)
		if(handcuffed)
			drop_item(held_item)
	if(update_icons)
		update_icons()

/mob/living/carbon/update_targeted(update_icons = TRUE)
	remove_overlay(TARGETED_LAYER)
	if(targeted_by && target_locked)
		overlays += overlays_standing[TARGETED_LAYER] = target_locked
	if(update_icons)
		update_icons()

/mob/living/carbon/update_hud()	//TODO: do away with this if possible
	if(client)
		client.screen |= contents
		if(hud_used)
			update_internals()
			hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar

/mob/living/carbon/proc/update_inv_by_slot(slot_flags)
	if(slot_flags & SLOT_BACK)
		update_inv_back()
	if(slot_flags & SLOT_MASK)
		update_inv_wear_mask()
	if(slot_flags & SLOT_BELT)
		update_inv_belt()
	if(slot_flags & SLOT_EARS)
		update_inv_ears()
	if(slot_flags & SLOT_EYES)
		update_inv_glasses()
	if(slot_flags & SLOT_GLOVES)
		update_inv_gloves()
	if(slot_flags & SLOT_HEAD)
		update_inv_head()
	if(slot_flags & SLOT_FEET)
		update_inv_shoes()
	if(slot_flags & SLOT_OCLOTHING)
		update_inv_wear_suit()
	if(slot_flags & SLOT_ICLOTHING)
		update_inv_w_uniform()
