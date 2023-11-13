/datum/outfit/special
	use_pref_bag = FALSE
	give_disabilities_equipment = TRUE
	equip_survival_gear = FALSE

// No id in most cases.
/datum/outfit/special/spawn_id()
	return

// -- Special outfits --

// ----- RIGSUITS

/datum/outfit/special/rig

/datum/outfit/special/rig/post_equip(var/mob/living/carbon/human/H)
	..()
	var/obj/item/clothing/suit/space/rig/R = H.wear_suit
	R.toggle_suit()

/datum/outfit/special/rig/gemsuit
	outfit_name = "Wizard Gemsuit"
	items_to_spawn = list(
		"Default" = list(
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/wizard,
			slot_gloves_str = /obj/item/clothing/gloves/purple,
			slot_shoes_str = /obj/item/clothing/shoes/sandal,
		),
	)

/datum/outfit/special/rig/nazi_rig
	outfit_name = "Nazi rigsuit"
	items_to_spawn = list(
		"Default" = list(
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/nazi,
		),
	)

/datum/outfit/special/rig/soviet_rig
	outfit_name = "Soviet rigsuit"
	items_to_spawn = list(
		"Default" = list(
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/soviet,
		),
	)

/datum/outfit/special/rig/engineer_rig
	outfit_name = "Engineer rig suit"
	items_to_spawn = list(
		"Default" = list(
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/engineer,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
			slot_s_store_str = /obj/item/weapon/tank/jetpack/oxygen,
		),
	)

/datum/outfit/special/rig/ce_rig
	outfit_name = "Chief engineer rig suit"
	items_to_spawn = list(
		"Default" = list(
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/engineer/elite,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
			slot_s_store_str = /obj/item/weapon/tank/jetpack/oxygen,
		),
	)

/datum/outfit/special/rig/mining_rig
	outfit_name = "Chief engineer rig suit"
	items_to_spawn = list(
		"Default" = list(
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/mining,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
			slot_s_store_str = /obj/item/weapon/tank/jetpack/oxygen,
		),
	)

/datum/outfit/special/rig/mining_rig
	outfit_name = "Syndie rig suit"
	items_to_spawn = list(
		"Default" = list(
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/syndi,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
			slot_s_store_str = /obj/item/weapon/tank/jetpack/oxygen,
		),
	)

/datum/outfit/special/rig/medical_rig
	outfit_name = "Medical rig suit"
	items_to_spawn = list(
		"Default" = list(
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/medical,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
			slot_s_store_str = /obj/item/weapon/tank/jetpack/oxygen,
		),
	)

/datum/outfit/special/rig/atmos_rig
	outfit_name = "Atmos rig suit"
	items_to_spawn = list(
		"Default" = list(
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/atmos,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
			slot_s_store_str = /obj/item/weapon/tank/jetpack/oxygen,
		),
	)

// ----- Other suits

/datum/outfit/special/dreed_gear
	outfit_name = "Judge Dreed"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/darkred,
			slot_glasses_str = /obj/item/clothing/glasses/hud/security,
			slot_gloves_str = /obj/item/clothing/gloves/combat,
			slot_shoes_str = /obj/item/clothing/shoes/combat,
			slot_head_str = /obj/item/clothing/head/helmet/dredd,
			slot_wear_mask_str = /obj/item/clothing/mask/gas/swat,
			slot_belt_str = /obj/item/weapon/storage/belt/security,
			slot_wear_suit_str = /obj/item/clothing/suit/armor/dredd,
			slot_s_store_str = /obj/item/weapon/gun/lawgiver,
		),
	)

/datum/outfit/special/standard_space_rig
	outfit_name = "Standard space rig suit"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_wear_suit_str = /obj/item/clothing/suit/space,
			slot_head_str = /obj/item/clothing/head/helmet/space,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
			slot_s_store_str = /obj/item/weapon/tank/jetpack/oxygen,
		),
	//Maybe replace with civilian rig whenever that becomes a truely unique rig.
	)

// ----- THUNDERDOME TOURNAMENT

