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
		if(user.wear_suit != src)
			to_chat(usr, "You have to put the coat on first.")
			return
		if(!is_hooded)
			to_chat(usr, "You put the hood up.")
			hoodup(user)
		else
			hooddown(user)
			to_chat(usr, "You put the hood down.")


/obj/item/clothing/suit/wintercoat/attack_self()
	togglehood()

/obj/item/clothing/suit/wintercoat/proc/hoodup(var/mob/living/carbon/human/user)
	user.equip_to_slot(hood, slot_head)
	icon_state = "[initial(icon_state)]_t"
	is_hooded = HAS_HOOD
	user.update_inv_wear_suit()

/obj/item/clothing/suit/wintercoat/proc/hooddown(var/mob/living/carbon/human/user,var/unequip = 1)
	icon_state = "[initial(icon_state)]"
	if(unequip)
		user.u_equip(user.head,0)
	is_hooded = NO_HOOD
	user.update_inv_wear_suit()

/obj/item/clothing/suit/wintercoat/unequipped(var/mob/living/carbon/human/user)
	if(hood && istype(user) && user.head == hood)
		hooddown(user)

/obj/item/clothing/head/winterhood/pickup(var/mob/living/carbon/human/user)
	if(coat && istype(coat) && user.wear_suit == coat)
		coat.hooddown(user,unequip = 0)
		user.drop_from_inventory(src)
		forceMove(coat)