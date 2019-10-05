//////////////////////
//					//
//     NARCOTICS	//
//					//
//////////////////////


/datum/reagent/space_drugs
	name = "Space drugs"
	id = SPACE_DRUGS
	description = "An illegal chemical compound used as drug."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#60A584" //rgb: 96, 165, 132
	custom_metabolism = 0.5
	overdose_am = REAGENTS_OVERDOSE
	density = 5.23
	specheatcap = 0.62

/datum/reagent/space_drugs/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.druggy = max(M.druggy, 15)
	if(isturf(M.loc) && !istype(M.loc, /turf/space))
		if(M.canmove && !M.restrained())
			if(prob(10))
				step(M, pick(cardinal))

	if(prob(7))
		M.emote(pick("twitch", "drool", "moan", "giggle"), null, null, TRUE)


/datum/reagent/serotrotium
	name = "Serotrotium"
	id = SEROTROTIUM
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#202040" //rgb: 20, 20, 40
	custom_metabolism = 0.25
	overdose_am = REAGENTS_OVERDOSE
	density = 1.8
	specheatcap = 2.84

/datum/reagent/serotrotium/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(7))
		M.emote(pick("twitch", "drool", "moan", "gasp"), null, null, TRUE)

	M.druggy = max(M.druggy, 50)


/datum/reagent/mindbreaker
	name = "Mindbreaker Toxin"
	id = MINDBREAKER
	description = "A powerful hallucinogen. Not a thing to be messed with."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#B31008" //rgb: 139, 166, 233
	custom_metabolism = 0.05
	density = 0.78
	specheatcap = 5.47

/datum/reagent/mindbreaker/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.hallucination += 10

/datum/reagent/nicotine
	name = "Nicotine"
	id = NICOTINE
	description = "A highly addictive stimulant extracted from the tobacco plant."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#181818" //rgb: 24, 24, 24
	density = 1.01

//Solely for flavor.
/datum/reagent/tobacco
	name = "Tobacco"
	id = TOBACCO
	description = "The cured and ground leaves of a tobacco plant."
	reagent_state = REAGENT_STATE_SOLID
	color = "#4c1e00" //rgb: 76, 30, 0
	density = 1.01

/datum/reagent/danbacco
	name = "Tobacco"
	id = DANBACCO //This product may or may not cause cancer.
	description = "The cured and ground leaves of a tobacco plant with additional Discount Dan flavors."
	reagent_state = REAGENT_STATE_SOLID
	color = "#4c1e00" //rgb: 76, 30, 0
	density = 1.01

/datum/reagent/danbacco/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(50)) //Discount dan's special blend.
			H.add_cancer(1, LIMB_CHEST)


/datum/reagent/creatine
	name = "Creatine"
	id = CREATINE
	description = "Highly toxic substance that grants the user enormous strength, before their muscles seize and tear their own body to shreds."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255, 255, 255
	var/has_been_hulk = 0
	var/has_ripped_and_torn = 0 //We've applied permanent damage.
	var/hulked_at = 0 //world.time
	custom_metabolism = 0.1
	data = 1 //Used as a tally
	density = 6.82
	specheatcap = 678.67

/datum/reagent/creatine/reagent_deleted()

	if(..())
		return 1

	if(!holder)
		return
	var/mob/M =  holder.my_atom

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!has_been_hulk || has_ripped_and_torn || (!(M_HULK in H.mutations)))
			return
		var/timedmg = ((30 SECONDS) - (H.hulk_time - world.time)) / 10
		dehulk(H, timedmg * 3, 1, 0)

/datum/reagent/creatine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	switch(volume)
		if(1 to 25)
			M.adjustToxLoss(1)
			M.Dizzy(5)
			M.Jitter(5)
			if(prob(5) && M.feels_pain())
				to_chat(M, "<span class='warning'>Oh god, the pain!</span>")
		if(25 to INFINITY)
			if(ishuman(M)) //Does nothing to non-humans.
				var/mob/living/carbon/human/H = M
				if(H.species.name != "Diona") //Dionae are broken as fuck
					if(H.hulk_time<world.time && !has_been_hulk)
						H.hulk_time = world.time + (30 SECONDS)
						hulked_at = H.hulk_time
						if(!(M_HULK in H.mutations))
							has_been_hulk = 1
							has_ripped_and_torn = 0 //Fuck them UP after they dehulk.
							H.mutations.Add(M_HULK)
							H.update_mutations() //Update our mutation overlays
							H.update_body()
							message_admins("[key_name(M)] is TOO SWOLE TO CONTROL (on creatine)! ([formatJumpTo(M)])")
					else if(H.hulk_time<world.time && has_been_hulk) //TIME'S UP
						dehulk(H)
					else if(prob(1))
						H.say(pick("YOU TRYIN' BUILD SUM MUSSLE?", "TOO SWOLE TO CONTROL", "HEY MANG", "HEY MAAAANG"))

	data++