/datum/outfit/special/tournament_standard_red
	outfit_name = "Tournament standard red"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/color/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/armor/vest,
			slot_head_str = /obj/item/clothing/head/helmet/thunderdome,
			slot_s_store_str = /obj/item/weapon/gun/energy/pulse_rifle/destroyer,
			slot_r_store_str = /obj/item/weapon/grenade/smokebomb,
		)
	)

/datum/outfit/special/tournament_standard_red/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/grenade/smokebomb(H))

/datum/outfit/special/tournament_standard_green
	outfit_name = "Tournament standard red"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/color/green,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/armor/vest,
			slot_head_str = /obj/item/clothing/head/helmet/thunderdome,
			slot_s_store_str = /obj/item/weapon/gun/energy/pulse_rifle/destroyer,
			slot_r_store_str = /obj/item/weapon/grenade/smokebomb,
		)
	)

/datum/outfit/special/tournament_standard_green/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/grenade/smokebomb(H))

/datum/outfit/special/tournament_gangster
	outfit_name = "Tournament gangster"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/det,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/storage/det_suit,
			slot_head_str = /obj/item/clothing/head/det_hat,
			slot_s_store_str = /obj/item/weapon/gun/projectile,
			slot_r_store_str = /obj/item/weapon/cloaking_device,
			slot_glasses_str = /obj/item/clothing/glasses/thermal/monocle,
		)
	)

/datum/outfit/special/tournament_chef
	outfit_name = "Tournament chef"
	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/rank/chef,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/chef,
			slot_head_str = /obj/item/clothing/head/chefhat,
		)
	)
	items_to_collect = list(
		/obj/item/weapon/kitchen/utensil/knife/large,
		/obj/item/weapon/kitchen/utensil/knife/large,
		/obj/item/weapon/kitchen/utensil/knife/large,
	)

/datum/outfit/special/tournament_chef/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/kitchen/utensil/knife/large(H))

/datum/outfit/special/tournament_janitor
	outfit_name = "Tournament janitor"
	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/rank/janitor,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_r_store_str = /obj/item/weapon/grenade/chem_grenade/cleaner,
			slot_l_store_str = /obj/item/weapon/grenade/chem_grenade/cleaner,
		)
	)
	items_to_collect = list(
		/obj/item/stack/tile/metal,
		/obj/item/stack/tile/metal,
		/obj/item/stack/tile/metal,
		/obj/item/stack/tile/metal,
		/obj/item/stack/tile/metal,
		/obj/item/stack/tile/metal,
		/obj/item/weapon/reagent_containers/glass/bucket/water_filled,
	)

/datum/outfit/special/tournament_janitor/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/mop(H))

// ----- MISC FLAVOR THINGS

/datum/outfit/special/pirate
	outfit_name = "Pirate"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/pirate,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_head_str = /obj/item/clothing/head/bandana,
			slot_glasses_str = /obj/item/clothing/glasses/eyepatch,
		)
	)

/datum/outfit/special/pirate/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/melee/energy/sword/pirate(H))

/datum/outfit/special/piratealt //no weapon & slightly different clothing
	outfit_name = "Pirate Alternative"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/pirate,
			slot_shoes_str = /obj/item/clothing/shoes/workboots,
			slot_head_str = /obj/item/clothing/head/pirate,
			slot_glasses_str = /obj/item/clothing/glasses/eyepatch,
		)
	)

/datum/outfit/special/piratealt/equip_backbag(var/mob/living/carbon/human/H)
	return FALSE

/datum/outfit/special/space_pirate
	outfit_name = "Space Pirate"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/pirate,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_head_str = /obj/item/clothing/head/helmet/space/pirate,
			slot_glasses_str = /obj/item/clothing/glasses/eyepatch,
			slot_wear_suit_str = /obj/item/clothing/suit/space/pirate,
		)
	)

/datum/outfit/special/space_pirate/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/melee/energy/sword/pirate(H))

/datum/outfit/special/rune_knight
	outfit_name = "Rune knight"
	items_to_spawn = list(
		"Default" = list(
			slot_head_str = /obj/item/clothing/head/helmet/rune,
			slot_wear_suit_str = /obj/item/clothing/suit/armor/rune,
		)
	)

/datum/outfit/special/rune_knight/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/rsscimmy(src))
	H.put_in_hands(new /obj/item/weapon/shield/riot/rune(src))

