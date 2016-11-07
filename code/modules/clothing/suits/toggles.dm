/obj/item/clothing/suit/wintercoat
    name = "winter coat"
    desc = "A warm, fluffy and incredibly comfortable jacket made from animal furs."
    icon_state = "coatwinter"
    var item_state_slots = list(slot_r_hand_str = "coatwinter", slot_l_hand_str = "coatwinter")
    body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
    heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
    armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
//    action_button_name = "Toggle Hood"
//    var/is_hooded = 2
    allowed = list (
    /obj/item/weapon/pen,
    /obj/item/weapon/paper,
    /obj/item/device/flashlight,
    /obj/item/weapon/tank/emergency_oxygen,
    /obj/item/weapon/storage/fancy/cigarettes,
//    /obj/item/weapon/storage/box/matches,
    /obj/item/weapon/reagent_containers/food/drinks/flask
    )


/obj/item/clothing/suit/wintercoat/cargo
    name = "cargo winter coat"
    icon_state = "coatcargo"


/obj/item/clothing/suit/wintercoat/science
    name = "science winter coat"
    icon_state = "coatscience"


/obj/item/clothing/suit/wintercoat/medical
    name = "medical winter coat"
    icon_state = "coatmedical"


/obj/item/clothing/suit/wintercoat/captain
    name = "captain winter coat"
    icon_state = "coatcaptain"


/obj/item/clothing/suit/wintercoat/engineering
    name = "engineering winter coat"
    icon_state = "coatengineering"


/obj/item/clothing/suit/wintercoat/hydro
    name = "hydroponics winter coat"
    icon_state = "coathydro"


/obj/item/clothing/suit/wintercoat/atmos
    name = "atmospherics winter coat"
    icon_state = "coatatmos"



/obj/item/clothing/suit/wintercoat/security
    name = "security winter coat"
    icon_state = "coatsecurity"


/obj/item/clothing/suit/wintercoat/mining
    name = "mining winter coat"
    icon_state = "coatmining"

///obj/item/clothing/head/winterhood
//	name = "winter hood"
//	icon_state ="generic_hood"
//	desc = "the hood of a winter coat"
//	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY


//Hood proc

//obj/item/clothing/suit/wintercoat/verb/togglehood()
//	set name = "Toggle Hood"
//	set category = "Object"
//	set src in usr
//	if(usr.incapacitated())
//		return
//	else
//		var/mob/living/carbon/human/user = usr
//		if(user.head)
//			to_chat(usr, "You try to put your hood up but something is in the way.")
//			return
//		if(src.is_hooded == 2)
//			icon_state = "[initial(icon_state)]_t"
//			user.head = /obj/item/clothing/head/winterhood
//			flags = initial(flags)
//			body_parts_covered &= ~(HEAD)
//			to_chat(usr, "You put \the hood up.")
//			src.is_hooded = 1
//		else
//			icon_state = "[initial(icon_state)]"
//			user.head = null
//			to_chat(usr, "You put \the hood down.")
//			flags = 0
//			src.is_hooded = 2
//			body_parts_covered = initial(body_parts_covered)
//		usr.update_inv_wear_suit()
//
//
///obj/item/clothing/suit/wintercoat/attack_self()
//	togglehood()