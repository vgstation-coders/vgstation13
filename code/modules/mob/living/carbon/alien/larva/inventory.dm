//can't unequip since it can't equip anything
//mob/living/carbon/alien/larva/u_equip(obj/item/W as obj)
//	return
//We do now.

/mob/living/carbon/alien/larva/equip_to_slot(obj/item/W as obj, slot)
	if(!slot)
		return
	if(!istype(W))
		return

	switch(slot)
		if(slot_handcuffed)
			var/obj/item/weapon/handcuffs/cuffs = W
			if (istype(cuffs) && cuffs.mutual_handcuffed_mobs.len) //if those are regular cuffs, and there are mobs cuffed to each other, do the mutual handcuff logic
				src.mutual_handcuffs = cuffs
			else 
				src.handcuffed = W
		else
			return

	W.equipped(src, slot)
	W.forceMove(src)

/mob/living/carbon/alien/larva/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_handcuffed)
			return handcuffed || mutual_handcuffs
	return null

/mob/living/carbon/alien/larva/get_all_slots()
	return list(
		handcuffed)
