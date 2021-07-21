/datum/outfit/striketeam/nt_deathsquad
	outfit_name = "NT deathsquad"
	use_pref_bag = FALSE

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/security
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/deathsquad,
			slot_w_uniform_str = /obj/item/clothing/under/deathsquad,
			slot_shoes_str = /obj/item/clothing/shoes/magboots/deathsquad,
			slot_gloves_str = /obj/item/clothing/gloves/combat,
			slot_glasses_str = /obj/item/clothing/glasses/thermal,
			slot_wear_mask_str = /obj/item/clothing/mask/gas/swat,
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/deathsquad,
			slot_s_store_str = /obj/item/weapon/tank/emergency_oxygen/double,
			slot_belt_str = /obj/item/weapon/gun/energy/pulse_rifle,
		),
	)

	equip_survival_gear = list(
		/datum/species/human = /obj/item/weapon/storage/box/survival/ert,
	)

	items_to_collect = list(
		/obj/item/weapon/storage/box,
		/obj/item/ammo_storage/speedloader/a357,
		/obj/item/weapon/storage/firstaid/regular,
		/obj/item/weapon/pinpointer,
		/obj/item/weapon/shield/energy,
	)

	implant_types = list(
		/obj/item/weapon/implant/loyalty/,
		/obj/item/weapon/implant/explosive/,
	)

	id_type = /obj/item/weapon/card/id/death_commando
	id_type_leader = /obj/item/weapon/card/id/death_commando_leader
	assignment_leader = "Death Commando"
	assignment_member = "Death Commander"

/datum/outfit/striketeam/nt_deathsquad/pre_equip(var/mob/living/carbon/human/H)
	if (is_leader)
		items_to_collect += /obj/item/weapon/disk/nuclear
		items_to_spawn["Default"][slot_w_uniform_str] = /obj/item/clothing/under/rank/centcom_officer/
	else
		items_to_collect += /obj/item/weapon/c4

	var/obj/machinery/camera/camera = new /obj/machinery/camera(H) //Gives all the commandos internals cameras.
	camera.network = list(CAMERANET_CREED)
	camera.c_tag = H.real_name

/datum/outfit/striketeam/nt_deathsquad/post_equip(var/mob/living/carbon/human/H)
	..()
	if (is_leader)
		equip_accessory(H, /obj/item/clothing/accessory/holomap_chip/deathsquad,  /obj/item/clothing/under, 5)
	equip_accessory(H, /obj/item/clothing/accessory/holster/handgun/preloaded/mateba, /obj/item/clothing/under, 5)
	equip_accessory(H, /obj/item/clothing/accessory/holster/knife/boot/preloaded/energysword, /obj/item/clothing/shoes, 5)
	var/obj/item/clothing/suit/space/rig/R = H.wear_suit
	R.toggle_suit()
