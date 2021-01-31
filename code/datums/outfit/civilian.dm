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
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
		),
	)

	pda_type = /obj/item/device/pda
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/assistant/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/storage/bag/plasticbag(H))

/datum/outfit/assistant/post_equip_priority(var/mob/living/carbon/human/H)
	H.put_in_hands(new /obj/item/weapon/storage/toolbox/mechanical(get_turf(H)))
	equip_accessory(H, /obj/item/clothing/accessory/storage/fannypack/preloaded/assistant, /obj/item/clothing/under, 5)
	return ..()

// -- Bartender

/datum/outfit/bartender

	outfit_name = "Bartender"
	associated_job = /datum/job/bartender

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_service,
			slot_w_uniform_str = /obj/item/clothing/under/rank/bartender,
			slot_wear_suit_str = /obj/item/clothing/suit/armor/vest,
			slot_shoes_str = /obj/item/clothing/shoes/black,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_service,
			slot_w_uniform_str = /obj/item/clothing/under/rank/bartender,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/service,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/service,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_service,
			slot_w_uniform_str = /obj/item/clothing/under/rank/bartender,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/bartender,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/bartender,
		),
	)

	items_to_collect = list(
		/obj/abstract/spawn_all/bartender = SURVIVAL_BOX,
		/obj/item/weapon/reagent_containers/food/drinks/shaker = slot_l_store_str,
	)

	pda_type = /obj/item/device/pda/bar
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/bartender/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/storage/bag/plasticbag(H))
	H.dna.SetSEState(SOBERBLOCK,1)
	H.mutations += M_SOBER
	H.check_mutations = 1

/datum/outfit/bartender/pre_equip_priority(var/mob/living/carbon/human/H, var/species)
	items_to_collect[/obj/item/weapon/circuitboard/chem_dispenser/soda_dispenser] = SURVIVAL_BOX
	items_to_collect[/obj/item/weapon/circuitboard/chem_dispenser/booze_dispenser] = SURVIVAL_BOX
	return ..()

/obj/abstract/spawn_all/bartender
	where_to_spawn = SPAWN_ON_LOC
	to_spawn = list(
		/obj/item/ammo_casing/shotgun/beanbag,
		/obj/item/ammo_casing/shotgun/beanbag,
		/obj/item/ammo_casing/shotgun/beanbag,
		/obj/item/ammo_casing/shotgun/beanbag
	)

// -- Chef

/datum/outfit/chef

	outfit_name = "Chef"
	associated_job = /datum/job/chef

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_service,
			slot_w_uniform_str = /obj/item/clothing/under/rank/chef,
			slot_wear_suit_str = /obj/item/clothing/suit/chef,
			slot_head_str = /obj/item/clothing/head/chefhat,
			slot_shoes_str = /obj/item/clothing/shoes/black,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_service,
			slot_w_uniform_str = /obj/item/clothing/under/rank/chef,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/service,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/service,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_service,
			slot_w_uniform_str = /obj/item/clothing/under/rank/bartender,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/chef,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/chef,
		),
	)

	pda_type = /obj/item/device/pda/chef
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/chef/pre_equip_priority(var/mob/living/carbon/human/H, var/species)
	items_to_collect[/obj/abstract/spawn_all/chef] = SURVIVAL_BOX
	return ..()

/obj/abstract/spawn_all/chef
	where_to_spawn = SPAWN_ON_LOC
	to_spawn = list(
		/obj/item/weapon/reagent_containers/food/drinks/flour,
		/obj/item/weapon/reagent_containers/food/drinks/flour
	)

// -- Botanist

/datum/outfit/hydro // (!)

	outfit_name = "Botanist"
	associated_job = /datum/job/hydro

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_hyd,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/hyd,
	)
	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_service,
			slot_w_uniform_str = list(
				"Hydroponicist" = /obj/item/clothing/under/rank/hydroponics,
				"Botanist" = /obj/item/clothing/under/rank/botany,
				"Beekeeper" = /obj/item/clothing/under/rank/beekeeper,
				"Gardener" = /obj/item/clothing/under/rank/gardener,
			),
			slot_wear_suit_str = /obj/item/clothing/suit/apron,
			slot_gloves_str = /obj/item/clothing/gloves/botanic_leather,
			slot_shoes_str = /obj/item/clothing/shoes/black,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_service,
			slot_w_uniform_str = list(
				"Hydroponicist" = /obj/item/clothing/under/rank/hydroponics,
				"Botanist" = /obj/item/clothing/under/rank/botany,
				"Beekeeper" = /obj/item/clothing/under/rank/beekeeper,
				"Gardener" = /obj/item/clothing/under/rank/gardener,
			),
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/botanist,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/botanist,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
			slot_gloves_str = /obj/item/clothing/gloves/botanic_leather,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_service,
			slot_w_uniform_str = list(
				"Hydroponicist" = /obj/item/clothing/under/rank/hydroponics,
				"Botanist" = /obj/item/clothing/under/rank/botany,
				"Beekeeper" = /obj/item/clothing/under/rank/beekeeper,
				"Gardener" = /obj/item/clothing/under/rank/gardener,
			),
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/botanist,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/botanist,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
			slot_gloves_str = /obj/item/clothing/gloves/botanic_leather,
		),
	)

	items_to_collect = list(
		/obj/item/device/analyzer/plant_analyzer = slot_s_store_str,
	)

	alt_title_items_to_collect = list(
		"Beekeeper" = list(
			/obj/item/queen_bee = slot_l_store_str,
		)
	)

	pda_type = /obj/item/device/pda/botanist
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/hydro/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/storage/bag/plasticbag(H))

