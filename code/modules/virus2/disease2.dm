
var/global/list/disease2_list = list()
/datum/disease2/disease
	var/form = "Virus"	//Virus, Bacteria, Parasite, Prion
	var/spread = 0 //if it remains at 0, the virus can never be transmitted or extracted from the carrier, therefore it cannot either be cured.
	var/uniqueID = 0// 0000 to 9999, set when the pathogen gets initially created
	var/subID = 0// 000 to 9999, set if the pathogen underwent effect or antigen mutation
	var/childID = 0// 01 to 99, incremented as the pathogen gets analyzed after a mutation
	var/list/datum/disease2/effect/effects = list()

	//When an opportunity for the disease to spread to a mob arrives, runs this percentage through prob()
	//Ignored if infected materials are ingested (injected with infected blood, eating infected meat)
	var/infectionchance = 70
	var/infectionchance_base = 70

	//alters a pathogen's propensity to mutate. Set to 0 to forbid a pathogen from ever mutating.
	var/mutation_modifier = 1

	//ticks increases by [speed] every time the disease activates. Drinking Virus Food also accelerates the process by 10.
	var/ticks = 0
	var/speed = 1

	//stage increments if prob(stageprob) once there are enough ticks (100 per current stage), up to max_stage
	var/stage = 1
	var/max_stage = 4
	var/stageprob = 10
	//when spreading to another mob, that new carrier has the disease's stage reduced by stage_variance
	var/stage_variance = -1
	//bitflag showing which transmission types are allowed for this disease
	var/allowed_transmission = SPREAD_BLOOD | SPREAD_CONTACT | SPREAD_AIRBORNE

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
	var/origin = "Unknown"
	var/logged_virusfood = 0
	var/fever_warning = 0

	//cosmetic
	var/color
	var/pattern = 1
	var/pattern_color

	//pathogenic warfare
	var/list/can_kill = list("Bacteria")

/datum/disease2/disease/virus
	form = "Virus"
	max_stage = 4
	infectionchance = 70
	infectionchance_base = 70
	stageprob = 10
	stage_variance = -1
	can_kill = list("Bacteria")

/datum/disease2/disease/bacteria//faster spread and progression, but only 3 stages max, and reset to stage 1 on every spread
	form = "Bacteria"
	max_stage = 3
	infectionchance = 90
	infectionchance_base = 90
	stageprob = 30
	stage_variance = -4
	can_kill = list("Parasite")

/datum/disease2/disease/parasite//slower spread. stage preserved on spread
	form = "Parasite"
	infectionchance = 50
	infectionchance_base = 50
	stageprob = 10
	stage_variance = 0
	can_kill = list("Virus")

/datum/disease2/disease/prion//very fast progression, but very slow spread and resets to stage 1.
	form = "Prion"
	infectionchance = 10
	infectionchance_base = 10
	stageprob = 80
	stage_variance = -10
	can_kill = list()

/datum/disease2/disease/fungus //most infectious, but with a greater stage setback; has special transmission
	form = "Fungus"
	infectionchance = 100
	infectionchance_base = 100
	stageprob = 15
	stage_variance = -2
	allowed_transmission = SPREAD_BLOOD | SPREAD_CONTACT | SPREAD_AIRBORNE | SPREAD_COLONY

/datum/disease2/disease/meme //infectious and fast progressing, but limited stages; has special transmission
	form = "Meme"
	max_stage = 2
	infectionchance = 70
	infectionchance_base = 70
	stageprob = 30
	stage_variance = -1
	allowed_transmission = SPREAD_BLOOD | SPREAD_MEMETIC
	//Note: if more types of creatures become infectable than humans/monkeys/mice, give them HEAR_ALWAYS

/datum/disease2/disease/proc/update_global_log()
	if ("[uniqueID]-[subID]" in disease2_list)
		return
	disease2_list["[uniqueID]-[subID]"] = getcopy()


