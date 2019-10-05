//////////////////////
//					//
//     POISONS		//
//					//
//////////////////////



/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	id = CRYPTOBIOLIN
	description = "Cryptobiolin causes confusion and dizzyness."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.2
	density = 1.21
	specheatcap = 0.85

/datum/reagent/cryptobiolin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.Dizzy(1)
	M.confused = max(M.confused, 20)


/datum/reagent/lexorin
	name = "Lexorin"
	id = LEXORIN
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 0.655293
	specheatcap = 7.549

/datum/reagent/lexorin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(33))
		M.take_organ_damage(REM, 0, ignore_inorganics = TRUE)
	M.adjustOxyLoss(3)
	if(prob(20))
		M.emote("gasp", null, null, TRUE)


/datum/reagent/hypozine //syndie hyperzine
	name = "Hypozine"
	id = HYPOZINE
	description = "Hypozine is an extremely effective, short lasting, muscle stimulant."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	var/has_been_hypozined = 0
	var/has_had_heart_explode = 0 //We've applied permanent damage.
	custom_metabolism = 0.04
	var/oldspeed = 0
	data = 0

/datum/reagent/hypozine/reagent_deleted()

	if(..())
		return 1

	if(!holder)
		return
	var/mob/M =  holder.my_atom

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!has_been_hypozined)
			return
		var/timedmg = ((data - 60) / 2)
		if (timedmg > 0)
			dehypozine(H, timedmg, 1, 0)

/datum/reagent/hypozine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.reagents.add_reagent ("hyperzine", 0.03) //To pretend it's all okay.
	if(ishuman(M))
		if(data<121 && !has_been_hypozined)
			has_been_hypozined = 1
			has_had_heart_explode = 0 //Fuck them UP after they're done going fast.

	switch(data)
		if(60 to 99)	//Speed up after a minute
			if(data==60)
				to_chat(M, "<span class='notice'>You feel faster.")
				M.movement_speed_modifier += 0.5
				oldspeed += 0.5
			if(prob(5))
				to_chat(M, "<span class='notice'>[pick("Your leg muscles pulsate", "You feel invigorated", "You feel like running")].")
		if(100 to 114)	//painfully fast
			if(data==100)
				to_chat(M, "<span class='notice'>Your muscles start to feel pretty hot.")
				M.movement_speed_modifier += 0.5
				oldspeed += 0.5
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(10))
					if (M.get_heart())
						to_chat(M, "<span class='notice'>[pick("Your legs are heating up", "You feel your heart racing", "You feel like running as far as you can")]!")
					else
						to_chat(M, "<span class='notice'>[pick("Your legs are heating up", "Your body is aching to move", "You feel like running as far as you can")]!")
				H.adjustFireLoss(0.1)
		if(115 to 120)	//traverse at a velocity exceeding the norm
			if(data==115)
				to_chat(M, "<span class='alert'>Your muscles are burning up!")
				M.movement_speed_modifier += 2
				oldspeed += 2

			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(25))
					if (M.get_heart())
						to_chat(M, "<span class='alert'>[pick("Your legs are burning", "All you feel is your heart racing", "Run! Run through the pain")]!")
					else
						to_chat(M, "<span class='alert'>[pick("Your legs are burning", "You feel like you're on fire", "Run! Run through the heat")]!")
				H.adjustToxLoss(1)
				H.adjustFireLoss(2)
		if(121 to INFINITY)	//went2fast
			dehypozine(M)
	data++

/datum/reagent/hypozine/proc/dehypozine(var/mob/living/M, heartdamage = 30, override_remove = 0, explodeheart = 1)
	M.movement_speed_modifier -= oldspeed
	if(has_been_hypozined && !has_had_heart_explode)
		has_had_heart_explode = 1
		if(!override_remove)
			holder.remove_reagent(src.id) //Clean them out

		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.get_heart())//Got a heart?
				var/datum/organ/internal/heart/damagedheart = H.get_heart()
				if (heartdamage >= 30)
					if(H.species.name != "Diona" && damagedheart) //fuck dionae
						to_chat(H, "<span class='danger'>You feel a terrible pain in your chest!</span>")
						damagedheart.damage += heartdamage //Bye heart.
						if(explodeheart)
							qdel(H.remove_internal_organ(H,damagedheart,H.get_organ(LIMB_CHEST)))
						H.adjustOxyLoss(heartdamage*2)
						H.adjustBruteLoss(heartdamage)
					else
						to_chat(H, "<span class='danger'>The heat engulfs you!</span>")
						for(var/datum/organ/external/E in H.organs)
							E.droplimb(1, 1) //Bye limbs!
							H.adjustFireLoss(heartdamage)
							H.adjustBruteLoss(heartdamage)
							H.adjustToxLoss(heartdamage)
							if(explodeheart)
								qdel(H.remove_internal_organ(H,damagedheart,H.get_organ(LIMB_CHEST))) //and heart!
				else if (heartdamage < 30)
					if(H.species.name != "Diona")
						to_chat(H, "<span class='danger'>You feel a sharp pain in your chest!</span>")
					else
						to_chat(H, "<span class='danger'>The heat engulfs you!</span>")
						H.adjustFireLoss(heartdamage)
					damagedheart.damage += heartdamage
					H.adjustToxLoss(heartdamage)
					H.adjustBruteLoss(heartdamage)
			else//No heart?
				to_chat(H, "<span class='danger'>The heat engulfs you!</span>")
				if (heartdamage >= 30)
					for(var/datum/organ/external/E in H.organs)
						E.droplimb(1, 1) //Bye limbs!
						H.adjustBruteLoss(heartdamage)
						H.adjustFireLoss(heartdamage)
				else if (heartdamage < 30)
					H.adjustBruteLoss(heartdamage)
					H.adjustFireLoss(heartdamage)
					H.adjustToxLoss(heartdamage)
		else
			M.gib()
		data = 0
		oldspeed = 0