/datum/outfit/hydro/pre_equip_priority(var/mob/living/carbon/human/H, var/species)
	items_to_collect[/obj/abstract/spawn_all/hydro] = SURVIVAL_BOX
	return ..()

/obj/abstract/spawn_all/hydro
	where_to_spawn = SPAWN_ON_LOC
	to_spawn = list(
		/obj/item/weapon/reagent_containers/glass/bottle/diethylamine,
		/obj/item/weapon/reagent_containers/glass/bottle/diethylamine
	)

// -- Clown

/datum/outfit/clown // Honk

	outfit_name = "Clown"
	associated_job = /datum/job/clown

	use_pref_bag = FALSE

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/clown,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = list(
				"Clown" = /obj/item/clothing/under/rank/clown,
				"Jester" = /obj/item/clothing/under/jester,
			),
			slot_shoes_str = list(
				"Clown" = /obj/item/clothing/shoes/clown_shoes,
				"Jester" = /obj/item/clothing/shoes/jestershoes,
			),
			slot_head_str = list(
				"Jester" = /obj/item/clothing/head/jesterhat,
			),
			slot_wear_mask_str = /obj/item/clothing/mask/gas/clown_hat,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = list(
				"Clown" = /obj/item/clothing/under/rank/clown,
				"Jester" = /obj/item/clothing/under/jester,
			),
			slot_shoes_str = list(
				"Clown" = /obj/item/clothing/shoes/clown_shoes,
				"Jester" = /obj/item/clothing/shoes/jestershoes,
			),
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/clown,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/clown,
			slot_wear_mask_str =  /obj/item/clothing/mask/gas/clown_hat,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = list(
				"Clown" = /obj/item/clothing/under/rank/clown,
				"Jester" = /obj/item/clothing/under/jester,
			),
			slot_shoes_str = list(
				"Clown" = /obj/item/clothing/shoes/clown_shoes,
				"Jester" = /obj/item/clothing/shoes/jestershoes,
			),
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
			slot_wear_mask_str =  /obj/item/clothing/mask/gas/clown_hat,
		),
	)

	items_to_collect = list( // No backup slots ; backbag pref ignored
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = null,
		/obj/item/weapon/bikehorn = null,
		/obj/item/weapon/stamp/clown = null,
		/obj/item/toy/crayon/rainbow = null,
		/obj/item/weapon/storage/fancy/crayons = null,
		/obj/item/toy/waterflower = null,
	)

	pda_type = /obj/item/device/pda/clown
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/clown

/datum/outfit/clown/post_equip(var/mob/living/carbon/human/H)
	..()
	H.mutations.Add(M_CLUMSY)
	H.fully_replace_character_name(H.real_name,pick(clown_names))
	H.dna.real_name = H.real_name
	mob_rename_self(H,"clown")
	H.add_language(LANGUAGE_CLOWN)
	to_chat(H, "<span class = 'notice'>You can perfectly paint Her colourbook blindfolded and have learned how to communicate with in the holiest of languages, honk. Praise be her Honkmother.</span>")


/datum/outfit/clown/pre_equip_priority(var/mob/living/carbon/human/H, var/species)
	items_to_collect[/obj/item/weapon/coin/clown] = SURVIVAL_BOX
	return ..()


// -- Mime

/datum/outfit/mime // ...

	outfit_name = "Mime"
	associated_job = /datum/job/mime

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/mime,
			slot_shoes_str = /obj/item/clothing/shoes/mime,
			slot_gloves_str = /obj/item/clothing/gloves/white,
			slot_wear_suit_str = /obj/item/clothing/suit/suspenders,
			slot_head_str = /obj/item/clothing/head/beret,
			slot_wear_mask_str = /obj/item/clothing/mask/gas/mime,
			slot_l_store_str = /obj/item/toy/crayon/mime,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/mime,
			slot_shoes_str = /obj/item/clothing/shoes/mime,
			slot_gloves_str = /obj/item/clothing/gloves/white,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/mime,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/mime,
			slot_wear_mask_str = /obj/item/clothing/mask/gas/mime,
			slot_l_store_str = /obj/item/toy/crayon/mime,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/mime,
			slot_shoes_str = /obj/item/clothing/shoes/mime,
			slot_gloves_str = /obj/item/clothing/gloves/white,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
			slot_wear_mask_str = /obj/item/clothing/mask/gas/mime,
			slot_l_store_str = /obj/item/toy/crayon/mime,
		),
	)

	items_to_collect = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing = GRASP_LEFT_HAND,
		/obj/item/weapon/stamp/mime = slot_r_store_str,
	)

	pda_type = /obj/item/device/pda/mime
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/mime

