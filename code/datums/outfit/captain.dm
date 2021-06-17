// -- Captain

/datum/outfit/captain

	outfit_name = "Captain"
	associated_job = /datum/job/captain

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/captain,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_cap,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/com,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/captain,
			slot_w_uniform_str = /obj/item/clothing/under/rank/captain,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_head_str = /obj/item/clothing/head/caphat,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/captain,
			slot_w_uniform_str = /obj/item/clothing/under/rank/captain,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/security/captain,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/security/captain,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/captain,
			slot_w_uniform_str = /obj/item/clothing/under/rank/captain,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
	)

	items_to_collect = list(
		/obj/item/weapon/storage/box/ids = GRASP_RIGHT_HAND,
		/obj/item/weapon/gun/energy/gun = GRASP_LEFT_HAND,
	)

	race_items_to_collect = list(
		/datum/species/vox/ = list(
			/obj/item/clothing/head/caphat,
		),
		/datum/species/plasmaman/ = list(
			/obj/item/clothing/head/caphat,
		)
	)

	implant_types = list(
		/obj/item/weapon/implant/loyalty/,
	)

	pda_type = /obj/item/device/pda/captain
	pda_slot = slot_l_store
	id_type = /obj/item/weapon/card/id/gold


/datum/outfit/captain/post_equip(var/mob/living/carbon/human/H)
	..()
	equip_accessory(H, /obj/item/clothing/accessory/medal/gold/captain, /obj/item/clothing/under)
	to_chat(world, "<b>[H.real_name] is the captain!</b>")
