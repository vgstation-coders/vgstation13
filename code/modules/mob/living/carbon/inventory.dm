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

/mob/living/carbon/verb/get_backpack()
	set name = "Get backpack"
	set category = "IC"
	set desc = "Get what is currently on your backslot"

	attack_ui(slot_back)
	
/mob/living/carbon/verb/get_belt()
	set name = "Get belt"
	set category = "IC"
	set desc = "Get what is currently on your beltslot"

	attack_ui(slot_belt)

/mob/living/carbon/proc/hotkey_box_slot(var/slot)
	if (slot <= 0 || slot > 9)
		return
	if (incapacitated())
		return
	if (!s_active) // No box to pick from
		return

	// attack if no held item
	var/obj/item/holding = src.get_active_hand()
	if (!holding)
		var/obj/item/I = s_active.contents[slot]
		if (!I)
			return

		if (istype(I, /obj/item/weapon/storage)) // Storage within storage
			var/obj/item/weapon/storage/S = I
			S.orient2hud(src)
			s_active.close(src)
			S.show_to(src)
			return

		if(s_active.remove_from_storage(I, get_turf(src)))
			put_in_hands(I)

	else
		if (!s_active.can_be_inserted(holding))
			return
		s_active.handle_item_insertion(holding)

/mob/living/carbon/verb/StorageHotkey(var/index as num)
	set hidden = 1
	hotkey_box_slot(index)
