/datum/outfit/striketeam/voxraider

	outfit_name = "Vox Raider"
	use_pref_bag = FALSE // Voxes are too poor for backbags :(

	specs = list(
		"Raider" = list(
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/carapace,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/carapace,
			slot_belt_str = /obj/item/weapon/melee/telebaton,
			slot_glasses_str = /obj/item/clothing/glasses/hud/thermal/monocle,
			slot_l_store_str = /obj/item/device/chameleon,
		),
		"Engineer" = list(
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/pressure,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/pressure,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/full,
			slot_glasses_str = /obj/item/clothing/glasses/scanner/meson,
		),
		"Saboteur" = list(
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/carapace,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/carapace,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/full,
			slot_glasses_str = /obj/item/clothing/glasses/hud/thermal/monocle,
			slot_l_store_str = /obj/item/weapon/card/emag,
			ACCESORY_ITEM = list(/obj/item/weapon/gun/dartgun/vox/raider, /obj/item/device/multitool),
		),
		"Medic" = list(
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/pressure,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/pressure,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/full,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_l_store_str = /obj/item/tool/circular_saw,
			ACCESORY_ITEM = /obj/item/weapon/gun/dartgun/vox/medical,
		)
	)

	items_to_spawn = list(
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/raider/pretuned,
			slot_w_uniform_str = /obj/item/clothing/under/vox/vox_robes,
			slot_shoes_str = /obj/item/clothing/shoes/magboots/vox,
			slot_gloves_str = /obj/item/clothing/gloves/yellow/vox,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
			slot_back_str = /obj/item/weapon/tank/nitrogen,
			slot_r_store_str = /obj/item/device/flashlight,
		)
	)

	assignment_leader = "Trader"
	assignment_member = "Trader"
	id_type = /obj/item/weapon/card/id/syndicate/raider
	id_type_leader = /obj/item/weapon/card/id/syndicate/raider

/datum/outfit/striketeam/voxraider/equip_backbag(var/mob/living/carbon/human/H)
	return FALSE

/datum/outfit/striketeam/voxraider/species_final_equip(var/mob/living/carbon/human/H)
	return FALSE

/datum/outfit/striketeam/voxraider/spawn_id(var/mob/living/carbon/human/H, rank)
	var/obj/item/weapon/card/id/W = ..()
	var/obj/item/weapon/storage/wallet/Wal = new(H)
	Wal.handle_item_insertion(W)
	H.equip_to_slot_or_del(Wal, slot_wear_id)

/datum/outfit/striketeam/voxraider/post_equip(var/mob/living/carbon/human/H)
	..()
	// Accesories.
	equip_accessory(H, /obj/item/clothing/accessory/holomap_chip/raider, /obj/item/clothing/under, 5)


	if (chosen_spec == "Raider")
		var/obj/item/weapon/crossbow/W = new(H)
		W.cell = new /obj/item/weapon/cell/crap(W)
		W.cell.charge = 500
		H.put_in_hands(W)

		var/obj/item/stack/rods/A = new(src)
		A.amount = 20
		H.put_in_hands(A)

	else
		var/obj/item/weapon/paper/vox_paper/VP = new(src)
		VP.initialize()
		H.put_in_hands(VP)