/datum/disease2/disease/proc/clean_global_log()
	var/ID = "[uniqueID]-[subID]"
	if (ID in virusDB)
		return
	for (var/mob/living/L in mob_list)
		if (ID in L.virus2)
			return
	for (var/obj/item/I in infected_items)
		if (ID in I.virus2)
			return
	var/dishes = 0
	for (var/obj/item/weapon/virusdish/dish in virusdishes)
		if (dish.contained_virus)
			if (ID == "[dish.contained_virus.uniqueID]-[dish.contained_virus.subID]")
				dishes++
				if (dishes > 1)//counting the dish we're in currently
					return
	//If a pathogen that isn't in the database mutates, we check whether it infected anything, and remove it from the disease list if it didn't
	//so we don't clog up the Diseases Panel with irrelevant mutations
	disease2_list -= ID

/datum/disease2/disease/proc/makerandom(var/list/str = list(), var/list/rob = list(), var/list/anti = list(), var/list/bad = list(), var/atom/source = null)
	//ID
	uniqueID = rand(0,9999)
	subID = rand(0,9999)

	//base stats
	strength = rand(str[1],str[2])
	robustness = rand(rob[1],rob[2])
	roll_antigen(anti)

	//effects
	for(var/i = 1; i <= max_stage; i++)
		var/selected_badness = pick(
			bad[EFFECT_DANGER_HELPFUL];EFFECT_DANGER_HELPFUL,
			bad[EFFECT_DANGER_FLAVOR];EFFECT_DANGER_FLAVOR,
			bad[EFFECT_DANGER_ANNOYING];EFFECT_DANGER_ANNOYING,
			bad[EFFECT_DANGER_HINDRANCE];EFFECT_DANGER_HINDRANCE,
			bad[EFFECT_DANGER_HARMFUL];EFFECT_DANGER_HARMFUL,
			bad[EFFECT_DANGER_DEADLY];EFFECT_DANGER_DEADLY,
			)
		var/datum/disease2/effect/e = new_effect(text2num(selected_badness), i)
		effects += e
		log += "<br />[timestamp()] Added effect [e.name] ([e.chance]% Occurence)."

	//slightly randomized infection chance
	var/variance = initial(infectionchance)/10
	infectionchance = rand(initial(infectionchance)-variance,initial(infectionchance)+variance)
	if (origin == "New Player")
		infectionchance = min(infectionchance,20)
	infectionchance_base = infectionchance

	//cosmetic petri dish stuff - if set beforehand, will not be randomized
	if (!color)
		var/list/randomhexes = list("8","9","a","b","c","d","e")
		color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
		pattern = rand(1,6)
		pattern_color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"

	//spreading vectors - if set beforehand, will not be randomized
	if (!spread)
		randomize_spread()

	//logging
	log_debug("Creating and Randomizing [form] #[uniqueID]-[subID].")
	log += "<br />[timestamp()] Created and Randomized<br>"

	//admin panel
	if (origin == "Unknown")
		if (istype(source,/obj/item/weapon/virusdish))
			if (istype(source.loc,/obj/structure/closet/crate/secure/medsec))
				origin = "Cargo Order"
			else if (isturf(source.loc))
				var/turf/T = source.loc
				if (istype(T.loc,/area/centcom))
					origin = "Centcom"
				else if (istype(T.loc,/area/medical/virology))
					origin = "Virology"
	update_global_log()


/datum/disease2/disease/proc/new_effect(var/badness = 2, var/stage = 0)
	var/list/datum/disease2/effect/list = list()
	var/list/to_choose = subtypesof(/datum/disease2/effect)
	for(var/e in to_choose)
		var/datum/disease2/effect/f = new e
		if(!f.restricted && f.stage == stage && text2num(f.badness) == badness)
			list += f
	if (list.len <= 0)
		return new_random_effect(badness+1,badness-1,stage)
	else
		var/datum/disease2/effect/e = pick(list)
		e.chance = rand(1, e.max_chance)
		return e

