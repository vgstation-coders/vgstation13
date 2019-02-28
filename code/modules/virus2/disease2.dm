var/global/list/disease2_list = list()
/datum/disease2/disease
	var/form = "Virus"
	var/infectionchance = 70
	var/speed = 1
	var/spreadtype = "Contact" // Can also be "Airborne" or "Blood"
	var/stage = 1
	var/stageprob = 10
	var/dead = 0
	var/clicks = 0
	var/uniqueID = 0
	var/list/datum/disease2/effect/effects = list()
	var/antigen = 0 // 16 bits describing the antigens, when one bit is set, a cure with that bit can dock here
	var/max_stage = 4
	var/stage_variance = -1
	var/log = ""
	var/logged_virusfood=0

/datum/disease2/disease/New(var/notes="No notes.")
	uniqueID = rand(0,10000)
	log_debug("[form] [uniqueID] created with notes: [notes]")
	log += "<br />[timestamp()] CREATED - [notes]<br>"
	disease2_list["[uniqueID]"] = src
	..()

/datum/disease2/disease/proc/new_random_effect(var/max_badness = 1, var/stage = 0, var/old_effect)
	var/list/datum/disease2/effect/list = list()
	var/list/to_choose = subtypesof(/datum/disease2/effect)
	if(old_effect) //So it doesn't just evolve right back into the previous virus type
		to_choose.Remove(old_effect)
	for(var/e in to_choose)
		var/datum/disease2/effect/f = new e
		if(f.stage == stage && f.badness <= max_badness)
			list += f
	var/datum/disease2/effect/e = pick(list)
	e.chance = rand(1, e.max_chance)
	return e

/datum/disease2/disease/proc/makerandom(var/greater = FALSE)
	log_debug("Randomizing [form][uniqueID] with greater=[greater]")
	for(var/i = 1; i <= max_stage; i++)
		if(greater)
			var/datum/disease2/effect/e = new_random_effect(2, i)
			effects += e
			log += "<br />[timestamp()] Added effect [e.name] [e.chance]%."
		else
			var/datum/disease2/effect/e = new_random_effect(1, i)
			effects += e
			log += "<br />[timestamp()] Added effect [e.name] [e.chance]%."
	uniqueID = rand(0,10000)
	disease2_list["[uniqueID]"] = src
	var/variance = initial(infectionchance)/10
	infectionchance = rand(initial(infectionchance)-variance,initial(infectionchance)+variance)
	antigen |= text2num(pick(ANTIGENS))
	antigen |= text2num(pick(ANTIGENS))
	spreadtype = prob(40) ? "Airborne" : prob(40) ? "Blood" :"Contact" //Try for airborne then try for blood.

/proc/virus2_make_custom(client/C)
	if(!C.holder || !istype(C))
		return 0
	if(!(C.holder.rights & R_DEBUG))
		return 0
	var/mob/living/carbon/infectedMob = input(C, "Select person to infect", "Infect Person") in (player_list) // get the selected mob
	if(!istype(infectedMob))
		return // return if isn't proper mob type
	var/datum/disease2/disease/D = new /datum/disease2/disease("custom_disease") //set base name
	for(var/i = 1; i <= D.max_stage; i++)  // run through this loop until everything is set
		var/datum/disease2/effect/symptom = input(C, "Choose a symptom to add ([5-i] remaining)", "Choose a Symptom") as null | anything in (typesof(/datum/disease2/effect))
		if (!symptom)
			return 0
			// choose a symptom from the list of them
		var/datum/disease2/effect/e = new symptom(D)
		e.chance = input(C, "Choose chance", "Chance") as null | num
			// set the chance of the symptom that can occur
		if(!e.chance || e.chance > 100 || e.chance < 0)
			return 0
		D.log += "Added [e.name] at [e.chance]% chance<br>"
		D.effects += e

	disease2_list -= D.uniqueID
	D.uniqueID = rand(0, 10000)
	disease2_list["[D.uniqueID]"] = D
	D.infectionchance = input(C, "Choose an infection rate percent", "Infection Rate") as null | num
	if(!D.infectionchance || D.infectionchance > 100 || D.infectionchance < 0)
		return 0
	//pick random antigens for the disease to have
	D.antigen |= text2num(pick(ANTIGENS))
	D.antigen |= text2num(pick(ANTIGENS))
	D.spreadtype = input(C, "Select spread type", "Spread Type") as null | anything in list("Airborne", "Contact", "Blood") // select how the disease is spread
	if (!D.spreadtype)
		return 0
	infectedMob.virus2["[D.uniqueID]"] = D // assign the disease datum to the infectedMob/ selected user.
	log_admin("[infectedMob] was infected with a virus with uniqueID : [D.uniqueID] by [C.ckey]")
	message_admins("[infectedMob] was infected with a virus with uniqueID : [D.uniqueID] by [C.ckey]")
	return 1

