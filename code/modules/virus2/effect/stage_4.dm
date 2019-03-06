/datum/disease2/effect/minttoxin
	name = "Creosote Syndrome"
	desc = "Causes the infected to synthesize a wafer thin mint."
	stage = 4

/datum/disease2/effect/minttoxin/activate(var/mob/living/carbon/mob)
	if(istype(mob) && mob.reagents.get_reagent_amount(MINTTOXIN) < 5)
		to_chat(mob, "<span class='notice'>You feel a minty freshness</span>")
		mob.reagents.add_reagent(MINTTOXIN, 5)


/datum/disease2/effect/gibbingtons
	name = "Gibbingtons Syndrome"
	desc = "Causes the infected to spontaneously explode in a shower of gore."
	stage = 4
	badness = 2

/datum/disease2/effect/gibbingtons/activate(var/mob/living/carbon/mob)
	mob.gib()


/datum/disease2/effect/radian
	name = "Radian's Syndrome"
	desc = "Causes the infected to generate strange protein, that begins radioactive decay in the denser material held within the infected's body, causing radioactive exposure."
	stage = 4
	max_multiplier = 3

/datum/disease2/effect/radian/activate(var/mob/living/carbon/mob)
	mob.radiation += (2*multiplier)


/datum/disease2/effect/deaf
	name = "Dead Ear Syndrome"
	desc = "Kills the infected's aural senses."
	stage = 4

/datum/disease2/effect/deaf/activate(var/mob/living/carbon/mob)
	mob.ear_deaf += 20


/datum/disease2/effect/monkey
	name = "Monkism Syndrome"
	desc = "Causes the infected to rapidly devolve to a lower form of life."
	stage = 4
	badness = 2

