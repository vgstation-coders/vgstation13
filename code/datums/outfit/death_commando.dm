/datum/outfit/death_commando

    var/is_leader = FALSE

    backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/security,
	)

    items_to_collect = list(
        /obj/item/weapon/storage/box,
        /obj/item/ammo_storage/speedloader/a357,
        /obj/item/weapon/storage/firstaid/regular,
        /obj/item/weapon/pinpointer,
        /obj/item/weapon/shield/energy,
    )

    implant_types = list(
        /obj/item/weapon/implant/loyalty,
        /obj/item/weapon/implant/explosive/nuclear,
    )

    use_pref_bag = FALSE // All commandos have the same backbag for uniformity.

    items_to_spawn = list(
		"Default" = list(
            slot_w_uniform_str = list(
                "Death Commando" = /obj/item/clothing/under/deathsquad,
            ),
            slot_shoes_str = /obj/item/clothing/shoes/magboots/deathsquad,
            slot_gloves_str = /obj/item/clothing/gloves/combat,
            slot_glasses_str = /obj/item/clothing/glasses/thermal,
            slot_ears_str = /obj/item/device/radio/headset/deathsquad,
            slot_head_str = /obj/item/clothing/head/helmet/space/rig/deathsquad,
            slot_belt_str = /obj/item/weapon/gun/energy/pulse_rifle,
        )

/datum/outfit/death_commando/pre_equip(var/mob/living/carbon/human/H)
    if (is_leader)
        items_to_collect += /obj/item/weapon/disk/nuclear
    else
        items_to_collect += /obj/item/weapon/plastique

// Custom ID card.
/datum/outfit/death_commando/misc_stuff(var/mob/living/carbon/human/H)
    var/obj/item/weapon/card/id/W = new(H)
	W.name = "[H.real_name]'s ID Card"
	if(is_leader)
		W.access = get_centcom_access("Creed Commander")
		W.icon_state = "creed"
		W.assignment = "Death Commander"
	else
		W.access = get_centcom_access("Death Commando")
		W.icon_state = "deathsquad"
		W.assignment = "Death Commando"
	W.registered_name = H.real_name
	H.equip_to_slot_or_del(W, slot_wear_id)