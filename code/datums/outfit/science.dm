// -- Science outfits
// -- RD

/datum/outfit/rd

	outfit_name = "Research Director"
	associated_job = /datum/job/rd

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_tox,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/tox,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/rd,
			slot_w_uniform_str = /obj/item/clothing/under/rank/research_director,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_wear_suit_str = /obj/item/clothing/suit/storage/labcoat/rd,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/rd,
			slot_w_uniform_str = /obj/item/clothing/under/rank/research_director,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/science/rd,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/science/rd,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/rd,
			slot_w_uniform_str = /obj/item/clothing/under/rank/research_director,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/science/rd,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/science/rd,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
	)


	implant_types = list(
		/obj/item/weapon/implant/loyalty/,
	)

	pda_type = /obj/item/device/pda/heads/rd
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/rd

/datum/outfit/rd/post_equip(var/mob/living/carbon/human/H)
	..()
	equip_accessory(H, pick(ties), /obj/item/clothing/under)
	H.put_in_hands(new /obj/item/weapon/storage/bag/clipboard(H))


// -- Scientist

/datum/outfit/scientist

	outfit_name = "Scientist"
	associated_job = /datum/job/scientist

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_tox,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/tox,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = list(
				"Scientist" = /obj/item/device/radio/headset/headset_sci,
				"Plasma Researcher" = /obj/item/device/radio/headset/headset_sci,
				"Xenobiologist" = /obj/item/device/radio/headset/headset_sci,
				"Anomalist" = /obj/item/device/radio/headset/headset_sci,
				"Xenoarcheologist" = /obj/item/device/radio/headset/headset_sci,
				"Research Botanist" = /obj/item/device/radio/headset/headset_servsci,
			),
			slot_w_uniform_str = list(
				"Scientist" = /obj/item/clothing/under/rank/scientist,
				"Plasma Researcher" =  /obj/item/clothing/under/rank/plasmares,
				"Xenobiologist" = /obj/item/clothing/under/rank/xenobio,
				"Anomalist" =  /obj/item/clothing/under/rank/anomalist,
				"Xenoarcheologist" = /obj/item/clothing/under/rank/xenoarch,
				"Research Botanist" = /obj/item/clothing/under/rank/scientist,
			),
			slot_gloves_str = list(
				"Research Botanist" = /obj/item/clothing/gloves/botanic_leather,
			),
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_wear_suit_str = /obj/item/clothing/suit/storage/labcoat/science,
			slot_s_store_str = list(
				"Research Botanist" = /obj/item/device/analyzer/plant_analyzer,
			),
			slot_l_store_str = list(
				"Xenobiologist" = /obj/item/weapon/storage/bag/xenobio,
			)
		),
		/datum/species/plasmaman = list(
			slot_ears_str = list(
				"Scientist" = /obj/item/device/radio/headset/headset_sci,
				"Plasma Researcher" = /obj/item/device/radio/headset/headset_sci,
				"Xenobiologist" = /obj/item/device/radio/headset/headset_sci,
				"Anomalist" = /obj/item/device/radio/headset/headset_sci,
				"Xenoarcheologist" = /obj/item/device/radio/headset/headset_sci,
				"Research Botanist" = /obj/item/device/radio/headset/headset_servsci,
			),
			slot_w_uniform_str = list(
				"Scientist" = /obj/item/clothing/under/rank/scientist,
				"Plasma Researcher" =  /obj/item/clothing/under/rank/plasmares,
				"Xenobiologist" = /obj/item/clothing/under/rank/xenobio,
				"Anomalist" =  /obj/item/clothing/under/rank/anomalist,
				"Xenoarcheologist" = /obj/item/clothing/under/rank/xenoarch,
				"Research Botanist" = /obj/item/clothing/under/rank/scientist,
			),
			slot_gloves_str = list(
				"Research Botanist" = /obj/item/clothing/gloves/botanic_leather,
			),
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/science,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/science,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
			slot_l_store_str = list(
				"Research Botanist" = /obj/item/device/analyzer/plant_analyzer,
				"Xenobiologist" = /obj/item/weapon/storage/bag/xenobio,
			)
		),
		/datum/species/vox = list(
			slot_ears_str = list(
                "Scientist" = /obj/item/device/radio/headset/headset_sci,
                "Plasma Researcher" = /obj/item/device/radio/headset/headset_sci,
                "Xenobiologist" = /obj/item/device/radio/headset/headset_sci,
                "Anomalist" = /obj/item/device/radio/headset/headset_sci,
                "Xenoarcheologist" = /obj/item/device/radio/headset/headset_sci,
                "Research Botanist" = /obj/item/device/radio/headset/headset_servsci,
            ),
			slot_w_uniform_str = list(
				"Scientist" = /obj/item/clothing/under/rank/scientist,
				"Plasma Researcher" =  /obj/item/clothing/under/rank/plasmares,
				"Xenobiologist" = /obj/item/clothing/under/rank/xenobio,
				"Anomalist" =  /obj/item/clothing/under/rank/anomalist,
				"Xenoarcheologist" = /obj/item/clothing/under/rank/xenoarch,
				"Research Botanist" = /obj/item/clothing/under/rank/scientist,
			),
			slot_gloves_str = list(
				"Research Botanist" = /obj/item/clothing/gloves/botanic_leather,
			),
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/science,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/science,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
			slot_l_store_str = list(
				"Research Botanist" = /obj/item/device/analyzer/plant_analyzer,
				"Xenobiologist" = /obj/item/weapon/storage/bag/xenobio,
			)
		),
	)

	pda_type = /obj/item/device/pda/toxins
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/research

/datum/outfit/scientist/post_equip(var/mob/living/carbon/human/H)
	..()
	equip_accessory(H, pick(ties), /obj/item/clothing/under)

// -- Roboticist

/datum/outfit/roboticist

	outfit_name = "Roboticist"
	associated_job = /datum/job/roboticist

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_tox,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/tox,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sci,
			slot_w_uniform_str = list(
				"Roboticist" = /obj/item/clothing/under/rank/roboticist,
				"Mechatronic Engineer" = /obj/item/clothing/under/rank/mechatronic,
				"Biomechanical Engineer" = /obj/item/clothing/under/rank/biomechanical,
			),
			slot_belt_str = /obj/item/weapon/storage/belt/utility/complete,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/storage/labcoat,

		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sci,
			slot_w_uniform_str = list(
				"Roboticist" = /obj/item/clothing/under/rank/roboticist,
				"Mechatronic Engineer" = /obj/item/clothing/under/rank/mechatronic,
				"Biomechanical Engineer" = /obj/item/clothing/under/rank/biomechanical,
			),
			slot_belt_str = /obj/item/weapon/storage/belt/utility/complete,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/science,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/science,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_sci,
			slot_w_uniform_str = list(
				"Roboticist" = /obj/item/clothing/under/rank/roboticist,
				"Mechatronic Engineer" = /obj/item/clothing/under/rank/mechatronic,
				"Biomechanical Engineer" = /obj/item/clothing/under/rank/biomechanical,
			),
			slot_belt_str = /obj/item/weapon/storage/belt/utility/complete,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/science/roboticist,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/science/roboticist,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
	)

	pda_type = /obj/item/device/pda/roboticist
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/research

/datum/outfit/roboticist/post_equip(var/mob/living/carbon/human/H)
	..()
	equip_accessory(H, pick(ties), /obj/item/clothing/under)

/datum/outfit/roboticist/pre_equip_priority(var/mob/living/carbon/human/H, var/species)
	items_to_collect[/obj/item/device/flash/synthetic] = SURVIVAL_BOX
	return ..()