/datum/disease2/effect/monkey/activate(var/mob/living/carbon/mob)
	if(istype(mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/h = mob
		h.monkeyize()


/datum/disease2/effect/catbeast
	name = "Kingston Syndrome"
	desc = "A previously experimental syndrome that found its way into the wild. Causes the infected to mutate into a Tajaran."
	stage = 4
	badness = 2

/datum/disease2/effect/catbeast/activate(var/mob/living/carbon/mob)
	if(istype(mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/h = mob
		if(h.species.name != "Tajaran")
			if(h.set_species("Tajaran"))
				h.regenerate_icons()

/datum/disease2/effect/zombie
	name = "Stubborn brain syndrome"
	desc = "UNKNOWN"
	stage = 4
	badness = 2

/datum/disease2/effect/zombie/activate(var/mob/living/carbon/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/h = mob
		h.become_zombie_after_death = 1


/datum/disease2/effect/voxpox
	name = "Vox Pox"
	desc = "A previously experimental syndrome that found its way into the wild. Causes the infected to mutate into a Vox."
	stage = 4
	badness = 2

/datum/disease2/effect/voxpox/activate(var/mob/living/carbon/mob)
	if(istype(mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/h = mob
		if(h.species.name != "Vox")
			if(h.set_species("Vox"))
				h.regenerate_icons()


/datum/disease2/effect/suicide
	name = "Suicidal Syndrome"
	desc = "Induces clinical depression in the infected, causing them to attempt to take their own life on the spot."
	stage = 4
	badness = 2

/datum/disease2/effect/suicide/activate(var/mob/living/carbon/mob)

	if(mob.stat != CONSCIOUS || !mob.canmove || mob.restrained()) //Try as we might, we still can't snap our neck when we are KO or restrained, even if forced.
		return

	mob.attempt_suicide(1, 0)

/datum/disease2/effect/killertoxins
	name = "Toxification Syndrome"
	desc = "A more advanced version of Hyperacidity, causing the infected to rapidly generate toxins."
	stage = 4

/datum/disease2/effect/killertoxins/activate(var/mob/living/carbon/mob)
	mob.adjustToxLoss(15*multiplier)


/datum/disease2/effect/dna
	name = "Reverse Pattern Syndrome"
	desc = "Attacks the infected's DNA, causing rapid spontaneous mutation, and inhibits the ability for the infected to be affected by cryogenics."
	stage = 4

/datum/disease2/effect/dna/activate(var/mob/living/carbon/mob)
	mob.bodytemperature = max(mob.bodytemperature, 350)
	scramble(0,mob,10)
	mob.apply_damage(10, CLONE)


/datum/disease2/effect/organs
	name = "Shutdown Syndrome"
	desc = "Attacks the infected's limbs, causing them to shut down. Also inhibits toxin processing, causing toxin buildup."
	stage = 4

/datum/disease2/effect/organs/activate(var/mob/living/carbon/mob)
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

/datum/disease2/effect/organs/vampire
	stage = 1 //For use with vampires?
	badness = 3

/datum/disease2/effect/organs/deactivate(var/mob/living/carbon/mob)
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

/datum/disease2/effect/immortal/activate(var/mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		for (var/datum/organ/external/E in H.organs)
			if (E.status & ORGAN_BROKEN && prob(30))
				E.status ^= ORGAN_BROKEN
	var/heal_amt = -5*multiplier
	mob.apply_damages(heal_amt,heal_amt,heal_amt,heal_amt)

/datum/disease2/effect/immortal/deactivate(var/mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		to_chat(H, "<span class='notice'>You suddenly feel hurt and old...</span>")
		H.age += 8
	var/backlash_amt = 5*multiplier
	mob.apply_damages(backlash_amt,backlash_amt,backlash_amt,backlash_amt)


/datum/disease2/effect/bones
	name = "Fragile Bones Syndrome"
	desc = "Attacks the infected's bone structure, making it more porous and fragile."
	stage = 4

/datum/disease2/effect/bones/activate(var/mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		for (var/datum/organ/external/E in H.organs)
			E.min_broken_damage = max(5, E.min_broken_damage - 30)

/datum/disease2/effect/bones/deactivate(var/mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		for (var/datum/organ/external/E in H.organs)
			E.min_broken_damage = initial(E.min_broken_damage)


/datum/disease2/effect/scc
	name = "Spontaneous Cellular Collapse"
	desc = "Converts the infected's internal toxin treatment to synthesize Polyacid, as well as cause the infected's skin to break, and their bones to fracture."
	stage = 4

/datum/disease2/effect/scc/activate(var/mob/living/carbon/mob)
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

/datum/disease2/effect/necrosis/activate(var/mob/living/carbon/mob)

	if(ishuman(mob)) //Only works on humans properly since it needs to do organ work
		var/mob/living/carbon/human/H = mob
		var/inst = pick(1, 2, 3)

		switch(inst)

			if(1)
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

			if(2)
				for(var/datum/organ/external/E in H.organs)
					if(pick(1, 0))
						E.droplimb(1)

			if(3)
				if(H.species.name != "Skellington")
					to_chat(H, "<span class='warning'>Your necrotic skin ruptures!</span>")

					for(var/datum/organ/external/E in H.organs)
						if(pick(1,0))
							E.createwound(CUT, pick(2, 4, 6, 8, 10))

					if(prob(30))
						if(H.species.name != "Skellington")
							if(H.set_species("Skellington"))
								to_chat(mob, "<span class='warning'>A massive amount of flesh sloughs off your bones!</span>")
								H.regenerate_icons()
				else
					return


/datum/disease2/effect/fizzle
	name = "Fizzle Effect"
	desc = "Causes an ill sensation in the infected's throat."
	stage = 4

/datum/disease2/effect/fizzle/activate(var/mob/living/carbon/mob)
	mob.emote("me",1,pick("sniffles...", "clears their throat..."))


/datum/disease2/effect/delightful
	name = "Delightful Effect"
	desc = "A more powerful version of Full Glass. Makes the infected feel delightful."
	stage = 4

/datum/disease2/effect/delightful/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class = 'notice'>You feel delightful!</span>")
	if (mob.reagents.get_reagent_amount(DOCTORSDELIGHT) < 1)
		mob.reagents.add_reagent(DOCTORSDELIGHT, 1)


/datum/disease2/effect/spawn
	name = "Arachnogenesis Effect"
	desc = "Converts the infected's stomach to begin producing creatures of the arachnid variety."
	stage = 4
	var/spawn_type=/mob/living/simple_animal/hostile/giant_spider/spiderling
	var/spawn_name="spiderling"

/datum/disease2/effect/spawn/activate(var/mob/living/carbon/mob)
	playsound(mob.loc, 'sound/effects/splat.ogg', 50, 1)

	new spawn_type(get_turf(mob))
	mob.emote("me",1,"vomits up a live [spawn_name]!")

/datum/disease2/effect/spawn/roach
	name = "Blattogenesis Effect"
	desc = "Converts the infected's stomach to begin producing creatures of the blattid variety."
	stage = 4
	spawn_type=/mob/living/simple_animal/cockroach
	spawn_name="cockroach"


/datum/disease2/effect/orbweapon
	name = "Biolobulin Effect"
	desc = "Converts the infected's pores of their palm to begin synthesizing a gelatenous substance, that explodes upon reaching a high velocity."
	stage = 4

/datum/disease2/effect/orbweapon/activate(var/mob/living/carbon/mob)
	var/obj/item/toy/snappop/virus/virus = new /obj/item/toy/snappop/virus
	mob.put_in_hands(virus)


/datum/disease2/effect/plasma
	name = "Toxin Sublimation"
	desc = "Converts the infected's pores and respiratory organs to synthesize Plasma gas."
	stage = 4

/datum/disease2/effect/plasma/activate(var/mob/living/carbon/mob)
	//var/src = mob
	var/hack = mob.loc
	var/turf/simulated/T = get_turf(hack)
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

	var/list/original_languages = list()

/datum/disease2/effect/babel/activate(var/mob/living/carbon/mob)
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

/datum/disease2/effect/babel/deactivate(var/mob/living/carbon/mob)
	if(original_languages.len)
		for(var/forgotten in original_languages)
			mob.add_language(forgotten)

		to_chat(mob, "Suddenly, your knowledge of languages comes back to you.")


/datum/disease2/effect/gregarious
	name = "Gregarious Impetus"
	desc = "Infests the social structures of the infected's brain, causing them to feel better in crowds of other potential victims, and punishing them for being alone."
	stage = 4
	max_chance = 25
	max_multiplier = 4

/datum/disease2/effect/gregarious/activate(var/mob/living/carbon/mob)
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
	var/skip = FALSE
	var/brute_mod_subtracted = 0
	var/therm_loss_mod_subtracted = 0
	var/cal_heat_mod_added = 0

/datum/disease2/effect/thick_skin/activate(var/mob/living/carbon/mob)
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

/datum/disease2/effect/thick_skin/deactivate(var/mob/living/carbon/mob)
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
	max_count = 1

/datum/disease2/effect/heart_attack/activate(var/mob/living/carbon/mob)
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