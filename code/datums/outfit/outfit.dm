/*
 * Outfit datums
 * For equipping characters with special provisions for race and so on
 *

	VARS :
	- items_to_spawn: items to spawn, arranged if needed by race.
	  "Default" is the list of items for humans.
	- use_pref_bag: if we use the backpack he has in prefs, or if we give him a standard backpack.
	- equip_survival_gear: if we give him the basic survival gear.
	- items_to_collect: items to put in the backbag
		The associative key is for when to put it if we have no backbag.
		Use GRASP_LEFT_HAND and GRASP_RIGHT_HAND if it goes to the hands, but slot_x_str if it goes to a slot on the person.
		Use nothing if you want it to drop on the ground.
	- alt_title_items_to_collect: for when you want special items based on job title.
	- race_items_to_collect: for when you want special items based on the race of the mob.
	- implant_types: the implants we give to the mob.
	- special_snowflakes: for the edge cases where you need a manual proc.
	- pda_slot/pda_type/id_type: for the ID and PDA of the mob.
	- give_disabilities_equipment: if we give equipment for disabilities or not.

	PROCS :
	-- "Static" procs
		- equip(var/mob/living/carbon/human/H, var/equip_mindless = FALSE, var/priority = FALSE): tries to equip everything on the list to the relevant slots. This is the "master proc".
		- equip_items(var/list/L, var/mob/living/carbon/human/H, var/species): equips the items in the list L to the human H of the given species.
		- equip_backbag(var/mob/living/carbon/human/H): equip the backbag with the correct pref, and tries to put items in it if possible.
		- pre_equip_disabilities(var/mob/living/carbon/human/H, var/list/items_to_equip): changes items based on disabilities registered
		- give_implants(var/mob/living/carbon/human/H): automatically implants the guy with the implants in the list.
		- give_disabilities_equipment(var/mob/living/carbon/human/H): give the correct equipement for the disabilities the mob has, in the correct slots.

	-- Procs you can override
		- pre_equip(var/mob/living/carbon/human/H): altering the mob or the list of items before the mob is dressed.
		- post_equip(var/mob/living/carbon/human/H): after the mob is fully dressed.
		- spawn_id(var/mob/living/carbon/human/H, rank): give an ID to the mob. Overriden by striketeams.
		- species_final_equip(var/mob/living/carbon/human/H): give internals/a tank to species as needed.
		- special_equip(var/title, var/slot, var/mob/living/carbon/human/H): for the more exotic item slots.

		- priority_pre_equip(var/mob/living/carbon/human/H, var/species): things to do BEFORE equipping the guy if he's a priority arrival.
		- priority_post_equip(var/mob/living/carbon/human/H): things to do AFTER equipping the guy if he's a priority arrival.

	NOTES:
		- if the mob is mindless, in case of alt-title items, the FIRST item is given.
*/

/datum/outfit/
	var/outfit_name = "Abstract outfit datum"

	var/associated_job = null

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
	var/give_disabilities_equipment = TRUE
	var/list/equip_survival_gear = list()

	var/list/items_to_collect = list()
	var/list/alt_title_items_to_collect = list()
	var/list/race_items_to_collect = list()

	var/list/implant_types = list()

	var/pda_slot
	var/pda_type = null
	var/id_type = null

	// For job-slot combinations that require a bit more work than just equipping an item at a given slot
	// Formatting  :
	/*
		special_snowflakes = list(
			"Default" = list(
				JOB_TITLE1 = list(slot1, slot2, ...),
				JOB_TITLE2 = list(slot1, ...),
				...
			),
			...,
		)
	*/
	var/list/special_snowflakes = list()

/datum/outfit/New()
	return

