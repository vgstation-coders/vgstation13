//Xenoarch bio suits.

/obj/item/clothing/suit/bio_suit/anomaly
	name = "Anomaly suit"
	desc = "A sealed bio suit capable of insulating against exotic alien energies."
	icon_state = "anomaly_suit"
	item_state = "engspace_suit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank)
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY

/obj/item/clothing/head/bio_hood/anomaly
	name = "Anomaly hood"
	desc = "A sealed bio hood capable of insulating against exotic alien energies."
	icon_state = "anomaly_helmet"
	item_state = "anomaly_helmet"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/xenoarch.dmi', "right_hand" = 'icons/mob/in-hand/right/xenoarch.dmi')
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	body_parts_visible_override = EYES|BEARD

/obj/item/clothing/suit/bio_suit/anomaly/old
	name = "Anomaly suit"
	desc = "A sealed bio suit capable of insulating against exotic alien energies. There is a small tag on it that reads: 'Property of <s>Engineering</s> Research'."
	icon_state = "engspace_suit"
	item_state = "engspace_suit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/spacesuits.dmi', "right_hand" = 'icons/mob/in-hand/right/spacesuits.dmi')

/obj/item/clothing/head/bio_hood/anomaly/old
	name = "Anomaly hood"
	desc = "A sealed bio hood capable of insulating against exotic alien energies. There is a small tag on it that reads: 'Property of <s>Engineering</s> Research'."
	icon_state = "engspace_helmet"
	item_state = "engspace_helmet"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/spacesuits.dmi', "right_hand" = 'icons/mob/in-hand/right/spacesuits.dmi')

//used for the xenoarch old anomally suit find
/obj/item/weapon/storage/box/large/xa_anomsuit
	desc = "There's a label on the box: 'Retired Anomaly Suit. Dispose ASAP'. The box is warped beyond use, but it could be used in research or broken down and remade."
	can_only_hold = null
	items_to_spawn = list(/obj/item/clothing/head/bio_hood/anomaly/old, /obj/item/clothing/suit/bio_suit/anomaly/old)


//Xenoarch space suit.
//For the current standard suit see /obj/item/clothing/suit/space/rig/arch in "code\modules\clothing\spacesuits\rig.dm".

/obj/item/clothing/suit/space/anomaly
	name = "Excavation suit"
	desc = "A pressure resistant excavation suit partially capable of insulating against exotic alien energies. There is a small tag on it that reads: 'Property of <s>Engineering</s> Research'."
	icon_state = "cespace_suit"
	item_state = "cespace_suit"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank)

/obj/item/clothing/head/helmet/space/anomaly
	name = "Excavation hood"
	desc = "A pressure resistant excavation hood partially capable of insulating against exotic alien energies. There is a small tag on it that reads: 'Property of <s>Engineering</s> Research.'"
	icon_state = "cespace_helmet"
	item_state = "cespace_helmet"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)
	body_parts_visible_override = EYES|BEARD

//used for the xenoarch old excavation suit find
/obj/item/weapon/storage/box/large/xa_excasuit
	desc = "There's a label on the box: 'Retired Excavation Suit. Dispose ASAP'. The box is warped beyond use, but it could be used in research or broken down and remade."
	can_only_hold = null
	items_to_spawn = list(/obj/item/clothing/head/helmet/space/anomaly, /obj/item/clothing/suit/space/anomaly)