/datum/disease2/disease/proc/new_random_effect(var/max_badness = 5, var/min_badness = 0, var/stage = 0, var/old_effect)
	var/list/datum/disease2/effect/list = list()
	var/list/to_choose = subtypesof(/datum/disease2/effect)
	if(old_effect) //So it doesn't just evolve right back into the previous virus type
		to_choose.Remove(old_effect)
	for(var/e in to_choose)
		var/datum/disease2/effect/f = new e
		if(!f.restricted && f.stage == stage && text2num(f.badness) <= max_badness && text2num(f.badness) >= min_badness)
			list += f
	if (list.len <= 0)
		return new_random_effect(min(max_badness+1,5),max(0,min_badness-1),stage)
	else
		var/datum/disease2/effect/e = pick(list)
		e.chance = rand(1, e.max_chance)
		return e

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

/datum/disease2/disease/meme/randomize_spread()
	spread = SPREAD_BLOOD | SPREAD_MEMETIC //not random

/datum/disease2/disease/fungus/randomize_spread()
	spread = SPREAD_BLOOD
	if(prob(50)) //40% just colonizing
		spread |= SPREAD_COLONY
		if(prob(20)) //10% colonizing + air OR contact
			spread |= pick(SPREAD_AIRBORNE,SPREAD_CONTACT)
	else if(prob(40)) //14% just airborne
		spread |= SPREAD_AIRBORNE
		if(prob(30))
			spread |= SPREAD_CONTACT //6% air+contact
	else if(prob(60)) //18% just contact
		spread |= SPREAD_CONTACT
			//12% blood only

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
		check += SPREAD_AIRBORNE
		if (spread > check)
			dat += ", "
	if (spread & SPREAD_COLONY)
		dat += "Colonizing"
		check += SPREAD_COLONY
		if (spread > check)
			dat += ", "
	if (spread & SPREAD_MEMETIC)
		dat += "Memetic"
		check += SPREAD_MEMETIC
		if (spread > check)
			dat += ", "

	return dat