// -- Equip mindless: if we're going to give the outfit to a mob without a mind
/datum/outfit/proc/equip(var/mob/living/carbon/human/H, var/equip_mindless = TRUE, var/priority = FALSE, var/strip = FALSE, var/delete = FALSE)
	if (!H || (!H.mind && !equip_mindless) )
		return

	pre_equip(H)

	var/species = H.species.type
	var/list/L = items_to_spawn[species]
	if (!L) // Couldn't find the particular species
		species = "Default"
		L = items_to_spawn["Default"]

	if(strip)
		var/list/dropped_items = H.unequip_everything()
		if(delete)
			for(var/atom/A in dropped_items)
				qdel(A)

	if (priority)
		pre_equip_priority(H, species)

	pre_equip_disabilities(H, L)
	equip_items(L, H, species)
	equip_backbag(H, species)
	give_implants(H)
	species_final_equip(H)
	spawn_id(H)
	post_equip(H) // Accessories, IDs, etc.
	map.map_equip(H) //Does this map give special gear?
	if (priority)
		post_equip_priority(H)
	give_disabilities_equipment(H)
	H.update_icons()

// -- Modify mob or loadout before giving items
/datum/outfit/proc/pre_equip(var/mob/living/carbon/human/H)
	return

// -- Same as above, for priority arrivals
/datum/outfit/proc/pre_equip_priority(var/mob/living/carbon/human/H)
	items_to_collect[/obj/item/weapon/storage/box/priority_care] = GRASP_RIGHT_HAND

// -- Handle disabilities
/datum/outfit/proc/pre_equip_disabilities(var/mob/living/carbon/human/H, var/list/items_to_equip)
	if (H.client?.IsByondMember())
		to_chat(H, "Thank you for supporting BYOND!")
		items_to_collect[/obj/item/weapon/storage/box/byond] = GRASP_LEFT_HAND

	if (H.client?.ivoted)
		to_chat(H, "Thank you for voting!")
		items_to_collect[/obj/item/clothing/accessory/voter_pin] = GRASP_RIGHT_HAND

	if (!give_disabilities_equipment)
		return
	if (H.disabilities & ASTHMA)
		items_to_collect[/obj/item/device/inhaler] = SURVIVAL_BOX
	if (!items_to_equip[slot_glasses_str] && (H.disabilities & NEARSIGHTED))
		items_to_equip[slot_glasses_str] = /obj/item/clothing/glasses/regular

// Spawning the actual items contained in L
/datum/outfit/proc/equip_items(var/list/L, var/mob/living/carbon/human/H, var/species)
	for (var/slot in L)

		var/list/snowflake_items = special_snowflakes[species]

		if (snowflake_items && (slot in snowflake_items[H?.mind.role_alt_title])) // ex: special_snowflakes["Vox"]["Emergency responder"].
			special_equip(H.mind.role_alt_title, slot, 	H)
			continue

		var/obj_type = L[slot]
		if (islist(obj_type)) // Special objects for alt-titles.
			var/list/L2 = obj_type
			obj_type = null
			if (H.mind && H.mind.role_alt_title)
				obj_type = L2[H.mind.role_alt_title]
			else // Mindless or spawned-in people get the first item.
				var/default_title = L2[1]
				obj_type = L2[default_title]
		if (isnull(obj_type))
			continue
		slot = text2num(slot)
		H.equip_to_slot_if_possible(new obj_type(get_turf(H)), slot, TRUE)