/datum/outfit/special/soviet_soldier
	outfit_name = "Soviet soldier"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/soviet,
			slot_head_str = /obj/item/clothing/head/ushanka,
			slot_shoes_str = /obj/item/clothing/shoes/black,
		)
	)

/datum/outfit/special/masked_killer
	outfit_name = "Masked killer"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/overalls,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_gloves_str = /obj/item/clothing/gloves/latex,
			slot_head_str = /obj/item/clothing/head/welding,
			slot_ears_str = /obj/item/device/radio/headset,
			slot_glasses_str = /obj/item/clothing/glasses/thermal/monocle,
			slot_wear_suit_str = /obj/item/clothing/suit/apron,
			slot_wear_mask_str = /obj/item/clothing/mask/surgical,
			slot_l_store_str = /obj/item/tool/scalpel,
		),
	)

/datum/outfit/special/masked_killer/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/fireaxe(H))
	H.put_in_hands(new /obj/item/weapon/kitchen/utensil/knife/large(H))
	for (var/obj/item/I in H) // Everything is bloody
		I.add_blood(H)

// ----- Outfit with IDS

/datum/outfit/special/with_id/spawn_id(var/mob/living/carbon/human/H, rank)
	var/obj/item/weapon/card/id/W
	W = new id_type(get_turf(H))
	W.name = "[H.real_name]'s ID Card"
	W.registered_name = H.real_name
	W.UpdateName()
	W.SetOwnerDNAInfo(H)
	H.equip_to_slot_or_drop(W, slot_wear_id)
	if (pda_type)
		var/obj/item/device/pda/pda = new pda_type(H)
		pda.owner = H.real_name
		pda.name = "PDA-[H.real_name]"
		H.equip_or_collect(pda, pda_slot)
	return W

/datum/outfit/special/with_id/tunnel_clown
	outfit_name = "Tunnel clown"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/rank/clown,
			slot_shoes_str = /obj/item/clothing/shoes/clown_shoes,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_ears_str = /obj/item/device/radio/headset,
			slot_glasses_str = /obj/item/clothing/glasses/thermal/monocle,
			slot_wear_suit_str = /obj/item/clothing/suit/chaplain_hoodie,
			slot_r_store_str = /obj/item/weapon/bikehorn,
		),
	)
	id_type = /obj/item/weapon/card/id/tunnel_clown

/datum/outfit/special/with_id/tunnel_clown/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/fireaxe(H))
	H.put_in_hands(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H))

/datum/outfit/special/with_id/assassin
	outfit_name = "Assassin"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_gloves_str = /obj/item/clothing/gloves/black,
			slot_ears_str = /obj/item/device/radio/headset,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
			slot_wear_suit_str = /obj/item/clothing/suit/wcoat,
			slot_r_store_str = /obj/item/weapon/melee/energy/sword,
			slot_l_store_str = /obj/item/tool/scalpel,
		),
	)
	pda_type = /obj/item/device/pda/heads/assassin
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/syndicate/assassin

/datum/outfit/special/with_id/nt_rep
	outfit_name = "Nanotrasen representative"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/rank/centcom/representative,
			slot_shoes_str = /obj/item/clothing/shoes/centcom,
			slot_gloves_str = /obj/item/clothing/gloves/white,
			slot_ears_str = /obj/item/device/radio/headset/heads/hop,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
		),
	)
	pda_type = /obj/item/device/pda/heads/nt_rep
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/nt_rep

/datum/outfit/special/with_id/nt_rep/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/storage/bag/clipboard(H))

/datum/outfit/special/with_id/nt_officer
	outfit_name = "Nanotrasen officer"
	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/satchel,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/rank/centcom/officer,
			slot_shoes_str = /obj/item/clothing/shoes/centcom,
			slot_gloves_str = /obj/item/clothing/gloves/white,
			slot_ears_str = /obj/item/device/radio/headset/heads/captain,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
			slot_head_str = /obj/item/clothing/head/beret/centcom/officer,
		),
	)
	items_to_collect = list(
		/obj/item/weapon/gun/energy,
	)
	pda_type = /obj/item/device/pda/heads/nt_officer
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/centcom/nt_officer


