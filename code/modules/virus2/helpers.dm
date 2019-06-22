//Checks if table-passing table can reach target (5 tile radius)
//For the record that proc is only used by the "Gregarious Impetus" symptom and super/toxic farts.
proc/airborne_can_reach(turf/source, turf/target, var/radius=5)
	var/obj/dummy = new(source)
	dummy.flags = FPRINT
	dummy.pass_flags = PASSTABLE

	for(var/i=0, i<radius, i++) if(!step_towards(dummy, target)) break

	var/rval = (target.Adjacent(dummy.loc))
	dummy.forceMove(null)
	dummy = null
	return rval

///////////////////////////////////////////
//                                       //
//          STERILITY CHECKS             //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                       //
///////////////////////////////////////////
//AIRBORNE

/mob/living/proc/check_airborne_sterility()
	return 0

/mob/living/carbon/human/check_airborne_sterility()
	var/block = 0
	if (wear_mask && (wear_mask.body_parts_covered & MOUTH) && prob(wear_mask.sterility))
		block = 1
	if (head && (head.body_parts_covered & MOUTH) && prob(head.sterility))
		block = 1
	return block

/mob/living/carbon/monkey/check_airborne_sterility()
	var/block = 0
	if (wear_mask && (wear_mask.body_parts_covered & MOUTH) && prob(wear_mask.sterility))
		block = 1
	if (hat && (hat.body_parts_covered & MOUTH) && prob(hat.sterility))
		block = 1
	return block

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//CONTACT

/mob/living/proc/check_contact_sterility(var/body_part)
	return 0

/mob/living/carbon/human/check_contact_sterility(var/body_part)
	var/block = 0
	var/list/clothing_to_check = list(
		wear_mask,
		w_uniform,
		head,
		wear_suit,
		back,
		gloves,
		handcuffed,
		legcuffed,
		belt,
		shoes,
		wear_mask,
		glasses,
		ears,
		wear_id)
	for (var/thing in clothing_to_check)
		var/obj/item/cloth = thing
		if(istype(cloth) && (cloth.body_parts_covered & body_part) && prob(cloth.sterility))
			block = 1
	return block

/mob/living/carbon/monkey/check_contact_sterility(var/body_part)
	var/block = 0
	var/list/clothing_to_check = list(
		wear_mask,
		uniform,
		hat,
		back,
		handcuffed,
		legcuffed,
		glasses,)
	for (var/thing in clothing_to_check)
		var/obj/item/cloth = thing
		if(istype(cloth) && (cloth.body_parts_covered & body_part) && prob(cloth.sterility))
			block = 1
	return block

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//BLEEDING (bleeding body parts allow SPREAD_BLOOD to infect)

/mob/living/proc/check_bodypart_bleeding(var/body_part)
	return 0

/mob/living/carbon/human/check_bodypart_bleeding(var/body_part)
	var/bleeding = 0
	switch(body_part)
		if (HEAD)//head-patting
			var/datum/organ/external/head = organs_by_name[LIMB_HEAD]
			if(head.status & ORGAN_BLEEDING)
				bleeding = 1
		if (FULL_TORSO)//hugging, lying over infected blood, broken dishes
			var/datum/organ/external/chest = organs_by_name[LIMB_CHEST]
			if(chest.status & ORGAN_BLEEDING)
				bleeding = 1
		if (FEET)//walking over infected blood, broken dishes
			var/datum/organ/external/l_foot = organs_by_name[LIMB_LEFT_FOOT]
			if(l_foot.status & ORGAN_BLEEDING)
				bleeding = 1
			var/datum/organ/external/r_foot = organs_by_name[LIMB_RIGHT_FOOT]
			if(r_foot.status & ORGAN_BLEEDING)
				bleeding = 1
		if (HANDS)//walking over infected blood, broken dishes
			var/datum/organ/external/l_hand = organs_by_name[LIMB_LEFT_HAND]
			if(l_hand.status & ORGAN_BLEEDING)
				bleeding = 1
			var/datum/organ/external/r_hand = organs_by_name[LIMB_RIGHT_HAND]
			if(r_hand.status & ORGAN_BLEEDING)
				bleeding = 1
	return bleeding

