//Returns 1 if mob can be infected, 0 otherwise. Checks his clothing.
proc/get_infection_chance(var/mob/living/carbon/M, var/vector = "Airborne")
	var/score = 0 // full protection at 100, none at 0, quadratic in between: having more protection helps less if you already have lots of it
	if (!istype(M))
		return 0

	if(istype(M, /mob/living/carbon/human))

		if (vector == "Airborne")
			if(M.internal)	//not breathing infected air helps greatly
				score += 100
			if(M.wear_mask)
				score += 15
				if(istype(M:wear_mask, /obj/item/clothing/mask/surgical) && !M.internal)
					score += 35
			if(istype(M:wear_suit, /obj/item/clothing/suit/space) && istype(M:head, /obj/item/clothing/head/helmet/space))
				score += 50
			if(istype(M:wear_suit, /obj/item/clothing/suit/bio_suit) && istype(M:head, /obj/item/clothing/head/bio_hood))
				score += 50

		if (vector == "Contact")
			if(M:gloves)
				score += 50
			if(istype(M:wear_suit, /obj/item/clothing/suit/space))
				score += 35
			if(istype(M:wear_suit, /obj/item/clothing/suit/bio_suit))
				score += 35

//	log_debug("[M]'s resistance to [vector] viruses: [score]")

	if(prob((min(score, 100) - 100) ** 2 / 100))
	//	log_debug("Infection got through")
		return 1
	return 0

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

//Attemptes to infect mob M with virus. Set forced to 1 to ignore protective clothing.  Returns 1 if successful.
/proc/infect_virus2(var/mob/living/carbon/M,var/datum/disease2/disease/disease,var/forced = 0, var/notes="")
	if(!istype(disease))
//		log_debug("Bad virus")
		return 0
	if(!istype(M))
//		log_debug("Bad mob")
		return 0
	if ("[disease.uniqueID]" in M.virus2)
		return 0
	// if one of the antibodies in the mob's body matches one of the disease's antigens, don't infect
	if(M.antibodies & disease.antigen != 0)
		return 0

//	log_debug("Infecting [M]")

	if(prob(disease.infectionchance) || forced)
		// certain clothes can prevent an infection
		if(!forced && !get_infection_chance(M, disease.spreadtype))
			return

		var/datum/disease2/disease/D = disease.getcopy()
		D.minormutate()
//		log_debug("Adding virus")
		log_debug("[key_name(M)] infected with [disease.uniqueID]: forced=[forced], notes=[notes].")
		D.log += "<br />[timestamp()] Infected [key_name(M)] [notes]"
		M.virus2["[D.uniqueID]"] = D
		return 1
	return 0

//Infects mob M with random lesser disease, if he doesn't have one
/proc/infect_mob_random_lesser(var/mob/living/carbon/M)
	var/datum/disease2/disease/D = new /datum/disease2/disease("infect_mob_random_lesser")
	D.makerandom()
	D.infectionchance = 1
	M.virus2["[D.uniqueID]"] = D

//Infects mob M with random greated disease, if he doesn't have one
/proc/infect_mob_random_greater(var/mob/living/carbon/M)
	var/datum/disease2/disease/D = new /datum/disease2/disease("infect_mob_random_greater")
	D.makerandom(1)
	M.virus2["[D.uniqueID]"] = D

//Fancy prob() function.
/proc/dprob(var/p)
	return(prob(sqrt(p)) && prob(sqrt(p)))

/mob/living/carbon/proc/spread_disease_to(var/mob/living/carbon/victim, var/vector = "Airborne")
	if (src == victim)
		return "retardation"

//	log_debug("Spreading [vector] diseases from [src] to [victim]")
	if (virus2.len > 0)
		for (var/ID in virus2)
			// log_debug("Attempting to infect [key_name(victim)] with virus [ID].")
			var/datum/disease2/disease/V = virus2[ID]
			if(V.spreadtype != vector)
				continue

			if (vector == "Airborne")
				if(airborne_can_reach(get_turf(src), get_turf(victim)))
//					log_debug("In range, infecting")
					infect_virus2(victim,V, notes="(Airborne, from [key_name(src)])")
				else
//					log_debug("Could not reach target")

			if (vector == "Contact")
				if (Adjacent(victim))
//					log_debug("In range, infecting")
					infect_virus2(victim,V, notes="(Contact with [key_name(src)])")

	//contact goes both ways
	if (victim.virus2.len > 0 && vector == "Contact")
//		log_debug("Spreading [vector] diseases from [victim] to [src]")
		var/nudity = 1

		if (ishuman(victim))
			var/mob/living/carbon/human/H = victim
			var/datum/organ/external/select_area = H.get_organ(src.zone_sel.selecting)
			var/list/clothes = list(H.head, H.wear_mask, H.wear_suit, H.w_uniform, H.gloves, H.shoes)
			for(var/obj/item/clothing/C in clothes )
				if(C && istype(C))
					if(C.body_parts_covered & select_area.body_part)
						nudity = 0
		if (nudity)
			for (var/ID in victim.virus2)
				var/datum/disease2/disease/V = victim.virus2[ID]
				if(V && V.spreadtype != vector)
					continue
				infect_virus2(src,V, notes="(Contact with [key_name(victim)])")