/datum/outfit/special/with_id/nt_captain
	outfit_name = "Nanotrasen captain"
	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/satchel,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/rank/centcom/captain,
			slot_shoes_str = /obj/item/clothing/shoes/centcom,
			slot_gloves_str = /obj/item/clothing/gloves/white,
			slot_ears_str = /obj/item/device/radio/headset/heads/captain,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
			slot_head_str = /obj/item/clothing/head/beret/centcom/captain,
		),
	)
	items_to_collect = list(
		/obj/item/weapon/gun/energy,
	)
	pda_type = /obj/item/device/pda/heads/nt_captain
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/centcom/nt_officer

/datum/outfit/special/with_id/nt_supreme_commander
	outfit_name = "Nanotrasen captain"
	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/satchel,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/rank/centcom/captain,
			slot_shoes_str = /obj/item/clothing/shoes/centcom,
			slot_gloves_str = /obj/item/clothing/gloves/centcom,
			slot_ears_str = /obj/item/device/radio/headset/heads/captain,
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
			slot_head_str = /obj/item/clothing/head/centhat,
			slot_wear_suit_str = /obj/item/clothing/suit/space/rig/centcomm,
		),
	)
	items_to_collect = list(
		/obj/item/weapon/gun/energy/laser/captain,
	)
	pda_type = /obj/item/device/pda/heads/nt_supreme
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/centcom/nt_supreme

/datum/outfit/special/with_id/spec_ops_officer
	outfit_name = "Special ops officer"
	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/satchel,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/syndicate/combat,
			slot_shoes_str = /obj/item/clothing/shoes/combat,
			slot_gloves_str = /obj/item/clothing/gloves/combat,
			slot_ears_str = /obj/item/device/radio/headset/heads/captain,
			slot_glasses_str = /obj/item/clothing/glasses/thermal/eyepatch,
			slot_head_str = /obj/item/clothing/head/beret/centcom, // the duality of man
			slot_wear_suit_str = /obj/item/clothing/suit/armor/swat/officer,
			slot_wear_mask_str = /obj/item/clothing/mask/cigarette/cigar/havana,
			slot_r_store_str = /obj/item/weapon/lighter/zippo,
		),
	)
	items_to_collect = list(
		/obj/item/weapon/gun/energy/pulse_rifle/M1911,
	)
	id_type = /obj/item/weapon/card/id/special_operations

/datum/outfit/special/with_id/soviet_admiral
	outfit_name = "Soviet admiral officer"
	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/satchel,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/soviet,
			slot_shoes_str = /obj/item/clothing/shoes/combat,
			slot_gloves_str = /obj/item/clothing/gloves/combat,
			slot_ears_str = /obj/item/device/radio/headset/heads/captain,
			slot_glasses_str = /obj/item/clothing/glasses/thermal/eyepatch,
			slot_head_str = /obj/item/clothing/head/hgpiratecap,
			slot_wear_suit_str = /obj/item/clothing/suit/hgpirate,
			slot_wear_mask_str = /obj/item/clothing/mask/cigarette/cigar/havana,
			slot_r_store_str = /obj/item/weapon/lighter/zippo,
		),
	)
	items_to_collect = list(
		/obj/item/weapon/gun/projectile/mateba,
	)
	id_type = /obj/item/weapon/card/id/soviet_admiral

// ----- Space hobo

