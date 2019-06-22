
var/global/list/disease2_list = list()
/datum/disease2/disease
	var/form = "Virus"	//Virus, Bacteria, Parasite, Prion
	var/spread = SPREAD_BLOOD //if set to 0, the virus can never be transmitted or extracted from the carrier, therefore it cannot either be cured.
	var/uniqueID = 0// 0000 to 9999, set when the pathogen gets initially created
	var/subID = 0// 000 to 9999, set if the pathogen underwent effect or antigen mutation
	var/childID = 0// 01 to 99, incremented as the pathogen gets analyzed after a mutation
	var/list/datum/disease2/effect/effects = list()

	//When an opportunity for the disease to spread to a mob arrives, runs this percentage through prob()
	//Ignored if infected materials are ingested (injected with infected blood, eating infected meat)
	var/infectionchance = 70

	//ticks increases by [speed] every time the disease activates. Drinking Virus Food also accelerates the process by 10.
	var/ticks = 0
	var/speed = 1

	//stage increments if prob(stageprob) once there are enough ticks (100 per current stage), up to max_stage
	var/stage = 1
	var/max_stage = 4
	var/stageprob = 10
	//when spreading to another mob, that new carrier has the disease's stage reduced by stage_variance
	var/stage_variance = -1

	//the antibody concentration at which the disease will fully exit the body
	var/strength = 100

	//the percentage of the strength at which effects will start getting disabled by antibodies.
	var/robustness = 100

	//chance to cure the disease at every proc when the body is getting cooked alive.
	var/max_bodytemperature = 1000

	//very low temperatures will stop the disease from activating/progressing
	var/min_bodytemperature = 120

	//the disease's antigens, that the body's immune_system will read to produce corresponding antibodies. Without antigens, a disease cannot be cured.
	var/list/antigen = list()

	//logging
	var/log = ""
	var/logged_virusfood = 0
	var/fever_warning = 0

	//cosmetic
	var/color
	var/pattern = 1
	var/pattern_color


/datum/disease2/disease/bacteria//faster spread and progression, but only 3 stages max, and reset to stage 1 on every spread
	form = "Bacteria"
	max_stage = 3
	infectionchance = 90
	stageprob = 30
	stage_variance = -4

/datum/disease2/disease/parasite//slower spread. stage preserved on spread
	form = "Parasite"
	infectionchance = 50
	stageprob = 10
	stage_variance = 0

/datum/disease2/disease/prion//very fast progression, but very slow spread and resets to stage 1.
	form = "Prion"
	infectionchance = 10
	stageprob = 80
	stage_variance = -10

/datum/disease2/disease/New(var/notes="No notes.")
	uniqueID = rand(0,9999)
	subID = rand(0,9999)
	log_debug("[form] [uniqueID]-[subID] created with notes: [notes]")
	log += "<br />[timestamp()] CREATED - [notes]<br>"
	disease2_list["[uniqueID]-[subID]"] = src
	var/list/randomhexes = list("8","9","a","b","c","d","e")
	color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
	pattern = rand(1,6)
	pattern_color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
	..()

/datum/disease2/disease/proc/new_random_effect(var/max_badness = 5, var/min_badness = 0, var/stage = 0, var/old_effect)
	var/list/datum/disease2/effect/list = list()
	var/list/to_choose = subtypesof(/datum/disease2/effect)
	if(old_effect) //So it doesn't just evolve right back into the previous virus type
		to_choose.Remove(old_effect)
	for(var/e in to_choose)
		var/datum/disease2/effect/f = new e
		if(f.stage == stage && f.badness <= max_badness && f.badness >= min_badness)
			list += f
	var/datum/disease2/effect/e = pick(list)
	e.chance = rand(1, e.max_chance)
	return e

