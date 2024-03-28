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
			slot_w_uniform_str = /obj/item/clothing/under/rank/medical,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/medical,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/medical,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = /obj/item/clothing/under/rank/medical,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/medical,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/medical,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox
		),
	)

	race_items_to_collect = list(
		/datum/species/vox/ = /obj/item/clothing/suit/storage/labcoat,
		/datum/species/plasmaman/ = /obj/item/clothing/suit/storage/labcoat,
	)

	pda_type = /obj/item/device/pda/medical
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/medical

/datum/outfit/doctor/post_equip(var/mob/living/carbon/human/H)
	..()


/datum/outfit/dogwalker
	outfit_name = "Dog Walker"
	associated_job = /datum/job/alternate/dogwalker

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/ianshirt,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/assistant,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/assistant,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
		),
	)

	pda_type = /obj/item/device/pda
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/dogwalker/post_equip(var/mob/living/carbon/human/H)
	..()


/datum/outfit/psychologist
	outfit_name = "Psychologist"
	associated_job = /datum/job/alternate/psychologist

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
			slot_w_uniform_str = /obj/item/clothing/under/rank/medical,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/medical,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/medical,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = /obj/item/clothing/under/rank/medical,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/medical,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/medical,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox
		),
	)

	race_items_to_collect = list(
		/datum/species/vox/ = /obj/item/clothing/suit/storage/labcoat,
		/datum/species/plasmaman/ = /obj/item/clothing/suit/storage/labcoat,
	)

	pda_type = /obj/item/device/pda/medical
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/medical

/datum/outfit/psychologist/post_equip(var/mob/living/carbon/human/H)
	..()


/datum/outfit/scubadiver
	outfit_name = "Scuba Diver"
	associated_job = /datum/job/alternate/scubadiver

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/ianshirt,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/assistant,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/assistant,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
		),
	)

	pda_type = /obj/item/device/pda
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/scubadiver/post_equip(var/mob/living/carbon/human/H)
	..()


/datum/outfit/plumber
	outfit_name = "Plumber"
	associated_job = /datum/job/alternate/plumber

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/color/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/suspenders,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/color/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/assistant,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/assistant,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/color/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
		),
	)

	pda_type = /obj/item/device/pda
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/plumber/post_equip(var/mob/living/carbon/human/H)
	..()


/datum/outfit/dentist
	outfit_name = "Dentist"
	associated_job = /datum/job/alternate/dentist

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
			slot_w_uniform_str = /obj/item/clothing/under/rank/medical,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/medical,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/medical,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = /obj/item/clothing/under/rank/medical,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/medical,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/medical,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox
		),
	)

	race_items_to_collect = list(
		/datum/species/vox/ = /obj/item/clothing/suit/storage/labcoat,
		/datum/species/plasmaman/ = /obj/item/clothing/suit/storage/labcoat,
	)

	pda_type = /obj/item/device/pda/medical
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/medical

/datum/outfit/dentist/post_equip(var/mob/living/carbon/human/H)
	..()
	var/obj/item/stack/teeth/gold/T = new /obj/item/stack/teeth/gold
	T.amount = 10
	H.put_in_hands(T)


/datum/outfit/managementconsultant
	outfit_name = "Management Consultant"
	associated_job = /datum/job/alternate/managementconsultant

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_iaa,
			slot_w_uniform_str = /obj/item/clothing/under/lawyer/bluesuit,
			slot_shoes_str = /obj/item/clothing/shoes/leather,
			slot_wear_suit_str = /obj/item/clothing/suit/storage/lawyer/bluejacket,
			slot_gloves_str = /obj/item/clothing/gloves/white,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_iaa,
			slot_w_uniform_str = /obj/item/clothing/under/lawyer/bluesuit,
			slot_shoes_str = /obj/item/clothing/shoes/leather,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/lawyer,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/lawyer,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
			slot_gloves_str = /obj/item/clothing/gloves/white,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_iaa,
			slot_w_uniform_str = /obj/item/clothing/under/lawyer/bluesuit,
			slot_shoes_str = /obj/item/clothing/shoes/leather,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
			slot_gloves_str = /obj/item/clothing/gloves/white,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
		),
	)

	race_items_to_collect = list(
		/datum/species/vox/ = list(/obj/item/clothing/suit/storage/lawyer/bluejacket),
		/datum/species/plasmaman/ = list(/obj/item/clothing/suit/storage/lawyer/bluejacket),
	)

	pda_type = /obj/item/device/pda/lawyer
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/centcom

/datum/outfit/managementconsultant/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/book/manual/how_to_win_friends_and_influence_people_primer)


