// WINTER COATS

/obj/item/clothing/suit/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon_state = "coatwinter"
	item_state = "labcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	var/is_hooded = 0
	var/nohood = 0
	var/obj/item/clothing/head/winterhood/hood
	actions_types = list(/datum/action/item_action/toggle_hood)

/obj/item/clothing/suit/wintercoat/New()
	if(!nohood)
		hood = new(src)
	else
		actions_types = null

	..()

/obj/item/clothing/head/winterhood
	name = "winter hood"
	desc = "A hood attached to a heavy winter jacket."
	icon_state = "whood"
	body_parts_covered = HIDEHEADHAIR
	heat_conductivity = SNOWGEAR_HEAT_CONDUCTIVITY
	var/obj/item/clothing/suit/wintercoat/coat

/obj/item/clothing/head/winterhood/New(var/obj/item/clothing/suit/wintercoat/wc)
	..()
	if(istype(wc))
		coat = wc
	else if(!coat)
		qdel(src)
		
/obj/item/clothing/suit/wintercoat/captain
	name = "captain's winter coat"
	icon_state = "coatcaptain"
	armor = list(melee = 20, bullet = 15, laser = 20, energy = 10, bomb = 15, bio = 0, rad = 0)

/obj/item/clothing/suit/wintercoat/security
	name = "security winter coat"
	icon_state = "coatsecurity"
	armor = list(melee = 25, bullet = 20, laser = 20, energy = 15, bomb = 20, bio = 0, rad = 0)

/obj/item/clothing/suit/wintercoat/security/hos
	name = "Head of Security's winter coat"
	icon_state = "coathos"
	nohood = 1
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/suit/wintercoat/security/warden
	name = "Warden's winter coat"
	icon_state = "coatwarden"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	nohood = 1
	
/obj/item/clothing/suit/wintercoat/medical
	name = "medical winter coat"
	icon_state = "coatmedical"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 50, rad = 0)

/obj/item/clothing/suit/wintercoat/science
	name = "science winter coat"
	icon_state = "coatscience"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/suit/wintercoat/engineering
	name = "engineering winter coat"
	icon_state = "coatengineer"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 20)

/obj/item/clothing/suit/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	icon_state = "coatatmos"

/obj/item/clothing/suit/wintercoat/hydro
	name = "hydroponics winter coat"
	icon_state = "coathydro"

/obj/item/clothing/suit/wintercoat/cargo
	name = "cargo winter coat"
	icon_state = "coatcargo"

/obj/item/clothing/suit/wintercoat/prisoner
	name = "prisoner winter coat"
	icon_state = "coatprisoner"
	
/obj/item/clothing/suit/wintercoat/hop
	name = "Head of Personnel's winter coat"
	icon_state = "coathop"
	armor = list(melee = 50, bullet = 10, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/suit/wintercoat/miner
	name = "mining winter coat"
	icon_state = "coatminer"
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	
/obj/item/clothing/suit/wintercoat/clown
	name = "Elfen winter coat"
	icon_state = "coatclown"

/obj/item/clothing/suit/wintercoat/ce
	name = "Chief Engineer's winter coat"
	icon_state = "coatce"

/obj/item/clothing/suit/wintercoat/cmo
	name = "Chief Medical Officer's winter coat"
	icon_state = "coatcmo"
	
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
		if(!istype(user))
			return
		if(user.get_item_by_slot(slot_wear_suit) != src)
			to_chat(user, "You have to put the coat on first.")
			return
		if(!is_hooded && !user.get_item_by_slot(slot_head) && hood.mob_can_equip(user,slot_head))
			to_chat(user, "You put the hood up.")
			hoodup(user)
		else if(user.get_item_by_slot(slot_head) == hood)
			hooddown(user)
			to_chat(user, "You put the hood down.")
		else
			to_chat(user, "You try to put your hood up, but there is something in the way.")
			return
		user.update_inv_wear_suit()

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
	if(hood && istype(user) && user.get_item_by_slot(slot_head) == hood)
		hooddown(user)

/obj/item/clothing/head/winterhood/pickup(var/mob/living/carbon/human/user)
	if(coat && istype(coat) && user.get_item_by_slot(slot_wear_suit) == coat)
		coat.hooddown(user,unequip = 0)
		user.drop_from_inventory(src)
		forceMove(coat)
	