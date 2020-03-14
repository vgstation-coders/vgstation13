


/datum/immune_system
	var/mob/living/body = null
	var/strength = 1
	var/overloaded = FALSE
	var/list/antibodies = list(
		ANTIGEN_O	= 0,
		ANTIGEN_A	= 0,
		ANTIGEN_B	= 0,
		ANTIGEN_RH	= 0,
		ANTIGEN_Q	= 0,
		ANTIGEN_U	= 0,
		ANTIGEN_V	= 0,
		ANTIGEN_M	= 0,
		ANTIGEN_N	= 0,
		ANTIGEN_P	= 0,
		ANTIGEN_X	= 0,
		ANTIGEN_Y	= 0,
		ANTIGEN_Z	= 0,
		)

/datum/immune_system/New(var/mob/living/L)
	..()
	if (!L)
		qdel(src)
		return
	body = L

	for (var/antibody in antibodies)
		if (antibody in rare_antigens)
			antibodies[antibody] = rand(1,15)
			if (prob(5))
				antibodies[antibody] += 10
		if (antibody in common_antigens)
			antibodies[antibody] = rand(10,30)
		if (antibody in blood_antigens)
			antibodies[antibody] = rand(10,20)
			if (body.dna && body.dna.b_type)
				if (antibody == ANTIGEN_O)
					antibodies[antibody] += rand(12,15)
				if (antibody == ANTIGEN_A && findtext(body.dna.b_type,"A"))
					antibodies[antibody] += rand(12,15)
				if (antibody == ANTIGEN_B && findtext(body.dna.b_type,"B"))
					antibodies[antibody] += rand(12,15)
				if (antibody == ANTIGEN_RH && findtext(body.dna.b_type,"+"))
					antibodies[antibody] += rand(12,15)

/datum/immune_system/Destroy()
	if(body)
		body.immune_system = null
		body = null
	..()

/datum/immune_system/proc/transfer_to(var/mob/living/L)
	if (!L.immune_system)
		L.immune_system = new (L)

	L.immune_system.strength = strength
	L.immune_system.overloaded = overloaded
	L.immune_system.antibodies = antibodies.Copy()

/datum/immune_system/proc/GetImmunity()
	var/effective_strength = strength

	if (body)
		if (ismartian(body))
			effective_strength *= 0.5
		if (M_HULK in body.mutations)
			effective_strength *= 2

	return list(effective_strength, antibodies.Copy())

/datum/immune_system/proc/Overload()
	body.adjustToxLoss(100)
	body.apply_radiation(50, RAD_INTERNAL)
	body.bodytemperature = max(body.bodytemperature, BODYTEMP_HEAT_DAMAGE_LIMIT)
	to_chat(body, "<span class='danger'>A terrible fever assails your body, you feel ill as your immune system kicks into overdrive to drive away your infections.</span>")
	if (ishuman(body))
		var/mob/living/carbon/human/H = body
		H.vomit(0,1)//hope you're wearing a biosuit or you'll get reinfected from your vomit, lol
	for(var/ID in body.virus2)
		var/datum/disease2/disease/D = body.virus2[ID]
		D.cure(body,2)
	strength = 0
	overloaded = TRUE


//If even one antibody hass sufficient concentration, the disease won't be able to infect
/datum/immune_system/proc/CanInfect(var/datum/disease2/disease/disease)
	if (overloaded)
		return TRUE

	for (var/antigen in disease.antigen)
		if ((strength * antibodies[antigen]) >= disease.strength)
			return FALSE
	return TRUE

/datum/immune_system/proc/ApplyAntipathogenics(var/threshold)
	if (overloaded)
		return

	for (var/ID in body.virus2)
		var/datum/disease2/disease/disease = body.virus2[ID]
		for (var/A in disease.antigen)
			var/tally = 0.5
			if (isturf(body.loc) && body.lying)
				tally += 0.5
				var/obj/structure/bed/B = locate() in body.loc
				if (B && B.mob_lock_type == /datum/locking_category/buckle/bed)//fucking chairs n stuff
					tally += 1
				if (body.sleeping)
					if (tally < 2)
						tally += 1
					else
						tally += 2//if we're sleeping in a bed, we get up to 4
			else if(istype(body.loc, /obj/machinery/atmospherics/unary/cryo_cell))
				tally += 1.5
			else if(body.locked_to && istype(body.locked_to, /obj/item/critter_cage))
				tally += 2

			if (antibodies[A] < threshold)
				antibodies[A] = min(antibodies[A] + tally, threshold)//no overshooting here
			else
				if (prob(threshold) && prob(tally * 10) && prob((100 - antibodies[A])*100/(100-threshold)))//smaller and smaller chance for further increase
					antibodies[A] = min(antibodies[A] + 1, 100)


/datum/immune_system/proc/ApplyVaccine(var/list/antigen)
	if (overloaded)
		return

	for (var/A in antigen)
		antibodies[A] = min(antibodies[A] + 20, 100)
