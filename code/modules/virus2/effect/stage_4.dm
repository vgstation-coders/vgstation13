/datum/disease2/effect/spaceadapt
	name = "Space Adaptation Effect"
	desc = "Heals the infected from the effects of space exposure, should they remain in a vacuum."
	stage = 4
	badness = EFFECT_DANGER_HELPFUL
	chance = 10
	max_chance = 25

/datum/disease2/effect/spaceadapt/activate(var/mob/living/mob)
	var/datum/gas_mixture/environment = mob.loc.return_air()
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = mob.calculate_affecting_pressure(pressure)
	if (istype(mob.loc, /turf/space) || adjusted_pressure < HAZARD_LOW_PRESSURE)
		if (mob.reagents.get_reagent_amount(DEXALINP) < 10)
			mob.reagents.add_reagent(DEXALINP, 4)
		if (mob.reagents.get_reagent_amount(LEPORAZINE) < 10)
			mob.reagents.add_reagent(LEPORAZINE, 4)
		if (mob.reagents.get_reagent_amount(BICARIDINE) < 10)
			mob.reagents.add_reagent(BICARIDINE, 4)
		if (prob(20))
			mob.emote("me",1,"exhales slowly.")

		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			var/datum/organ/internal/lungs/L = H.internal_organs_by_name["lungs"]
			if (L)
				L.damage = 0

/datum/disease2/effect/minttoxin
	name = "Creosote Syndrome"
	desc = "Causes the infected to synthesize a wafer thin mint."
	stage = 4
	badness = EFFECT_DANGER_HARMFUL

/datum/disease2/effect/minttoxin/activate(var/mob/living/mob)
	if(istype(mob) && mob.reagents.get_reagent_amount(MINTTOXIN) < 5)
		to_chat(mob, "<span class='notice'>You feel a minty freshness</span>")
		mob.reagents.add_reagent(MINTTOXIN, 5)


/datum/disease2/effect/gibbingtons
	name = "Gibbingtons Syndrome"
	desc = "Causes the infected to spontaneously explode in a shower of gore."
	encyclopedia = "The individual will feel more and more bloated as the limits of his body are reached."
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	var/gibchance = 20

/datum/disease2/effect/gibbingtons/activate(var/mob/living/mob)
	if (prob(gibchance))
		to_chat(mob, "<span class = 'danger'>You explode in a shower of gore.</span>")
		mob.gib()
	else
		to_chat(mob, "<span class = 'danger'>You get a foreboding feeling as your limbs and chest feel more and more bloated.</span>")
		gibchance += rand(9,15)


/datum/disease2/effect/radian
	name = "Radian's Syndrome"
	desc = "Causes the infected to generate strange protein, that begins radioactive decay in the denser material held within the infected's body, causing radioactive exposure."
	stage = 4
	max_multiplier = 3
	badness = EFFECT_DANGER_DEADLY

/datum/disease2/effect/radian/activate(var/mob/living/mob)
	mob.radiation += (2*multiplier)


/datum/disease2/effect/deaf
	name = "Dead Ear Syndrome"
	desc = "Kills the infected's aural senses."
	stage = 4
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/deaf/activate(var/mob/living/mob)
	mob.ear_deaf += 20


/datum/disease2/effect/monkey
	name = "Monkism Syndrome"
	desc = "Causes the infected to rapidly devolve to a lower form of life."
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	var/transformed = FALSE

/datum/disease2/effect/monkey/getcopy(var/datum/disease2/disease/disease)
	var/datum/disease2/effect/monkey/new_e = ..(disease)
	new_e.transformed = transformed
	return new_e

/datum/disease2/effect/monkey/activate(var/mob/living/carbon/human/mob)
	if(istype(mob))
		transformed = TRUE
		var/datum/dna/gene/gene = dna_genes[/datum/dna/gene/monkey]
		gene.activate(mob, null, null)
/*
/datum/disease2/effect/monkey/deactivate(var/mob/living/carbon/monkey/mob)
	if(istype(mob) && transformed)
		var/datum/dna/gene/gene = dna_genes[/datum/dna/gene/monkey]
		gene.deactivate(mob, null, null)
*/

/datum/disease2/effect/catbeast
	name = "Kingston Syndrome"
	desc = "A previously experimental syndrome that found its way into the wild. Causes the infected to mutate into a Tajaran."
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	var/old_species = "Human"