/datum/disease2/disease/proc/makerandom(var/greater = FALSE)
	log_debug("Randomizing [form][uniqueID] with greater=[greater]")
	for(var/i = 1; i <= max_stage; i++)
		if(greater)
			var/datum/disease2/effect/e = new_random_effect(5, 2, i)
			effects += e
			log += "<br />[timestamp()] Added effect [e.name] [e.chance]%."
		else
			var/datum/disease2/effect/e = new_random_effect(3, 0, i)
			effects += e
			log += "<br />[timestamp()] Added effect [e.name] [e.chance]%."
	var/variance = initial(infectionchance)/10
	infectionchance = rand(initial(infectionchance)-variance,initial(infectionchance)+variance)
	roll_antigen()

	//cosmetic petri dish stuff
	var/list/randomhexes = list("8","9","a","b","c","d","e")
	color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
	pattern = rand(1,6)
	pattern_color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
	randomize_spread()


/datum/disease2/disease/proc/randomize_spread()
	spread = SPREAD_BLOOD	//without blood spread, the disease cannot be extracted or cured, we don't want that for regular diseases
	if (prob(5))			//5% chance of spreading through both contact and the air.
		spread |= SPREAD_CONTACT
		spread |= SPREAD_AIRBORNE
	else if (prob(40))		//38% chance of spreading through the air only.
		spread |= SPREAD_AIRBORNE
	else if (prob(60))		//34,2% chance of spreading through contact only.
		spread |= SPREAD_CONTACT
							//22,8% chance of staying in blood

/datum/disease2/disease/proc/get_spread_string()
	var/dat = ""
	var/check = 0
	if (spread & SPREAD_BLOOD)
		dat += "Blood"
		check += SPREAD_BLOOD
		if (spread > check)
			dat += ", "
	if (spread & SPREAD_CONTACT)
		dat += "Contact"
		check += SPREAD_CONTACT
		if (spread > check)
			dat += ", "
	if (spread & SPREAD_AIRBORNE)
		dat += "Airborne"
		//check += SPREAD_AIRBORNE
		//if (spread > check)
		//	dat += ", "

	return dat

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

	disease2_list -= "[D.uniqueID]-[D.subID]"
	D.uniqueID = rand(0, 9999)
	D.subID = rand(0,9999)
	D.childID = 0
	disease2_list["[D.uniqueID]-[D.subID]"] = D
	D.infectionchance = input(C, "Choose an infection rate percent", "Infection Rate") as null | num
	if(!D.infectionchance || D.infectionchance > 100 || D.infectionchance < 0)
		return 0
	//pick random antigens for the disease to have
	D.roll_antigen()
	D.spread = 0
	if (alert("Can this virus spread into blood? (warning! if choosing No, this virus will be very hard to cure!)",,"Yes","No") == "Yes")
		D.spread |= SPREAD_BLOOD
	if (alert("Can this virus spread by contact?",,"Yes","No") == "Yes")
		D.spread |= SPREAD_CONTACT
	if (alert("Can this virus spread by the air?",,"Yes","No") == "Yes")
		D.spread |= SPREAD_AIRBORNE
	infectedMob.virus2["[D.uniqueID]-[D.subID]"] = D // assign the disease datum to the infectedMob/ selected user.
	log_admin("[infectedMob] was infected with a virus with uniqueID : [D.uniqueID]-[D.subID] by [C.ckey]")
	message_admins("[infectedMob] was infected with a virus with uniqueID : [D.uniqueID]-[D.subID] by [C.ckey]")
	return 1

