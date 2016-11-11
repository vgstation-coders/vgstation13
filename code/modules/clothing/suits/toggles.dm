#define HAS_HOOD 1
#define NO_HOOD 0
/obj/item/clothing/suit/wintercoat/proc/togglehood()
	set name = "Toggle Hood"
	set category = "Object"
	set src in usr
	if(usr.incapacitated())
		return
	else
		var/mob/living/carbon/human/user = usr
		if((!usr || !istype(usr)) || (user.head && user.head != hood)) // the head slot is empty
			to_chat(usr, "You try to put your hood up but something is in the way.")
			return
		if(src.is_hooded == NO_HOOD)
			user.equip_to_slot(hood, slot_head)
			icon_state = "[initial(icon_state)]_t"
			flags = initial(flags)
			to_chat(usr, "You put \the hood up.")
			src.is_hooded = HAS_HOOD
		else
			icon_state = "[initial(icon_state)]"
			to_chat(usr, "You put \the hood down.")
			user.u_equip(user.head,0)
			flags = 0
			src.is_hooded = NO_HOOD
			body_parts_covered = initial(body_parts_covered)
		usr.update_inv_wear_suit()


/obj/item/clothing/suit/wintercoat/attack_self()
	togglehood()