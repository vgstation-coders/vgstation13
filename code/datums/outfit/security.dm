// -- Security outfits
// -- HoS

/datum/outfit/hos

	outfit_name = "Head of Security"
	associated_job = /datum/job/hos

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/security,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_sec,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/sec,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/hos,
			slot_w_uniform_str = /obj/item/clothing/under/rank/head_of_security,
			slot_shoes_str = /obj/item/clothing/shoes/jackboots/knifeholster,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/sechud,
			slot_wear_suit_str = /obj/item/clothing/suit/armor/hos/jensen,
			slot_s_store_str = /obj/item/weapon/gun/energy/gun,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/hos,
			slot_w_uniform_str = /obj/item/clothing/under/rank/head_of_security,
			slot_shoes_str = /obj/item/clothing/shoes/jackboots/knifeholster,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/sechud,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/security/hos,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/security/hos,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
			slot_s_store_str = /obj/item/weapon/gun/energy/gun,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/hos,
			slot_w_uniform_str = /obj/item/clothing/under/rank/head_of_security,
			slot_shoes_str = /obj/item/clothing/shoes/jackboots/knifeholster,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/sechud,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/security,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/security,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
			slot_s_store_str = /obj/item/weapon/gun/energy/gun,
		),
	)

	items_to_collect = list(
		/obj/item/weapon/handcuffs = slot_r_store_str,
	)

	implant_types = list(
		/obj/item/weapon/implant/loyalty/,
	)

	pda_type = /obj/item/device/pda/heads/hos
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/hos

/datum/outfit/hos/post_equip(var/mob/living/carbon/human/H)
	if (H.mind)
		return
	H.mind.store_memory("Frequencies list: <br/><b>Command:</b> [COMM_FREQ]<br/> <b>Security:</b> [SEC_FREQ]<br/>")

// -- Warden

/datum/outfit/warden

	outfit_name = "Warden"
	associated_job = /datum/job/warden

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/security,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_sec,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/sec,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sec,
			slot_w_uniform_str = /obj/item/clothing/under/rank/warden,
			slot_shoes_str = /obj/item/clothing/shoes/jackboots,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/sechud,
			slot_l_store_str = /obj/item/device/flash,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sec,
			slot_w_uniform_str = /obj/item/clothing/under/rank/warden,
			slot_shoes_str = /obj/item/clothing/shoes/jackboots,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/sechud,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/security,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/security,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
			slot_l_store_str = /obj/item/device/flash,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sec,
			slot_w_uniform_str = /obj/item/clothing/under/rank/warden,
			slot_shoes_str = /obj/item/clothing/shoes/jackboots,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/sechud,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/security,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/security,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
			slot_l_store_str = /obj/item/device/flash,
		),
	)

	items_to_collect = list(
		/obj/item/weapon/handcuffs = slot_r_store_str,
		/obj/item/weapon/gun/energy/taser = GRASP_LEFT_HAND,
	)

	implant_types = list(
		/obj/item/weapon/implant/loyalty/,
	)

	pda_type = /obj/item/device/pda/warden
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/security

/datum/outfit/warden/post_equip(var/mob/living/carbon/human/H)
	if (H.mind)
		return
	H.mind.store_memory("Frequencies list: <br/> <b>Security:</b> [SEC_FREQ]<br/>")

// -- Detective

