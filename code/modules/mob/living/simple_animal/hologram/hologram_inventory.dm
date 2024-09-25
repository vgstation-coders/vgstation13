/mob/living/simple_animal/hologram/advanced/u_equip(obj/item/W, dropped = 1)
	var/success = 0

	if(!W)
		return 0

	if (W == head)
		head = null
		success = 1
		update_inv_head()
		INVOKE_EVENT(src, /event/unequipped, W)
	else if (W == w_uniform)
		w_uniform = null
		success = 1
		update_inv_w_uniform()
		INVOKE_EVENT(src, /event/unequipped, W)
	else if (W == wear_suit)
		wear_suit = null
		success = 1
		update_inv_wear_suit()
		INVOKE_EVENT(src, /event/unequipped, W)
	else
		success = ..()

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

	return success

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

/mob/living/simple_animal/hologram/advanced/update_inv_hand(index)
	overlays -= overlays_standing["[HAND_LAYER]-[index]"]
	overlays_standing["[HAND_LAYER]-[index]"] = null
	var/obj/item/held_item = get_held_item_by_index(index)
	if(!(held_item && held_item.is_visible()))
		return
	var/t_state = held_item.item_state || held_item.icon_state
	var/t_inhand_state = held_item.inhand_states[get_direction_by_index(index)]
	var/icon/check_dimensions = new(t_inhand_state)
	var/mutable_appearance/hand_overlay = mutable_appearance(t_inhand_state, t_state, -HAND_LAYER)
	hand_overlay.color = held_item.color
	hand_overlay.pixel_x = -1*(check_dimensions.Width() - WORLD_ICON_SIZE)/2
	hand_overlay.pixel_y = -1*(check_dimensions.Height() - WORLD_ICON_SIZE)/2
	if(held_item.dynamic_overlay && held_item.dynamic_overlay["[HAND_LAYER]-[index]"])
		var/mutable_appearance/dyn_overlay = held_item.dynamic_overlay["[HAND_LAYER]-[index]"]
		hand_overlay.overlays += dyn_overlay
	held_item.screen_loc = get_held_item_ui_location(index)
	overlays += overlays_standing["[HAND_LAYER]-[index]"] = hand_overlay

/mob/living/simple_animal/hologram/advanced/update_inv_head()
	overlays -= overlays_standing[HEAD_LAYER]
	overlays_standing[HEAD_LAYER] = null
	if(!(head && head.is_visible()))
		return
	head.screen_loc = ui_id
	var/mutable_appearance/head_overlay = mutable_appearance(((head.icon_override) ? head.icon_override : 'icons/mob/head.dmi'), "[head.icon_state]", -HEAD_LAYER)
	if(head.dynamic_overlay)
		if(head.dynamic_overlay["[HEAD_LAYER]"])
			var/mutable_appearance/dyn_overlay = head.dynamic_overlay["[HEAD_LAYER]"]
			head_overlay.overlays += dyn_overlay
	if(head.blood_DNA && head.blood_DNA.len)
		var/mutable_appearance/bloodsies = mutable_appearance('icons/effects/blood.dmi', "helmetblood")
		bloodsies.color = head.blood_color
		head_overlay.overlays += bloodsies
	head.generate_accessory_overlays(head_overlay)
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/hat = head
		var/i = 1
		var/mutable_appearance/abovehats
		for(var/obj/item/clothing/head/above = hat.on_top; above; above = above.on_top)
			abovehats = mutable_appearance(((above.icon_override) ? above.icon_override : 'icons/mob/head.dmi'), "[above.icon_state]")
			abovehats.pixel_y = (2 * i) * PIXEL_MULTIPLIER
			head_overlay.overlays += abovehats
			if(above.dynamic_overlay)
				if(above.dynamic_overlay["[HEAD_LAYER]"])
					var/mutable_appearance/dyn_overlay = above.dynamic_overlay["[HEAD_LAYER]"]
					head_overlay.overlays += dyn_overlay
			if(above.blood_DNA && above.blood_DNA.len)
				var/mutable_appearance/bloodsies = mutable_appearance('icons/effects/blood.dmi', "helmetblood")
				bloodsies.color = above.blood_color
				bloodsies.pixel_y = (2 * i) * PIXEL_MULTIPLIER
				head_overlay.overlays += bloodsies
			i++
	overlays += overlays_standing[HEAD_LAYER] = head_overlay

