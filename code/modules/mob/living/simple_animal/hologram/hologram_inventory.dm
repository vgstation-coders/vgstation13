/mob/living/simple_animal/hologram/advanced/u_equip(obj/item/W, dropped = 1)
	var/success = 0

	if(!W)
		return 0

	if (W == head)
		head = null
		success = 1
		update_inv_head()
	if (W == w_uniform)
		w_uniform = null
		success = 1
		update_inv_w_uniform()
	if (W == wear_suit)
		wear_suit = null
		success = 1
		update_inv_wear_suit()
	else
		..()

	if(success)
		if (W)
			if(client)
				client.screen -= W
			W.forceMove(loc)
			W.unequipped(src)
			if(dropped)
				W.dropped(src)
			if(W)
				W.reset_plane_and_layer()

	return

/mob/living/simple_animal/hologram/advanced/equip_to_slot(obj/item/W, slot, redraw_mob = 1)
	if(!istype(W))
		return

	if(src.is_holding_item(W))
		src.u_equip(W)

	if(slot == slot_head)
		head = W
		update_inv_head(redraw_mob)
	if(slot == slot_w_uniform)
		w_uniform = W
		update_inv_w_uniform(redraw_mob)
	if(slot == slot_wear_suit)
		wear_suit = W
		update_inv_wear_suit(redraw_mob)

	W.hud_layerise()
	W.equipped(src, slot)
	W.forceMove(src)
	if(client)
		client.screen |= W

// Return the item currently in the slot ID
/mob/living/simple_animal/hologram/advanced/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_head)
			return head
		if(slot_w_uniform)
			return w_uniform
		if(slot_wear_suit)
			return wear_suit
	return null

/mob/living/simple_animal/hologram/advanced/show_inv(mob/living/carbon/user)
	user.set_machine(src)
	var/dat
	for(var/i = 1 to held_items.len) //Hands
		var/obj/item/I = held_items[i]
		dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(I)]</A><BR>"
	dat += "<BR><B>Head:</B> <A href='?src=\ref[src];item=[slot_head]'>[makeStrippingButton(head)]</A>"
	dat += "<BR><B>Uniform:</B> <A href='?src=\ref[src];item=[slot_w_uniform]'>[makeStrippingButton(w_uniform)]</A>"
	dat += "<BR><B>Suit:</B> <A href='?src=\ref[src];item=[slot_wear_suit]'>[makeStrippingButton(wear_suit)]</A>"
	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}
	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/hologram/advanced/update_inv_hand(index, var/update_icons = 1)
	if(!obj_overlays)
		return
	var/obj/abstract/Overlays/hand_layer/O = obj_overlays["[HAND_LAYER]-[index]"]
	if(!O)
		O = getFromPool(/obj/abstract/Overlays/hand_layer)
		obj_overlays["[HAND_LAYER]-[index]"] = O
	else
		overlays.Remove(O)
		O.overlays.len = 0
	var/obj/item/I = get_held_item_by_index(index)
	if(I && I.is_visible())
		var/t_state = I.item_state
		var/t_inhand_state = I.inhand_states[get_direction_by_index(index)]
		var/icon/check_dimensions = new(t_inhand_state)
		if(!t_state)
			t_state = I.icon_state
		O.name = "[index]"
		O.icon = t_inhand_state
		O.icon_state = t_state
		O.color = I.color
		O.pixel_x = -1*(check_dimensions.Width() - WORLD_ICON_SIZE)/2
		O.pixel_y = -1*(check_dimensions.Height() - WORLD_ICON_SIZE)/2
		O.layer = O.layer
		if(I.dynamic_overlay && I.dynamic_overlay["[HAND_LAYER]-[index]"])
			var/image/dyn_overlay = I.dynamic_overlay["[HAND_LAYER]-[index]"]
			O.overlays.Add(dyn_overlay)
		I.screen_loc = get_held_item_ui_location(index)
		overlays.Add(O)
	if(update_icons)
		update_icons()