/datum/disease2/disease/proc/activate(var/mob/living/mob,var/starved = FALSE)
	if(mob.stat == DEAD)
		return

	//Searing body temperatures cure diseases, on top of killing you.
	if(mob.bodytemperature > max_bodytemperature)
		cure(mob,1)
		return

	if(!mob.immune_system.CanInfect(src))
		cure(mob)
		return

	//Freezing body temperatures halt diseases completely
	if(mob.bodytemperature < min_bodytemperature)
		return

	//Virus food speeds up disease progress
	if(mob.reagents.has_reagent(VIRUSFOOD))
		mob.reagents.remove_reagent(VIRUSFOOD,0.1)
		if(!logged_virusfood)
			log += "<br />[timestamp()] Virus Fed ([mob.reagents.get_reagent_amount(VIRUSFOOD)]U)"
			logged_virusfood=1
		ticks += 10
	else
		logged_virusfood=0

	//Moving to the next stage
	if(ticks > stage*100 && prob(stageprob) && stage < max_stage)
		stage++
		log += "<br />[timestamp()] NEXT STAGE ([stage])"
		ticks = 0

	// This makes it so that <mob> only ever gets affected by the equivalent of one virus so antags don't just stack a bunch
	if(starved)
		return

	var/list/immune_data = GetImmuneData(mob)

	for(var/datum/disease2/effect/e in effects)
		if (e.can_run_effect(immune_data[1]))
			e.run_effect(mob)

	//fever is a reaction of the body's immune system to the infection. The higher the antibody concentration (and the disease still not cured), the higher the fever
	if (mob.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT)//but we won't go all the way to burning up just because of a fever, probably
		var/fever = round((robustness / 100) * (immune_data[2] / 10) * (stage / max_stage))
		switch (mob.size)
			if (SIZE_TINY)
				mob.bodytemperature += fever*0.2
			if (SIZE_SMALL)
				mob.bodytemperature += fever*0.5
			if (SIZE_NORMAL)
				mob.bodytemperature += fever
			if (SIZE_BIG)
				mob.bodytemperature += fever*1.5
			if (SIZE_HUGE)
				mob.bodytemperature += fever*2

		if (fever > 0  && prob(3))
			switch (fever_warning)
				if (0)
					to_chat(mob, "<span class='warning'>You feel a fever coming on, your body warms up and your head hurts a bit.</span>")
					fever_warning++
				if (1)
					if (mob.bodytemperature > 320)
						to_chat(mob, "<span class='warning'>Your palms are sweaty.</span>")
						fever_warning++
				if (2)
					if (mob.bodytemperature > 335)
						to_chat(mob, "<span class='warning'>Your knees are weak.</span>")
						fever_warning++
				if (3)
					if (mob.bodytemperature > 350)
						to_chat(mob, "<span class='warning'>Your arms are heavy.</span>")
						fever_warning++


	ticks += speed


/datum/disease2/disease/proc/incubate(var/atom/incubator,var/mutatechance=1)
	var/mob/living/body = null
	var/obj/item/weapon/virusdish/dish = null
	var/obj/machinery/disease2/incubator/machine = null

	if (isliving(incubator))
		body = incubator
	else if (istype(incubator,/obj/item/weapon/virusdish))
		dish = incubator
		if (istype(dish.loc,/obj/machinery/disease2/incubator))
			machine = dish.loc

	if ((body || dish) && incubator.reagents)
		if (incubator.reagents.has_reagent(MUTAGEN,0.5) && incubator.reagents.has_reagent(CREATINE,0.5))
			if(!incubator.reagents.remove_reagent(MUTAGEN,0.5) && !incubator.reagents.remove_reagent(CREATINE,0.5))
				log += "<br />[timestamp()] Robustness Strengthening (Mutagen and Creatine in [incubator])"
				var/change = rand(1,5)
				robustness = min(100,robustness + change)
				for(var/datum/disease2/effect/e in effects)
					e.multiplier_tweak(0.1)
				if (dish)
					if (machine)
						machine.update_minor(dish,0,change,0.1)
		else if (incubator.reagents.has_reagent(MUTAGEN,0.5) && incubator.reagents.has_reagent(SPACEACILLIN,0.5))
			if(!incubator.reagents.remove_reagent(MUTAGEN,0.5) && !incubator.reagents.remove_reagent(SPACEACILLIN,0.5))
				log += "<br />[timestamp()] Robustness Weakening (Mutagen and Spaceacillin in [incubator])"
				var/change = rand(1,5)
				robustness = max(0,robustness - change)
				for(var/datum/disease2/effect/e in effects)
					e.multiplier_tweak(-0.1)
				if (dish)
					if (machine)
						machine.update_minor(dish,0,-change,-0.1)
		else
			if(!incubator.reagents.remove_reagent(MUTAGEN,0.05) && prob(mutatechance))
				log += "<br />[timestamp()] Effect Mutation (Mutagen in [incubator])"
				effectmutate(body != null)
				if (dish)
					if(dish.info && dish.analysed)
						dish.info = "OUTDATED : [dish.info]"
						dish.analysed = 0
					dish.update_icon()
					if (machine)
						machine.update_major(dish)
			if(!incubator.reagents.remove_reagent(CREATINE,0.05) && prob(mutatechance))
				log += "<br />[timestamp()] Strengthening (Creatine in [incubator])"
				var/change = rand(1,5)
				strength = min(100,strength + change)
				if (dish)
					if (machine)
						machine.update_minor(dish,change)
			if(!incubator.reagents.remove_reagent(SPACEACILLIN,0.05) && prob(mutatechance))
				log += "<br />[timestamp()] Weakening (Spaceacillin in [incubator])"
				var/change = rand(1,5)
				strength = max(0,strength - change)
				if (dish)
					if (machine)
						machine.update_minor(dish,-change)
		if(!incubator.reagents.remove_reagent(RADIUM,0.02) && prob(mutatechance/8))
			log += "<br />[timestamp()] Antigen Mutation (Radium in [incubator])"
			antigenmutate()
			if (dish)
				if(dish.info && dish.analysed)
					dish.info = "OUTDATED : [dish.info]"
					dish.analysed = 0
				if (machine)
					machine.update_major(dish)


