
/mob/living/carbon/martian/get_item_offset_by_index(index)
	switch(index)
		if(1,6)
			return list("x"=0, "y"=0)
		if(2,5)
			return list("x"=0, "y"=10)
		if(3,4)
			return list("x"=0, "y"=16)

	return list()

/mob/living/carbon/martian/get_held_item_ui_location(index)
	if(!is_valid_hand_index(index))
		return

	switch(index)
		if(1)
			return "CENTER-3:16,SOUTH:5"
		if(2)
			return "CENTER-2:16,SOUTH:5:4"
		if(3)
			return "CENTER-1:16,SOUTH:5:10"
		if(4)
			return "CENTER+1:16,SOUTH:5:10"
		if(5)
			return "CENTER+2:16,SOUTH:5:4"
		if(6)
			return "CENTER+3:16,SOUTH:5"
		else
			return ..()

/mob/living/carbon/martian/get_index_limb_name(index)
	if(!index)
		index = active_hand

	switch(index)
		if(1)
			return "right lower tentacle"
		if(2)
			return "right middle tentacle"
		if(3)
			return "right upper tentacle"
		if(4)
			return "left upper tentacle"
		if(5)
			return "left middle tentacle"
		if(6)
			return "left lower tentacle"
		else
			return "tentacle"

/mob/living/carbon/martian/get_direction_by_index(index)
	if(index <= 3)
		return "right_hand"
	else
		return "left_hand"


/mob/living/carbon/martian/GetAccess()
	var/list/ACL=list()

	for(var/obj/item/I in held_items)
		ACL |= I.GetAccess()

	return ACL

/mob/living/carbon/martian/get_visible_id()
	var/id = null
	for(var/obj/item/I in held_items)
		id = I.GetID()
		if(id)
			break
	return id

/mob/living/carbon/martian/can_wield()
	return 1

/mob/living/carbon/martian/u_equip(obj/item/W, dropped = 1)
	var/success = 0

	if(!W)
		return 0

	if (W == head)
		head = null
		success = 1
		update_inv_head()
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

/mob/living/carbon/martian/equip_to_slot(obj/item/W, slot, redraw_mob = 1)
	if(!istype(W))
		return

	if(src.is_holding_item(W))
		src.u_equip(W)

	if(slot == slot_head)
		head = W
		update_inv_head(redraw_mob)

	W.hud_layerise()
	W.equipped(src, slot)
	W.forceMove(src)
	if(client)
		client.screen |= W

/mob/living/carbon/martian/abiotic()
	for(var/obj/item/I in held_items)
		if(I.abstract)
			continue

		return I

	return head

/mob/living/carbon/martian/show_inv(mob/living/carbon/user)
	user.set_machine(src)

	var/dat

	for(var/i = 1 to held_items.len) //Hands
		var/obj/item/I = held_items[i]
		dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(I)]</A><BR>"

	dat += "<BR><B>Head:</B> <A href='?src=\ref[src];item=[slot_head]'>[makeStrippingButton(head)]</A>"

	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()


// Return the item currently in the slot ID
/mob/living/carbon/martian/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_head)
			return head
	return null