/datum/disease2/disease/proc/activate(var/mob/living/carbon/mob)
	if(dead)
		cure(mob)
		return


	if(mob.stat == 2) //Dead, brown bread
		return
/*
	if(mob.radiation > 50)
		if(prob(1))
			majormutate()
			log += "<br />[timestamp()] MAJORMUTATE (rads)!"
*/

	//Space antibiotics stop disease completely (temporary)
	if(mob.reagents.has_reagent(SPACEACILLIN))
		return

	//Virus food speeds up disease progress
	if(mob.reagents.has_reagent(VIRUSFOOD))
		mob.reagents.remove_reagent(VIRUSFOOD,0.1)
		if(!logged_virusfood)
			log += "<br />[timestamp()] Virus Fed ([mob.reagents.get_reagent_amount(VIRUSFOOD)]U)"
			logged_virusfood=1
		clicks += 10
	else
		logged_virusfood=0

	//Moving to the next stage
	if(clicks > stage*100 && prob(stageprob) && stage < max_stage)
		stage++
		log += "<br />[timestamp()] NEXT STAGE ([stage])"
		clicks = 0

	// This makes it so that <mob> only ever gets affected by the equivalent of one virus so antags don't just stack a bunch
	if(prob(100 - (100 / mob.virus2.len)))
		return

	//Do nasty effects
	for(var/datum/disease2/effect/e in effects)
		if (e.can_run_effect(stage))
			e.run_effect(mob)

	//Short airborne spread
	if(src.spreadtype == "Airborne")
		for(var/mob/living/carbon/M in oview(1,mob))
			if(airborne_can_reach(get_turf(mob), get_turf(M)))
				infect_virus2(M,src, notes="(Airborne from [key_name(mob)])")
		for(var/mob/living/simple_animal/mouse/MM in oview(1,mob))
			if(airborne_can_reach(get_turf(mob), get_turf(MM)))
				infect_virus2(MM,src, notes="(Airborne from [key_name(mob)])")

	//fever
	mob.bodytemperature = max(mob.bodytemperature, min(310+5*stage ,mob.bodytemperature+5*stage))
	clicks+=speed

/datum/disease2/disease/proc/cure(var/mob/living/carbon/mob)
	log_debug("[form] [uniqueID] in [key_name(mob)] has been cured and is being removed from their body.")
	for(var/datum/disease2/effect/e in effects)
		e.disable_effect(mob)
	mob.virus2.Remove("[uniqueID]")

/datum/disease2/disease/proc/minormutate(var/index)
	//uniqueID = rand(0,10000)
	var/datum/disease2/effect/e = get_effect(index)
	e.minormutate()
	infectionchance = min(50,infectionchance + rand(0,10))
	log += "<br />[timestamp()] Infection chance now [infectionchance]%"

/datum/disease2/disease/proc/minorstrength(var/index)
	var/datum/disease2/effect/e = get_effect(index)
	e.multiplier_tweak(0.1)

/datum/disease2/disease/proc/minorweak(var/index)
	var/datum/disease2/effect/e = get_effect(index)
	e.multiplier_tweak(-0.1)

/datum/disease2/disease/proc/get_effect(var/index)
	if(!index)
		return pick(effects)
	return effects[Clamp(index,0,effects.len)]