/datum/disease2/disease/proc/GetImmuneData(var/mob/living/mob)
	var/lowest_stage = stage
	var/highest_concentration = 0

	if (mob.immune_system)
		var/subdivision = (strength - ((robustness * strength) / 100)) / max_stage
		//for each antigen, we measure the corresponding antibody concentration in the carrier's immune system
		//the less robust the pathogen, the more likely that further stages' effects won't activate at a given concentration
		for (var/A in antigen)
			var/concentration = mob.immune_system.antibodies[A]
			highest_concentration = max(highest_concentration,concentration)
			var/i = lowest_stage
			while (i > 0)
				if (concentration > (strength - i * subdivision))
					lowest_stage = i-1
				i--

	return list(lowest_stage,highest_concentration)

/datum/disease2/disease/proc/cure(var/mob/living/carbon/mob,var/condition=0)
	switch (condition)
		if (0)
			log_debug("[form] [uniqueID]-[subID] in [key_name(mob)] has been cured, and is being removed from their body.")
		if (1)
			log_debug("[form] [uniqueID]-[subID] in [key_name(mob)] has died from extreme temperature inside their host, and is being removed from their body.")
		if (2)
			log_debug("[form] [uniqueID]-[subID] in [key_name(mob)] has been wiped out by an immunity overload.")
	for(var/datum/disease2/effect/e in effects)
		e.disable_effect(mob)
	mob.virus2.Remove("[uniqueID]-[subID]")
	var/list/V = filter_disease_by_spread(mob.virus2, required = SPREAD_CONTACT)
	if (V && V.len <= 0)
		infected_contact_mobs -= mob
		if (mob.pathogen)
			for (var/mob/living/L in science_goggles_wearers)
				if (L.client)
					L.client.images -= mob.pathogen

/datum/disease2/disease/proc/get_effect(var/index)
	if(!index)
		return pick(effects)
	return effects[Clamp(index,0,effects.len)]

/datum/disease2/disease/proc/roll_antigen()
	antigen = list(pick(all_antigens))
	antigen |= pick(all_antigens)


//Major Mutations
/datum/disease2/disease/proc/effectmutate(var/inBody=FALSE)
	subID = rand(0,9999)
	var/list/randomhexes = list("7","8","9","a","b","c","d","e")
	var/colormix = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
	color = BlendRGB(color,colormix,0.25)
	var/i = rand(1, effects.len)
	var/datum/disease2/effect/e = effects[i]
	var/datum/disease2/effect/f
	if (inBody)//mutations that occur directly in a body don't cause helpful symptoms to become deadly instantly.
		f = new_random_effect(min(5,e.badness+1), max(0,e.badness-1), e.stage, e.type)
	else
		f = new_random_effect(5, 0, e.stage, e.type)
	effects[i] = f
	log_debug("[form] [uniqueID]-[subID] has mutated [e.name] into [f.name].")
	log += "<br />[timestamp()] Mutated effect [e.name] [e.chance]% into [f.name] [f.chance]%."

