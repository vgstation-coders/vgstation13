
/mob/living/proc/HasDisease(datum/disease/D)
	for(var/thing in diseases)
		var/datum/disease/DD = thing
		if(D.IsSame(DD))
			return TRUE
	return FALSE


/mob/living/proc/CanContractDisease(datum/disease/D)
	if(stat == DEAD)
		return FALSE

	if(D.GetDiseaseID() in disease_resistances)
		return FALSE

	if(HasDisease(D))
		return FALSE

	if(!(type in D.viable_mobtypes))
		return FALSE

	return TRUE


/mob/living/proc/ContactContractDisease(datum/disease/D)
	if(!CanContractDisease(D))
		return FALSE
	D.try_infect(src)


/mob/living/carbon/ContactContractDisease(datum/disease/D, target_zone)
	if(!CanContractDisease(D))
		return FALSE

	var/obj/item/clothing/Cl = null
	var/passed = TRUE

	var/head_ch = 80
	var/body_ch = 100
	var/hands_ch = 35
	var/feet_ch = 15

	if(prob(15/D.permeability_mod))
		return

	if(satiety>0 && prob(satiety/10)) // positive satiety makes it harder to contract the disease.
		return

	//Lefts and rights do not matter for arms and legs, they both run the same checks
	if(!target_zone)
		target_zone = pick(head_ch;BODY_ZONE_HEAD,body_ch;BODY_ZONE_CHEST,hands_ch;BODY_ZONE_L_ARM,feet_ch;BODY_ZONE_L_LEG)
	else
		target_zone = check_zone(target_zone)

	if(ishuman(src))
		var/mob/living/carbon/human/H = src

		switch(target_zone)
			if(BODY_ZONE_HEAD)
				if(isobj(H.head) && !istype(H.head, /obj/item/paper))
					Cl = H.head
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(H.wear_mask))
					Cl = H.wear_mask
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(H.wear_neck))
					Cl = H.wear_neck
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if(BODY_ZONE_CHEST)
				if(isobj(H.wear_suit))
					Cl = H.wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(slot_w_uniform))
					Cl = slot_w_uniform
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
				if(isobj(H.wear_suit) && H.wear_suit.body_parts_covered&HANDS)
					Cl = H.wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)

				if(passed && isobj(H.gloves))
					Cl = H.gloves
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
				if(isobj(H.wear_suit) && H.wear_suit.body_parts_covered&FEET)
					Cl = H.wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)

				if(passed && isobj(H.shoes))
					Cl = H.shoes
					passed = prob((Cl.permeability_coefficient*100) - 1)

	else if(ismonkey(src))
		var/mob/living/carbon/monkey/M = src
		switch(target_zone)
			if(BODY_ZONE_HEAD)
				if(M.wear_mask && isobj(M.wear_mask))
					Cl = M.wear_mask
					passed = prob((Cl.permeability_coefficient*100) - 1)

	if(passed)
		D.try_infect(src)

/mob/living/proc/AirborneContractDisease(datum/disease/D, force_spread)
	if( ((D.spread_flags & DISEASE_SPREAD_AIRBORNE) || force_spread) && prob((50*D.permeability_mod) - 1))
		ForceContractDisease(D)

/mob/living/carbon/AirborneContractDisease(datum/disease/D, force_spread)
	if(internal)
		return
	if(has_trait(TRAIT_NOBREATH))
		return
	..()


//Proc to use when you 100% want to try to infect someone (ignoreing protective clothing and such), as long as they aren't immune
/mob/living/proc/ForceContractDisease(datum/disease/D, make_copy = TRUE, del_on_fail = FALSE)
	if(!CanContractDisease(D))
		if(del_on_fail)
			qdel(D)
		return FALSE
	if(!D.try_infect(src, make_copy))
		if(del_on_fail)
			qdel(D)
		return FALSE
	return TRUE


/mob/living/carbon/human/CanContractDisease(datum/disease/D)
	if(dna)
		if(has_trait(TRAIT_VIRUSIMMUNE) && !D.bypasses_immunity)
			return FALSE

		var/can_infect = FALSE
		for(var/host_type in D.infectable_hosts)
			if(host_type in dna.species.species_traits)
				can_infect = TRUE
				break
		if(!can_infect)
			return FALSE

	for(var/thing in D.required_organs)
		if(!((locate(thing) in bodyparts) || (locate(thing) in internal_organs)))
			return FALSE
	return ..()