/datum/reagent/creatine/proc/dehulk(var/mob/living/carbon/human/H, damage = 200, override_remove = 0, gib = 1)

	if(has_been_hulk && !has_ripped_and_torn)
		to_chat(H, "<span class='warning'>You feel like your muscles are ripping apart!</span>")
		has_ripped_and_torn = 1
		if(!override_remove)
			holder.remove_reagent(src.id) //Clean them out
		H.adjustBruteLoss(damage) //Crit

		if(gib)
			for(var/datum/organ/external/E in H.organs)
				if(prob(50))
					//Override the current limb status and don't cause an explosion
					E.droplimb(1, 1)

			if(H.species)
				hgibs(H.loc, H.virus2, H.dna, H.species.flesh_color, H.species.blood_color)
			else
				hgibs(H.loc, H.virus2, H.dna)

		H.hulk_time = 0 //Just to be sure.
		H.mutations.Remove(M_HULK)
		//M.dna.SetSEState(HULKBLOCK,0)
		H.update_mutations()		//update our mutation overlays
		H.update_body()


/datum/reagent/psilocybin
	name = "Psilocybin"
	id = PSILOCYBIN
	description = "A strong psycotropic derived from certain species of mushroom."
	color = "#E700E7" //rgb: 231, 0, 231
	data = 1 //Used as a tally

/datum/reagent/psilocybin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.druggy = max(M.druggy, 30)
	switch(data)
		if(1 to 5)
			if(!M.stuttering)
				M.stuttering = 1
			M.Dizzy(5)
			if(prob(10))
				M.emote(pick("twitch", "giggle"))
		if(5 to 10)
			if(!M.stuttering)
				M.stuttering = 1
			M.Jitter(10)
			M.Dizzy(10)
			M.druggy = max(M.druggy, 35)
			if(prob(20))
				M.emote(pick("twitch", "giggle"))
		if (10 to INFINITY)
			if(!M.stuttering)
				M.stuttering = 1
			M.Jitter(20)
			M.Dizzy(20)
			M.druggy = max(M.druggy, 40)
			if(prob(30))
				M.emote(pick("twitch", "giggle"))
	data++


/datum/reagent/impedrezene
	name = "Impedrezene"
	id = IMPEDREZENE
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	overdose_am = REAGENTS_OVERDOSE
	density = 8.15
	specheatcap = 0.16

/datum/reagent/impedrezene/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.jitteriness = max(M.jitteriness - 5,0)
	if(prob(80))
		M.adjustBrainLoss(5 * REM)
	if(prob(50))
		M.drowsyness = max(M.drowsyness, 3)
	if(prob(10))
		M.emote("drool", null, null, TRUE)




/datum/reagent/degeneratecalcium
	name = "Degenerate calcium"
	id = DEGENERATECALCIUM
	description = "A highly radical chemical derived from calcium that aggressively attempts to regenerate osseus tissues it comes in contact with. In the presence of micro-fractures caused by extensive brute damage it rapidly heals the surrounding tissues, but in healthy limbs the new tissue quickly causes the osseal structure to lose shape and shatter rather graphically."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#ccffb3" //rgb: 204, 255, 179
	density = 3.9
	specheatcap = 128.12
	custom_metabolism = 0.1

/datum/reagent/degeneratecalcium/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.anatomy_flags & NO_BONES)
			return

		//if you have 30 or more brute damage: rapidly heals, makes your bones stronk
		//if you have less than 30 brute damage: rapidly heals, breaks all your bones one by one
		//(the rapid healing is likely to land you in that "less than 30" club real quick if you're not careful...)
		H.heal_organ_damage(3 * REM, 0)

		if(H.getBruteLoss(TRUE) >= 30)
			for(var/datum/organ/external/E in H.organs) //"organs" list only contains external organs aka limbs
				if((E.status & ORGAN_BROKEN) || !E.is_organic() || (E.min_broken_damage >= E.max_damage))
					continue
				E.min_broken_damage += rand(4,8) * REM
				if(E.min_broken_damage >= E.max_damage)
					E.min_broken_damage = E.max_damage
					to_chat(H, "Your [E.display_name] feels [pick("sturdy", "hardy")] as it can be!") //todo unfunny skeleton jokes (someone will probably comment them in the PR)
		else if(prob((100 - H.getBruteLoss() * 100 / 30)/3)) //33% at 0 damage, 16.6% at 15 damage, 1.1% at 29 damage etc
			var/datum/organ/external/E = pick(H.organs) //"organs" list only contains external organs aka limbs
			E.fracture()


/datum/reagent/hyperzine
	name = "Hyperzine"
	id = HYPERZINE
	description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.03
	overdose_am = REAGENTS_OVERDOSE/2
	density = 1.79
	specheatcap = 0.70

/datum/reagent/hyperzine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(5) && M.stat == CONSCIOUS)
		M.emote(pick("twitch","blink_r","shiver"))