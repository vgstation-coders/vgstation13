/datum/reagent/nanites
	name = "Nanomachines"
	id = "nanites"
	description = "Microscopic construction robots."
	reagent_state = LIQUID
	color = "#535E66" // rgb: 83, 94, 102

/datum/reagent/nanites/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)

	if(!holder) return
	src = null
	if( (prob(10) && method==TOUCH) || method==INGEST)
		M.contract_disease(new /datum/disease/robotic_transformation(0),1)

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = "xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	reagent_state = LIQUID
	color = "#535E66" // rgb: 83, 94, 102

/datum/reagent/xenomicrobes/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)

	if(!holder) return
	src = null
	if( (prob(10) && method==TOUCH) || method==INGEST)
		M.contract_disease(new /datum/disease/xeno_transformation(0),1)