/datum/reagent/carpotoxin
	name = "Carpotoxin"
	id = CARPOTOXIN
	description = "A deadly neurotoxin produced by the dreaded spess carp."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#003333" //rgb: 0, 51, 51
	density = 319.27 //Assuming it's Tetrodotoxin
	specheatcap = 41.53

/datum/reagent/carpotoxin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustToxLoss(2 * REM)

/datum/reagent/zombiepowder
	name = "Zombie Powder"
	id = ZOMBIEPOWDER
	description = "A strong neurotoxin that puts the subject into a death-like state."
	color = "#669900" //rgb: 102, 153, 0
	density = 829.48
	specheatcap = 274.21

/datum/reagent/zombiepowder/on_mob_life(var/mob/living/carbon/M)

	if(..())
		return 1

	if(volume >= 1) //Hotfix for Fakedeath never ending.
		M.status_flags |= FAKEDEATH
	else
		M.status_flags &= ~FAKEDEATH
	M.adjustOxyLoss(0.5 * REM)
	M.adjustToxLoss(0.5 * REM)
	M.Knockdown(10)
	M.Stun(10)
	M.silent = max(M.silent, 10)
	M.tod = worldtime2text()

/datum/reagent/zombiepowder/reagent_deleted()
	return on_removal(volume)

//Hotfix for Fakedeath never ending.
/datum/reagent/zombiepowder/on_removal(var/amount)
	if(!..(amount))
		return 0

	var/newvol = max(0, volume - amount)
	if(iscarbon(holder.my_atom))
		var/mob/living/carbon/M = holder.my_atom
		if(newvol >= 1)
			M.status_flags |= FAKEDEATH
		else
			M.status_flags &= ~FAKEDEATH
	return 1

/datum/reagent/heartbreaker
	name = "Heartbreaker Toxin"
	id = HEARTBREAKER
	description = "A powerful hallucinogen and suffocant. Not a thing to be messed with."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#ff91b7" //rgb: 255, 145, 183
	density = 0.78
	specheatcap = 5.47

/datum/reagent/heartbreaker/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.hallucination += 5
	M.adjustOxyLoss(4 * REM)

/datum/reagent/spiritbreaker
	name = "Spiritbreaker Toxin"
	id = SPIRITBREAKER
	description = "An extremely dangerous hallucinogen often used for torture. Extracted from the leaves of the rare Ambrosia Cruciatus plant."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3B0805" //rgb: 59, 8, 5
	custom_metabolism = 0.05

