/datum/outfit/striketeam/nukeops

	outfit_name = "Nuclear Operative"

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/security,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_sec,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel_sec,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/sec,
	)

	// With the original comments on what each spec does for authencity.
	specs = list(
		// Classic Ballistics setup. C20R rifle with ammo, and Beretta handgun also with ammo as a backup
		"Ballistics" = list(
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/prescription, //Changed to prescription sunglasses for near-sighted players
			slot_belt_str = /obj/item/weapon/gun/projectile/automatic/c20r,
			slot_in_backpack_str = list(
				/obj/item/ammo_storage/magazine/a12mm/ops = 2,
				/obj/item/weapon/gun/projectile/beretta = 1,
				/obj/item/ammo_storage/magazine/beretta = 2,
			),
		),

		// Classic alternate setup with a twist. Laser Rifle as a primary, but ion carbine as a backup and extra EMP nades for those ENERGY needs. Zap-zap the borgs
		"Energy" = list(
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/prescription,
			slot_belt_str = /obj/item/weapon/gun/energy/laser,
			slot_in_backpack_str = list(
				/obj/item/weapon/gun/energy/ionrifle/ioncarbine = 1,
				/obj/item/weapon/grenade/empgrenade = 2,
			),
		),

		// Boom boom, shake the room as the kids say. RPG as primary and grenade launcher as secondary, with C4 and nades reserve. He blows
		"Demolition" = list(
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/prescription,
			slot_s_store_str = /obj/item/weapon/gun/projectile/rocketlauncher, //Only place we can store it, it will drop on the ground for plasmamen
			slot_belt_str = /obj/item/weapon/gun/grenadelauncher/syndicate,
			slot_in_backpack_str = list(
				/obj/item/ammo_casing/rocket_rpg = 3,
				/obj/item/weapon/storage/box/syndigrenades = 2
			),
		),

		// Really powerful melee weapons and energy shield, along with random extra goods and eviscerator nades. A dream come true
		"Melee" = list(
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses/prescription,
			slot_belt_str = /obj/item/weapon/grenade/spawnergrenade/manhacks,
			slot_in_backpack_str = list(
				/obj/item/weapon/melee/energy/sword/dualsaber = 1,
				/obj/item/weapon/melee/energy/hfmachete = 1,
			),
			slot_l_store_str = /obj/item/weapon/shield/energy,

		),

		 //The good guy who just wants to help their dumb fucking teammates not die horribly. Has some fancy gear like the mobile surgery table. Main gun is a VERY lethal syringe gun
		"Medical" = list(
			slot_glasses_str = /obj/item/clothing/glasses/hud/health/prescription,
			slot_belt_str = /obj/item/weapon/gun/syringe/rapidsyringe,
			slot_in_backpack_str = list(
				/obj/item/weapon/storage/box/syndisyringes = 1,
				/obj/item/weapon/storage/firstaid/adv = 1,
				/obj/item/weapon/reagent_containers/hypospray = 1,
				/obj/item/weapon/storage/pill_bottle/hyperzine = 1,
				/obj/item/weapon/storage/pill_bottle/inaprovaline = 1,
			),
			ACCESSORY_ITEM = /obj/item/roller/surgery,
		),

		//Mister deconstruction, C4 and efficient. Engineers have shotguns because stereotype, and eswords for utility
		"Engineering" = list(
			slot_glasses_str = /obj/item/clothing/glasses/scanner/meson/prescription,
			slot_s_store_str = /obj/item/weapon/gun/projectile/shotgun/pump/combat/shorty,
			slot_belt_str = /obj/item/weapon/storage/belt/utility/complete,
			slot_in_backpack_str = list(
				/obj/item/weapon/storage/box/lethalshells = 1,
				/obj/item/weapon/melee/energy/sword = 1,
				/obj/item/weapon/c4 = 3,
				/obj/item/clothing/glasses/welding/superior = 1,
			),
			ACCESSORY_ITEM = /obj/item/clothing/shoes/magboots/syndie/elite,
		),

		//WE STELT. Has an energy crossbow primary and a silenced pistol with magazines, along with a basic kit of infiltration items you could need to not nuke the Ops' credits
		"Stealth" = list(
			slot_glasses_str = /obj/item/clothing/glasses/thermal/syndi,
			slot_wear_mask_str = /obj/item/clothing/mask/gas/voice,
			slot_belt_str = /obj/item/weapon/gun/projectile/silenced,
			slot_in_backpack_str = list(
				/obj/item/ammo_storage/magazine/c45 = 1,
				/obj/item/weapon/card/emag = 1,
				/obj/item/weapon/pen/paralysis = 1,
			),
			slot_l_store_str =  /obj/item/weapon/gun/energy/crossbow,
		),

		//The guy who stays on the shuttle and goes braindead. This kit is basically useless outside of giving you the coveted teleporter board, saving your team 40 points if you use it
		"Ship and Cameras" = list(
			slot_glasses_str = /obj/item/clothing/glasses/thermal/syndi,
			slot_in_backpack_str = list(
				/obj/item/device/encryptionkey/binary = 1,
				/obj/item/device/megaphone/madscientist = 1,
			),
			slot_l_store_str = /obj/item/weapon/circuitboard/teleporter,
		),
	) // End of the specs.

	items_to_spawn = list(
		// Human
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/syndicate,
			slot_w_uniform_str = /obj/item/clothing/under/syndicate/holomap,
			slot_shoes_str = /obj/item/clothing/shoes/combat,
			slot_wear_suit_str = /obj/item/clothing/suit/armor/bulletproof,
			slot_gloves_str = /obj/item/clothing/gloves/combat,
			slot_head_str = /obj/item/clothing/head/helmet/tactical/swat,
			slot_wear_id_str = /obj/item/weapon/card/id/syndicate,
		),

		// Plasmaman
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset/syndicate,
			slot_w_uniform_str = /obj/item/clothing/under/syndicate/holomap,
			slot_shoes_str = /obj/item/clothing/shoes/combat,

			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/nuclear, // Different
			slot_wear_mask_str = /obj/item/clothing/mask/breath,

			slot_gloves_str = /obj/item/clothing/gloves/combat,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/nuclear, // Different
			slot_wear_id_str = /obj/item/weapon/card/id/syndicate,
		),

		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset/syndicate,
			slot_w_uniform_str = /obj/item/clothing/under/syndicate/holomap,
			slot_shoes_str = /obj/item/clothing/shoes/combat,
			slot_wear_suit_str = /obj/item/clothing/suit/armor/bulletproof,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox, // Different
			slot_gloves_str = /obj/item/clothing/gloves/combat,
			slot_head_str = /obj/item/clothing/head/helmet/tactical/swat,
			slot_wear_id_str = /obj/item/weapon/card/id/syndicate,
		),
	)

	equip_survival_gear = list(
		/datum/species/human = /obj/item/weapon/storage/box/survival/nuke/human,
		/datum/species/plasmaman = /obj/item/weapon/storage/box/survival/nuke/human,
		/datum/species/diona = /obj/item/weapon/storage/box/survival/nuke/human,
		/datum/species/insectoid = /obj/item/weapon/storage/box/survival/nuke/human,
		/datum/species/vox = /obj/item/weapon/storage/box/survival/nuke/vox,
	)

	implant_types = list(
		/obj/item/weapon/implant/explosive/nuclear,
	)

/datum/outfit/striketeam/nukeops/spawn_id(var/mob/living/carbon/human/H, rank)
	return // Nuke ops have anonymous ID cards.

/datum/outfit/striketeam/nukeops/post_equip(var/mob/living/carbon/human/H)
	..()
	var/obj/item/device/radio/R = H.ears
	R.set_frequency(SYND_FREQ)
	if(H.mind.GetRole(NUKE_OP_LEADER))
		H.equip_to_slot_or_del(new /obj/item/device/modkit/syndi_commander(H), slot_in_backpack)

/datum/outfit/striketeam/nukeops/pre_equip(var/mob/living/carbon/human/H)
	if(H.overeatduration) //We need to do this here and now, otherwise a lot of gear will fail to spawn
		to_chat(H, "<span class='notice'>Your intensive physical training to become a Nuclear Operative has paid off and made you fit again!</span>")
		H.overeatduration = 0 //Fat-B-Gone
		if(H.nutrition > 400) //We are also overeating nutriment-wise
			H.nutrition = 400 //Fix that
		H.mutations.Remove(M_FAT)
		H.update_mutantrace(0)
		H.update_mutations(0)
		H.update_inv_w_uniform(0)
		H.update_inv_wear_suit()
	return ..()
