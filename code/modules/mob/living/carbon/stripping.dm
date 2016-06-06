/mob/living/carbon/proc/strip_hand(var/mob/living/user, var/index)
	if(!index || !isnum(index))	return

	var/obj/item/held = user.get_active_hand()
	var/obj/item/target_item = src.held_items[index]
	var/pickpocket = user.isGoodPickpocket()
	to_chat(world, "HITLERS: We are holding [held], our target is [target_item] in hand index [index] and our pickpocketness level is [pickpocket]")

	var/stripping
	if(istype(target_item))
		if(target_item.cant_drop > 0)
			to_chat(user, "<span class='notice'>\The [target_item] is stuck to \the [src]!</span>")
			return
		stripping = TRUE
	else if(istype(held))
		stripping = FALSE
	else //Nothing to plant and nothing to take, why are we here?
		return

	//HITLERS: Fingerprints?
	//HITLERS: Logging

	if(!pickpocket)
		if(stripping) visible_message("<span class='warning'>\The [user] is trying to take \the [target_item] from \the [src]'s [src.get_index_limb_name(index)]!</span>")
		else visible_message("<span class='warning'>\The [user] is trying to put \a [held] on \the [src]'s [src.get_index_limb_name(index)]!</span>")

	if(do_mob(user, src, HUMAN_STRIP_DELAY)) //Fails if the user moves, changes held item, is incapacitated, etc.
		if(stripping)
			drop_from_inventory(target_item)
			if(pickpocket) user.put_in_hands(target_item)
		else
			if(src.put_in_hand_check(held, index))
				user.drop_from_inventory(held)
				src.put_in_hand(index, held)

		if(in_range(src, user)) //HITLERS: Don't reopen the window
			show_inv(usr)

/mob/living/carbon/proc/strip_slot(var/mob/living/user, var/slot)
	if(!slot) return

	if(slot in src.check_obscured_slots()) //Ideally they wouldn't even get the button to do this, but they could have an outdated menu or something
		to_chat(user, "<span class='warning'>You can't reach that, something is covering it.</span>")
		return

	var/obj/item/held = user.get_active_hand()
	var/obj/item/target_item = src.get_item_by_slot(slot)
	var/pickpocket = user.isGoodPickpocket()
	to_chat(world, "HITLERS: We are holding [held], our target is [target_item] in slot [slot] and our pickpocketness level is [pickpocket]")

	//HITLERS: Fingerprints?
	var/stripping
	if(istype(target_item)) //We want the player to be able to strip someone while holding an item in their hands, for convenience and because otherwise people will bitch about it.
		if(!target_item.canremove)
			to_chat(user, "<span class='warning'>You can't seem to be able to take that off!</span>")
			return
		stripping = TRUE
	else if(istype(held))
		if(!held.mob_can_equip(src, slot, disable_warning = 1)) //This also checks for glued items, target being too fat for the clothing item, and such
			to_chat(user, "<span class='warning'>You can't put that there!</span>") //Ideally we could have a more descriptive message since this can fail for a variety of reasons, but whatever
			return
		stripping = FALSE
	else //We're not holding anything and the guy is not wearing anything in that slot, what are we even doing here?
		return

	if(!pickpocket)
		if(stripping) visible_message("<span class='danger'>\The [user] is trying to take off \the [target_item] from \the [src]'s TARGETAREA!</span>") //HITLERS: Targetarea
		else visible_message("<span class='danger'>\The [user] is trying to put \a [held] on \the [src]!</span>")

	if(!do_mob(user, src, HUMAN_STRIP_DELAY)) //Fails if the user moves, changes held item, is incapacitated, etc.
		return

	if(!src.has_organ_for_slot(slot))
		to_chat(user, "<span class='warning'>It takes you way too long to realize \the [src] has no TARGETAREA.</span>") //intentionally not throwing the error earlier :^) //HITLERS: targetarea
		return

	if(stripping)
		if(is_holder_of(src, target_item)) //do_mob makes sure the item to be placed hasn't gone anywhere, but it doesn't check for the item to be stripped
			if(slot == slot_w_uniform) //I'm so sorry, really, I am
				var/list/obj/item/pocket_items = list(src.get_item_by_slot(slot_l_store), src.get_item_by_slot(slot_r_store))
				for(var/obj/item/I in pocket_items)
					if(I.on_found(user)) //if this returns 1, then the action was interrupted
						return 1
				for(var/obj/item/I in pocket_items) //doing the for loop again because we don't want to trigger this on the first pocket if the second has an on_found
					I.stripped(src, user)

			drop_from_inventory(target_item)
			target_item.stripped(src, user)
			if(pickpocket) user.put_in_hands(target_item)
	else
		if(held.mob_can_equip(src, slot, disable_warning = 1))
			user.drop_from_inventory(held)
			src.equip_to_slot(held, slot)
	if(in_range(src, user)) //HITLERS: Don't reopen the window
		show_inv(usr)

