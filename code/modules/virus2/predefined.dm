//Pre-Defined Global Diseases for use by nanites/wendigo/xenomicrobes/ect.




var/list/global_diseases = list()



/proc/create_global_diseases()
	for(var/datum/disease2/disease/predefined/disease_type in /datum/disease2/disease/predefined)
		new disease_type
	
	

/datum/disease2/disease/predefined
	var/category = ""

/datum/disease2/disease/predefined/New()
	antigen = list(pick(antigen_family(ANTIGEN_RARE)))
	antigen |= pick(antigen_family(ANTIGEN_RARE))
	uniqueID = rand(0,9999)
	subID = rand(0,9999)
	strength = rand(70,100)

	global_diseases[category] = src
	update_global_log()
	..()

/datum/disease2/disease/predefined/cyborg
	form = "Robotic Nanites"
	category = DISEASE_CYBORG
	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0
	can_kill = list()

	effects = list(
		new /datum/disease2/effect/cyborg_warning,
		new /datum/disease2/effect/cyborg_vomit,
		new /datum/disease2/effect/cyborg_limbs,
		new /datum/disease2/effect/cyborg
	)

	spread = SPREAD_BLOOD
	robustness = 100
	mutation_modifier = 0

	color = "#c0c2be"
	pattern = 1
	pattern_color = "#6b6967"

	origin = "Nanites Reagent"

/datum/disease2/disease/predefined/mommi
	form = "Robotic Nanites"
	category = DISEASE_MOMMI
	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0
	can_kill = list()

	effects = list(
		new /datum/disease2/effect/mommi_warning,
		new /datum/disease2/effect/mommi_shrink,
		new /datum/disease2/effect/mommi_hallucination,
		new /datum/disease2/effect/mommi
	)

	spread = SPREAD_BLOOD
	robustness = 100
	mutation_modifier = 0

	color = "#c0c2be"
	pattern = 1
	pattern_color = "#6b6967"

	origin = "Autism Nanites Reagent"

/datum/disease2/disease/predefined/xenomorph
	form = "Alien Microbes"
	category = DISEASE_XENO
	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0
	can_kill = list()

	effects = list(
		new /datum/disease2/effect/xenomorph_warning,
		new /datum/disease2/effect/xenomorph_babel,
		new /datum/disease2/effect/xenomorph_traits,
		new /datum/disease2/effect/xenomorph
	)

	spread = SPREAD_BLOOD
	robustness = 100
	mutation_modifier = 0

	color = "#76a843"
	pattern = 1
	pattern_color = "#5eff00"

	origin = "Xenomicrobes Reagent"

/datum/disease2/disease/predefined/wendigo
	form = "malicious entity"
	category = DISEASE_WENDIGO
	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0
	can_kill = list()

	effects = list(
		new /datum/disease2/effect/wendigo_warning,
		new /datum/disease2/effect/wendigo_vomit,
		new /datum/disease2/effect/wendigo_hallucination,
		new /datum/disease2/effect/wendigo
	)

	spread = SPREAD_BLOOD
	robustness = 100
	mutation_modifier = 0

	color = "#353535"
	pattern = 2
	pattern_color = "#3f0606"

	origin = "Wendigo Meat"