/datum/outfit/mime/post_equip(var/mob/living/carbon/human/H)
	..()
	if (type == /datum/outfit/mime) // A bit hacky but post_equip should always call its parent.
		H.add_spell(new /spell/aoe_turf/conjure/forcewall/mime, "grey_spell_ready")
		H.add_spell(new /spell/targeted/oathbreak/)
		mob_rename_self(H,"mime")
		if (H.mind)
			H.mind.miming = MIMING_OUT_OF_CHOICE

/datum/outfit/mime/post_equip_priority(var/mob/living/carbon/human/H)
	items_to_collect[/obj/item/weapon/coin/clown] = SURVIVAL_BOX
	return ..()

// -- Clown ling (aka fake mime)
/datum/outfit/mime/clown_ling
	items_to_collect = list(
		/obj/item/weapon/bikehorn = null,
		/obj/item/weapon/stamp/clown = null,
		/obj/item/clothing/under/rank/clown = null,
		/obj/item/clothing/mask/gas/clown_hat/ling_mask = null,
	)

/datum/outfit/mime/clown_ling/post_equip(var/mob/living/carbon/human/H)
	. = ..()
	mob_rename_self(H,"clown")

// -- Janitor

/datum/outfit/janitor

	outfit_name = "Janitor"
	associated_job = /datum/job/janitor

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/rank/janitor,
			slot_shoes_str = /obj/item/clothing/shoes/black,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/rank/janitor,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/janitor,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/janitor,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/rank/janitor,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/janitor,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/janitor,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
		),
	)

	pda_type = /obj/item/device/pda/janitor
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/janitor/post_equip(var/mob/living/carbon/human/H)
	..()
	H.add_language(LANGUAGE_MOUSE)
	to_chat(H, "<span class = 'notice'>Decades of roaming maintenance tunnels and interacting with its denizens have granted you the ability to understand the speech of mice and rats.</span>")

/datum/outfit/janitor/post_equip_priority(var/mob/living/carbon/human/H)
	items_to_collect[/obj/item/weapon/grenade/chem_grenade/cleaner] = SURVIVAL_BOX
	items_to_collect[/obj/item/weapon/reagent_containers/spray/cleaner] = SURVIVAL_BOX
	return ..()

// -- Librarian

/datum/outfit/librarian

	outfit_name = "Librarian"
	associated_job = /datum/job/librarian

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/librarian,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/librarian,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/suit_jacket/red,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/librarian,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/librarian,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
		),
	)

	items_to_collect = list(
		/obj/item/weapon/barcodescanner = GRASP_RIGHT_HAND,
	)

	alt_title_items_to_collect = list(
		"Game Master" = list(
			/obj/item/weapon/storage/pill_bottle/dice/with_die = GRASP_LEFT_HAND,
		)
	)

	pda_type = /obj/item/device/pda/librarian
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/librarian/post_equip(var/mob/living/carbon/human/H)
	..()
	var/obj/item/weapon/storage/bag/plasticbag/P = new /obj/item/weapon/storage/bag/plasticbag(H)
	H.put_in_hands(P)
	var/list/new_languages = list()
	for(var/L in all_languages)
		var/datum/language/lang = all_languages[L]
		if(~lang.flags & RESTRICTED && !(lang in H.languages))
			new_languages += lang.name

	var/picked_lang = pick(new_languages)
	H.add_language(picked_lang)
	to_chat(H, "<span class = 'notice'>Due to your well read nature, you find yourself versed in the language of [picked_lang]. Check-Known-Languages under the IC tab to use it.</span>")

// -- Lawyer, IAA, Bridge Officer

