/mob/living/carbon/complex/martian/update_inv_hand(index, update_icons = TRUE)
	var/obj/item/held_item = get_held_item_by_index(index)
	var/list/offsets = get_item_offset_by_index(index)
	var/pixelx = 0
	var/pixely = 0
	remove_overlay("[HAND_LAYER]-[index]")
	if(offsets["x"])
		pixelx = offsets["x"]
	if(offsets["y"])
		pixely = offsets["y"]
	if(held_item)
		var/t_state = held_item.item_state || held_item.icon_state
		var/t_inhand_states = held_item.inhand_states[get_direction_by_index(index)]
		var/mutable_appearance/hand_overlay = mutable_appearance(icon, "hand_[index]", -HAND_LAYER)
		var/mutable_appearance/extra_hand_overlay = mutable_appearance(t_inhand_states, t_state)
		extra_hand_overlay.pixel_x = pixelx
		extra_hand_overlay.pixel_y = pixely
		hand_overlay.overlays += extra_hand_overlay
		overlays += overlays_standing["[HAND_LAYER]-[index]"] = hand_overlay
		held_item.screen_loc = get_held_item_ui_location(index)
		if(handcuffed)
			drop_item(held_item)
	if(update_icons)
		update_icons()

/mob/living/carbon/complex/martian/update_inv_head(update_icons = TRUE)
	remove_overlay(HEAD_LAYER)
	if(!head)
		if(update_icons)
			update_icons()
		return
	var/mutable_appearance/hat_overlay = mutable_appearance(((head.icon_override) ? head.icon_override : 'icons/mob/head.dmi'), "[head.icon_state]", -HEAD_LAYER)
	hat_overlay.pixel_y = 5
	overlays += overlays_standing[HEAD_LAYER] = hat_overlay
	if(update_icons)
		update_icons()
	if(client)
		client.screen |= head
		head.screen_loc = ui_monkey_hat
