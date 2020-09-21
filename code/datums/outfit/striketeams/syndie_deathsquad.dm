/datum/outfit/striketeam/syndie_deathsquad
	outfit_name = "Syndie deathsquad"
	use_pref_bag = FALSE

	backpack_types = list(
		BACKPACK_STRING = /obj/item/storage/backpack/security
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/syndicate,
			slot_w_uniform_str = /obj/item/clothing/under/syndicate,
			slot_r_store_str = /obj/item/melee/energy/sword,
			slot_l_store_str = /obj/item/grenade/empgrenade,
			slot_shoes_str = /obj/item/clothing/shoes/swat,
			slot_gloves_str = /obj/item/clothing/gloves/swat,
			slot_glasses_str = /obj/item/clothing/glasses/thermal,
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/syndicate_elite,
			slot_wear_mask_str = /obj/item/clothing/mask/gas/syndicate,
			slot_s_store_str = /obj/item/tank/emergency_oxygen,
			slot_belt_str = /obj/item/gun/projectile/silenced,
		),
	)

	equip_survival_gear = list(
		"Default" = /obj/item/storage/box/survival/ert,
	)

	items_to_collect = list(
		/obj/item/storage/box,
		/obj/item/ammo_storage/box/c45,
		/obj/item/storage/firstaid/regular,
		/obj/item/c4,
		/obj/item/osipr_core,
		/obj/item/gun/osipr,
	)

	implant_types = list(
		/obj/item/implant/explosive/,
	)

	id_type = /obj/item/card/id/syndicate/commando
	id_type_leader = /obj/item/card/id/syndicate/commando
	assignment_leader = "Syndicate Commando"
	assignment_member = "Syndicate Commando"

/datum/outfit/striketeam/syndie_deathsquad/pre_equip(var/mob/living/carbon/human/H)
	if (is_leader)
		items_to_collect += /obj/item/disk/nuclear
		items_to_collect += /obj/item/pinpointer
	else
		items_to_collect += /obj/item/c4
		items_to_collect += /obj/item/energy_magazine/osipr

/datum/outfit/striketeam/syndie_deathsquad/post_equip(var/mob/living/carbon/human/H)
	..()
	equip_accessory(H, /obj/item/clothing/accessory/holomap_chip/elite,  /obj/item/clothing/under, 5)
	var/obj/item/clothing/suit/space/rig/R = H.wear_suit
	R.toggle_suit()
