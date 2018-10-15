var/global/list/disease2_list = list()
/datum/disease2/disease
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
	var/patient_zero = FALSE // Bypasses the roll for natural antibodies if true

	var/log = ""
	var/logged_virusfood=0

/datum/disease2/disease/New(var/notes="No notes.")
	uniqueID = rand(0,10000)
	log_debug("Virus [uniqueID] created with notes: [notes]")
	log += "<br />[timestamp()] CREATED - [notes]<br>"
	disease2_list["[uniqueID]"] = src
	..()

/datum/disease2/disease/proc/new_random_effect(var/max_badness = 1, var/stage = 0)
	var/list/datum/disease2/effect/list = list()
	for(var/e in typesof(/datum/disease2/effect))
		var/datum/disease2/effect/f = new e
		if(f.stage == stage && f.badness <= max_badness)
			list += f
	var/datum/disease2/effect/e = pick(list)
	e.chance = rand(1, e.max_chance)
	return e

/datum/disease2/disease/proc/makerandom(var/greater = FALSE, var/pz)
	log_debug("Randomizing virus [uniqueID] with greater=[greater]")
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
	infectionchance = rand(60,90)
	antigen |= text2num(pick(ANTIGENS))
	antigen |= text2num(pick(ANTIGENS))
	spreadtype = prob(70) ? "Airborne" : prob(20) ? "Blood" :"Contact" //Try for airborne then try for blood.
	patient_zero = pz

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
	D.patient_zero = TRUE

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


	if(mob.stat == 2)
		return
	if(stage <= 1 && clicks == 0 && !patient_zero) 	// with a certain chance, the mob may become immune to the disease before it starts properly. Not if they're patient zero though.
		if(prob(5))
			log_debug("[key_name(mob)] rolled for starting immunity against virus [uniqueID] and received antigens [antigens2string(antigen)].")
			mob.antibodies |= antigen // 20% immunity is a good chance IMO, because it allows finding an immune person easily
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
	if(clicks > stage*100 && prob(stageprob))
		if(stage == max_stage)
			log_debug("Virus [uniqueID] in [key_name(mob)] has advanced past its last stage, giving them antigens [antigens2string(antigen)].")
			src.cure(mob)
			mob.antibodies |= src.antigen
			log += "<br />[timestamp()] STAGEMAX ([stage])"
			return
		else
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
	log_debug("Virus [uniqueID] in [key_name(mob)] has been cured and is being removed from their body.")
	for(var/datum/disease2/effect/e in effects)
		e.disable_effect(mob)
	mob.virus2.Remove("[uniqueID]")

/datum/disease2/disease/proc/minormutate()
	//uniqueID = rand(0,10000)
	var/datum/disease2/effect/e = pick(effects)
	e.minormutate()
	infectionchance = min(50,infectionchance + rand(0,10))
	log += "<br />[timestamp()] Infection chance now [infectionchance]%"

/datum/disease2/disease/proc/majormutate()
	uniqueID = rand(0,10000)
	var/i = rand(1, effects.len)
	var/datum/disease2/effect/e = effects[i]
	var/datum/disease2/effect/f = new_random_effect(2, e.stage)
	effects[i] = f
	log_debug("Virus [uniqueID] has major mutated [e.name] into [f.name].")
	log += "<br />[timestamp()] Mutated effect [e.name] [e.chance]% into [f.name] [f.chance]%."
	if (prob(5))
		antigen = text2num(pick(ANTIGENS))
		antigen |= text2num(pick(ANTIGENS))

/datum/disease2/disease/proc/getcopy()
	var/datum/disease2/disease/disease = new /datum/disease2/disease("")
	disease.log=log
	disease.infectionchance = infectionchance
	disease.spreadtype = spreadtype
	disease.stageprob = stageprob
	disease.antigen   = antigen
	disease.uniqueID = uniqueID
	disease.speed = speed
//	disease.stage = stage
//	disease.clicks = clicks
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
	.= "stamm #[add_zero("[uniqueID]", 4)]"
	if ("[uniqueID]" in virusDB)
		var/datum/data/record/V = virusDB["[uniqueID]"]
		.= V.fields["name"]

/datum/disease2/disease/proc/get_info()
	var/r = "GNAv2 based virus lifeform - [name()], #[add_zero("[uniqueID]", 4)]"
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