// -- Give out backbag and items to be collected in the backpack
/datum/outfit/proc/equip_backbag(var/mob/living/carbon/human/H, var/species)
	// -- Backbag
	var/obj/item/chosen_backpack = null
	if (use_pref_bag)
		var/backbag_string = num2text(H.backbag)
		chosen_backpack = backpack_types[backbag_string]
	else
		chosen_backpack = backpack_types[BACKPACK_STRING]

	// -- The (wo)man has a backpack, let's put stuff in them
	var/special_items
	var/my_species = H.species.type // This temporary var is necessary.
	var/list/other_items_to_collect = list()
	for (var/thing in race_items_to_collect[my_species])
		if (ispath(thing))
			other_items_to_collect += thing
		else // String = list of things for that alt-title
			if (thing == H.mind.role_alt_title)
				for (var/type in race_items_to_collect[my_species][thing])
					other_items_to_collect += type

	if (H.mind)
		special_items = alt_title_items_to_collect[H.mind.role_alt_title]

	if (chosen_backpack)
		H.equip_to_slot_or_del(new chosen_backpack(H), slot_back, 1)
		for (var/item_type in (items_to_collect + other_items_to_collect))
			if (ispath(item_type, /obj/item))
				H.equip_or_collect(new item_type(H.back), slot_in_backpack)
			else // More abstract thing
				new item_type(H.back)
		// -- Special surival gear for that species
		if (islist(equip_survival_gear) && equip_survival_gear.len)
			if (ispath(equip_survival_gear[my_species]))
				var/path = equip_survival_gear[my_species]
				H.equip_or_collect(new path(H.back), slot_in_backpack)
			// -- No special path, but the outfit still needs to give out a surival box => we give out the default one
			else
				H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		else if (equip_survival_gear)
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)

		// Special alt-title items
		if (special_items)
			for (var/item_type in special_items)
				if (ispath(item_type, /obj/item))
					H.equip_or_collect(new item_type(H.back), slot_in_backpack)
				else // More abstract thing
					new item_type(H.back)

	// -- No backbag, let's improvise

	else
		var/obj/item/weapon/storage/box/survival/pack
		if (islist(equip_survival_gear) && equip_survival_gear.len)
			if (ispath(equip_survival_gear[species]))
				pack = new equip_survival_gear(H)
				H.put_in_hand(GRASP_RIGHT_HAND, pack)
		for (var/item in items_to_collect)
			if (items_to_collect[item] == "Surival Box" && pack)
				new item(pack)
			else
				if (!isnum(items_to_collect[item])) // Not a number : it's a slot
					var/item_slot = text2num(items_to_collect[item])
					if (item_slot)
						H.equip_or_collect(new item(get_turf(H)), item_slot)
					else
						new item(get_turf(H))
				else
					var/hand_slot = items_to_collect[item]
					if (hand_slot) // ie, if it's an actual number
						H.put_in_hand(hand_slot, new item)

		// Special alt-title items, given out the same way.
		if (special_items)
			for (var/item_type in special_items)
				var/chosen_slot = special_items[item_type]
				H.equip_to_slot_if_possible(new item_type(get_turf(H)), chosen_slot)

// -- Implant the dude
/datum/outfit/proc/give_implants(var/mob/living/carbon/human/H)
	for (var/imp_type in implant_types)
		var/obj/item/weapon/implant/I = new imp_type(H)
		if(!I.insert(H, LIMB_HEAD))
			stack_trace("implant/insert() failed")

// -- Species-related equip (turning on internals, etc)
/datum/outfit/proc/species_final_equip(var/mob/living/carbon/human/H)
	if (H.species)
		H.species.final_equip(H)

// -- Spawn correct ID and PDA
/datum/outfit/proc/spawn_id(var/mob/living/carbon/human/H)
	if (!associated_job)
		CRASH("Outfit [outfit_name] has no associated job, and the proc to spawn the ID is not overriden.")
	var/datum/job/concrete_job = new associated_job

	var/obj/item/weapon/card/id/C
	C = new id_type(H)
	C.access = concrete_job.get_access()
	C.registered_name = H.real_name
	C.rank = concrete_job.title
	C.assignment = H.mind ? H.mind.role_alt_title : concrete_job.title
	C.name = "[C.registered_name]'s ID Card ([C.assignment])"
	C.associated_account_number = H?.mind?.initial_account?.account_number
	H.equip_or_collect(C, slot_wear_id)
	if(C.virtual_wallet && H.mind)
		C.update_virtual_wallet(H.mind.initial_wallet_funds)

	if (pda_type)
		var/obj/item/device/pda/pda = new pda_type(H)
		pda.owner = H.real_name
		pda.ownjob = C.assignment
		pda.name = "PDA-[H.real_name] ([pda.ownjob])"
		H.equip_or_collect(pda, pda_slot)