/datum/reagent/spiritbreaker/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	if(data >= 165)
		M.adjustToxLoss(0.2)
		M.adjustBrainLoss(5)
		M.hallucination += 100
		M.dizziness += 100
		M.confused += 2
	data++


/datum/reagent/bicarodyne
	name = "Bicarodyne"
	id = BICARODYNE
	description = "Not to be confused with Bicaridine, Bicarodyne is a volatile chemical that reacts violently in the presence of most human endorphins."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	overdose_am = REAGENTS_OVERDOSE * 2 //No need for anyone to get suspicious.
	custom_metabolism = 0.01


//Otherwise known as a "Mickey Finn"
/datum/reagent/chloralhydrate
	name = "Chloral Hydrate"
	id = CHLORALHYDRATE
	description = "A powerful sedative."
	reagent_state = REAGENT_STATE_SOLID
	color = "#000067" //rgb: 0, 0, 103
	data = 1 //Used as a tally
	flags = CHEMFLAG_DISHONORABLE // NO CHEATING
	density = 11.43
	specheatcap = 13.79

/datum/reagent/chloralhydrate/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	switch(data)
		if(1)
			M.confused += 2
			M.drowsyness += 2
		if(2 to 80)
			M.sleeping++
		if(81 to INFINITY)
			M.sleeping++
			M.toxloss += (data - 50)
	data++

//Chloral hydrate disguised as normal beer for use by emagged brobots
/datum/reagent/chloralhydrate/beer2
	name = "Beer"
	id = BEER2
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0


/datum/reagent/amatoxin
	name = "Amatoxin"
	id = AMATOXIN
	description = "A powerful poison derived from certain species of mushroom."
	color = "#792300" //rgb: 121, 35, 0

/datum/reagent/amatoxin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustToxLoss(1.5)

/datum/reagent/amanatin
	name = "Alpha-Amanatin"
	id = AMANATIN
	description = "A deadly poison derived from certain species of Amanita. Sits in the victim's system for a long period of time, then ravages the body."
	color = "#792300" //rgb: 121, 35, 0
	custom_metabolism = 0.01
	data = 1 //Used as a tally
	var/activated = 0

/datum/reagent/amanatin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(volume <= 3 && data >= 60 && !activated)	//Minimum of 1 minute required to be useful
		activated = 1
	if(activated)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(prob(8))
				H << "<span class='warning'>You feel violently ill.</span>"
			if(prob(min(data / 10, 100)))
				H.vomit()
			var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
			if(istype(L) && !L.is_broken())
				L.take_damage(data * 0.01, 0)
				H.adjustToxLoss(round(data / 20, 1))
			else
				H.adjustToxLoss(round(data / 10, 1))
				data += 4
	switch(data)
		if(1 to 30)
			M.druggy = max(M.druggy, 10)
		if(540 to 600)	//Start barfing violently after 9 minutes
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(12))
					H << "<span class='warning'>You feel violently ill.</span>"
				H.adjustToxLoss(0.1)
				if(prob(8))
					H.vomit()
		if(600 to INFINITY)	//Ded in 10 minutes with a minimum of 6 units
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(20))
					H << "<span class='sinister'>You feel deathly ill.</span>"
				var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
				if(istype(L) && !L.is_broken())
					L.take_damage(10, 0)
				else
					H.adjustToxLoss(60)
	data++


/datum/reagent/stoxin
	name = "Sleep Toxin"
	id = STOXIN
	description = "An effective hypnotic used to treat insomnia."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#E895CC" //rgb: 232, 149, 204
	custom_metabolism = 0.1
	data = 1 //Used as a tally
	density = 3.56
	specheatcap = 17.15

/datum/reagent/stoxin/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	switch(data)
		if(1 to 15)
			M.eye_blurry = max(M.eye_blurry, 10)
		if(15 to 25)
			M.drowsyness  = max(M.drowsyness, 20)
		if(25 to INFINITY)
			M.Paralyse(20)
			M.drowsyness  = max(M.drowsyness, 30)
	data++


