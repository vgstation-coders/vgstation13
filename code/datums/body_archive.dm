
var/list/body_archives = list()

// basically /datum/mind scans its mob when first created, allowing the original body to be re-created if needed
/datum/body_archive
	var/mob_type

	// those of the source mind
	var/name
	var/key
	var/rank

	// just an empty list where you can store extra data, such as human DNA records
	var/list/data = list()

/datum/body_archive/New(var/mob/source)//created in mind_initialize()
	if (!source)
		qdel(src)
		return
	..()
	body_archives += src
	mob_type = source.type
	name = source.mind.name
	key = source.mind.key
	rank = source.mind.assigned_role
	log_debug("[key_name(source)] has has had their body ([mob_type]) archived.")
	source.archive_body(src)

/datum/body_archive/proc/spawn_copy(var/turf/T)//admin toy
	var/mob/temp_mob = new mob_type(T)
	var/spawn_naked = ishuman(temp_mob) && alert("Keep current job equipment again or not?", "Body Resetting", "Keep Outfit", "Spawn Naked") == "Keep Outfit"
	temp_mob.actually_reset_body(src, FALSE, spawn_naked, null, null)
	qdel(temp_mob)

/datum/body_archive/proc/spawn_transfer(var/turf/T)//admin toy
	var/mob/temp_mob = new mob_type(T)
	var/spawn_naked = ishuman(temp_mob) && alert("Let them get their current job equipment again or not?", "Body Resetting", "Keep Outfit", "Spawn Naked") == "Keep Outfit"
	temp_mob.actually_reset_body(src, FALSE, spawn_naked, null, get_mind_by_key(src.key))
	qdel(temp_mob)

////////////////////////////////////////////////////////////////////
//																  //
//							MOB PROCS							  //
//																  //
////////////////////////////////////////////////////////////////////

/mob/proc/archive_body(var/datum/body_archive/archive)

/mob/proc/reset_body(var/datum/body_archive/archive,var/keep_clothes = FALSE, var/spawn_naked = TRUE)
	if (!archive)
		if (mind && mind.body_archive)
			archive = mind.body_archive
		else
			return

	var/mob/new_mob

	if (type == archive.mob_type)
		new_mob = actually_reset_body(archive, keep_clothes, spawn_naked, src, mind)
	else
		var/mob/temp_mob = new archive.mob_type(loc)
		new_mob = temp_mob.actually_reset_body(archive, keep_clothes, spawn_naked, src, mind)
		qdel(temp_mob)

	drop_all()
	qdel(src)
	return new_mob

// With this proc we're guarranted that the mob_type in the archive is the same as src
/mob/proc/actually_reset_body(var/datum/body_archive/archive,var/keep_clothes = FALSE, var/spawn_naked = TRUE, var/mob/old_mob, var/datum/mind/our_mind)
	var/mob/new_mob = new archive.mob_type(loc)
	if (our_mind)
		our_mind.transfer_to(new_mob)
	return new_mob


////////////////////////////////////////////////////////////////////
//																  //
//					MOB TYPE-SPECIFIC ARCHIVES					  //
//																  //
////////////////////////////////////////////////////////////////////

/////////////////////// HUMAN //////////////////////

/mob/living/carbon/human/archive_body(var/datum/body_archive/archive)
	var/datum/organ/internal/brain/Brain = internal_organs_by_name["brain"]
	var/datum/dna2/record/R = new /datum/dna2/record()
	if(Brain && !isnull(Brain.owner_dna) && Brain.owner_dna != dna)
		R.dna = Brain.owner_dna.Clone()
	else
		R.dna = dna.Clone()
	R.ckey = ckey
	R.id= copytext(md5(R.dna.real_name), 2, 6)
	R.name=R.dna.real_name
	R.types=DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
	R.languages = languages.Copy()
	R.attack_log = attack_log.Copy()
	R.default_language = default_language
	R.times_cloned = times_cloned
	R.talkcount = talkcount

	archive.data["dna_records"] = R
	archive.data["underwear"] = underwear

	//I gave a shot at preserving limb status (destroyed, peg, mechanized) then decided I was too tired and it's too much trouble, so TODO for anyone with the determination

