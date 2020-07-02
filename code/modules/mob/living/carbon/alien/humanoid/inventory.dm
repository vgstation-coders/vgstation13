/mob/living/carbon/alien/humanoid/equip_to_slot(obj/item/W, slot, redraw_mob = 1)
	if(!slot)
		return
	if(!istype(W))
		return

	if(src.is_holding_item(W))
		src.u_equip(W, 0)

	switch(slot)
		if(slot_l_store)
			src.l_store = W
			update_inv_pockets(redraw_mob)
		if(slot_r_store)
			src.r_store = W
			update_inv_pockets(redraw_mob)
		if(slot_handcuffed)
			var/obj/item/weapon/handcuffs/cuffs = W
			if (istype(cuffs) && cuffs.mutual_handcuffed_mobs.len) //if those are regular cuffs, and there are mobs cuffed to each other, do the mutual handcuff logic
				src.mutual_handcuffs = cuffs
				update_inv_mutual_handcuffed(redraw_mob)
			else 
				src.handcuffed = cuffs
				update_inv_handcuffed(redraw_mob)
		else
			to_chat(usr, "<span class='warning'>You are trying to equip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return

	W.hud_layerise()
	W.equipped(src, slot)
	W.forceMove(src)
	if(client)
		client.screen |= W

// Return the item currently in the slot ID
/mob/living/carbon/alien/humanoid/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_l_store)
			return l_store
		if(slot_r_store)
			return r_store
		if(slot_handcuffed)
			return handcuffed || mutual_handcuffs
	return null

/mob/living/carbon/alien/humanoid/u_equip(obj/item/W, dropped = 1, var/slot = null)
	if(!W)
		return 0
	var/success = 0
	if (W == r_store)
		r_store = null
		success = 1
		slot = slot_r_store
		update_inv_pockets()
	else if (W == l_store)
		l_store = null
		success = 1
		slot = slot_l_store
		update_inv_pockets()
	else
		..()

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
	return 1

//Literally copypasted /mob/proc/attack_ui(slot, hand_index) while replacing attack_hand with attack_alien
/mob/living/carbon/alien/humanoid/attack_ui(slot, hand_index)
	var/obj/item/W = get_active_hand()
	if(istype(W))
		if(slot)
			equip_to_slot_if_possible(W, slot)
		else if(hand_index)
			put_in_hand(hand_index, W)
	else
		W = get_item_by_slot(slot)
		if(W)
			W.attack_alien(src)

/mob/living/carbon/alien/humanoid/put_in_hand_check(var/obj/item/W)
	if(!has_fine_manipulation && !is_type_in_list(W, can_only_pickup))
		to_chat(src, "<span class = 'warning'>Your claws aren't capable of such fine manipulation.</span>")
		return 0
	return 1