/datum/outfit/special/with_id/hobo

	outfit_name = "Space Hobo"

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_shoes_str = /obj/item/clothing/shoes/magboots,
			slot_glasses_str = /obj/item/clothing/glasses/scanner/meson,
			slot_belt_str = /obj/item/weapon/pickaxe,
            slot_wear_suit_str = /obj/item/clothing/suit/space/ghettorig/hobo,
            slot_head_str = /obj/item/clothing/head/helmet/space/ghetto/hobo,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/vox = list(
			slot_w_uniform_str =/obj/item/clothing/under/vox/vox_robes,
			slot_shoes_str = /obj/item/clothing/shoes/magboots/vox,
			slot_glasses_str = /obj/item/clothing/glasses/scanner/meson,
			slot_belt_str = /obj/item/weapon/pickaxe,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
		/datum/species/mushroom = list(
			slot_w_uniform_str = /obj/item/clothing/under/stilsuit,
			slot_shoes_str = /obj/item/clothing/shoes/magboots,
			slot_glasses_str = /obj/item/clothing/glasses/scanner/meson,
			slot_belt_str = /obj/item/weapon/pickaxe,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/trader/flex,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/trader/flex,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/tajaran = list(
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_shoes_str = /obj/item/clothing/shoes/sandal/catbeast,
			slot_glasses_str = /obj/item/clothing/glasses/scanner/meson,
			slot_belt_str = /obj/item/weapon/pickaxe,
            slot_wear_suit_str = /obj/item/clothing/suit/space/ghettorig/hobo,
            slot_head_str = /obj/item/clothing/head/helmet/space/ghetto/hobo,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/unathi = list(
			slot_w_uniform_str = /obj/item/clothing/under/color/grey,
			slot_glasses_str = /obj/item/clothing/glasses/scanner/meson,
			slot_belt_str = /obj/item/weapon/pickaxe,
            slot_wear_suit_str = /obj/item/clothing/suit/space/ghettorig/hobo,
            slot_head_str = /obj/item/clothing/head/helmet/space/ghetto/hobo,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
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

	pda_type = null
	id_type = /obj/item/weapon/card/id/hobo

// ----- Antags

/datum/outfit/special/bomberman
	outfit_name = "Bomberman"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str =/obj/item/clothing/under/darkblue,
			slot_shoes_str = /obj/item/clothing/shoes/purple,
			slot_gloves_str = /obj/item/clothing/gloves/purple,
			slot_head_str = /obj/item/clothing/head/helmet/space/bomberman,
			slot_wear_suit_str = /obj/item/clothing/suit/space/bomberman,
			slot_s_store_str = /obj/item/weapon/bomberman,
		),
	)

/datum/outfit/special/bomberman/arena
	outfit_name = "Arena bomberman"

/datum/outfit/special/bomberman/arena/post_equip(var/mob/living/carbon/human/H)
	..()
	for(var/obj/item/clothing/C in H)
		C.canremove = 0
		if(istype(C, /obj/item/clothing/suit/space/bomberman))
			var/obj/item/clothing/suit/space/bomberman/B = C
			B.slowdown = HARDSUIT_SLOWDOWN_LOW
	var/list/randomhexes = list("7","8","9","a","b","c","d","e","f",)
	H.color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
	H.name = "Bomberman #[rand(1,999)]"
	H.mind.special_role = BOMBERMAN // NEEDED FOR CHEAT CHECKS!

// Wizards

/datum/outfit/special/wizard
	equip_survival_gear = list() // Default survival gear
	use_pref_bag = TRUE
	var/apprentice = FALSE // Apprentice wiz?
	outfit_name = "Blue wizard"
	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str =/obj/item/clothing/under/lightpurple,
			slot_shoes_str = /obj/item/clothing/shoes/sandal,
			slot_head_str = /obj/item/clothing/head/wizard,
			slot_wear_suit_str = /obj/item/clothing/suit/wizrobe,
			slot_ears_str = /obj/item/device/radio/headset,
		),
	)

/datum/outfit/special/wizard/post_equip(var/mob/living/carbon/human/H)
	..()
	disable_suit_sensors(H)
	if(!apprentice)
		H.put_in_hands(new /obj/item/weapon/teleportation_scroll(H))
		H.put_in_hands(new /obj/item/weapon/spellbook(H))
	else
		H.put_in_hands(new /obj/item/weapon/teleportation_scroll/apprentice(H))
	H.equip_to_slot_or_del(new /obj/item/weapon/hair_dye/skin_dye(H), slot_in_backpack)

/datum/outfit/special/wizard/red
	outfit_name = "Red wizard"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str =/obj/item/clothing/under/lightpurple,
			slot_shoes_str = /obj/item/clothing/shoes/sandal,
			slot_head_str = /obj/item/clothing/head/wizard/red,
			slot_wear_suit_str = /obj/item/clothing/suit/wizrobe/red,
			slot_ears_str = /obj/item/device/radio/headset,
		),
	)