/datum/outfit/iaa

	outfit_name = "Internal Affairs Agent"
	associated_job = /datum/job/iaa

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = list(
				"Lawyer" = /obj/item/device/radio/headset/headset_iaa,
				"Bridge Officer" = /obj/item/device/radio/headset/headset_iaa,
				"Internal Affairs Agent" = /obj/item/device/radio/headset/headset_iaa,
			),
			slot_w_uniform_str = list(
				"Lawyer" = /obj/item/clothing/under/lawyer/bluesuit,
				"Bridge Officer" = /obj/item/clothing/under/bridgeofficer,
				"Internal Affairs Agent" = /obj/item/clothing/under/rank/internalaffairs,
			),
			slot_shoes_str = list(
				"Lawyer" = /obj/item/clothing/shoes/leather,
				"Bridge Officer" = /obj/item/clothing/shoes/centcom,
				"Internal Affairs Agent" = /obj/item/clothing/shoes/centcom,
			),
			slot_wear_suit_str = list(
				"Lawyer" = /obj/item/clothing/suit/storage/lawyer/bluejacket,
				"Bridge Officer" = /obj/item/clothing/suit/storage/lawyer/bridgeofficer,
				"Internal Affairs Agent" = /obj/item/clothing/suit/storage/internalaffairs,
			),
			slot_head_str = list(
				"Bridge Officer" = /obj/item/clothing/head/soft/bridgeofficer,
			),
			slot_gloves_str = list(
				"Bridge Officer" = /obj/item/clothing/gloves/white,
			),
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = list(
				"Lawyer" = /obj/item/device/radio/headset/headset_iaa,
				"Bridge Officer" = /obj/item/device/radio/headset/headset_iaa,
				"Internal Affairs Agent" = /obj/item/device/radio/headset/headset_iaa,
			),
			slot_w_uniform_str = list(
				"Lawyer" = /obj/item/clothing/under/lawyer/bluesuit,
				"Bridge Officer" = /obj/item/clothing/under/bridgeofficer,
				"Internal Affairs Agent" = /obj/item/clothing/under/rank/internalaffairs,
			),
			slot_shoes_str = list(
				"Lawyer" = /obj/item/clothing/shoes/leather,
				"Bridge Officer" = /obj/item/clothing/shoes/centcom,
				"Internal Affairs Agent" = /obj/item/clothing/shoes/centcom,
			),
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/lawyer,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/lawyer,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
			slot_gloves_str = list(
				"Bridge Officer" = /obj/item/clothing/gloves/white,
			),
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
		),
		/datum/species/vox/ = list(
			slot_ears_str = list(
				"Lawyer" = /obj/item/device/radio/headset/headset_iaa,
				"Bridge Officer" = /obj/item/device/radio/headset/headset_iaa,
				"Internal Affairs Agent" = /obj/item/device/radio/headset/headset_iaa,
			),
			slot_w_uniform_str = list(
				"Lawyer" = /obj/item/clothing/under/lawyer/bluesuit,
				"Bridge Officer" = /obj/item/clothing/under/bridgeofficer,
				"Internal Affairs Agent" = /obj/item/clothing/under/rank/internalaffairs,
			),
			slot_shoes_str = list(
				"Lawyer" = /obj/item/clothing/shoes/leather,
				"Bridge Officer" = /obj/item/clothing/shoes/centcom,
				"Internal Affairs Agent" = /obj/item/clothing/shoes/centcom,
			),
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
			slot_gloves_str = list(
				"Bridge Officer" = /obj/item/clothing/gloves/white,
			),
			slot_glasses_str = /obj/item/clothing/glasses/sunglasses,
		),
	)

	implant_types = list(
		/obj/item/weapon/implant/loyalty,
	)

	pda_type = /obj/item/device/pda/lawyer
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/centcom

/datum/outfit/iaa/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/storage/briefcase/centcomm(H))

// -- Chaplain

/datum/outfit/chaplain
	outfit_name = "Chaplain"
	associated_job = /datum/job/chaplain

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/rank/chaplain,
			slot_shoes_str = /obj/item/clothing/shoes/laceup,
			slot_l_store_str = /obj/item/weapon/nullrod,
		),
		/datum/species/plasmaman/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/rank/chaplain,
			slot_shoes_str = /obj/item/clothing/shoes/laceup,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/chaplain,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/chaplain,
			slot_wear_mask_str = /obj/item/clothing/mask/breath,
			slot_l_store_str = /obj/item/weapon/nullrod,
		),
		/datum/species/vox/ = list(
			slot_ears_str = /obj/item/device/radio/headset,
			slot_w_uniform_str = /obj/item/clothing/under/rank/chaplain,
			slot_shoes_str = /obj/item/clothing/shoes/laceup,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/chaplain,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/chaplain,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
			slot_l_store_str = /obj/item/weapon/nullrod,
		),
	)

	pda_type = /obj/item/device/pda/chaplain
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id

/datum/outfit/chaplain/post_equip(var/mob/living/carbon/human/H)
	..()
	H.add_language("Spooky")
	H.put_in_hands(new /obj/item/weapon/thurible(H))
	spawn(0)
		ChooseReligion(H) // Contains an input() proc and hence must be spawn()ed.

/datum/outfit/chaplain/post_equip_priority(var/mob/living/carbon/human/H)
	items_to_collect[/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater] = SURVIVAL_BOX
	return ..()
