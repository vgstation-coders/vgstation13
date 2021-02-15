/datum/outfit/striketeam/death_commando

	outfit_name = "Death Commando"

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
			slot_w_uniform_str = /obj/item/clothing/under/rank/centcom_officer,
			slot_shoes_str = /obj/item/clothing/shoes/magboots/deathsquad,
			slot_gloves_str = /obj/item/clothing/gloves/combat,
			slot_glasses_str = /obj/item/clothing/glasses/thermal,
			slot_ears_str = /obj/item/device/radio/headset/deathsquad,
			slot_belt_str = /obj/item/weapon/gun/energy/pulse_rifle,
			slot_wear_mask_str = /obj/item/clothing/mask/gas/swat,
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/deathsquad,
			slot_s_store_str = /obj/item/weapon/tank/emergency_oxygen/double,
		)
	)

	id_type_leader = /obj/item/weapon/card/id/death_commando_leader
	id_type = /obj/item/weapon/card/id/death_commando
	assignment_leader = "Death Commander"
	assignment_member = "Death Commando"

/datum/outfit/striketeam/death_commando/pre_equip(var/mob/living/carbon/human/H)
	if (is_leader)
		items_to_collect += /obj/item/weapon/disk/nuclear
	else
		items_to_collect += /obj/item/weapon/c4
	return ..()

/datum/outfit/striketeam/death_commando/post_equip(var/mob/living/carbon/human/H)
	..()
	// Accesories.
	equip_accessory(H, /obj/item/clothing/accessory/holster/handgun/preloaded/mateba, /obj/item/clothing/under, 5)
	equip_accessory(H, /obj/item/clothing/accessory/holster/knife/boot/preloaded/energysword, /obj/item/clothing/shoes, 5)
	var/obj/item/clothing/suit/space/rig/R = H.wear_suit
	R.toggle_suit()
