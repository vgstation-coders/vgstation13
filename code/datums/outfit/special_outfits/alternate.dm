/datum/outfit/chiropractor

	outfit_name = "Chiropractor"
	associated_job = /datum/job/alternate/chiropractor

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/medic,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_med,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/med,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str =  /obj/item/clothing/under/rank/medical/blue,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/storage/labcoat,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = list(
				"Emergency Physician" = /obj/item/clothing/under/rank/medical,
				"Surgeon" =  /obj/item/clothing/under/rank/medical/blue,
				"Medical Doctor" = /obj/item/clothing/under/rank/medical,
			),
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/medical,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/medical,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = list(
				"Emergency Physician" = /obj/item/clothing/under/rank/medical,
				"Surgeon" =  /obj/item/clothing/under/rank/medical/blue,
				"Medical Doctor" = /obj/item/clothing/under/rank/medical
			),
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/medical,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/medical,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox
		),
	)

	race_items_to_collect = list(
		/datum/species/vox/ = list(
			"Emergency Physician" = /obj/item/clothing/suit/storage/fr_jacket,
			"Surgeon" =  /obj/item/clothing/suit/storage/labcoat,
			"Medical Doctor" =  /obj/item/clothing/suit/storage/labcoat,
		),
		/datum/species/plasmaman/ = list(
			"Emergency Physician" = /obj/item/clothing/suit/storage/fr_jacket,
			"Surgeon" =  /obj/item/clothing/suit/storage/labcoat,
			"Medical Doctor" =  /obj/item/clothing/suit/storage/labcoat,
		)
	)

	pda_type = /obj/item/device/pda/medical
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/medical

/datum/outfit/doctor/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/storage/firstaid/regular(get_turf(H)))
