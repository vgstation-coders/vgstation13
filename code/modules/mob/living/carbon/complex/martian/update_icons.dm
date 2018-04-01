//MOB ICONS

/mob/living/carbon/complex/martian/update_icons()
	..()
	overlays.len = 0
	for(var/image/I in item_overlays)
		overlays += I
//INVENTORY ICONS

#define HAT_LAYER 1
//2-7 are used for hands
#define MAX_LAYERS 7

/mob/living/carbon/complex/martian
	var/list/item_overlays[MAX_LAYERS] //6 hands + hat

/mob/living/carbon/complex/martian/update_inv_hand(index, var/update_icons=1)
	var/obj/item/I = get_held_item_by_index(index)
	var/list/offsets = get_item_offset_by_index(index)
	var/pixelx = 0
	var/pixely = 0
	if(offsets["x"])
		pixelx = offsets["x"]
	if(offsets["y"])
		pixely = offsets["y"]

	if(I)
		var/t_state = I.item_state
		var/t_inhand_states = I.inhand_states[get_direction_by_index(index)]
		if(!t_state)
			t_state = I.icon_state

		var/image/hand_image = image("icon" = src.icon, "icon_state" = "hand_[index]")
		hand_image.overlays += image("icon" = t_inhand_states, "icon_state" = t_state, "pixel_x" = pixelx, "pixel_y" = pixely)

		item_overlays[HAT_LAYER + index] = hand_image

		I.screen_loc = get_held_item_ui_location(index)
		if (handcuffed)
			drop_item(I)
	else
		item_overlays[HAT_LAYER + index]	= null

	if(update_icons)
		update_icons()


/mob/living/carbon/complex/martian/update_inv_head(var/update_icons=1)
	if(!head)
		item_overlays[HAT_LAYER] = null

		if(update_icons)
			update_icons()
		return
	else
		item_overlays[HAT_LAYER] = image("icon" = ((head.icon_override) ? head.icon_override : 'icons/mob/head.dmi'), "icon_state" = "[head.icon_state]", "pixel_y" = 5)

		if(update_icons)
			update_icons()

		if(client)
			client.screen |= head
			head.screen_loc = ui_monkey_hat



/mob/living/carbon/complex/martian/update_hud()
	if(client)
		update_internals()
		client.screen |= contents

#undef HAT_LAYER
#undef MAX_LAYERS