/datum/outfit/detective

	outfit_name = "Detective"
	associated_job = /datum/job/detective

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/sec,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sec,
			slot_w_uniform_str = list(
				"Forensic Technician" = /obj/item/clothing/under/det,
				"Gumshoe" = /obj/item/clothing/under/det/noir,
				"Private Eye" = /obj/item/clothing/under/det/noir,
				"Detective" = /obj/item/clothing/under/det,
			),
			slot_shoes_str = list(
				"Forensic Technician" = /obj/item/clothing/shoes/brown,
				"Gumshoe" = /obj/item/clothing/shoes/laceup,
				"Private Eye" = /obj/item/clothing/shoes/laceup,
				"Detective" = /obj/item/clothing/shoes/brown,
			),
			slot_head_str = list(
				"Gumshoe" = /obj/item/clothing/head/det_hat/noir,
				"Private Eye" = /obj/item/clothing/head/det_hat/noir,
				"Detective" = /obj/item/clothing/head/det_hat,
			),
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/sechud,
			slot_wear_suit_str = list(
				"Forensic Technician" = /obj/item/clothing/suit/storage/forensics/blue,
				"Gumshoe" = /obj/item/clothing/suit/storage/det_suit/noir,
				"Private Eye" = /obj/item/clothing/suit/storage/det_suit/noir,
				"Detective" = /obj/item/clothing/suit/storage/det_suit,
			),
			slot_l_store_str = /obj/item/weapon/lighter/zippo,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sec,
			slot_w_uniform_str = list(
				"Forensic Technician" = /obj/item/clothing/under/det,
				"Gumshoe" =  /obj/item/clothing/under/det/noir,
				"Private Eye" =  /obj/item/clothing/under/det/noir,
				"Detective" = /obj/item/clothing/under/det,
			),
			slot_shoes_str = list(
				"Forensic Technician" = /obj/item/clothing/shoes/brown,
				"Gumshoe" = /obj/item/clothing/shoes/laceup,
				"Private Eye" = /obj/item/clothing/shoes/laceup,
				"Detective" = /obj/item/clothing/shoes/brown,
			),
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/sechud,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/security/detective,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/security/detective,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
			slot_l_store_str = /obj/item/weapon/lighter/zippo,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sec,
			slot_w_uniform_str = list(
				"Forensic Technician" = /obj/item/clothing/under/det,
				"Gumshoe" = /obj/item/clothing/under/det/noir,
				"Private Eye" = /obj/item/clothing/under/det/noir,
				"Detective" = /obj/item/clothing/under/det,
			),
			slot_shoes_str = list(
				"Forensic Technician" = /obj/item/clothing/shoes/brown,
				"Gumshoe" = /obj/item/clothing/shoes/laceup,
				"Private Eye" = /obj/item/clothing/shoes/laceup,
				"Detective" = /obj/item/clothing/shoes/brown,
			),
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/sechud,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/security,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/security,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
			slot_l_store_str = /obj/item/weapon/lighter/zippo,
		),
	)

	items_to_collect = list(
		/obj/item/weapon/storage/box/evidence = GRASP_LEFT_HAND,
		/obj/item/device/detective_scanner =  slot_belt_str,
	)

	implant_types = list(
		/obj/item/weapon/implant/loyalty/,
	)

	pda_type = /obj/item/device/pda/detective
	pda_slot = slot_r_store
	id_type = /obj/item/weapon/card/id/security

/datum/outfit/detective/post_equip(var/mob/living/carbon/human/H)
	H.dna.SetSEState(SOBERBLOCK,1)
	H.mutations += M_SOBER
	if (H.mind.role_alt_title == "Gumshoe" || H.mind.role_alt_title == "Private Eye")
		H.mutations += M_NOIR
		H.dna.SetSEState(NOIRBLOCK,1)
	H.check_mutations = 1
	if (H.mind)
		return
	H.mind.store_memory("Frequencies list: <b>Security:</b> [SEC_FREQ]<br/>")

// -- Offficer

/datum/outfit/officer

	outfit_name = "Security Officer"
	associated_job = /datum/job/officer

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/security,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_sec,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/sec,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sec,
			slot_w_uniform_str = /obj/item/clothing/under/rank/security,
			slot_shoes_str = /obj/item/clothing/shoes/jackboots,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/sechud,
			slot_wear_suit_str = /obj/item/clothing/suit/armor/vest/security,
			slot_s_store_str = /obj/item/weapon/gun/energy/taser,
			slot_l_store_str = /obj/item/device/flash,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sec,
			slot_w_uniform_str = /obj/item/clothing/under/rank/security,
			slot_shoes_str = /obj/item/clothing/shoes/jackboots,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/sechud,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/security,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/security,
			slot_s_store_str = /obj/item/weapon/gun/energy/taser,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
			slot_l_store_str = /obj/item/device/flash,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sec,
			slot_w_uniform_str = /obj/item/clothing/under/rank/security,
			slot_shoes_str = /obj/item/clothing/shoes/jackboots,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/sechud,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/security,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/security,
			slot_s_store_str = /obj/item/weapon/gun/energy/taser,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
			slot_l_store_str = /obj/item/device/flash,
		),
	)

	items_to_collect = list(
		/obj/item/weapon/handcuffs = slot_r_store_str,
	)

	implant_types = list(
		/obj/item/weapon/implant/loyalty/,
	)

	pda_type = /obj/item/device/pda/security
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/security

/datum/outfit/officer/post_equip(var/mob/living/carbon/human/H)
	if (!H.mind)
		return
	H.mind.store_memory("Frequencies list: <b>Security:</b> [SEC_FREQ]<br/>")
