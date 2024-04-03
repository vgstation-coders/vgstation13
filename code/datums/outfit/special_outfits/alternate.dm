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

/datum/outfit/weddingplanner
	outfit_name = "Wedding Planner"
	associated_job = /datum/job/alternate/weddingplanner

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_head_str =  /obj/item/clothing/head/beret,
			),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/librarian,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/librarian,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/librarian,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/librarian,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
		)
	)

	pda_type = /obj/item/device/pda/lawyer
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/centcom

/datum/outfit/weddingplanner/post_equip(var/mob/living/carbon/human/H)
	..()
	var/obj/item/weapon/folder/red/F = new /obj/item/weapon/folder/red
	F.name = "Demands of the Bride"
	F.desc = "You MUST get ALL of the details right or there will be hell to pay!"
	H.put_in_hands(F)

/datum/outfit/lifeguard
	outfit_name = "Lifeguard"
	associated_job = /datum/job/alternate/lifeguard

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/swimsuit/red,
			slot_shoes_str = /obj/item/clothing/shoes/sandal,
			slot_belt_str = /obj/item/weapon/storage/bag/bookbag,
			slot_head_str =  /obj/item/clothing/head/beret,
			),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/swimsuit/red,
			slot_shoes_str = /obj/item/clothing/shoes/sandal,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/swimsuit/red,
			slot_shoes_str = /obj/item/clothing/shoes/sandal,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
		)
	)

	pda_type = /obj/item/device/pda
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/lifeguard/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/device/hailer/lifeguard)
	var/obj/item/toy/gasha/skub/S = new /obj/item/toy/gasha/skub
	S.name = "SkubCo Sunblock"
	S.desc = "SkubCo does not guarantee use of Skub as sunblock prevents skin cancer."
	H.put_in_hands(S)

/datum/outfit/insurancesalesman
	outfit_name = "Insurance Salesman"
	associated_job = /datum/job/alternate/insurancesalesman

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

	pda_type = /obj/item/device/pda
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/insurancesalesman/post_equip(var/mob/living/carbon/human/H)
	..()
	var/obj/item/weapon/folder/red/F = new /obj/item/weapon/folder/red
	F.name = "Plans and Subscriptions"
	F.desc = "Inventory of all plan options and current policies."
	H.put_in_hands(F)

/datum/outfit/cableguy

	outfit_name = "Cable Guy"
	associated_job = /datum/job/alternate/cableguy

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
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/engineer,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_engsci,
			slot_w_uniform_str = /obj/item/clothing/under/rank/mechanic,
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/mechanic,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/complete,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/mechanic,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
		),
	)

	equip_survival_gear = list(
		/datum/species/human = /obj/item/weapon/storage/box/survival/engineer,
		/datum/species/plasmaman = /obj/item/weapon/storage/box/survival/engineer/plasmaman,
		/datum/species/diona = /obj/item/weapon/storage/box/survival/engineer,
		/datum/species/insectoid = /obj/item/weapon/storage/box/survival/engineer,
		/datum/species/vox = /obj/item/weapon/storage/box/survival/engineer/vox,
		/datum/species/grey = /obj/item/weapon/storage/box/survival/engineer,
	)

	pda_type = /obj/item/device/pda/mechanic
	pda_slot = slot_l_store
	id_type = /obj/item/weapon/card/id/engineering

/datum/outfit/cableguy/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/stack/cable_coil)

/datum/outfit/woodidentifier

	outfit_name = "Research Director"
	associated_job = /datum/job/alternate/woodidentifier

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_tox,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/tox,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sci,
			slot_w_uniform_str = /obj/item/clothing/under/rank/research_director,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_wear_suit_str = /obj/item/clothing/suit/storage/labcoat/rd,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sci,
			slot_w_uniform_str = /obj/item/clothing/under/rank/research_director,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/science/rd,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/science/rd,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sci,
			slot_w_uniform_str = /obj/item/clothing/under/rank/research_director,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/science/rd,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/science/rd,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
	)

	race_items_to_collect = list(
		/datum/species/vox/ = list(
			/obj/item/clothing/suit/storage/labcoat/rd,
		),
		/datum/species/plasmaman/ = list(
			/obj/item/clothing/suit/storage/labcoat/rd,
		)
	)

	pda_type = /obj/item/device/pda/toxins
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/research

/datum/outfit/woodidentifier/post_equip(var/mob/living/carbon/human/H)
	..()
	equip_accessory(H, pick(ties), /obj/item/clothing/under)
	H.put_in_hands(new /obj/item/device/analyzer/wood)

/datum/outfit/interiordesigner
	outfit_name = "Interior Designer"
	associated_job = /datum/job/alternate/interiordesigner

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_head_str =  /obj/item/clothing/head/beret,
			),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/librarian,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/librarian,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/librarian,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/librarian,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
		)
	)

	pda_type = /obj/item/device/pda
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/interiordesigner/post_equip(var/mob/living/carbon/human/H)
	..()
	var/obj/item/weapon/folder/red/F = new /obj/item/weapon/folder/red
	F.name = "Design Solutions"
	F.desc = "Stores all design proposals for your happy customers."
	H.put_in_hands(F)

/datum/outfit/sommelier
	outfit_name = "Sommelier"
	associated_job = /datum/job/alternate/sommelier

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_head_str =  /obj/item/clothing/head/beret,
			),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/librarian,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/librarian,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/librarian,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/librarian,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
		)
	)

	pda_type = /obj/item/device/pda
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/sommelier/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/reagent_containers/food/drinks/bottle/pwine)

/datum/outfit/bathroomattendant
	outfit_name = "Bathroom Attendant"
	associated_job = /datum/job/alternate/bathroomattendant

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/really_black,
			slot_wear_suit_str = /obj/item/clothing/suit/wcoat,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_head_str =  /obj/item/clothing/head/beret,
			),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/really_black,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/librarian,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/librarian,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/really_black,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/librarian,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/librarian,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
		)
	)

	pda_type = /obj/item/device/pda
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/bathroomattendant/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/storage/pill_bottle/mint/nano)
	H.put_in_hands(new /obj/item/weapon/reagent_containers/glass/rag)

/datum/outfit/wftr //DEBUG: add sprites
	outfit_name = "Welding Fuel Tank Refiller"
	associated_job = /datum/job/alternate/wftr

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
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/engineer,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_engsci,
			slot_w_uniform_str = /obj/item/clothing/under/rank/mechanic,
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/mechanic,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/complete,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/mechanic,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
		),
	)

	pda_type = /obj/item/device/pda
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/wftr/post_equip(var/mob/living/carbon/human/H)
	..()
	new /obj/structure/reagent_dispensers/fueltank/bulk(get_turf(H))
	H.put_in_hands(new /obj/item/weapon/reagent_containers/glass/bucket)

/datum/outfit/historicalreenactor
	outfit_name = "Historical Reenactor"
	associated_job = /datum/job/alternate/historicalreenactor

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/industrial,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_eng,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/engi,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_head_str = /obj/item/clothing/head/lordadmiralhat,
			slot_wear_suit_str = /obj/item/clothing/suit/lordadmiral,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
		),
	)

	pda_type = /obj/item/device/pda
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/historicalreenactor/post_equip(var/mob/living/carbon/human/H)
	..()
	var/obj/item/toy/gun/G = new /obj/item/toy/gun
	G.name = "reenactment rifle"
	G.desc = "A fake rifle used for historical reenactments."
	G.icon_state = "mosinlarge"
	G.item_state = "mosinlarge"
	H.put_in_hands(G)
	H.put_in_hands(new /obj/item/toy/ammo/gun)