/mob/living/carbon/human/actually_reset_body(var/datum/body_archive/archive, var/keep_clothes = FALSE, var/spawn_naked = TRUE, var/mob/old_mob, var/datum/mind/our_mind)

	//Creating our new body
	var/datum/dna2/record/R = archive.data["dna_records"]
	var/mob/living/carbon/human/H = new /mob/living/carbon/human(loc, R.dna.species, delay_ready_dna = TRUE)
	H.times_cloned = 0
	H.talkcount = R.talkcount
	if(isplasmaman(H))
		H.fire_sprite = "Plasmaman"
	H.dna = R.dna.Clone()
	H.dna.flavor_text = R.dna.flavor_text
	H.dna.species = R.dna.species
	if(H.dna.species != "Human")
		H.set_species(H.dna.species, TRUE)
	H.check_mutations = TRUE
	H.updatehealth()
	if (our_mind)
		has_been_shade -= our_mind
		our_mind.transfer_to(H)
		H.ckey = R.ckey // Maybe needed to put things like ghosts back in bodies
	if (H.mind && H.mind.miming)
		H.add_spell(new /spell/aoe_turf/conjure/forcewall/mime, "grey_spell_ready")
		if (H.mind.miming == MIMING_OUT_OF_CHOICE)
			H.add_spell(new /spell/targeted/oathbreak/)
	if (isvampire(H))
		var/datum/role/vampire/V = isvampire(H)
		V.check_vampire_upgrade()
		V.update_vamp_hud()
	H.UpdateAppearance()
	H.set_species(R.dna.species)
	H.dna.mutantrace = R.dna.mutantrace
	H.update_mutantrace()
	for(var/datum/language/L in R.languages)
		H.add_language(L.name)
		if (L == R.default_language)
			H.default_language = R.default_language
	H.attack_log = R.attack_log
	H.real_name = H.dna.real_name
	H.name = H.real_name
	H.flavor_text = H.dna.flavor_text
	if(H.mind)
		H.mind.suiciding = FALSE
	H.update_name()
	if (H.client)
		H.client.eye = H.client.mob
		H.client.perspective = MOB_PERSPECTIVE
	H.updatehealth()
	domutcheck(H)

	//Optionally transferring items
	if (ishuman(old_mob) && keep_clothes)
		//taking care of those items separately so they don't fall on the floor
		var/obj/item/transfered_uniform = old_mob.get_item_by_slot(slot_w_uniform)
		var/obj/item/transfered_suit = old_mob.get_item_by_slot(slot_wear_suit)
		var/obj/item/transfered_id = old_mob.get_item_by_slot(slot_wear_id)
		var/obj/item/transfered_belt = old_mob.get_item_by_slot(slot_belt)
		var/obj/item/transfered_suit_storage = old_mob.get_item_by_slot(slot_s_store)
		var/obj/item/transfered_left_pocket = old_mob.get_item_by_slot(slot_l_store)
		var/obj/item/transfered_right_pocket = old_mob.get_item_by_slot(slot_r_store)
		if (transfered_uniform)
			old_mob.u_equip(transfered_uniform)
			H.equip_to_slot_or_drop(transfered_uniform,slot_w_uniform)
		if (transfered_suit)
			old_mob.u_equip(transfered_suit)
			H.equip_to_slot_or_drop(transfered_suit,slot_wear_suit)
		//no need to unequip those since they fell off when removing the previous two
		if (transfered_id)
			H.equip_to_slot_or_drop(transfered_id,slot_wear_id)
		if (transfered_belt)
			H.equip_to_slot_or_drop(transfered_belt,slot_belt)
		if (transfered_suit_storage)
			H.equip_to_slot_or_drop(transfered_suit_storage,slot_s_store)
		if (transfered_left_pocket)
			H.equip_to_slot_or_drop(transfered_left_pocket,slot_l_store)
		if (transfered_right_pocket)
			H.equip_to_slot_or_drop(transfered_right_pocket,slot_r_store)
		var/list/other_slots = list(slot_back,slot_wear_mask,slot_handcuffed,slot_ears,slot_glasses,slot_gloves,slot_head,slot_shoes,slot_in_backpack,slot_legcuffed,slot_legs)
		for(var/slot in other_slots)
			var/obj/item/transfered_worn_item = old_mob.get_item_by_slot(slot)
			if (transfered_worn_item)
				old_mob.u_equip(transfered_worn_item)
				H.equip_to_slot_or_drop(transfered_worn_item,slot)
		for (var/i = 1 to old_mob.held_items.len)
			if (i > H.held_items.len)
				break
			var/obj/transfered_held_item = old_mob.held_items[i]
			if (transfered_held_item)
				old_mob.drop_item(transfered_held_item,loc,TRUE)
				H.put_in_hands(transfered_held_item)
	else if(!spawn_naked)
		var/datum/job/J = GetJob(archive.rank)
		if(J)
			J.equip(H, J.priority)
		H.job = archive.rank

	//Maybe putting some pants on too
	H.underwear = archive.data["underwear"]

	return H