/proc/virus2_make_custom(var/client/C,var/mob/living/infectedMob)
	if(!istype(C) || !C.holder)
		return 0

	var/datum/disease2/disease/D = new /datum/disease2/disease()
	D.origin = "Badmin"

	var/list/known_forms = list()
	for (var/disease_type in subtypesof(/datum/disease2/disease))
		var/datum/disease2/disease/d_type = disease_type
		known_forms[initial(d_type.form)] = d_type

	known_forms += "custom"

	if (islist(disease2_list) && disease2_list.len > 0)
		known_forms += "infect with an already existing pathogen"

	var/chosen_form = input(C, "Choose a form for your pathogen", "Choose a form") as null | anything in known_forms
	if (!chosen_form)
		qdel(D)
		return

	if (chosen_form == "infect with an already existing pathogen")
		var/chosen_pathogen = input(C, "Choose a pathogen", "Choose a pathogen") as null | anything in disease2_list
		if (!chosen_pathogen)
			qdel(D)
			return
		var/datum/disease2/disease/dis = disease2_list[chosen_pathogen]
		D = dis.getcopy()
		D.origin = "[D.origin] (Badmin)"
	else
		if (chosen_form == "custom")
			var/form_name = copytext(sanitize(input(C, "Give your custom form a name", "Name your form", "Pathogen")  as null | text),1,MAX_NAME_LEN)
			if (!form_name)
				qdel(D)
				return
			D.form = form_name
			D.max_stage = input(C, "How many stages will your pathogen have?", "Custom Pathogen", D.max_stage) as num
			D.max_stage = Clamp(D.max_stage,1,99)
			D.infectionchance = input(C, "What will be your pathogen's infection chance?", "Custom Pathogen", D.infectionchance) as num
			D.infectionchance = Clamp(D.infectionchance,0,100)
			D.infectionchance_base = D.infectionchance
			D.stageprob = input(C, "What will be your pathogen's progression speed?", "Custom Pathogen", D.stageprob) as num
			D.stageprob = Clamp(D.stageprob,0,100)
			D.stage_variance = input(C, "What will be your pathogen's stage variance?", "Custom Pathogen", D.stage_variance) as num
			D.stageprob = Clamp(D.stageprob,-1*D.max_stage,0)
			//D.can_kill = something something a while loop but probably not worth the effort. If you need it for your bus code it yourself.
		else
			var/d_type = known_forms[chosen_form]
			var/datum/disease2/disease/d_inst = new d_type
			D.form = chosen_form
			D.max_stage = d_inst.max_stage
			D.infectionchance = d_inst.infectionchance
			D.stageprob = d_inst.stageprob
			D.stage_variance = d_inst.stage_variance
			D.can_kill = d_inst.can_kill.Copy()
			qdel(d_inst)

		D.strength = input(C, "What will be your pathogen's strength? (1-50 is trivial to cure. 50-100 requires a bit more effort)", "Pathogen Strength", D.infectionchance) as num
		D.strength = Clamp(D.strength,0,100)

		D.robustness = input(C, "What will be your pathogen's robustness? (1-100) Lower values mean that infected can carry the pathogen without getting affected by its symptoms.", "Pathogen Robustness", D.infectionchance) as num
		D.robustness = Clamp(D.strength,0,100)

		var/new_id = copytext(sanitize(input(C, "You can pick a 4 number ID for your Pathogen. Otherwise a random ID will be generated.", "Pick a unique ID", rand(0,9999)) as null | num),1,4)
		if (!new_id)
			D.uniqueID = rand(0,9999)
		else
			D.uniqueID = new_id

		D.subID = rand(0,9999)
		D.childID = 0

		for(var/i = 1; i <= D.max_stage; i++)  // run through this loop until everything is set
			var/datum/disease2/effect/symptom = input(C, "Choose a symptom for your disease's stage [i] (out of [D.max_stage])", "Choose a Symptom") as null | anything in (subtypesof(/datum/disease2/effect))
			if (!symptom)
				return 0

			var/datum/disease2/effect/e = new symptom(D)
			e.stage = i
			e.chance = input(C, "Choose the default chance for this effect to activate", "Effect", e.chance) as null | num
			e.chance = Clamp(e.chance,0,100)
			e.max_chance = input(C, "Choose the maximum chance for this effect to activate", "Effect", e.max_chance) as null | num
			e.max_chance = Clamp(e.max_chance,0,100)
			e.multiplier = input(C, "Choose the default strength for this effect", "Effect", e.multiplier) as null | num
			e.multiplier = Clamp(e.multiplier,0,100)
			e.max_multiplier = input(C, "Choose the maximum strength for this effect", "Effect", e.max_multiplier) as null | num
			e.max_multiplier = Clamp(e.max_multiplier,0,100)

			D.log += "Added [e.name] at [e.chance]% chance and [e.multiplier] strength<br>"
			D.effects += e

		if (alert("Do you want to specify which antigen are selected?","Choose your Antigen","Yes","No") == "Yes")
			D.antigen = list(input(C, "Choose your first antigen", "Choose your Antigen") as null | anything in all_antigens)
			if (!D.antigen)
				D.antigen = list(input(C, "Choose your second antigen", "Choose your Antigen") as null | anything in all_antigens)
			else
				D.antigen |= input(C, "Choose your second antigen", "Choose your Antigen") as null | anything in all_antigens
			if (!D.antigen)
				if (alert("Beware, your disease having no antigen means that it's incurable. We can still roll some random antigen for you. Are you sure you want your pathogen to have no antigen anyway?","Choose your Antigen","Yes","No") == "No")
					D.roll_antigen()
				else
					D.antigen = list()
		else
			D.roll_antigen()

		var/list/randomhexes = list("8","9","a","b","c","d","e")
		D.color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
		D.pattern = rand(1,6)
		D.pattern_color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
		if (alert("Do you want to specify the appearance of your pathogen in a petri dish?","Choose your appearance","Yes","No") == "Yes")
			D.color = input(C, "Choose the color of the dish", "Cosmetic") as color
			D.pattern = input(C, "Choose the shape of the pattern inside the dish (1 to 6)", "Cosmetic",rand(1,6)) as num
			D.pattern = Clamp(D.pattern,1,6)
			D.pattern_color = input(C, "Choose the color of the pattern", "Cosmetic") as color

		D.spread = 0
		if (alert("Can this virus spread into blood? (warning! if choosing No, this virus will be impossible to sample and analyse!)","Spreading Vectors","Yes","No") == "Yes")
			D.spread |= SPREAD_BLOOD
		if(D.allowed_transmission & SPREAD_CONTACT)
			if (alert("Can this virus spread by contact, and on items?","Spreading Vectors","Yes","No") == "Yes")
				D.spread |= SPREAD_CONTACT
		if(D.allowed_transmission & SPREAD_AIRBORNE)
			if (alert("Can this virus spread through the air?","Spreading Vectors","Yes","No") == "Yes")
				D.spread |= SPREAD_AIRBORNE
		if(D.allowed_transmission & SPREAD_COLONY)
			if (alert("Does this fungus prefer suits? Exclusive with contact/air.","Spreading Vectors","Yes","No") == "Yes")
				D.spread |= SPREAD_COLONY
				D.spread &= ~(SPREAD_BLOOD|SPREAD_AIRBORNE)
		if(D.allowed_transmission & SPREAD_MEMETIC)
			if (alert("Can this virus spread through words?","Spreading Vectors","Yes","No") == "Yes")
				D.spread |= SPREAD_MEMETIC

		disease2_list -= "[D.uniqueID]-[D.subID]"//little odds of this happening thanks to subID but who knows
		D.update_global_log()

		if (alert("Lastly, do you want this pathogen to be added to the station's Database? (allows medical HUDs to locate infected mobs, among other things)","Pathogen Database","Yes","No") == "Yes")
			D.addToDB()

	if (istype(infectedMob))
		D.log += "<br />[timestamp()] Infected [key_name(infectedMob)]"
		infectedMob.virus2["[D.uniqueID]-[D.subID]"] = D
		var/nickname = ""
		if ("[D.uniqueID]-[D.subID]" in virusDB)
			var/datum/data/record/v = virusDB["[D.uniqueID]-[D.subID]"]
			nickname = v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""
		log_admin("[infectedMob] was infected with [D.form] #[add_zero("[D.uniqueID]", 4)]-[add_zero("[D.subID]", 4)][nickname] by [C.ckey]")
		message_admins("[infectedMob] was infected with  [D.form] #[add_zero("[D.uniqueID]", 4)]-[add_zero("[D.subID]", 4)][nickname] by [C.ckey]")
		D.AddToGoggleView(infectedMob)
	else
		var/obj/item/weapon/virusdish/dish = new(C.mob.loc)
		dish.contained_virus = D
		dish.growth = rand(5, 50)
		dish.name = "growth dish (Unknown [D.form])"
		if ("[D.uniqueID]-[D.subID]" in virusDB)
			dish.name = "growth dish ([D.name(TRUE)])"
		dish.update_icon()

	return 1