/mob/living/carbon/proc/strip_id(var/mob/living/user)
	var/obj/item/id_item = src.get_item_by_slot(slot_wear_id)
	var/obj/item/place_item = user.get_active_hand()
	var/pickpocket = user.isGoodPickpocket()

	if(id_item)
		to_chat(user, "<span class='notice'>You try to take [src]'s ID.</span>")
	else if(place_item && place_item.mob_can_equip(src, slot_wear_id, disable_warning = 1))
		to_chat(user, "<span class='notice'>You try to place [place_item] on [src].</span>")
	else return //Nothing to do here

	if(do_mob(user, src, HUMAN_STRIP_DELAY)) //Fails if the user moves, changes held item, is incapacitated, etc.
		if(id_item)
			u_equip(id_item,1)
			if(pickpocket) user.put_in_hands(id_item)
		else
			if(place_item)
				user.u_equip(place_item,1)
				equip_to_slot_if_possible(place_item, slot_wear_id, 0, 1)
		// Update strip window
		if(in_range(src, user))
			show_inv(user)

	else if(!pickpocket) // Display a warning if the user mocks up. Unless they're just that good of a pickpocket.
		to_chat(src, "<span class='warning'>You feel your ID being fumbled with!</span>")

/mob/living/carbon/proc/strip_pocket(var/mob/living/user, var/pocket_side)
	if(!pocket_side) return

	var/pocket_id = (pocket_side == "right" ? slot_r_store : slot_l_store)
	var/obj/item/pocket_item = get_item_by_slot(pocket_id)
	var/obj/item/place_item = user.get_active_hand() // Item to place in the pocket, if it's empty
	var/pickpocket = user.isGoodPickpocket()

	if(pocket_item)
		to_chat(user, "<span class='notice'>You try to empty [src]'s [pocket_side] pocket.</span>")
	else if(place_item && place_item.mob_can_equip(src, pocket_id, disable_warning = 1))
		to_chat(user, "<span class='notice'>You try to place [place_item] into [src]'s [pocket_side] pocket.</span>")
	else return //Nothing to do here

	if(do_mob(usr, src, HUMAN_STRIP_DELAY)) //Fails if the user moves, changes held item, is incapacitated, etc.
		if(pocket_item)
			if(pocket_item.on_found(usr)) //If this returns 1, then the action was interrupted
				return
			u_equip(pocket_item,1)
			pocket_item.stripped(src,usr)
			if(pickpocket) usr.put_in_hands(pocket_item)
		else
			if(place_item)
				usr.u_equip(place_item,1)
				equip_to_slot_if_possible(place_item, pocket_id, 0, 1)
		// Update strip window
		if(in_range(src, usr))
			show_inv(usr)

	else if(!pickpocket) // Display a warning if the user mocks up. Unless they're just that good of a pickpocket.
		to_chat(src, "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>")

// Modify the current target sensor level.
/mob/living/carbon/human/proc/toggle_sensors(var/mob/living/user)
	var/obj/item/clothing/under/suit = w_uniform
	if(!suit)
		user << "<span class='warning'>\The [src] is not wearing a suit with sensors.</span>"
		return
	if (suit.has_sensor >= 2)
		user << "<span class='warning'>\The [src]'s suit sensor controls are locked.</span>"
		return
	attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their sensors toggled by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to toggle [name]'s ([ckey]) sensors</font>")
	suit.set_sensors(user)

// Set internals on or off.
/mob/living/carbon/human/proc/toggle_internals(var/mob/living/user)
	if(internal)
		internal.add_fingerprint(user)
		internal = null
		if(internals)
			internals.icon_state = "internal0"
	else
		// Check for airtight mask/helmet.
		if(!(istype(wear_mask, /obj/item/clothing/mask) || istype(head, /obj/item/clothing/head/helmet/space)))
			return
		// Find an internal source.
		if(istype(back, /obj/item/weapon/tank))
			internal = back
		else if(istype(s_store, /obj/item/weapon/tank))
			internal = s_store
		else if(istype(belt, /obj/item/weapon/tank))
			internal = belt

	if(internal)
		visible_message("<span class='warning'>\The [src] is now running on internals.</span>")
		internal.add_fingerprint(user)
		if (internals)
			internals.icon_state = "internal1"
	else
		visible_message("<span class='danger'>\The [user] disables \the [src]'s internals!</span>")