/mob/living/simple_animal/hologram/advanced/update_inv_head(var/update_icons=1)
	overlays -= obj_overlays[HEAD_LAYER]
	if(head && head.is_visible())
		var/obj/abstract/Overlays/O = obj_overlays[HEAD_LAYER]
		O.overlays.len = 0
		head.screen_loc = ui_id
		var/image/standing = image("icon" = ((head.icon_override) ? head.icon_override : 'icons/mob/head.dmi'), "icon_state" = "[head.icon_state]")
		if(head.dynamic_overlay)
			if(head.dynamic_overlay["[HEAD_LAYER]"])
				var/image/dyn_overlay = head.dynamic_overlay["[HEAD_LAYER]"]
				O.overlays += dyn_overlay
		if(head.blood_DNA && head.blood_DNA.len)
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood")
			bloodsies.color = head.blood_color
			O.overlays	+= bloodsies
		head.generate_accessory_overlays(O)
		O.icon = standing
		O.icon_state = standing.icon_state
		var/image/I = new()
		I.appearance = O.appearance
		I.plane = FLOAT_PLANE
		obj_overlays[HEAD_LAYER] = I
		overlays += I
	if(update_icons)
		update_icons()

/mob/living/simple_animal/hologram/advanced/update_inv_w_uniform(var/update_icons=1)
	overlays -= obj_overlays[UNIFORM_LAYER]
	if(w_uniform && istype(w_uniform, /obj/item/clothing/under) && w_uniform.is_visible())
		w_uniform.screen_loc = ui_belt
		var/obj/abstract/Overlays/O = obj_overlays[UNIFORM_LAYER]
		O.overlays.len = 0
		var/t_color = w_uniform._color
		if(!t_color)
			t_color = icon_state
		var/image/standing	= image("icon_state" = "[t_color]_s")
		standing.icon	= 'icons/mob/uniform.dmi'
		var/obj/item/clothing/under/under_uniform = w_uniform
		if(w_uniform.icon_override)
			standing.icon	= w_uniform.icon_override
		if(w_uniform.dynamic_overlay)
			if(w_uniform.dynamic_overlay["[UNIFORM_LAYER]"])
				var/image/dyn_overlay = w_uniform.dynamic_overlay["[UNIFORM_LAYER]"]
				O.overlays += dyn_overlay
		if(w_uniform.blood_DNA && w_uniform.blood_DNA.len)
			var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "uniformblood")
			bloodsies.color		= w_uniform.blood_color
			O.overlays += bloodsies
		under_uniform.generate_accessory_overlays(O)
		O.icon = standing
		O.icon_state = standing.icon_state
		var/image/I = new()
		I.appearance = O.appearance
		I.plane = FLOAT_PLANE
		obj_overlays[UNIFORM_LAYER] = I
		overlays += I
	if(update_icons)
		update_icons()

/mob/living/simple_animal/hologram/advanced/update_inv_wear_suit(var/update_icons=1)
	overlays -= obj_overlays[SUIT_LAYER]
	if( wear_suit && istype(wear_suit, /obj/item/clothing/suit) && wear_suit.is_visible())	//TODO check this
		wear_suit.screen_loc = ui_back
		var/obj/abstract/Overlays/O = obj_overlays[SUIT_LAYER]
		O.overlays.len = 0
		var/image/standing	= image("icon" = ((wear_suit.icon_override) ? wear_suit.icon_override : 'icons/mob/suit.dmi'), "icon_state" = "[wear_suit.icon_state]")
		if( istype(wear_suit, /obj/item/clothing/suit/straight_jacket) )
			drop_hands()
		if(wear_suit.dynamic_overlay)
			if(wear_suit.dynamic_overlay["[SUIT_LAYER]"])
				var/image/dyn_overlay = wear_suit.dynamic_overlay["[SUIT_LAYER]"]
				O.overlays += dyn_overlay
		if(istype(wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/C = wear_suit
			if(C.blood_DNA && C.blood_DNA.len)
				var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[C.blood_overlay_type]blood")
				bloodsies.color = wear_suit.blood_color
				O.overlays	+= bloodsies
		wear_suit.generate_accessory_overlays(O)
		O.icon = standing
		O.icon_state = standing.icon_state
		var/image/I = new()
		I.appearance = O.appearance
		I.plane = FLOAT_PLANE
		obj_overlays[SUIT_LAYER] = I
		overlays += I
	if(update_icons)
		update_icons()