/datum/disease2/disease/proc/AddToGoggleView(var/mob/living/infectedMob)
	if (spread & (SPREAD_CONTACT | SPREAD_COLONY))
		infected_contact_mobs |= infectedMob
		if (!infectedMob.pathogen)
			infectedMob.pathogen = image('icons/effects/effects.dmi',infectedMob,"pathogen_contact")
			infectedMob.pathogen.plane = HUD_PLANE
			infectedMob.pathogen.layer = UNDER_HUD_LAYER
			infectedMob.pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
		for (var/mob/L in science_goggles_wearers)
			if (L.client)
				L.client.images |= infectedMob.pathogen

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

	//Pathogen killing each others
	for (var/ID in mob.virus2)
		if (ID == "[uniqueID]-[subID]")
			continue
		var/datum/disease2/disease/enemy_pathogen = mob.virus2[ID]
		if ((enemy_pathogen.form in can_kill) && strength > enemy_pathogen.strength)
			log += "<br />[timestamp()] destroyed enemy [enemy_pathogen.form] #[ID] ([strength] > [enemy_pathogen.strength])"
			enemy_pathogen.cure(mob)

	if (iscatbeast(mob))//Catbeasts were born in the disease, molded by it.
		ticks += speed
		return

	// This makes it so that <mob> only ever gets affected by the equivalent of one virus so antags don't just stack a bunch
	if(starved)
		return

	var/list/immune_data = GetImmuneData(mob)

	for(var/datum/disease2/effect/e in effects)
		if (e.can_run_effect(immune_data[1]))
			e.run_effect(mob)

	var/temp_limit = BODYTEMP_HEAT_DAMAGE_LIMIT
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		temp_limit = H.species.heat_level_1
	//fever is a reaction of the body's immune system to the infection. The higher the antibody concentration (and the disease still not cured), the higher the fever
	if (mob.bodytemperature <= temp_limit)//but we won't go all the way to burning up just because of a fever, probably
		var/fever = round((robustness / 100) * (immune_data[2] / 10) * (stage / max_stage))
		switch (mob.size)
			if (SIZE_TINY)
				fever *= 0.2
			if (SIZE_SMALL)
				fever *= 0.5
			if (SIZE_BIG)
				fever *=1.5
			if (SIZE_HUGE)
				fever *=2

		mob.bodytemperature = min(temp_limit, mob.bodytemperature+fever)

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
	mutatechance *= mutation_modifier

	var/mob/living/body = null
	var/obj/item/weapon/virusdish/dish = null
	var/obj/machinery/disease2/incubator/machine = null

	if (isliving(incubator))
		body = incubator
	else if (istype(incubator,/obj/item/weapon/virusdish))
		dish = incubator
		if (istype(dish.loc,/obj/machinery/disease2/incubator))
			machine = dish.loc

	if (mutatechance > 0 && (body || dish) && incubator.reagents)
		if (incubator.reagents.has_reagent(MUTAGEN,0.5) && incubator.reagents.has_reagent(CREATINE,0.5))
			if(!incubator.reagents.remove_reagent(MUTAGEN,0.5) && !incubator.reagents.remove_reagent(CREATINE,0.5))
				log += "<br />[timestamp()] Robustness Strengthening (Mutagen and Creatine in [incubator])"
				var/change = rand(1,5)
				robustness = min(100,robustness + change)
				for(var/datum/disease2/effect/e in effects)
					e.multiplier_tweak(0.1)
					minormutate()
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
					minormutate()
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
		var/immune_system = mob.immune_system.GetImmunity()
		var/immune_str = immune_system[1]
		var/list/antibodies = immune_system[2]
		var/subdivision = (strength - ((robustness * strength) / 100)) / max_stage
		//for each antigen, we measure the corresponding antibody concentration in the carrier's immune system
		//the less robust the pathogen, the more likely that further stages' effects won't activate at a given concentration
		for (var/A in antigen)
			var/concentration = immune_str * antibodies[A]
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
	//--Plague Stuff--
	var/datum/faction/plague_mice/plague = find_active_faction_by_type(/datum/faction/plague_mice)
	if (plague && ("[uniqueID]-[subID]" == plague.diseaseID))
		plague.update_hud_icons()
	//----------------
	var/list/V = filter_disease_by_spread(mob.virus2, required = (SPREAD_CONTACT | SPREAD_COLONY))
	if (V && V.len <= 0)
		infected_contact_mobs -= mob
		if (mob.pathogen)
			for (var/mob/L in science_goggles_wearers)
				if (L.client)
					L.client.images -= mob.pathogen