/datum/disease2/effect/catbeast/activate(var/mob/living/mob)
	if(istype(mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/h = mob
		old_species = h.species.name
		if(old_species != "Tajaran")
			if(h.set_species("Tajaran"))
				h.regenerate_icons()
/*
/datum/disease2/effect/catbeast/deactivate(var/mob/living/mob)
	if(istype(mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/h = mob
		if(h.species.name == "Tajaran" && old_species != "Tajaran")
			if(h.set_species(old_species))
				h.regenerate_icons()
*/
/datum/disease2/effect/zombie
	name = "Stubborn brain syndrome"
	desc = "UNKNOWN"
	stage = 4
	badness = EFFECT_DANGER_ANNOYING

/datum/disease2/effect/zombie/activate(var/mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/h = mob
		h.become_zombie_after_death = 1


/datum/disease2/effect/voxpox
	name = "Vox Pox"
	desc = "A previously experimental syndrome that found its way into the wild. Causes the infected to mutate into a Vox."
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	var/old_species = "Human"

/datum/disease2/effect/voxpox/activate(var/mob/living/mob)
	if(istype(mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/h = mob
		old_species = h.species.name
		if(old_species != "Vox")
			if(h.set_species("Vox"))
				h.regenerate_icons()
/*
/datum/disease2/effect/voxpox/deactivate(var/mob/living/mob)
	if(istype(mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/h = mob
		if(h.species.name == "Vox" && old_species != "Vox")
			if(h.set_species(old_species))
				h.regenerate_icons()
*/

/datum/disease2/effect/suicide
	name = "Suicidal Syndrome"
	desc = "Induces clinical depression in the infected, causing them to attempt to take their own life on the spot."
	stage = 4
	badness = EFFECT_DANGER_DEADLY

/datum/disease2/effect/suicide/activate(var/mob/living/mob)

	if(mob.stat != CONSCIOUS || !mob.canmove || mob.restrained()) //Try as we might, we still can't snap our neck when we are KO or restrained, even if forced.
		return

	mob.attempt_suicide(1, 0)

/datum/disease2/effect/killertoxins
	name = "Toxification Syndrome"
	desc = "A more advanced version of Hyperacidity, causing the infected to rapidly generate toxins."
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	multiplier = 3
	max_multiplier = 5

/datum/disease2/effect/killertoxins/activate(var/mob/living/mob)
	mob.adjustToxLoss(5*multiplier)


/datum/disease2/effect/dna
	name = "Reverse Pattern Syndrome"
	desc = "Attacks the infected's DNA, causing rapid spontaneous mutation, and inhibits the ability for the infected to be affected by cryogenics."
	stage = 4
	badness = EFFECT_DANGER_DEADLY

/datum/disease2/effect/dna/activate(var/mob/living/mob)
	mob.bodytemperature = max(mob.bodytemperature, 350)
	scramble(0,mob,10)
	mob.apply_damage(10, CLONE)


/datum/disease2/effect/organs
	name = "Shutdown Syndrome"
	desc = "Attacks the infected's limbs, causing them to shut down. Also inhibits toxin processing, causing toxin buildup."
	stage = 4
	badness = EFFECT_DANGER_DEADLY

/datum/disease2/effect/organs/activate(var/mob/living/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		var/organ = pick(list(LIMB_RIGHT_ARM,LIMB_LEFT_ARM,LIMB_RIGHT_LEG,LIMB_RIGHT_LEG))
		var/datum/organ/external/E = H.organs_by_name[organ]
		if (!(E.status & ORGAN_DEAD))
			E.status |= ORGAN_DEAD
			to_chat(H, "<span class='notice'>You can't feel your [E.display_name] anymore...</span>")
			for (var/datum/organ/external/C in E.children)
				C.status |= ORGAN_DEAD
		H.update_body(1)
		if(multiplier < 1)
			multiplier = 1
		H.adjustToxLoss(15*multiplier)

/datum/disease2/effect/organs/deactivate(var/mob/living/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		for (var/datum/organ/external/E in H.organs)
			E.status &= ~ORGAN_DEAD
			for (var/datum/organ/external/C in E.children)
				C.status &= ~ORGAN_DEAD
		H.update_body(1)


/datum/disease2/effect/immortal
	name = "Longevity Syndrome"
	desc = "Grants functional immortality to the infected so long as the symptom is active. Heals broken bones and healing external damage. Creates a backlash if cured."
	stage = 4
	badness = EFFECT_DANGER_HELPFUL

/datum/disease2/effect/immortal/activate(var/mob/living/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		for (var/datum/organ/external/E in H.organs)
			if (E.status & ORGAN_BROKEN && prob(30))
				to_chat(H, "<span class = 'notice'>You feel the bones in your [E.display_name] set back into place.</span>")
				E.status &= ~ORGAN_BROKEN
	var/heal_amt = -5*multiplier
	mob.apply_damages(heal_amt,heal_amt,heal_amt,heal_amt)

/datum/disease2/effect/immortal/deactivate(var/mob/living/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		to_chat(H, "<span class='warning'>You suddenly feel hurt and old...</span>")
		H.age += 4*multiplier
	var/backlash_amt = 5*multiplier
	mob.apply_damages(backlash_amt,backlash_amt,backlash_amt,backlash_amt)


/datum/disease2/effect/bones
	name = "Fragile Bones Syndrome"
	desc = "Attacks the infected's bone structure, making it more porous and fragile."
	stage = 4
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/bones/activate(var/mob/living/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		for (var/datum/organ/external/E in H.organs)
			E.min_broken_damage = max(5, E.min_broken_damage - 30)

/datum/disease2/effect/bones/deactivate(var/mob/living/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		for (var/datum/organ/external/E in H.organs)
			E.min_broken_damage = initial(E.min_broken_damage)


/datum/disease2/effect/scc
	name = "Spontaneous Cellular Collapse"
	desc = "Converts the infected's internal toxin treatment to synthesize Polyacid, as well as cause the infected's skin to break, and their bones to fracture."
	stage = 4
	badness = EFFECT_DANGER_DEADLY

/datum/disease2/effect/scc/activate(var/mob/living/mob)
	//
	if(!ishuman(mob))
		return 0
	var/mob/living/carbon/human/H = mob
	mob.reagents.add_reagent(PACID, 10)
	to_chat(mob, "<span class = 'warning'>Your body burns as your cells break down.</span>")
	shake_camera(mob,5*multiplier)

	for (var/datum/organ/external/E in H.organs)
		if(pick(1,0))
			//
			E.createwound(CUT, pick(2,4,6,8,10))
			E.fracture()


/datum/disease2/effect/necrosis
	name = "Necrosis"
	desc = "Attacks the cell structure of the infected, causing the infected's skin and flesh to slough off rapidly."
	stage = 4
	badness = EFFECT_DANGER_DEADLY

/datum/disease2/effect/necrosis/activate(var/mob/living/mob)

	if(ishuman(mob)) //Only works on humans properly since it needs to do organ work
		var/mob/living/carbon/human/H = mob
		var/inst = pick(1, 2, 3)

		switch(inst)

			if(1) // Losing flesh
				to_chat(H, "<span class='warning'>A chunk of meat falls off of you!</span>")
				var/totalslabs = 1
				var/obj/item/weapon/reagent_containers/food/snacks/meat/allmeat[totalslabs]
				var/sourcename = H.real_name
				var/sourcejob = H.job
				var/sourcenutriment = H.nutrition / 15
				//var/sourcetotalreagents = mob.reagents.total_volume

				for(var/i = 1 to totalslabs)
					var/obj/item/weapon/reagent_containers/food/snacks/meat/human/newmeat = new
					newmeat.name = sourcename + newmeat.name
					newmeat.subjectname = sourcename
					newmeat.subjectjob = sourcejob
					newmeat.reagents.add_reagent(NUTRIMENT, sourcenutriment / totalslabs) //Thehehe. Fat guys go first
					//src.occupant.reagents.trans_to(newmeat, round (sourcetotalreagents / totalslabs, 1)) // Transfer all the reagents from the
					allmeat[i] = newmeat

					var/obj/item/meatslab = allmeat[i]
					var/turf/Tx = locate(mob.x, mob.y, mob.z)
					meatslab.forceMove(get_turf(H))
					meatslab.throw_at(Tx, i, 3)

					if(!Tx.density)
						var/obj/effect/decal/cleanable/blood/gibs/D = getFromPool(/obj/effect/decal/cleanable/blood/gibs, Tx)
						D.New(Tx,i)

			if(2) // Losing a limb
				for(var/datum/organ/external/E in H.organs)
					if(pick(1, 0))
						E.droplimb(1)

			if(3) // Losing your skin
				if(H.species.name != "Skellington")
					to_chat(H, "<span class='warning'>Your necrotic skin ruptures!</span>")

					for(var/datum/organ/external/E in H.organs)
						if(pick(1,0))
							E.createwound(CUT, pick(2, 4, 6, 8, 10))

					if(prob(30))
						if(H.set_species("Skellington"))
							to_chat(mob, "<span class='warning'>A massive amount of flesh sloughs off your bones!</span>")
							H.regenerate_icons()


/datum/disease2/effect/fizzle
	name = "Fizzle Effect"
	desc = "Causes an ill, though harmless, sensation in the infected's throat."
	stage = 4
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/fizzle/activate(var/mob/living/mob)
	mob.emote("me",1,pick("sniffles...", "clears their throat..."))


/datum/disease2/effect/delightful
	name = "Delightful Effect"
	desc = "A more powerful version of Full Glass. Makes the infected feel delightful."
	stage = 4
	badness = EFFECT_DANGER_HELPFUL

/datum/disease2/effect/delightful/activate(var/mob/living/mob)
	to_chat(mob, "<span class = 'notice'>You feel delightful!</span>")
	if (mob.reagents.get_reagent_amount(DOCTORSDELIGHT) < 1)
		mob.reagents.add_reagent(DOCTORSDELIGHT, 1)


/datum/disease2/effect/spawn
	name = "Arachnogenesis Effect"
	desc = "Converts the infected's stomach to begin producing creatures of the arachnid variety."
	stage = 4
	badness = EFFECT_DANGER_HARMFUL
	var/spawn_type=/mob/living/simple_animal/hostile/giant_spider/spiderling
	var/spawn_name="spiderling"

/datum/disease2/effect/spawn/activate(var/mob/living/mob)
	playsound(mob.loc, 'sound/effects/splat.ogg', 50, 1)

	if (ismouse(mob))
		new spawn_type(get_turf(mob))
		new spawn_type(get_turf(mob))
		new spawn_type(get_turf(mob))
		mob.emote("me",1,"explodes into [spawn_name]s!")
		mob.gib()
	else
		new spawn_type(get_turf(mob))
		mob.emote("me",1,"vomits up a live [spawn_name]!")

/datum/disease2/effect/spawn/roach
	name = "Blattogenesis Effect"
	desc = "Converts the infected's stomach to begin producing creatures of the blattid variety."
	stage = 4
	badness = EFFECT_DANGER_HINDRANCE
	spawn_type=/mob/living/simple_animal/cockroach
	spawn_name="cockroach"


/datum/disease2/effect/orbweapon
	name = "Biolobulin Effect"
	desc = "Converts the infected's pores of their palm to begin synthesizing a gelatenous substance, that explodes upon reaching a high velocity."
	stage = 4
	badness = EFFECT_DANGER_HELPFUL

/datum/disease2/effect/orbweapon/activate(var/mob/living/mob)
	var/obj/item/toy/snappop/virus/virus = new /obj/item/toy/snappop/virus
	virus.virus2 = virus_copylist(mob.virus2)
	mob.put_in_hands(virus)


/datum/disease2/effect/plasma
	name = "Toxin Sublimation"
	desc = "Converts the infected's pores and respiratory organs to synthesize Plasma gas."
	stage = 4
	badness = EFFECT_DANGER_DEADLY

/datum/disease2/effect/plasma/activate(var/mob/living/mob)
	//var/src = mob
	var/turf/simulated/T = get_turf(mob)
	if(!T)
		return
	var/datum/gas_mixture/GM = new
	if(prob(10))
		GM.adjust_gas(GAS_PLASMA, 100)
		//GM.temperature = 1500+T0C //should be enough to start a fire
		to_chat(mob, "<span class='warning'>You exhale a large plume of toxic gas!</span>")
	else
		GM.temperature = istype(T) ? T.air.temperature : T20C
		GM.adjust_gas(GAS_PLASMA, 100)
		to_chat(mob, "<span class = 'warning'> A toxic gas emanates from your pores!</span>")
	T.assume_air(GM)
	return


/datum/disease2/effect/babel
	name = "Babel Syndrome"
	desc = "Confuses the infected's brain, causing them to speak a different language."
	stage = 4
	max_count = 1
	badness = EFFECT_DANGER_HINDRANCE

	var/list/original_languages = list()

/datum/disease2/effect/babel/activate(var/mob/living/mob)
	if(mob.languages.len <= 1)
		to_chat(mob, "Your knowledge of language is just fine.")
		return

	for(var/datum/language/L in mob.languages)
		original_languages += L.name
		mob.remove_language(L.name)

	var/list/new_languages = list()
	for(var/L in all_languages)
		var/datum/language/lang = all_languages[L]
		if(!(lang.flags & RESTRICTED))
			new_languages += lang.name

	var/picked_lang = pick(new_languages)
	mob.add_language(picked_lang)
	mob.default_language = mob.languages[1]

	to_chat(mob, "You can't seem to remember any language but [picked_lang]. Odd.")

/datum/disease2/effect/babel/deactivate(var/mob/living/mob)
	if(original_languages.len)
		for(var/forgotten in original_languages)
			mob.add_language(forgotten)

		to_chat(mob, "Suddenly, your knowledge of languages comes back to you.")


/datum/disease2/effect/gregarious
	name = "Gregarious Impetus"
	desc = "Infests the social structures of the infected's brain, causing them to feel better in crowds of other potential victims, and punishing them for being alone."
	stage = 4
	badness = EFFECT_DANGER_HINDRANCE
	max_chance = 25
	max_multiplier = 4

/datum/disease2/effect/gregarious/activate(var/mob/living/mob)
	var/others_count = 0
	for(var/mob/living/carbon/m in oview(5, mob))
		if (airborne_can_reach(mob.loc, m.loc, 9)) // Apparently mobs physically block airborne viruses
			others_count += 1
	if (others_count >= multiplier)
		to_chat(mob, "<span class='notice'>A friendly sensation is satisfied with how many are near you - for now.</span>")
		mob.adjustBrainLoss(-multiplier)
		mob.reagents.add_reagent(OXYCODONE, multiplier) // ADDICTED TO HAVING FRIENDS
		if (multiplier < max_multiplier)
			multiplier += 0.15 // The virus gets greedier
	else
		to_chat(mob, "<span class='warning'>A hostile sensation in your brain stings you... it wants more of the living near you.</span>")
		mob.adjustBrainLoss(multiplier / 2)
		mob.AdjustParalysis(multiplier) // This practically permaparalyzes you at higher multipliers but
		mob.AdjustKnockdown(multiplier) // that's your fucking fault for not being near enough people
		mob.AdjustStunned(multiplier)   // You'll have to wait until the multiplier gets low enough
		if (multiplier > 1)
			multiplier -= 0.3 // The virus tempers expectations


/datum/disease2/effect/thick_skin	//increases brute damage resistance, decreases thermal loss, and increases heat gained from calories burned, all scaling with the multiplier
	name = "Harlequin Ichthyosis"	//also causes loss of sweat glands, difficulty breathing, and bleeding with a high multiplier
	desc = "Dries out the infected's skin should they have any, causing it to become brittle and hard, inhibiting temperature control."
	stage = 4
	max_multiplier = 100
	chance = 10
	badness = EFFECT_DANGER_HARMFUL
	var/skip = FALSE
	var/brute_mod_subtracted = 0
	var/therm_loss_mod_subtracted = 0
	var/cal_heat_mod_added = 0

/datum/disease2/effect/thick_skin/activate(var/mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(H.species && (H.species.anatomy_flags & NO_SKIN))	//Can't have thick skin if you don't have skin at all.
			skip = TRUE
			return
	mob.brute_damage_modifier += brute_mod_subtracted
	mob.thermal_loss_multiplier += therm_loss_mod_subtracted
	mob.calorie_burning_heat_multiplier -= cal_heat_mod_added
	brute_mod_subtracted = 0
	therm_loss_mod_subtracted = 0
	cal_heat_mod_added = 0
	switch(multiplier)
		if(1 to 30)
			switch(multiplier)
				if(1 to 10)
					to_chat(mob, "<span class='warning'>Your skin feels a little thick.</span>")
				if(11 to 20)
					to_chat(mob, "<span class='warning'>Your skin feels a little dry.</span>")
				if(21 to 30)
					to_chat(mob, "<span class='warning'>Your skin is beginning to crack at the joints.</span>")
			brute_mod_subtracted = 0.05
			therm_loss_mod_subtracted = 0.5
			cal_heat_mod_added = 5
			if(ishuman(mob))
				var/mob/living/carbon/human/H = mob
				if(initial(H.species.anatomy_flags) & HAS_SWEAT_GLANDS)
					H.species.anatomy_flags |= HAS_SWEAT_GLANDS
		if(31 to 100)
			switch(multiplier)
				if(31 to 50)
					switch(multiplier)
						if(31 to 40)
							to_chat(mob, "<span class='warning'>Your skin feels hard as a rock.</span>")
						if(41 to 50)
							to_chat(mob, "<span class='warning'>You feel warmer than usual.</span>")
					brute_mod_subtracted = 0.1
					therm_loss_mod_subtracted = 1
					cal_heat_mod_added = 10
				if(51 to 70)
					switch(multiplier)
						if(51 to 60)
							to_chat(mob, "<span class='warning'>The cracks in your skin multiply, separating it into plates.</span>")
						if(61 to 70)
							to_chat(mob, "<span class='warning'>The cracks between the plates on your skin widen.</span>")
					brute_mod_subtracted = 0.25
					therm_loss_mod_subtracted = 1
					cal_heat_mod_added = 10
				if(71 to 100)
					switch(multiplier)
						if(71 to 80)
							to_chat(mob, "<span class='warning'>The plates on your skin grow thicker.</span>")
						if(81 to 100)
							switch(multiplier)
								if(81 to 90)
									if(ishuman(mob))
										var/mob/living/carbon/human/H = mob
										if(~H.flags & NO_BREATHE)
											to_chat(mob, "<span class='warning'>The thickness of the plate on your chest is making it difficult to breathe.</span>")
								if(91 to 100)
									to_chat(mob, "<span class='warning'>The cracks in your skin are beginning to open into wounds.</span>")
									if(ishuman(mob))
										var/mob/living/carbon/human/H = mob
										H.drip(10)
							mob.losebreath += rand(1,5)
					brute_mod_subtracted = 0.5
					therm_loss_mod_subtracted = 1
					cal_heat_mod_added = 20
			if(ishuman(mob))
				var/mob/living/carbon/human/H = mob
				H.species.anatomy_flags &= ~HAS_SWEAT_GLANDS

	mob.brute_damage_modifier -= brute_mod_subtracted
	mob.thermal_loss_multiplier -= therm_loss_mod_subtracted
	mob.calorie_burning_heat_multiplier += cal_heat_mod_added
	mob.cap_calorie_burning_bodytemp = FALSE
	multiplier = min(multiplier + 10, max_multiplier)

/datum/disease2/effect/thick_skin/deactivate(var/mob/living/mob)
	if(!skip)
		mob.brute_damage_modifier += brute_mod_subtracted
		mob.thermal_loss_multiplier += therm_loss_mod_subtracted
		mob.calorie_burning_heat_multiplier -= cal_heat_mod_added
		mob.cap_calorie_burning_bodytemp = initial(mob.cap_calorie_burning_bodytemp)
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			if(initial(H.species.anatomy_flags) & HAS_SWEAT_GLANDS)
				H.species.anatomy_flags |= HAS_SWEAT_GLANDS
		to_chat(mob, "<span class='notice'>Your skin feels nice and smooth again!</span>")
	..()

/datum/disease2/effect/heart_attack
	name = "Heart Attack Syndrome"
	desc = "Infests the infected's heart, causing it to burst forth from the infected and attack them."
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	max_count = 1

/datum/disease2/effect/heart_attack/activate(var/mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(H.get_heart())
			H.visible_message("<span class='danger'>\The [H]'s heart bursts out of \his chest!</span>","<span class='danger'>Your heart bursts out of your chest!</span>")
			var/obj/item/organ/internal/blown_heart = H.remove_internal_organ(H,H.get_heart(),H.get_organ(LIMB_CHEST))
			var/list/spawn_turfs = list()
			for(var/turf/T in orange(1, H))
				if(!T.density)
					spawn_turfs.Add(T)
			if(!spawn_turfs.len)
				spawn_turfs.Add(get_turf(H))
			var/mob/living/simple_animal/hostile/heart_attack = new(pick(spawn_turfs))
			heart_attack.appearance = blown_heart.appearance
			heart_attack.icon_dead = "heart-off"
			heart_attack.environment_smash_flags = 0
			heart_attack.melee_damage_lower = 15
			heart_attack.melee_damage_upper = 15
			heart_attack.health = 50
			heart_attack.maxHealth = 50
			heart_attack.stat_attack = 1
			score["heartattacks"]++
			qdel(blown_heart)

/datum/disease2/effect/wizarditis
	name = "Wizarditis"
	desc = "Subjects affected show the signs of mental retardation, yelling obscure sentences or total gibberish."
	encyclopedia = "Some may express the feelings of inner power, and, cite, 'the ability to control the forces of cosmos themselves!'. This led to speculations that this symptom is the cause of Wizard Federation's existance."
	stage = 4
	badness = EFFECT_DANGER_HARMFUL
	chance = 10
	max_chance = 20
	var/old_r_hair = 0
	var/old_g_hair = 0
	var/old_b_hair = 0
	var/old_f_style = "Bald"
	var/old_h_style = "Shaved"
	var/old_r_facial = 0
	var/old_g_facial = 0
	var/old_b_facial = 0
	var/old_r_eyes = 0
	var/old_g_eyes = 0
	var/old_b_eyes = 0

/datum/disease2/effect/wizarditis/proc/backup_appearance(var/mob/living/carbon/human/affected)
	old_r_hair = affected.my_appearance.r_hair
	old_g_hair = affected.my_appearance.g_hair
	old_b_hair = affected.my_appearance.b_hair
	old_f_style = affected.my_appearance.f_style
	old_h_style = affected.my_appearance.h_style
	old_r_facial = affected.my_appearance.r_facial
	old_g_facial = affected.my_appearance.g_facial
	old_b_facial = affected.my_appearance.b_facial
	old_r_eyes = affected.my_appearance.r_eyes
	old_g_eyes = affected.my_appearance.g_eyes
	old_b_eyes = affected.my_appearance.b_eyes

/datum/disease2/effect/wizarditis/proc/spawn_wizard_clothes(var/mob/living/mob)
	if (ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(prob(50))
			if(!istype(H.head, /obj/item/clothing/head/wizard))
				if(H.head)
					H.drop_from_inventory(H.head)
				H.head = new /obj/item/clothing/head/wizard(H)
				H.head.hud_layerise()
		if(prob(50))
			if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
				if(H.wear_suit)
					H.drop_from_inventory(H.wear_suit)
				H.wear_suit = new /obj/item/clothing/suit/wizrobe(H)
				H.wear_suit.hud_layerise()
		if(prob(50))
			if(!istype(H.shoes, /obj/item/clothing/shoes/sandal))
				if(H.shoes)
					H.drop_from_inventory(H.shoes)
				H.shoes = new /obj/item/clothing/shoes/sandal(H)
				H.hud_layerise()
	if (iscarbon(mob))
		var/mob/living/carbon/C = mob
		if(prob(50))
			if(!istype(C.get_held_item_by_index(GRASP_RIGHT_HAND), /obj/item/weapon/staff))
				if(C.drop_item(C.get_held_item_by_index(GRASP_RIGHT_HAND)))
					C.put_in_r_hand( new /obj/item/weapon/staff(C) )

/datum/disease2/effect/wizarditis/activate(var/mob/living/mob)
	if (count == 0)
		to_chat(mob, "<span class='warning'>You feel an ancient wisdom take root in your mind.</span>")
	if (ishuman(mob))
		if (count == 0)
			backup_appearance(mob)
		var/mob/living/carbon/human/affected = mob
		affected.my_appearance.r_hair = 178
		affected.my_appearance.g_hair = 178
		affected.my_appearance.b_hair = 178
		affected.my_appearance.r_eyes = 102
		affected.my_appearance.g_eyes = 51
		affected.my_appearance.b_eyes = 0
		affected.my_appearance.r_facial = 178
		affected.my_appearance.g_facial = 178
		affected.my_appearance.b_facial = 178
		affected.my_appearance.f_style = "Dwarf Beard"
		affected.my_appearance.h_style = "Shoulder-length Hair Alt"
		affected.update_body(0)
		affected.update_hair()

	switch(count)
		if (10 to 30)
			if(prob(3))
				mob.say(pick("You shall not pass!", "Expeliarmus!", "By Merlins beard!", "Feel the power of the Dark Side!"))
			if(prob(5))
				to_chat(mob, "<span class='warning'>You feel [pick("that you don't have enough mana.", "that the winds of magic are gone.", "an urge to summon familiar.")]</span>")
		if (30 to INFINITY)
			if(prob(3))
				var/list/possible_invocations = list(
					"By Merlins beard!",
					"Feel the power of the Dark Side!",
					"NEC CANTIO!",
					"AULIE OXIN FIERA!",
					"STI KALY!",
					"TARCOL MINTI ZHERI!")

				if (count >= 40)
					possible_invocations += "SCYAR NILA!"

				if (count >= 60)
					possible_invocations += "EI NATH!"//may the gods forgive me

				var/spell_to_cast = pick(possible_invocations)

				mob.say(spell_to_cast)

				switch (spell_to_cast)
					if ("NEC CANTIO!")
						empulse(get_turf(mob), 6, 10)
					if ("AULIE OXIN FIERA!")
						for(var/turf/T in range(3, get_turf(mob)))
							for(var/obj/machinery/door/door in T.contents)
								spawn(1)
									if(istype(door,/obj/machinery/door/airlock))
										var/obj/machinery/door/airlock/AL = door //casting is important
										AL.locked = 0
									door.open()
							for(var/obj/structure/closet/C in T.contents)
								spawn(1)
									if(istype(C,/obj/structure/closet))
										var/obj/structure/closet/LC = C
										LC.locked = 0
										LC.welded = 0
									C.open()
							for(var/obj/structure/safe/S in T.contents)
								spawn(1)
									if(istype(S,/obj/structure/safe))
										var/obj/structure/safe/SA = S
										SA.open = 1
									S.update_icon()
							for(var/obj/item/weapon/storage/lockbox/L in T.contents)
								spawn(1)
									if(istype(L,/obj/item/weapon/storage/lockbox))
										var/obj/item/weapon/storage/lockbox/LL = L
										LL.locked = 0
									L.update_icon()
					if ("STI KALY!")
						for(var/mob/living/target in range(7, get_turf(mob)))
							if (target == mob)
								continue
							target.eye_blind += 10
							target.eye_blurry += 20
							target.disabilities |= DISABILITY_FLAG_NEARSIGHTED
							spawn(300)
								target.disabilities &= ~DISABILITY_FLAG_NEARSIGHTED
					if ("TARCOL MINTI ZHERI!")
						var/obj/effect/forcefield/wizard/wall = new(get_turf(mob))
						spawn(300)
						if(wall)
							qdel(wall)
					if ("SCYAR NILA!")
						var/list/theareas = new/list()
						for(var/area/AR in orange(80, mob))
							if(theareas.Find(AR) || isspace(AR))
								continue
							theareas += AR
						if(theareas)
							var/area/thearea = pick(theareas)
							var/list/L = list()
							for(var/turf/T in get_area_turfs(thearea.type))
								if(T.z != mob.z)
									continue
								if(T.name == "space")
									continue
								if(!T.density)
									var/clear = 1
									for(var/obj/O in T)
										if(O.density)
											clear = 0
											break
									if(clear)
										L+=T
							if(L?.len)
								mob.forceMove(pick(L))
					if ("EI NATH!")//at least it's 1 out of 7, in a 2% chance to happen of an effect with a 10% (max 20%) to proc.
						var/list/targets = list()
						for(var/mob/living/L in range(1, get_turf(mob)))
							if (L != mob)
								targets += L
						var/mob/living/target = pick(targets)
						if (target)
							if (!mob.is_pacified(VIOLENCE_DEFAULT,target))
								if(ishuman(target) || ismonkey(target))
									var/mob/living/carbon/C = target
									if(!C.has_brain()) // Their brain is already taken out
										var/obj/item/organ/internal/brain/B = new(C.loc)
										B.transfer_identity(C)
								target.gib()

			if(prob(3) && count >= 60)
				spawn_wizard_clothes(mob)

			if(prob(5))
				if (count < 60)
					to_chat(mob, "<span class='warning'>You feel [pick("the magic bubbling in your veins","that this location gives you a +1 to INT","an urge to summon familiar.")].</span>")
				else
					to_chat(mob, "<span class='warning'>You feel [pick("the tidal wave of raw power building inside","that this location gives you a +2 to INT and +1 to WIS","an urge to teleport")].</span>")


/datum/disease2/effect/wizarditis/deactivate(var/mob/living/mob)
	if (ishuman(mob) && count > 0)
		var/mob/living/carbon/human/affected = mob
		affected.my_appearance.r_hair = old_r_hair
		affected.my_appearance.g_hair = old_g_hair
		affected.my_appearance.b_hair = old_b_hair
		affected.my_appearance.r_eyes = old_r_eyes
		affected.my_appearance.g_eyes = old_g_eyes
		affected.my_appearance.b_eyes = old_b_eyes
		affected.my_appearance.r_facial = old_r_facial
		affected.my_appearance.g_facial = old_g_facial
		affected.my_appearance.b_facial = old_b_facial
		affected.my_appearance.f_style = old_f_style
		affected.my_appearance.h_style = old_h_style
		affected.update_body(0)
		affected.update_hair()

/datum/disease2/effect/magnitis
	name = "Magnitis"
	desc = "This disease disrupts the magnetic field of the body, making it act as if a powerful magnet."
	encyclopedia = "Injections of iron help temporarily stabilize the magnetic field."
	stage = 4
	badness = EFFECT_DANGER_HARMFUL

/datum/disease2/effect/magnitis/activate(var/mob/living/mob)
	if(mob.reagents.has_reagent(IRON))
		return

	switch(count)
		if(0 to 10)
			if(prob(2))
				to_chat(mob, "<span class='warning'>You feel a slight shock course through your body.</span>")
				for(var/obj/M in orange(2,mob))
					if(!M.anchored && (M.is_conductor()))
						step_towards(M,mob)
				for(var/mob/living/silicon/S in orange(2,mob))
					if(istype(S, /mob/living/silicon/ai))
						continue
					step_towards(S,mob)
		if(11 to 20)
			if(prob(4))
				to_chat(mob, "<span class='warning'>You feel a strong shock course through your body.</span>")
				for(var/obj/M in orange(4,mob))
					if(!M.anchored && (M.is_conductor()))
						var/iter = rand(1,2)
						for(var/i=0,i<iter,i++)
							step_towards(M,mob)
				for(var/mob/living/silicon/S in orange(4,mob))
					if(istype(S, /mob/living/silicon/ai))
						continue
					var/iter = rand(1,2)
					for(var/i=0,i<iter,i++)
						step_towards(S,mob)
		if(21 to INFINITY)
			if(prob(8))
				to_chat(mob, "<span class='warning'>You feel a powerful shock course through your body.</span>")
				for(var/obj/M in orange(6,mob))
					if(!M.anchored && (M.is_conductor()))
						var/iter = rand(1,3)
						for(var/i=0,i<iter,i++)
							step_towards(M,mob)
				for(var/mob/living/silicon/S in orange(6,mob))
					if(istype(S, /mob/living/silicon/ai))
						continue
					var/iter = rand(1,3)
					for(var/i=0,i<iter,i++)
						step_towards(S,mob)
