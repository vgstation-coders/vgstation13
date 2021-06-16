// -- Space hobo -kanef

/datum/outfit/hobo

	outfit_name = "Space Hobo"

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_shoes_str = /obj/item/clothing/shoes/magboots,
			slot_belt_str = /obj/item/device/radio,
            slot_wear_suit_str = /obj/item/clothing/suit/space/ghettorig,
            slot_head_str = /obj/item/clothing/head/helmet/space/ghetto,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/vox = list(
			slot_w_uniform_str =/obj/item/clothing/under/vox/vox_robes,
			slot_shoes_str = /obj/item/clothing/shoes/magboots/vox,
			slot_belt_str = /obj/item/device/radio,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
		/datum/species/mushroom = list(
			slot_w_uniform_str = /obj/item/clothing/under/stilsuit,
			slot_shoes_str = /obj/item/clothing/shoes/magboots,
			slot_belt_str = /obj/item/device/radio,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/mushmen,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/mushmen,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		)
	)

	equip_survival_gear = list(
		/datum/species/human = /obj/item/weapon/storage/box/survival/engineer,
		/datum/species/plasmaman = /obj/item/weapon/storage/box/survival/engineer/plasmaman,
		/datum/species/diona = /obj/item/weapon/storage/box/survival/engineer,
		/datum/species/insectoid = /obj/item/weapon/storage/box/survival/engineer,
		/datum/species/vox = /obj/item/weapon/storage/box/survival/engineer/vox,
		/datum/species/grey = /obj/item/weapon/storage/box/survival/engineer,
	)

	pda_type = null
	id_type = /obj/item/weapon/card/id/vox
