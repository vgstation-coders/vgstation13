/*
 * Outfit datums
 * For equipping characters with special provisions for race and so on
 *

	VARS :
	- items_to_spawn: items to spawn, arranged if needed by race.
	  "Default" is the list of items for humans.
	- use_pref_bag: if we use the backpack he has in prefs, or if we give him a standard backpack.
	- equip_survival_gear: if we give him the basic survival gear.
	- items_to_collect: item to put in the backbag
		The associative key is for when to put it if we have no backbag.

	PROCS :
	-- "Static" procs
		- equip(var/mob/living/carbon/human/H) : tries to equip everything on the list to the relevant slots

	-- Procs you can override
		- misc_stuff(var/mob/living/carbon/human/H) : for things like implants.

*/

/datum/outfit/
	var/outfit_name = "Abstract outfit datum"

	var/list/items_to_spawn = list(
		"Default" = list(),
	)

	var/list/backpack_types = list(
		BACKPACK_STRING = null,
		SATCHEL_NORM_STRING = null,
		SATCHEL_ALT_STRING = null,
		MESSENGER_BAG_STRING = null,
	)

	var/use_pref_bag = TRUE
	var/equip_survival_gear = SURVIVAL_NORMAL

	var/list/items_to_collect = list()

	var/list/implant_types = list()

/datum/outfit/New()
	return

/datum/outfit/proc/pre_equip(var/mob/living/carbon/human/H)
	return

/datum/outfit/proc/equip(var/mob/living/carbon/human/H)
	pre_equip(H)
	var/species = H.species.type
	var/list/L = items_to_spawn[species]
	if (!L) // Couldn't find the particular species
		L = items_to_spawn["Default"]

	for (var/slot in L)
		var/obj_type = L[slot]
		if (islist(obj_type))
			var/list/L2 = obj_type
			obj_type = L2[H.mind.role_alt_title]
		slot = text2num(slot)
		H.equip_to_slot_or_del(new obj_type(H), slot, TRUE)

	equip_backbag(H)

	for (var/imp_type in implant_types)
		var/obj/item/weapon/implant/I = new imp_type
		I.imp_in = H
		I.implanted = 1
		var/datum/organ/external/affected = H.get_organ(LIMB_HEAD) // By default, all implants go to the head.
		affected.implants += I
		I.part = affected

	species_final_equip(H)

/datum/outfit/proc/equip_backbag(var/mob/living/carbon/human/H)
	// -- Backbag
	var/obj/item/chosen_backpack = null
	if (use_pref_bag)
		var/backbag_string = num2text(H.backbag)
		chosen_backpack = backpack_types[backbag_string]
	else
		chosen_backpack = backpack_types[BACKPACK_STRING]

	// -- The (wo)man has a backpack, let's put stuff in them

	if (chosen_backpack)
		H.equip_to_slot_or_del(new chosen_backpack(H), slot_back, 1)
		for (var/item in items_to_collect)
			var/item_type = item
			if (islist(item)) // For alt-titles.
				item_type = item[H.mind.role_alt_title]
			H.equip_or_collect(new item_type(H.back), slot_in_backpack)
		if (equip_survival_gear)
			if (ispath(equip_survival_gear))
				H.equip_or_collect(new equip_survival_gear(H.back), slot_in_backpack)
			else
				H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)

	// -- No backbag, let's improvise
	else
		var/obj/item/weapon/storage/box/survival/pack
		if (equip_survival_gear)
			if (ispath(equip_survival_gear))
				pack = new equip_survival_gear(H)
				H.put_in_hand(GRASP_RIGHT_HAND, pack)
			else
				pack = new H.species.survival_gear(H)
				H.put_in_hand(GRASP_RIGHT_HAND, pack)
		for (var/item in items_to_collect)
			if (items_to_collect[item] == "Surival Box" && pack)
				new item(pack)
			else
				var/hand_slot = text2num(items_to_collect[item])
				if (hand_slot) // ie, if it's an actual number
					H.put_in_hand(hand_slot, new item)
				else // It's supposed to be in the survival box or something
					new item(H)

/datum/outfit/proc/species_final_equip(var/mob/living/carbon/human/H)
	if (H.species)
		H.species.final_equip(H)

/datum/outfit/proc/misc_stuff(var/mob/living/carbon/human/H)
	return // Empty