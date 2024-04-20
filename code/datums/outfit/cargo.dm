// -- Cargo outfits
// -- HoP - (technically a cargo man)

/datum/outfit/hop

	outfit_name = "Head of Personnel"
	associated_job = /datum/job/hop

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/hop,
			slot_w_uniform_str = /obj/item/clothing/under/rank/head_of_personnel,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/hop,
			slot_w_uniform_str = /obj/item/clothing/under/rank/head_of_personnel,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/security/hop,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/security/hop,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/hop,
			slot_w_uniform_str = /obj/item/clothing/under/rank/head_of_personnel,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/cargo,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/cargo,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
	)

	items_to_collect = list(
		/obj/item/weapon/storage/box/ids = GRASP_RIGHT_HAND,
	)

	implant_types = list(
		/obj/item/weapon/implant/loyalty/,
	)

	pda_type = /obj/item/device/pda/heads/hop
	pda_slot = slot_l_store
	id_type = /obj/item/weapon/card/id/silver

// -- QM

/datum/outfit/qm

	outfit_name = "Quartermaster"
	associated_job = /datum/job/qm

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_cargo,
			slot_w_uniform_str = /obj/item/clothing/under/rank/cargo,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_cargo,
			slot_w_uniform_str = /obj/item/clothing/under/rank/cargo,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/cargo,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/cargo,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_cargo,
			slot_w_uniform_str = /obj/item/clothing/under/rank/cargo,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/cargo,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/cargo,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
	)

	pda_type = /obj/item/device/pda/quartermaster
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/supply

/datum/outfit/qm/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/storage/bag/clipboard(H))

// -- Cargo techie

/datum/outfit/cargo_tech

	outfit_name = "Cargo Technician"
	associated_job = /datum/job/cargo_tech

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = list(
				"Mailman" = /obj/item/device/radio/headset/headset_cargo,
				"Cargo Technician" = /obj/item/device/radio/headset/headset_cargo,
			),
			slot_w_uniform_str = list(
				"Mailman" = /obj/item/clothing/under/rank/mailman,
				"Cargo Technician" = /obj/item/clothing/under/rank/cargotech,
			),
			slot_shoes_str = list(
				"Mailman" = /obj/item/clothing/shoes/brown,
				"Cargo Technician" = /obj/item/clothing/shoes/black,
			),
			slot_head_str = list(
				"Mailman" = /obj/item/clothing/head/mailman,
			),
		),
		/datum/species/plasmaman = list(
			slot_ears_str = list(
				"Mailman" = /obj/item/device/radio/headset/headset_cargo,
				"Cargo Technician" = /obj/item/device/radio/headset/headset_cargo,
			),
			slot_w_uniform_str = list(
				"Mailman" = /obj/item/clothing/under/rank/mailman,
				"Cargo Technician" = /obj/item/clothing/under/rank/cargotech,
			),
			slot_shoes_str = list(
				"Mailman" = /obj/item/clothing/shoes/brown,
				"Cargo Technician" = /obj/item/clothing/shoes/black,
			),
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/cargo,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/cargo,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/vox = list(
			slot_ears_str = list(
				"Mailman" = /obj/item/device/radio/headset/headset_cargo,
				"Cargo Technician" = /obj/item/device/radio/headset/headset_cargo,
			),
			slot_w_uniform_str = list(
				"Mailman" = /obj/item/clothing/under/rank/mailman,
				"Cargo Technician" = /obj/item/clothing/under/rank/cargotech,
			),
			slot_shoes_str = list(
				"Mailman" = /obj/item/clothing/shoes/brown,
				"Cargo Technician" = /obj/item/clothing/shoes/black,
			),
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/cargo,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/cargo,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
	)

	items_to_collect = list(
		/obj/item/weapon/storage/belt/slim = SURVIVAL_BOX,
		/obj/item/clothing/accessory/storage/fannypack = SURVIVAL_BOX
	)

	pda_type = /obj/item/device/pda/cargo
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/supply

/datum/outfit/cargo_tech/post_equip(var/mob/living/carbon/human/H)
	..()

// -- Shaft Miner

/datum/outfit/mining

	outfit_name = "Shaft Miner"
	associated_job = /datum/job/mining

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_mining,
			slot_w_uniform_str = /obj/item/clothing/under/rank/miner,
			slot_shoes_str = /obj/item/clothing/shoes/black,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_mining,
			slot_w_uniform_str = /obj/item/clothing/under/rank/miner,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/miner,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/miner,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_mining,
			slot_w_uniform_str = /obj/item/clothing/under/rank/miner,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/mining,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/mining,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
	)

	items_to_collect = list(
		/obj/item/tool/crowbar = GRASP_LEFT_HAND,
		/obj/item/weapon/storage/bag/ore = slot_l_store_str,
	)

	equip_survival_gear = list(
		/datum/species/human = /obj/item/weapon/storage/box/survival/engineer,
		/datum/species/plasmaman = /obj/item/weapon/storage/box/survival/engineer/plasmaman,
		/datum/species/diona = /obj/item/weapon/storage/box/survival/engineer,
		/datum/species/insectoid = /obj/item/weapon/storage/box/survival/engineer,
		/datum/species/vox = /obj/item/weapon/storage/box/survival/engineer/vox,
		/datum/species/grey = /obj/item/weapon/storage/box/survival/engineer,
	)

	pda_type = /obj/item/device/pda/shaftminer
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/supply

/datum/outfit/mining/post_equip_priority(var/mob/living/carbon/human/H)
	H.put_in_hands(new /obj/item/weapon/pickaxe/drill(get_turf(H)))
	return ..()