/datum/disease2/disease/proc/antigenmutate()
	subID = rand(0,9999)
	var/old_dat = get_antigen_string()
	roll_antigen()
	log_debug("[form] [uniqueID]-[subID] has mutated its antigen from [old_dat] to [get_antigen_string()].")
	log += "<br />[timestamp()] Mutated antigen [old_dat] into [get_antigen_string()]."


//Minor Mutations
/datum/disease2/disease/proc/minormutate(var/index)
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


/datum/disease2/disease/proc/getcopy()
	var/datum/disease2/disease/disease = new /datum/disease2/disease("")
	disease.form=form
	disease.log=log
	disease.infectionchance = infectionchance
	disease.spread = spread
	disease.stageprob = stageprob
	disease.antigen   = antigen.Copy()
	disease.uniqueID = uniqueID
	disease.subID = subID
	disease.childID = childID
	disease.speed = speed
	disease.stage = stage
	disease.strength = strength
	disease.robustness = robustness
	disease.ticks = ticks
	disease.max_stage = max_stage
	disease.stage_variance = stage_variance
	disease.color = color
	disease.pattern = pattern
	disease.pattern_color = pattern_color
	for(var/datum/disease2/effect/e in effects)
		disease.effects += e.getcopy(disease)
	return disease


/proc/virus_copylist(var/list/datum/disease2/disease/viruses)
	var/list/res = list()
	for (var/ID in viruses)
		var/datum/disease2/disease/V = viruses[ID]
		if(istype(V))
			res["[V.uniqueID]-[V.subID]"] = V.getcopy()
		else
			testing("Got a NULL disease2 in virus_copylist ([V] is [V.type])!")
	return res


var/global/list/virusDB = list()

/datum/disease2/disease/proc/name(var/override=FALSE)
	.= "[form] #[add_zero("[uniqueID]", 4)][childID ? "-[add_zero("[childID]", 2)]" : ""]"
	if (!override && ("[uniqueID]-[subID]" in virusDB))
		var/datum/data/record/V = virusDB["[uniqueID]-[subID]"]
		.= V.fields["name"]

/datum/disease2/disease/proc/get_subdivisions_string()
	var/subdivision = (strength - ((robustness * strength) / 100)) / max_stage
	var/dat = "("
	for (var/i = 1 to max_stage)
		dat += "[round(strength - i * subdivision)]"
		if (i < max_stage)
			dat += ", "
	dat += ")"
	return dat

/datum/disease2/disease/proc/get_antigen_string()
	var/dat = ""
	for (var/A in antigen)
		dat += "[A]"
	return dat

/datum/disease2/disease/proc/get_info()
	var/r = "GNAv3 [name()]"
	r += "<BR>Strength / Robustness : <b>[strength]% / [robustness]%</b> - [get_subdivisions_string()]"
	r += "<BR>Infectability : <b>[infectionchance]%</b>"
	r += "<BR>Spread forms : <b>[get_spread_string()]</b>"
	r += "<BR>Progress Speed : <b>[stageprob]%</b>"
	r += "<dl>"
	for(var/datum/disease2/effect/e in effects)
		r += "<dt> &#x25CF; <b>Stage [e.stage] - [e.name]</b> (Danger: [e.badness]). Strength: <b>[e.multiplier]</b>. Occurence: <b>[e.chance]%</b>.</dt>"
		r += "<dd>[e.desc]</dd>"
	r += "</dl>"
	r += "<BR>Antigen pattern: [get_antigen_string()]"
	r += "<BR><i>last analyzed at: [worldtime2text()]</i>"
	return r

/datum/disease2/disease/proc/addToDB()
	if ("[uniqueID]-[subID]" in virusDB)
		return 0
	childID = 0
	for (var/virus_file in virusDB)
		var/datum/data/record/v = virusDB[virus_file]
		if (v.fields["id"] == uniqueID)
			childID++
	var/datum/data/record/v = new()
	v.fields["id"] = uniqueID
	v.fields["sub"] = subID
	v.fields["child"] = childID
	v.fields["form"] = form
	v.fields["name"] = name()
	v.fields["description"] = get_info()
	v.fields["antigen"] = antigen
	v.fields["spread type"] = get_spread_string()
	virusDB["[uniqueID]-[subID]"] = v
	return 1
