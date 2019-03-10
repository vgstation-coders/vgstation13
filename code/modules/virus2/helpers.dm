/*
	proc/get_infection_chance -> checks for protections, gonna need a thorough rework
	proc/airborne_can_reach -> this is so stupid (5 tile reach but unused for more than 1 tile anyway)
	/proc/infect_virus2 -> actually infects mobs (if infectionchance or forced), disease.getcopy()

	/proc/infect_mob_random_lesser -> infects mob with a weak virus
	/proc/infect_mob_random_greater -> infects mob with a strong virus

	/proc/spread_disease_to -> used for mobs directly spreading to other mobs, calls infect_virus2

	/proc/has_recorded_virus2 -> medhud instantly pick up on viruses in the database
	/proc/has_recorded_disease -> holy shit we gotta remove the old disease code already

	// combination of above two procs
	/proc/has_any_recorded_disease(var/mob/living/carbon/patient) -> we won't need that one anymore
*/



/*
//Returns 1 if mob can be infected, 0 otherwise. Checks his clothing.
proc/get_infection_chance(var/mob/living/M, var/vector = "Airborne")
	var/score = 0 // full protection at 100, none at 0, quadratic in between: having more protection helps less if you already have lots of it
	if (!istype(M))
		return 0

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if (vector == "Airborne")
			if(H.internal)	//not breathing infected air helps greatly
				score += 100
			if(H.wear_mask)
				score += 15
				if(istype(H:wear_mask, /obj/item/clothing/mask/surgical) && !M.internal)
					score += 35
			if(istype(H:wear_suit, /obj/item/clothing/suit/space) && istype(M:head, /obj/item/clothing/head/helmet/space))
				score += 50
			if(istype(H:wear_suit, /obj/item/clothing/suit/bio_suit) && istype(M:head, /obj/item/clothing/head/bio_hood))
				score += 50

		if (vector == "Contact")
			if(H:gloves)
				score += 50
			if(istype(H:wear_suit, /obj/item/clothing/suit/space))
				score += 35
			if(istype(H:wear_suit, /obj/item/clothing/suit/bio_suit))
				score += 35

//	log_debug("[M]'s resistance to [vector] viruses: [score]")
	if(istype(M, /mob/living/simple_animal/mouse))
		return 1

	if(istype(M, /mob/living/carbon/complex/martian)) //Martians are incredibly susceptible to viruses
		var/mob/living/carbon/complex/martian/MR = M
		if (vector == "Airborne")
			if(MR.head && istype(MR.head, /obj/item/clothing/head/helmet/space/martian))
				score += 40
				var/obj/item/clothing/head/helmet/space/martian/fishbowl = MR.head
				if(fishbowl.tank && istype(fishbowl.tank, /obj/item/weapon/tank))
					score += 60

	if(prob((min(score, 100) - 100) ** 2 / 100))
//		log_debug("Infection got through")
		return 1
	return 0
*/
//Checks if table-passing table can reach target (5 tile radius)
proc/airborne_can_reach(turf/source, turf/target, var/radius=5)
	var/obj/dummy = new(source)
	dummy.flags = FPRINT
	dummy.pass_flags = PASSTABLE

	for(var/i=0, i<radius, i++) if(!step_towards(dummy, target)) break

	var/rval = (target.Adjacent(dummy.loc))
	dummy.forceMove(null)
	dummy = null
	return rval
