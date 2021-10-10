//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/monkey/equip_to_slot(obj/item/W as obj, slot, redraw_mob = 1)
	if(!slot)
		return
	if(!istype(W))
		return

	if(src.is_holding_item(W))
		src.u_equip(W, 0)

	switch(slot)
		if(slot_back)
			src.back = W
			update_inv_back(redraw_mob)
		if(slot_head)
			src.hat = W
			update_inv_hat(redraw_mob)
		if(slot_w_uniform)
			src.uniform = W
			update_inv_uniform(redraw_mob)
		if(slot_glasses)
			src.glasses = W
			update_inv_glasses(redraw_mob)
		if(slot_wear_mask)
			src.wear_mask = W
			update_inv_wear_mask(redraw_mob)
		if(slot_handcuffed)
			var/obj/item/weapon/handcuffs/cuffs = W
			if (istype(cuffs) && cuffs.mutual_handcuffed_mobs.len) //if those are regular cuffs, and there are mobs cuffed to each other, do the mutual handcuff logic
				src.mutual_handcuffs = cuffs
				update_inv_mutual_handcuffed(redraw_mob)
			else
				src.handcuffed = W
				update_inv_handcuffed(redraw_mob)
		if(slot_legcuffed)
			src.legcuffed = W
			update_inv_legcuffed(redraw_mob)
		if(slot_in_backpack)
			W.forceMove(src.back)
		else
			to_chat(usr, "<span class='warning'>You are trying to equip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return

	W.hud_layerise()
	W.equipped(src, slot)
	W.forceMove(src)
	if(client)
		client.screen |= W

// Return the item currently in the slot ID
/mob/living/carbon/monkey/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_back)
			return back
		if(slot_w_uniform)
			return uniform
		if(slot_head)
			return hat
		if(slot_wear_mask)
			return wear_mask
		if(slot_glasses)
			return glasses
		if(slot_handcuffed)
			return handcuffed || mutual_handcuffs
		if(slot_legcuffed)
			return legcuffed
	return null

// Return the item currently in the slot denoted by the slot flag
/mob/living/carbon/monkey/get_item_by_flag(slot_flag)
	switch(slot_flag)
		if(SLOT_BACK)
			return back
		if(SLOT_ICLOTHING)
			return uniform
		if(SLOT_HEAD)
			return hat
		if(SLOT_MASK)
			return wear_mask
		if(SLOT_EYES)
			return glasses
	return null

/mob/living/carbon/monkey/get_all_slots()
	return list(
		back,
		uniform,
		hat,
		wear_mask,
		glasses,
		handcuffed,
		legcuffed)

/mob/living/carbon/monkey/u_equip(obj/item/W as obj, dropped = 1, var/slot = null)
	var/success = 0
	if(!W)
		return 0

	if(W == hat)
		hat = null
		success = 1
		slot = slot_head
		update_inv_hat()
		INVOKE_EVENT(src, /event/unequipped, W)
	else if(W == glasses)
		glasses = null
		success = 1
		slot = slot_glasses
		update_inv_glasses()
		INVOKE_EVENT(src, /event/unequipped, W)
	else if(W == uniform)
		uniform = null
		success = 1
		slot = slot_w_uniform
		update_inv_uniform()
		INVOKE_EVENT(src, /event/unequipped, W)
	else
		success = ..()
	if(success)
		if (W)
			if (client)
				client.screen -= W
			W.unequipped(src, slot)
			if(dropped)
				W.forceMove(loc)
				W.dropped(src)
			if(W)
				W.reset_plane_and_layer()

/mob/living/carbon/monkey/strip_time()
	return MONKEY_STRIP_DELAY

/mob/living/carbon/monkey/reversestrip_time()
	return MONKEY_REVERSESTRIP_DELAY
