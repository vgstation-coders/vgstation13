/datum/outfit/striketeam/syndie_deathsquad
	outfit_name = "Syndie deathsquad"
	use_pref_bag = FALSE

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/security
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/syndicate,
			slot_w_uniform_str = /obj/item/clothing/under/syndicate,
			slot_r_store_str = /obj/item/weapon/melee/energy/sword,
			slot_l_store_str = /obj/item/weapon/grenade/empgrenade,
			slot_shoes_str = /obj/item/clothing/shoes/swat,
			slot_gloves_str = /obj/item/clothing/gloves/swat,
			slot_glasses_str = /obj/item/clothing/glasses/thermal,
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/syndicate_elite,
			slot_wear_mask_str = /obj/item/clothing/mask/gas/syndicate,
			slot_s_store_str = /obj/item/weapon/tank/emergency_oxygen,
			slot_belt_str = /obj/item/weapon/gun/projectile/silenced,
		),
	)

	equip_survival_gear = list(
		/datum/species/human = /obj/item/weapon/storage/box/survival/ert,
	)

	items_to_collect = list(
		/obj/item/weapon/storage/box,
		/obj/item/ammo_storage/box/c45,
		/obj/item/weapon/storage/firstaid/regular,
		/obj/item/weapon/c4,
		/obj/item/osipr_core,
		/obj/item/weapon/gun/osipr,
	)

	implant_types = list(
		/obj/item/weapon/implant/explosive/nuclear,
	)

	id_type = /obj/item/weapon/card/id/syndicate/commando
	id_type_leader = /obj/item/weapon/card/id/syndicate/commando
	assignment_leader = "Syndicate Commando"
	assignment_member = "Syndicate Commando"

/datum/outfit/striketeam/syndie_deathsquad/pre_equip(var/mob/living/carbon/human/H)
	if (is_leader)
		items_to_collect += /obj/item/weapon/disk/nuclear
		items_to_collect += /obj/item/weapon/pinpointer
	else
		items_to_collect += /obj/item/weapon/c4
		items_to_collect += /obj/item/energy_magazine/osipr

/datum/outfit/striketeam/syndie_deathsquad/post_equip(var/mob/living/carbon/human/H)
	..()
	equip_accessory(H, /obj/item/clothing/accessory/holomap_chip/elite,  /obj/item/clothing/under, 5)
	var/obj/item/clothing/suit/space/rig/R = H.wear_suit
	R.toggle_suit()
