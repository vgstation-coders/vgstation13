
// -- Engineering outfits
// -- CE

/datum/outfit/chief_engineer

	outfit_name = "Chief Engineer"
	associated_job = /datum/job/chief_engineer

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/industrial,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_eng,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/engi,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/ce,
			slot_w_uniform_str = /obj/item/clothing/under/rank/chief_engineer,
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/hardhat/white,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/complete,
			slot_gloves_str = /obj/item/clothing/gloves/black,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/ce,
			slot_w_uniform_str = /obj/item/clothing/under/rank/chief_engineer,
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/engineer/ce,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/complete,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slo_suit_str = /obj/item/clothing/head/helmet/space/plasmaman/engineer,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,         
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/ce,
			slot_w_uniform_str = /obj/item/clothing/under/rank/chief_engineer,
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/engineer/ce,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/complete,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_suit_str = /obj/item/clothing/suit/space/vox/civ/engineer/ce,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,         
		),
	)

	equip_survival_gear = list(
		"Default" = /obj/item/weapon/storage/box/survival/engineer,
	)

	pda_type = /obj/item/device/pda/heads/ce
	pda_slot = slot_l_store
	id_type = /obj/item/weapon/card/id/ce

/datum/outfit/chief_engineer/post_equip(var/mob/living/carbon/human/H)
	H.mind.store_memory("Frequencies list: <br/><b>Command:</b> [COMM_FREQ]<br/> <b>Engineering:</b> [ENG_FREQ]<br/>")

// -- Station engineer

/datum/outfit/engineer

	outfit_name = "Engineer"
	associated_job = /datum/job/engineer

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/industrial,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_eng,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/engi,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_eng,
			slot_w_uniform_str = list(
				"Station Engineer" = /obj/item/clothing/under/rank/engineer,
				"Maintenance Technician" = /obj/item/clothing/under/rank/maintenance_tech,
				"Electrician" = /obj/item/clothing/under/rank/electrician,
				"Engine Technician" = /obj/item/clothing/under/rank/engine_tech,
			),
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/hardhat,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/full,
			slot_gloves_str = /obj/item/clothing/gloves/black,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_eng,
			slot_w_uniform_str = list(
				"Station Engineer" = /obj/item/clothing/under/rank/engineer,
				"Maintenance Technician" = /obj/item/clothing/under/rank/maintenance_tech,
				"Electrician" = /obj/item/clothing/under/rank/electrician,
				"Engine Technician" = /obj/item/clothing/under/rank/engine_tech,
			),
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/engineer/,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/full,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_suit_str = /obj/item/clothing/suit/space/plasmaman/engineer,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_eng,
			slot_w_uniform_str = list(
				"Station Engineer" = /obj/item/clothing/under/rank/engineer,
				"Maintenance Technician" = /obj/item/clothing/under/rank/maintenance_tech,
				"Electrician" = /obj/item/clothing/under/rank/electrician,
				"Engine Technician" = /obj/item/clothing/under/rank/engine_tech,
			),
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/engineer,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/full,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_suit_str = /obj/item/clothing/suit/space/vox/civ/engineer,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
		),
	)

	equip_survival_gear = list(
		"Default" = /obj/item/weapon/storage/box/survival/engineer,
	)

	pda_type = /obj/item/device/pda/engineering
	pda_slot = slot_l_store
	id_type = /obj/item/weapon/card/id/engineering

/datum/outfit/engineer/post_equip(var/mob/living/carbon/human/H)
	H.mind.store_memory("Frequencies list: <br/><b>Engineering:</b> [ENG_FREQ]<br/>")

// -- Atmos tech

/datum/outfit/atmos

	outfit_name = "Atmospheric technician"
	associated_job = /datum/job/atmos

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_eng,
			slot_w_uniform_str = /obj/item/clothing/under/rank/atmospheric_technician,
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/hardhat,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/atmostech,
			slot_gloves_str = /obj/item/clothing/gloves/black,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_eng,
			slot_w_uniform_str = /obj/item/clothing/under/rank/atmospheric_technician,
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/atmostech,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/atmostech,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_suit_str = /obj/item/clothing/suit/space/plasmaman/atmostech,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_eng,
			slot_w_uniform_str = /obj/item/clothing/under/rank/atmospheric_technician,
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/engineer/atmos,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/atmostech,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_suit_str = /obj/item/clothing/suit/space/vox/civ/engineer/atmos,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
		),
	)

	equip_survival_gear = list(
		"Default" = /obj/item/weapon/storage/box/survival/engineer,
	)

	pda_type = /obj/item/device/pda/engineering
	pda_slot = slot_l_store
	id_type = /obj/item/weapon/card/id/engineering

/datum/outfit/atmos/post_equip(var/mob/living/carbon/human/H)
	H.mind.store_memory("Frequencies list: <br/><b>Engineering:</b> [ENG_FREQ]<br/>")

// -- Mechanic

/datum/outfit/mechanic

	outfit_name = "Atmospheric technician"
	associated_job = /datum/job/mechanic

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/industrial,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_eng,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/engi,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_engsci,
			slot_w_uniform_str = /obj/item/clothing/under/rank/mechanic,
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/complete,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_engsci,
			slot_w_uniform_str = /obj/item/clothing/under/rank/mechanic,
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/engineer,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/complete,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_engsci,
			slot_w_uniform_str = /obj/item/clothing/under/rank/mechanic,
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/mechanic,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/complete,
			slot_suit_str = /obj/item/clothing/suit/space/vox/civ/mechanic,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
		),
	)

	equip_survival_gear = list(
		"Default" = /obj/item/weapon/storage/box/survival/engineer,
	)

	pda_type = /obj/item/device/pda/mechanic
	pda_slot = slot_l_store
	id_type = /obj/item/weapon/card/id/engineering

/datum/outfit/atmos/post_equip(var/mob/living/carbon/human/H)
	H.mind.store_memory("Frequencies list: <br/><b>Engineering:</b> [ENG_FREQ]<br/> <b>Science:</b> [SCI_FREQ] ")
	if(!(H.flags&DISABILITY_FLAG_NEARSIGHTED))
		var/obj/item/clothing/glasses/welding/W = new (H)
		H.equip_or_collect(W, slot_glasses)
		W.toggle()
	else
		var/obj/item/clothing/head/welding/W = new (H)
		H.equip_or_collect(W, slot_head)
		W.toggle()