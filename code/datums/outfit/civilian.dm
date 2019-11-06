// -- Civilian outfits
// -- Assistants

/datum/outfit/assistant

    outfit_name = "Assistant"
    associated_job = /datum/job/assistant

    backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)
    items_to_spawn = list(
		"Default" = list(
            slot_ears_str = /obj/item/device/radio/headset,
            slot_w_uniform_str = list(
                "Assistant" = /obj/item/clothing/under/color/grey,
                "Technical Assistant" = /obj/item/clothing/under/color/yellow,
                "Medical Intern" = /obj/item/clothing/under/color/white,
                "Research Assistant" = /obj/item/clothing/under/purple,
                "Security Cadet" = /obj/item/clothing/under/color/red,
            ),
            slot_shoes_str = /obj/item/clothing/shoes/black,
        ),
        // Same as above, plus some
        /datum/species/plasmaman/ = list(
            slot_ears_str = /obj/item/device/radio/headset,
            slot_w_uniform_str = list(
                "Assistant" = /obj/item/clothing/under/color/grey,
                "Technical Assistant" = /obj/item/clothing/under/color/yellow,
                "Medical Intern" = /obj/item/clothing/under/color/white,
                "Research Assistant" = /obj/item/clothing/under/purple,
                "Security Cadet" = /obj/item/clothing/under/color/red,
            ),
            slot_shoes_str = /obj/item/clothing/shoes/black,
            slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/assistant,
            slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
            slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/assistant,
        ),
        /datum/species/vox/ = list(
            slot_ears_str = /obj/item/device/radio/headset,
            slot_w_uniform_str = list(
                "Assistant" = /obj/item/clothing/under/color/grey,
                "Technical Assistant" = /obj/item/clothing/under/color/yellow,
                "Medical Intern" = /obj/item/clothing/under/color/white,
                "Research Assistant" = /obj/item/clothing/under/purple,
                "Security Cadet" = /obj/item/clothing/under/color/red,
            ),
            slot_shoes_str = /obj/item/clothing/shoes/black,
            slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
            slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
            slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
        ),
    )

    pda_type = /obj/item/device/pda
    pda_slot = slot_belt
    id_type = /obj/item/weapon/card/id

/datum/outfit/assistant/post_equip(var/mob/living/carbon/human/H)
    H.put_in_hands(new /obj/item/weapon/storage/bag/plasticbag(H))