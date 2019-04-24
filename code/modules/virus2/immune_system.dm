


/datum/immune_system
	var/mob/living/body = null
	var/strength = 1
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
		del(src)
		return
	body = L

	for (var/antibody in antibodies)
		if (antibody in rare_antigens)
			antibodies[antibody] = rand(1,10)
		if (antibody in common_antigens)
			antibodies[antibody] = rand(5,15)
		if (antibody in blood_antigens)
			antibodies[antibody] = rand(10,15)
			if (body.dna && body.dna.b_type)
				if (antibody == ANTIGEN_O)
					antibodies[antibody] += rand(12,15)
				if (antibody == ANTIGEN_A && findtext(body.dna.b_type,"A"))
					antibodies[antibody] += rand(12,15)
				if (antibody == ANTIGEN_B && findtext(body.dna.b_type,"B"))
					antibodies[antibody] += rand(12,15)
				if (antibody == ANTIGEN_RH && findtext(body.dna.b_type,"+"))
					antibodies[antibody] += rand(12,15)

//If even one antibody hass sufficient concentration, the disease won't be able to infect
/datum/immune_system/proc/CanInfect(var/datum/disease2/disease/disease)
	for (var/antigen in disease.antigen)
		if ((strength * antibodies[antigen]) >= disease.strength)
			return FALSE
	return TRUE
