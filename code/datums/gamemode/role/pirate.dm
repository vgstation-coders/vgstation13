/datum/role/pirate
	name = "Pirate"
	id = PIRATE
	required_pref = ROLE_PIRATE

/datum/role/pirate/OnPostSetup()
	.=..()
	if(!.)
		return
	equip_pirate(antag.current)

/datum/role/pirate/proc/equip_pirate(var/mob/living/carbon/human/H)
	if (!istype(H))
		return

	qdel(H.wear_suit)
	qdel(H.head)
	qdel(H.shoes)
	qdel(H.r_store)
	qdel(H.l_store)
	qdel(H.w_uniform)
	qdel(H.wear_id)
	qdel(slot_back)

	if(!H.find_empty_hand_index())
		H.u_equip(H.held_items[GRASP_LEFT_HAND])

	H.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/pirate(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/pirate(H), slot_wear_suit)
	if(H.backbag == 2)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
	if(H.backbag == 3)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
	if(H.backbag == 4)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/bag/shot_bag/full(H), slot_r_store)

	H.make_all_robot_parts_organic()
	H.update_icons()
	return 1


/datum/role/pirate/captain
	name = "Pirate captain"
	id = PIRATECAPTAIN

/datum/role/pirate/captain/equip_pirate(var/mob/living/carbon/human/H)
	.=..()
	if(.)
		qdel(H.wear_id)
		H.equip_to_slot_or_del(new /obj/item/weapon/card/id/pirate_captain(H), slot_wear_id)