/datum/disease2/disease/proc/get_effect(var/index)
	if(!index)
		return pick(effects)
	return effects[Clamp(index,0,effects.len)]

/datum/disease2/disease/proc/roll_antigen(var/list/factors = list())
	if (factors.len <= 0)
		antigen = list(pick(all_antigens))
		antigen |= pick(all_antigens)
	else
		var/selected_first_antigen = pick(
			factors[ANTIGEN_BLOOD];ANTIGEN_BLOOD,
			factors[ANTIGEN_COMMON];ANTIGEN_COMMON,
			factors[ANTIGEN_RARE];ANTIGEN_RARE,
			factors[ANTIGEN_ALIEN];ANTIGEN_ALIEN,
			)

		antigen = list(pick(antigen_family(selected_first_antigen)))

		var/selected_second_antigen = pick(
			factors[ANTIGEN_BLOOD];ANTIGEN_BLOOD,
			factors[ANTIGEN_COMMON];ANTIGEN_COMMON,
			factors[ANTIGEN_RARE];ANTIGEN_RARE,
			factors[ANTIGEN_ALIEN];ANTIGEN_ALIEN,
			)

		antigen |= pick(antigen_family(selected_second_antigen))


//Major Mutations
/datum/disease2/disease/proc/effectmutate(var/inBody=FALSE)
	clean_global_log()
	subID = rand(0,9999)
	var/list/randomhexes = list("7","8","9","a","b","c","d","e")
	var/colormix = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
	color = BlendRGB(color,colormix,0.25)
	var/i = rand(1, effects.len)
	var/datum/disease2/effect/e = effects[i]
	var/datum/disease2/effect/f
	if (inBody)//mutations that occur directly in a body don't cause helpful symptoms to become deadly instantly.
		f = new_random_effect(min(5,text2num(e.badness)+1), max(0,text2num(e.badness)-1), e.stage, e.type)
	else
		f = new_random_effect(min(5,text2num(e.badness)+2), max(0,text2num(e.badness)-3), e.stage, e.type)//badness is slightly more likely to go down than up.
	effects[i] = f
	log_debug("[form] [uniqueID]-[subID] has mutated [e.name] into [f.name].")
	log += "<br />[timestamp()] Mutated effect [e.name] [e.chance]% into [f.name] [f.chance]%."
	update_global_log()