/datum/disease2/disease/proc/majormutate()
	uniqueID = rand(0,10000)
	var/i = rand(1, effects.len)
	var/datum/disease2/effect/e = effects[i]
	var/datum/disease2/effect/f = new_random_effect(2, e.stage, e.type)
	effects[i] = f
	log_debug("[form] [uniqueID] has major mutated [e.name] into [f.name].")
	log += "<br />[timestamp()] Mutated effect [e.name] [e.chance]% into [f.name] [f.chance]%."
	if (prob(5))
		antigen = text2num(pick(ANTIGENS))
		antigen |= text2num(pick(ANTIGENS))

/datum/disease2/disease/proc/getcopy()
	var/datum/disease2/disease/disease = new /datum/disease2/disease("")
	disease.form=form
	disease.log=log
	disease.infectionchance = infectionchance
	disease.spreadtype = spreadtype
	disease.stageprob = stageprob
	disease.antigen   = antigen
	disease.uniqueID = uniqueID
	disease.speed = speed
	disease.stage = Clamp(stage+stage_variance, 1, max_stage)
	disease.clicks = clicks
	disease.max_stage = max_stage
	disease.stage_variance = stage_variance
	for(var/datum/disease2/effect/e in effects)
		disease.effects += e.getcopy(disease)
	return disease

/datum/disease2/disease/proc/issame(var/datum/disease2/disease/disease)
	var/list/types = list()
	var/list/types2 = list()
	for(var/datum/disease2/effect/e in effects)
		types += e.type
	var/equal = 1

	for(var/datum/disease2/effect/e in disease.effects)
		types2 += e.type

	for(var/type in types)
		if(!(type in types2))
			equal = 0

	if (antigen != disease.antigen)
		equal = 0
	return equal

/proc/virus_copylist(var/list/datum/disease2/disease/viruses)
	var/list/res = list()
	for (var/ID in viruses)
		var/datum/disease2/disease/V = viruses[ID]
		if(istype(V))
			res["[V.uniqueID]"] = V.getcopy()
		else
			testing("Got a NULL disease2 in virus_copylist ([V] is [V.type])!")
	return res


var/global/list/virusDB = list()

/datum/disease2/disease/proc/name()
	.= "[form] #[add_zero("[uniqueID]", 4)]"
	if ("[uniqueID]" in virusDB)
		var/datum/data/record/V = virusDB["[uniqueID]"]
		.= V.fields["name"]

/datum/disease2/disease/proc/get_info()
	var/r = "GNAv2 [name()]"
	r += "<BR>Infection rate : [infectionchance]"
	r += "<BR>Spread form : [spreadtype]"
	r += "<BR>Progress Speed : [stageprob]"
	for(var/datum/disease2/effect/e in effects)
		r += "<BR>Effect:[e.name]. Strength : [e.multiplier]. Verosity : [e.chance]. Type : [e.stage]."

	r += "<BR>Antigen pattern: [antigens2string(antigen)]"
	return r

/datum/disease2/disease/proc/addToDB()
	if ("[uniqueID]" in virusDB)
		return 0
	var/datum/data/record/v = new()
	v.fields["id"] = uniqueID
	v.fields["form"] = form
	v.fields["name"] = name()
	v.fields["description"] = get_info()
	v.fields["antigen"] = antigens2string(antigen)
	v.fields["spread type"] = spreadtype
	virusDB["[uniqueID]"] = v
	return 1

proc/virus2_lesser_infection()
	var/list/candidates = list()	//list of candidate keys

	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G
	if(!candidates.len)
		return

	candidates = shuffle(candidates)

	infect_mob_random_lesser(candidates[1])

proc/virus2_greater_infection()
	var/list/candidates = list()	//list of candidate keys

	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G
	if(!candidates.len)
		return

	candidates = shuffle(candidates)

	infect_mob_random_greater(candidates[1])

/datum/disease2/disease/bacteria
	form = "Bacteria"
	max_stage = 3
	infectionchance = 90
	stageprob = 30
	stage_variance = -4

/datum/disease2/disease/parasite
	form = "Parasite"
	infectionchance = 50
	stageprob = 10
	stage_variance = 0

/datum/disease2/disease/prion
	form = "Prion"
	infectionchance = 10
	stageprob = 80
	stage_variance = -10