//until monkeys can bleed or have open wounds, they're safe on that end.

/mob/living/simple_animal/mouse/check_bodypart_bleeding(var/body_part)
	return splat//visibly bleeding

///////////////////////////////////////////
//                                       //
//              INFECTION                //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                       //
///////////////////////////////////////////
//This proc is called when the disease has already bypassed clothing and other protections
//The only checks left are for antibodies/sterility and the disease's infection chance
/atom/proc/infect_disease2(var/datum/disease2/disease/disease,var/forced = 0, var/notes="")
	return 0

//MOBS
var/list/infected_contact_mobs = list()

/mob/living/infect_disease2(var/datum/disease2/disease/disease,var/forced = 0, var/notes="")
	if(!istype(disease))
		return 0
	if(disease.spread == 0)//in case admins bus'd in a non-spreadable disease.
		return 0
	if(!can_be_infected())//humans, monkeys, mouse, for now
		return 0
	if ("[disease.uniqueID]-[disease.subID]" in virus2)
		return 0
	if(!immune_system.CanInfect(disease))
		return 0
	if(prob(disease.infectionchance) || forced)
		var/datum/disease2/disease/D = disease.getcopy()
		if (D.infectionchance > 10)
			D.infectionchance = max(10, D.infectionchance - 10)//The virus gets weaker as it jumps from people to people
		D.stage = Clamp(D.stage+D.stage_variance, 1, D.max_stage)
		D.log += "<br />[timestamp()] Infected [key_name(src)] [notes]. Infection chance now [D.infectionchance]%"
		virus2["[D.uniqueID]-[D.subID]"] = D

		if (disease.spread & SPREAD_CONTACT)
			infected_contact_mobs |= src
			if (!pathogen)
				pathogen = image('icons/effects/effects.dmi',src,"pathogen_contact")
				pathogen.plane = HUD_PLANE
				pathogen.layer = UNDER_HUD_LAYER
				pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
			for (var/mob/living/L in science_goggles_wearers)
				if (L.client)
					L.client.images |= pathogen

		return 1
	return 0

//ITEMS
var/list/infected_items = list()

/obj/item/infect_disease2(var/datum/disease2/disease/disease,var/forced = 0, var/notes="",var/decay = 1)
	if(!istype(disease))
		return 0
	if(disease.spread == 0)
		return 0
	if (prob(sterility))
		return 0
	if ("[disease.uniqueID]-[disease.subID]" in virus2)
		return 0
	if(prob(disease.infectionchance) || forced)
		var/datum/disease2/disease/D = disease.getcopy()
		D.log += "<br />[timestamp()] Infected \a [src] [notes]"
		virus2["[D.uniqueID]-[D.subID]"] = D

		infected_items |= src
		if (!pathogen)
			pathogen = image('icons/effects/effects.dmi',src,"pathogen_contact")
			pathogen.plane = HUD_PLANE
			pathogen.layer = HUD_ABOVE_ITEM_LAYER
			pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
		for (var/mob/living/L in science_goggles_wearers)
			if (L.client)
				L.client.images |= pathogen

		if (decay)
			spawn((disease.infectionchance/10) MINUTES)
				remove_disease2("[D.uniqueID]-[D.subID]")
		return 1
	return 0

/atom/proc/remove_disease2(var/diseaseID)
	return 0

/obj/item/remove_disease2(var/diseaseID)
	if (diseaseID)
		virus2 -= diseaseID
	else
		virus2 = list()
	if (virus2 && virus2.len <= 0)
		infected_items -= src
		if (pathogen)
			for (var/mob/living/L in science_goggles_wearers)
				if (L.client)
					L.client.images -= pathogen