/datum/disease2/disease/proc/antigenmutate()
	clean_global_log()
	subID = rand(0,9999)
	var/old_dat = get_antigen_string()
	var/list/anti = list(
		ANTIGEN_BLOOD	= 2,
		ANTIGEN_COMMON	= 2,
		ANTIGEN_RARE	= 1,
		ANTIGEN_ALIEN	= 0,
		)
	roll_antigen(anti)
	log_debug("[form] [uniqueID]-[subID] has mutated its antigen from [old_dat] to [get_antigen_string()].")
	log += "<br />[timestamp()] Mutated antigen [old_dat] into [get_antigen_string()]."
	update_global_log()


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
	disease.origin=origin
	disease.infectionchance = infectionchance
	disease.infectionchance_base = infectionchance_base
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
	disease.can_kill = can_kill.Copy()
	disease.mutation_modifier = mutation_modifier
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
		r += "<dt> &#x25CF; <b>Stage [e.stage] - [e.name]</b> (Danger: [e.badness]). Strength: <b>[e.multiplier]</b>. Occurrence: <b>[e.chance]%</b>.</dt>"
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
	v.fields["nickname"] = ""
	v.fields["description"] = get_info()
	v.fields["antigen"] = get_antigen_string()
	v.fields["spread type"] = get_spread_string()
	v.fields["danger"] = "Undetermined"
	virusDB["[uniqueID]-[subID]"] = v
	return 1
