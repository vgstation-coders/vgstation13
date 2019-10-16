// -- Civilian outfits
// -- Assistants

/datum/outfit/assistant

    outfit_name = "Assistant"

    backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)
    items_to_spawn = list(
		"Default" = list(
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
            slot_w_uniform_str = list(
                "Assistant" = /obj/item/clothing/under/color/grey,
                "Technical Assistant" = /obj/item/clothing/under/color/yellow,
                "Medical Intern" = /obj/item/clothing/under/color/white,
                "Research Assistant" = /obj/item/clothing/under/purple,
                "Security Cadet" = /obj/item/clothing/under/color/red,
            ),
            slot_shoes_str = /obj/item/clothing/shoes/black,
            slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/assistant,
            slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/assistant,
        ),
        /datum/species/vox/ = list(
            slot_w_uniform_str = list(
                "Assistant" = /obj/item/clothing/under/color/grey,
                "Technical Assistant" = /obj/item/clothing/under/color/yellow,
                "Medical Intern" = /obj/item/clothing/under/color/white,
                "Research Assistant" = /obj/item/clothing/under/purple,
                "Security Cadet" = /obj/item/clothing/under/color/red,
            ),
            slot_shoes_str = /obj/item/clothing/shoes/black,
            slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
            slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
        ),
    )

/datum/outfit/assistant/misc_stuff(var/mob/living/carbon/human/H)
    H.put_in_hands(new /obj/item/weapon/storage/bag/plasticbag(H))