/*
///////////////////////////////////////////
//                                       //
//          CREATING A VIRUS             //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                       //
///////////////////////////////////////////

proc/virus2_lesser_infection()
	var/list/candidates = list()	//list of candidate keys

	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G
	if(!candidates.len)
		return

	candidates = shuffle(candidates)

	infect_mob_random_lesser(candidates[1])

//Infects mob M with random lesser disease, if he doesn't have one
/proc/infect_mob_random_lesser(var/mob/living/carbon/M)
	var/datum/disease2/disease/D
	if(prob(70))
		D = new /datum/disease2/disease/bacteria("infect_mob_random_lesser")
	else
		D = new /datum/disease2/disease("infect_mob_random_lesser")
	D.makerandom(FALSE, TRUE)
	D.infectionchance = 1
	M.virus2["[D.uniqueID]"] = D

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

proc/virus2_greater_infection()
	var/list/candidates = list()	//list of candidate keys

	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G
	if(!candidates.len)
		return

	candidates = shuffle(candidates)

	infect_mob_random_greater(candidates[1])

//Infects mob M with random greated disease, if he doesn't have one
/proc/infect_mob_random_greater(var/mob/living/carbon/M)
	var/datum/disease2/disease/D
	if(prob(30))
		D = new /datum/disease2/disease/parasite("infect_mob_random_greater")
	else
		D = new /datum/disease2/disease("infect_mob_random_greater")
	D.makerandom(TRUE, TRUE)
	M.virus2["[D.uniqueID]"] = D
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MEDHUD STUFF

// Returns 1 if patient has virus2 that medHUDs would pick up.
// Otherwise returns 0
/proc/has_recorded_virus2(var/mob/living/carbon/patient)
	for (var/ID in patient.virus2)
		if (ID in virusDB)
			return 1
	return 0

// This one doesn't really belong here, but old disease code has no helpers, so
// Returns 1 if patient has old-style disease that medHUDs would pick up.
// Otherwise returns 0
/proc/has_recorded_disease(var/mob/living/carbon/patient)
	for(var/datum/disease/D in patient.viruses)
		if(!D.hidden[SCANNER])
			return 1
	return 0

// combination of above two procs
/proc/has_any_recorded_disease(var/mob/living/carbon/patient)
	if(has_recorded_disease(patient))
		return 1
	else if (has_recorded_virus2(patient))
		return 1
	return 0

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/proc/filter_disease_by_spread(var/list/diseases = list(), var/required = 0, var/forbidden = 0)
	if (!diseases || diseases.len <= 0)
		return list()
	var/list/result = list()
	for (var/ID in diseases)
		var/datum/disease2/disease/V = diseases[ID]
		if ((!required || (V.spread & required)) && (!forbidden || !(V.spread & forbidden)))
			result[ID] = V
	return result

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/proc/get_part_from_limb(var/limb)
	var/part = FULL_TORSO
	switch (limb)
		if(LIMB_HEAD)
			part = HEAD
		if(LIMB_LEFT_HAND)
			part = HAND_LEFT
		if(LIMB_RIGHT_HAND)
			part = HAND_RIGHT
		if(LIMB_LEFT_ARM)
			part = ARM_LEFT
		if(LIMB_RIGHT_ARM)
			part = ARM_RIGHT
		if(LIMB_GROIN)
			part = LOWER_TORSO
		if(LIMB_LEFT_LEG)
			part = LEG_LEFT
		if(LIMB_RIGHT_LEG)
			part = LEG_RIGHT
		if(LIMB_LEFT_FOOT)
			part = FOOT_LEFT
		if(LIMB_RIGHT_FOOT)
			part = FOOT_RIGHT
		if(TARGET_MOUTH)
			part = MOUTH
		if("eyes")
			part = EYES
	return part