/datum/outfit/special/wizard/marisa
	outfit_name = "Marisa wizard"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str =/obj/item/clothing/under/lightpurple,
			slot_shoes_str = /obj/item/clothing/shoes/sandal/marisa,
			slot_head_str = /obj/item/clothing/head/wizard/marisa,
			slot_wear_suit_str = /obj/item/clothing/suit/wizrobe/marisa,
			slot_ears_str = /obj/item/device/radio/headset,
			slot_r_store_str = /obj/item/weapon/teleportation_scroll,
			slot_l_store_str = /obj/item/weapon/spellbook,
		),
	)


/datum/outfit/special/prisoner
	equip_survival_gear = list() //no backpack, no gear
	outfit_name = "Prisoner"
	use_pref_bag = FALSE
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/color/prisoner,
			slot_shoes_str = /obj/item/clothing/shoes/orange,
			slot_ears_str = /obj/item/device/radio/headset,
			slot_head_str = /obj/item/clothing/head/beanie/black,
		),
		/datum/species/plasmaman = list(
			slot_w_uniform_str = /obj/item/clothing/under/color/prisoner,
			slot_shoes_str = /obj/item/clothing/shoes/orange,
			slot_ears_str = /obj/item/device/radio/headset,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/prisoner,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/prisoner,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/color/prisoner,
			slot_shoes_str = /obj/item/clothing/shoes/orange,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
			slot_back_str = /obj/item/weapon/tank/nitrogen,
		),
	)

/datum/outfit/special/prisoner/equip_backbag(var/mob/living/carbon/human/H)
	return FALSE

/datum/outfit/special/prisoneralt //no headset + soap
	outfit_name = "Prisoner Alternative"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/color/prisoner,
			slot_shoes_str = /obj/item/clothing/shoes/orange,
			slot_r_store_str = /obj/item/weapon/soap,
		)
	)

/datum/outfit/special/prisoneralt/equip_backbag(var/mob/living/carbon/human/H)
	return FALSE

/datum/outfit/special/pizzaman
	outfit_name = "Pizza Delivery Guy"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/rank/dispatch,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_head_str = /obj/item/clothing/head/soft/blue,
			slot_r_store_str = /obj/item/weapon/spacecash/c10,
		)
	)

/datum/outfit/special/pizzaman/equip_backbag(var/mob/living/carbon/human/H)
	return FALSE

/datum/outfit/special/pizzaman/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/pizzabox/margherita(H))

/datum/outfit/special/gangster
	outfit_name = "Gangster"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/callum,
			slot_wear_suit_str = /obj/item/clothing/suit/wcoat,
			slot_shoes_str = /obj/item/clothing/shoes/knifeboot,
			slot_head_str = /obj/item/clothing/head/det_hat/noir,
			slot_r_store_str = /obj/item/weapon/switchtool/switchblade,
			slot_wear_mask_str = /obj/item/clothing/mask/cigarette/cigar,
		)
	)

/datum/outfit/special/gangster/equip_backbag(var/mob/living/carbon/human/H)
	return FALSE

/datum/outfit/special/roman
	outfit_name = "Roman"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/roman,
			slot_shoes_str = /obj/item/clothing/shoes/roman,
			slot_head_str = /obj/item/clothing/head/helmet/roman/legionaire,
			slot_r_store_str = /obj/item/weapon/coin/gold,
		)
	)

/datum/outfit/special/roman/equip_backbag(var/mob/living/carbon/human/H)
	return FALSE

/datum/outfit/special/samurai
	outfit_name = "Samurai"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/color/black,
			slot_shoes_str = /obj/item/clothing/shoes/sandal,
			slot_wear_suit_str = /obj/item/clothing/suit/armor/samurai,
			slot_head_str = /obj/item/clothing/head/helmet/samurai,
			slot_wear_mask_str = /obj/item/clothing/mask/gas/oni,
		)
	)

/datum/outfit/special/samurai/equip_backbag(var/mob/living/carbon/human/H)
	return FALSE