/mob/living/simple_animal/hologram/advanced/update_inv_w_uniform()
	overlays -= overlays_standing[UNIFORM_LAYER]
	overlays_standing[UNIFORM_LAYER] = null
	if(!(istype(w_uniform, /obj/item/clothing/under) && w_uniform.is_visible()))
		return
	var/obj/item/clothing/under/worn_uniform = w_uniform
	worn_uniform.screen_loc = ui_belt
	var/t_color = worn_uniform._color
	if(!t_color)
		t_color = icon_state
	var/mutable_appearance/uniform_overlay = mutable_appearance('icons/mob/uniform.dmi', "[t_color]_s", -UNIFORM_LAYER)
	if(worn_uniform.icon_override)
		uniform_overlay.icon = worn_uniform.icon_override
	if(worn_uniform.dynamic_overlay)
		if(worn_uniform.dynamic_overlay["[UNIFORM_LAYER]"])
			var/mutable_appearance/dyn_overlay = worn_uniform.dynamic_overlay["[UNIFORM_LAYER]"]
			uniform_overlay.overlays += dyn_overlay
	if(worn_uniform.blood_DNA && worn_uniform.blood_DNA.len)
		var/mutable_appearance/bloodsies = mutable_appearance('icons/effects/blood.dmi', "uniformblood")
		bloodsies.color	= worn_uniform.blood_color
		uniform_overlay.overlays += bloodsies
	worn_uniform.generate_accessory_overlays(uniform_overlay)
	overlays += overlays_standing[UNIFORM_LAYER] = uniform_overlay

/mob/living/simple_animal/hologram/advanced/update_inv_wear_suit()
	overlays -= overlays_standing[SUIT_LAYER]
	overlays_standing[SUIT_LAYER] = null
	if(!(istype(wear_suit, /obj/item/clothing/suit) && wear_suit.is_visible()))	//TODO check this
		return
	var/obj/item/clothing/suit/worn_suit = wear_suit
	worn_suit.screen_loc = ui_back
	var/mutable_appearance/suit_overlay = mutable_appearance(((worn_suit.icon_override) ? worn_suit.icon_override : 'icons/mob/suit.dmi'), "[worn_suit.icon_state]", -SUIT_LAYER)
	if(istype(worn_suit, /obj/item/clothing/suit/strait_jacket))
		drop_hands()
	if(worn_suit.dynamic_overlay)
		if(worn_suit.dynamic_overlay["[SUIT_LAYER]"])
			var/mutable_appearance/dyn_overlay = worn_suit.dynamic_overlay["[SUIT_LAYER]"]
			suit_overlay.overlays += dyn_overlay
	if(worn_suit.blood_DNA && worn_suit.blood_DNA.len)
		var/mutable_appearance/bloodsies = mutable_appearance('icons/effects/blood.dmi', "[worn_suit.blood_overlay_type]blood")
		bloodsies.color = worn_suit.blood_color
		suit_overlay.overlays += bloodsies
	worn_suit.generate_accessory_overlays(suit_overlay)
	overlays += overlays_standing[SUIT_LAYER] = suit_overlay

/mob/living/simple_animal/hologram/advanced/put_in_hand_check(var/obj/item/W, index)
	if(lying && !W.laying_pickup) //&& !(W.flags & ABSTRACT))
		return 0
	if(!isitem(W))
		return 0

	if(held_items[index])
		return 0

	if((W.flags & MUSTTWOHAND) && !(M_STRONG in mutations))
		if(!W.wield(src, 1))
			to_chat(src, "You need both hands to pick up \the [W].")
			return 0

	if(W.cant_drop) //if the item can't be dropped
		var/I = is_holding_item(W) //AND the item is currently being held in one of the mob's hands
		if(I)
			to_chat(src, "You can't pry \the [W] out of your [get_index_limb_name(I)]!")
			return 0

	return 1