/datum/reagent/toxin
	name = "Toxin"
	id = TOXIN
	description = "A Toxic chemical."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	custom_metabolism = 0.01
	density = 1.4 //Let's just assume it's alpha-solanine

/datum/reagent/toxin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	//Toxins are really weak, but without being treated, last very long
	M.adjustToxLoss(0.2)

/datum/reagent/plasticide
	name = "Plasticide"
	id = PLASTICIDE
	description = "Liquid plastic, do not eat."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	custom_metabolism = 0.01
	density = 0.4
	specheatcap = 1.67

/datum/reagent/plasticide/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	//Toxins are really weak, but without being treated, last very long
	M.adjustToxLoss(0.2)


/datum/reagent/mutagen
	name = "Unstable mutagen"
	id = MUTAGEN
	description = "Might cause unpredictable mutations. Keep away from children."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#13BC5E" //rgb: 19, 188, 94
	density = 3.35
	specheatcap = 96.86

/datum/reagent/mutagen/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	if(!M.dna) //No robots, AIs, aliens, Ians or other mobs should be affected by this.
		return
	if((method == TOUCH && prob(33)) || method == INGEST)
		if(prob(98))
			randmutb(M)
		else
			randmutg(M)
		domutcheck(M, null)
		if(M.last_appearance_mutation + 1 SECONDS < world.time)
			randmuti(M)
			M.UpdateAppearance()

/datum/reagent/mutagen/on_mob_life(var/mob/living/M)
	if(!M.dna)
		return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if(!M)
		M = holder.my_atom
	if(..())
		return 1
	M.apply_radiation(10,RAD_INTERNAL)


//Petritricin = cockatrice juice
//Lore explanation for it affecting worn items (like hardsuits), but not items dropped on the ground that it was splashed over:
//Pure petritricin can stonify any matter, organic or unorganic. However, if it's outside of a living organism, it rapidly deterogates
//until it is only strong enough to affect organic matter.
//When introduced to organic matter, petritricin converts living cells to produce more of itself, and the freshly produced substance
//can affect items worn close enough to the body

/datum/reagent/petritricin
	name = "Petritricin"
	id = PETRITRICIN
	description = "Petritricin is a venom produced by cockatrices. The extraction process causes a major potency loss, but a right dose of this can still petrify somebody."
	color = "#002000" //rgb: 0, 32, 0
	dupeable = FALSE

	var/minimal_dosage = 1 //At least 1 unit is needed for petriication

/datum/reagent/petritricin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(volume >= minimal_dosage && prob(30))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(locate(/datum/disease/petrification) in H.viruses)
				return

			var/datum/disease/D = new /datum/disease/petrification
			D.holder = H
			D.affected_mob = H
			H.viruses += D
		else if(!issilicon(M))
			if(M.turn_into_statue(1)) //Statue forever
				to_chat(M, "<span class='userdanger'>You have been turned to stone by ingesting petritricin.</span>")


/datum/reagent/hemoscyanine
	name = "Hemoscyanine"
	id = HEMOSCYANINE
	description = "Hemoscyanine is a toxin which can destroy blood cells."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#600000" //rgb: 96, 0, 0
	density = 11.53
	specheatcap = 0.22

/datum/reagent/hemoscyanine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!(H.species.anatomy_flags & NO_BLOOD))
			H.vessel.remove_reagent(BLOOD, 2)


/datum/reagent/ironrot
	name = "Ironrot"
	id = IRONROT
	description = "A mutated fungal compound that causes rapid rotting in iron infrastructures."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#005200" //moldy green

/datum/reagent/ironrot/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(volume >= 5 && T.can_thermite)
		T:rot()

/datum/reagent/ironrot/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustToxLoss(2 * REM)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/chest/C = H.get_organ(LIMB_CHEST)
		for(var/datum/organ/internal/I in C.internal_organs)
			if(I.robotic == 2)
				I.take_damage(10, 0)//robo organs get damaged by ingested ironrot

/datum/reagent/ironrot/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	if(..())
		return 1

	if(method == TOUCH)
		if(issilicon(M))//borgs are hurt on touch by this chem
			M.adjustFireLoss(5*REM)
			M.adjustBruteLoss(5*REM)