/*
//Attemptes to infect mob M with virus. Set forced to 1 to ignore protective clothing.  Returns 1 if successful.
/proc/infect_virus2(var/mob/living/carbon/M,var/datum/disease2/disease/disease,var/forced = 0, var/notes="")
	if(!istype(disease))
//		log_debug("Bad virus")
		return 0
	if(!M.can_be_infected())
//		log_debug("Bad mob")
		return 0
	if ("[disease.uniqueID]" in M.virus2)
		return 0
	// if one of the antibodies in the mob's body matches one of the disease's antigens, don't infect
	if((M.antibodies & disease.antigen) != 0)
		return 0



//	log_debug("Infecting [M]")

	if(prob(disease.infectionchance) || forced)
		// certain clothes can prevent an infection
		if(!forced && !get_infection_chance(M, disease.spreadtype))
			return

		var/datum/disease2/disease/D = disease.getcopy()
		D.minormutate()
//		log_debug("Adding virus")
//		log_debug("[key_name(M)] infected with [disease.uniqueID]: forced=[forced], notes=[notes].")
		D.log += "<br />[timestamp()] Infected [key_name(M)] [notes]"
		M.virus2["[D.uniqueID]"] = D
		return 1
	return 0
*/

//This proc is called when the disease has already bypassed clothing and other protections
/proc/infect_disease2(var/mob/living/carbon/M,var/datum/disease2/disease/disease,var/forced = 0, var/notes="")
	if(!istype(disease))
		return 0
	if(!M.can_be_infected())
		return 0
	if ("[disease.uniqueID]" in M.virus2)
		return 0
	if((M.antibodies & disease.antigen) != 0)
		return 0
	if(prob(disease.infectionchance) || forced)
		var/datum/disease2/disease/D = disease.getcopy()
		if (D.infectionchance > 10)
			D.infectionchance -= 10//The virus gets weaker as it jumps from people to people
		D.log += "<br />[timestamp()] Infected [key_name(M)] [notes]"
		M.virus2["[D.uniqueID]"] = D
		return 1
	return 0

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


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/proc/spread_disease_to(var/mob/living/carbon/infector, var/mob/living/carbon/victim, var/vector = "Airborne")
	if (infector == victim)
		return "retardation"

//	log_debug("Spreading [vector] diseases from [infector] to [victim]")
	if (infector.virus2.len > 0)
		for (var/ID in infector.virus2)
//		log_debug("Attempting to infect [key_name(victim)] with virus [ID].")
			var/datum/disease2/disease/V = infector.virus2[ID]
			if(V.spreadtype != vector)
				continue

			if (vector == "Airborne")
				if(airborne_can_reach(get_turf(infector), get_turf(victim)))
//					log_debug("In range, infecting")
					infect_virus2(victim,V, notes="(Airborne, from [key_name(infector)])")
				else
//					log_debug("Could not reach target")

			if (vector == "Contact")
				if (infector.Adjacent(victim))
//					log_debug("In range, infecting")
					infect_virus2(victim,V, notes="(Contact with [key_name(infector)])")

	//contact goes both ways
	if (victim.virus2.len > 0 && vector == "Contact")
//		log_debug("Spreading [vector] diseases from [victim] to [infector]")
		var/nudity = 1

		if (ishuman(victim) && ishuman(infector)) //Both are human, so the victim and infector can have a mutual zone selection
			var/mob/living/carbon/human/H = victim
			if(infector.zone_sel)
				var/datum/organ/external/select_area = H.get_organ(infector.zone_sel.selecting)
				var/list/clothes = list(H.head, H.wear_mask, H.wear_suit, H.w_uniform, H.gloves, H.shoes)
				for(var/obj/item/clothing/C in clothes )
					if(C && istype(C))
						if(C.body_parts_covered & select_area.body_part)
							nudity = 0
			else
				nudity = 0
		if (nudity)
			for (var/ID in victim.virus2)
				var/datum/disease2/disease/V = victim.virus2[ID]
				if(V && V.spreadtype != vector)
					continue
				infect_virus2(infector,V, notes="(Contact with [key_name(victim)])")
*/
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

/proc/filter_disease_by_spread(var/list/diseases = list(), var/required = 0, var/forbidden = 0)
	if (!diseases || diseases.len <= 0)
		return list()
	var/list/result = list()
	for (var/ID in diseases)
		var/datum/disease2/disease/V = diseases[ID]
		if ((!required || (V.spread & required)) && (!forbidden || !(V.spread & forbidden)))
			result[ID] = V
	return result