/datum/outfit/special/cowboy
	outfit_name = "Cowboy"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/det,
			slot_shoes_str = /obj/item/clothing/shoes/jackboots/cowboy,
			slot_wear_suit_str = /obj/item/clothing/suit/suspenders,
			slot_head_str = /obj/item/clothing/head/cowboy,
			slot_wear_mask_str = /obj/item/clothing/mask/bandana/red,
			slot_r_store_str = /obj/item/weapon/reagent_containers/food/drinks/flask/detflask,
		)
	)

/datum/outfit/special/cowboy/equip_backbag(var/mob/living/carbon/human/H)
	return FALSE

/datum/outfit/special/tourist
	outfit_name = "Tourist"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/tourist,
			slot_shoes_str = /obj/item/clothing/shoes/sandal,
			slot_belt_str = /obj/item/device/camera,
			slot_r_store_str = /obj/item/device/camera_film,
			slot_l_store_str = /obj/item/weapon/spacecash/c100,
		)
	)

/datum/outfit/special/tourist/equip_backbag(var/mob/living/carbon/human/H)
	return FALSE

/datum/outfit/special/tourist/post_equip(var/mob/living/carbon/human/H)
	..()
	equip_accessory(H, /obj/item/clothing/accessory/wristwatch, /obj/item/clothing/under)

/datum/outfit/special/cosmonaut
	outfit_name = "Cosmonaut"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/soviet,
			slot_shoes_str = /obj/item/clothing/shoes/jackboots/neorussian,
			slot_wear_suit_str = /obj/item/clothing/suit/space/syndicate/orange,
			slot_head_str = /obj/item/clothing/head/helmet/space/syndicate/orange,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
			slot_belt_str = /obj/item/weapon/tank/emergency_oxygen/double,
		)
	)

/datum/outfit/special/cosmonaut/equip_backbag(var/mob/living/carbon/human/H)
	return FALSE

/datum/outfit/special/sports
	outfit_name = "Sports Fan"
	items_to_spawn = list(
		"Default" = list(
			slot_w_uniform_str = /obj/item/clothing/under/football,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_r_store_str = /obj/item/weapon/reagent_containers/food/drinks/soda_cans/gibness,
		)
	)

/datum/outfit/special/sports/equip_backbag(var/mob/living/carbon/human/H)
	return FALSE

/datum/outfit/special/sports/post_equip(var/mob/living/carbon/human/H)
	..()
	equip_accessory(H, /obj/item/clothing/accessory/storage/fannypack, /obj/item/clothing/under, 5)


/datum/outfit/special/time_agent
	var/is_twin = FALSE
	outfit_name = "Time Agent"
	give_disabilities_equipment = TRUE
	equip_survival_gear = list() // default gear
	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/satchel_tox,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/rank/scientist,
			slot_shoes_str = /obj/item/clothing/shoes/jackboots,
			slot_wear_mask_str = /obj/item/clothing/mask/gas/grim_reaper/death_commando,
			slot_wear_suit_str = /obj/item/clothing/suit/space/time,
			slot_s_store_str = /obj/item/weapon/tank/emergency_oxygen/double,
			slot_belt_str = /obj/item/weapon/storage/belt/grenade/chrono,
			slot_head_str = /obj/item/clothing/head/helmet/space/time,
		)
	)

	items_to_collect = list(
		/obj/item/device/jump_charge,
		/obj/item/device/timeline_eraser,
		/obj/item/weapon/gun/projectile/automatic/rewind,
		/obj/item/device/chronocapture,
		/obj/item/weapon/pinpointer/advpinpointer/time_agent,
	)

/datum/outfit/special/time_agent/pre_equip(var/mob/living/carbon/human/H)
	if (is_twin)
		items_to_collect -= /obj/item/device/jump_charge
		items_to_collect += /obj/item/weapon/storage/box/chrono_grenades/future

	if(H.overeatduration) //We need to do this here and now, otherwise a lot of gear will fail to spawn
		to_chat(H, "<span class='notice'>Your intensive physical training to become a Time Agent has paid off and made you fit again!</span>")
		H.overeatduration = 0 //Fat-B-Gone
		if(H.nutrition > 400) //We are also overeating nutriment-wise
			H.nutrition = 400
		H.mutations.Remove(M_FAT)
		H.update_mutantrace(0)
		H.update_mutations(0)
		H.update_inv_w_uniform(0)
		H.update_inv_wear_suit()
