/mob/living/carbon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_back)
			return back
		if(slot_wear_mask)
			return wear_mask
		if(slot_handcuffed)
			return handcuffed || mutual_handcuffs
		if(slot_legcuffed)
			return legcuffed
	return null

/mob/living/carbon/u_equip(obj/item/W as obj, dropped = 1, var/slot = null)
	var/success = 0
	if(!W)
		return 0
	else if (W == handcuffed)
		if(handcuffed.on_restraint_removal(src)) //If this returns 1, then the unquipping action was interrupted
			return 0
		handcuffed = null
		success = 1
		slot = slot_handcuffed
		update_inv_handcuffed()
	else if (W == mutual_handcuffs)
		if(mutual_handcuffs.on_restraint_removal(src)) //If this returns 1, then the unquipping action was interrupted
			return 0
		mutual_handcuffs = null
		success = 1
		slot = slot_handcuffed
		update_inv_mutual_handcuffed()
	else if (W == legcuffed)
		legcuffed = null
		success = 1
		slot = slot_legcuffed
		update_inv_legcuffed()
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

	return

/mob/living/carbon/get_all_slots()
	return list(handcuffed,
				legcuffed,
				back,
				wear_mask) + held_items

//everything on the mob that is not in its pockets, hands belt, etc.
/mob/living/carbon/get_clothing_items()
	var/list/equipped = ..()
	equipped -= list(handcuffed,
					legcuffed,
					back)
	return equipped