/mob/living/proc/store_frequency_list_in_memory()
	if(!mind)
		return
	var/obj/item/device/radio/headset/earpiece = get_item_by_slot(slot_ears)
	var/list/frequency_list = earpiece?.secure_radio_connections
	if(!frequency_list)
		return
	var/list/text = list("You remember the frequencies of the radio channels: <br>")
	for(var/channel in frequency_list)
		var/frequency = frequency_list[channel]
		text += "<b>[channel]:</b> [format_frequency(frequency)] <br>"
	mind.store_memory(jointext(text, null))

// -- Things to do AFTER all the equipment is given (ex: accessories)
/datum/outfit/proc/post_equip(var/mob/living/carbon/human/H)
	SHOULD_CALL_PARENT(TRUE)
	H.store_frequency_list_in_memory()

// -- Same as above, for priority arrivals
/datum/outfit/proc/post_equip_priority(var/mob/living/carbon/human/H)
	return

// -- Final disabilities things, after all is given
/datum/outfit/proc/give_disabilities_equipment(var/mob/living/carbon/human/H)
	if (!give_disabilities_equipment)
		return

	// -- Automatically giving out a wheelchair if the guy can't stand
	if(!H.check_stand_ability())
		var/obj/structure/bed/chair/vehicle/wheelchair/W = new(H.loc)
		W.buckle_mob(H,H)

	if ((H.disabilities & NEARSIGHTED) && H.glasses && (H.glasses.nearsighted_modifier >= 0) && H.glasses.prescription_type)
		var/obj/item/clothing/glasses/prescription = new H.glasses.prescription_type(H)
		var/obj/prev_glasses = H.glasses
		H.u_equip(H.glasses,1)
		qdel(prev_glasses)
		H.equip_to_slot_or_drop(prescription, slot_glasses)

	return 1

// Special snowflakes : handle special cases for a given title and a given slot
/datum/outfit/proc/special_equip(var/title, var/slot, var/mob/living/carbon/human/H)
	return

// Strike teams have 2 particularities : a leader, and several specialised roles.
// Give the concrete (instanced) outfit datum the right "specialisation" after the player made his choice.
// Then, call "equip_special_items(player)" to give him the items associated.

/datum/outfit/striketeam/
	give_disabilities_equipment = FALSE
	var/is_leader = FALSE

	var/list/specs = list()

	var/chosen_spec = null

	var/assignment_leader = "Striketeam Leader"
	var/assignment_member = "Striketeam Member"

	var/id_type_leader = null

/datum/outfit/striketeam/spawn_id(var/mob/living/carbon/human/H, rank)
	var/obj/item/weapon/card/id/W
	if(is_leader)
		W = new id_type_leader(get_turf(H))
		W.assignment = assignment_leader
	else
		W = new id_type(get_turf(H))
		W.assignment = assignment_member
	W.name = "[H.real_name]'s ID Card"
	W.registered_name = H.real_name
	W.UpdateName()
	W.SetOwnerDNAInfo(H)
	H.equip_to_slot_or_drop(W, slot_wear_id)
	return W

/datum/outfit/striketeam/proc/equip_special_items(var/mob/living/carbon/human/H)
	if (!chosen_spec)
		return

	if (!(chosen_spec in specs))
		CRASH("Trying to give [chosen_spec] to [H], but cannot find this spec in [src.type].")

	var/list/to_equip = specs[chosen_spec]

	for (var/slot_str in to_equip)
		var/equipment = to_equip[slot_str]

		switch (slot_str)
			if (ACCESSORY_ITEM) // It's an accesory. We put it in their hands if possible.
				H.put_in_hands(new equipment(H))

			else // It's a concrete item.
				var/slot = text2num(slot_str) // slots stored are STRINGS.

				if (islist(equipment)) // List of things to equip
					for (var/item in equipment)
						for (var/i = 1 to equipment[item]) // Give them this much of that item
							var/concrete_item = new item(H)
							if (!H.equip_to_slot_or_drop(concrete_item, slot)) // Can't put them in the designate slot ? Put it in their hands.
								H.put_in_hands(concrete_item)
				else
					var/concrete_item = new equipment(H)
					if (!H.equip_to_slot_or_drop(concrete_item, slot))
						H.put_in_hands(concrete_item)
