//Illicit chemicals, with the exception of toxins

/datum/reagent/caffeine
	name = "Caffeine"
	id = CAFFEINE
	description = "Caffeine is a common stimulant. It works by making your metabolism faster so it also increases your appetite."
	color = "#E8E8E8" //rgb: 232, 232, 232
	// it also makes you hungry because it speeds up your metabolism
	nutriment_factor = -5 * REAGENTS_METABOLISM
	density = 1.23
	specheatcap = 0.89
	custom_metabolism = 0.1

/datum/reagent/caffeine/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	// you just ingested pure caffeine so you're gonna get the BIG shakes
	M.Jitter(10)

/datum/reagent/creatine
	name = "Creatine"
	id = CREATINE
	description = "Highly toxic substance that grants the user enormous strength, before their muscles seize and tear their own body to shreds."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255, 255, 255
	var/has_been_hulk = 0
	var/has_ripped_and_torn = 0 //We've applied permanent damage.
	var/hulked_at = 0 //world.time
	var/has_mouse_bulked = 0
	custom_metabolism = 0.1
	density = 6.82
	specheatcap = 0.67867

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
			if(ishuman(M)) //If human and not diona, hulk out
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
			if(ismouse(M)) //If mouse, become a gym rat. With a 1 in 20 chance of becoming a roid rat
				if(has_mouse_bulked == 0)
					if(prob(95))
						has_mouse_bulked = 1
						if(prob(95))
							M.visible_message("<span class='warning'>[M] suddenly grows significantly in size, the color draining from its fur as its muscles expand!</span>")
							M.transmogrify(/mob/living/simple_animal/hostile/retaliate/gym_rat)
						else
							M.visible_message("<span class='warning'>[M] suddenly grows significantly in size, the color draining from its fur as its muscles expand! A pomadour also sprouts from the top of its head!</span>")
							M.transmogrify(/mob/living/simple_animal/hostile/retaliate/gym_rat/pompadour_rat)
					else
						has_mouse_bulked = 1
						M.visible_message("<span class='danger'>[M] grows to the size of a dog, and its muscles expand to ridiculous proportions! It's ripped!</span>")
						M.transmogrify(/mob/living/simple_animal/hostile/retaliate/gym_rat/roid_rat)
				else //You only bulk once, fella. If you lose the bulk, you're outta luck
					return

/datum/reagent/creatine/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return
	var/amount = T.reagents.get_reagent_amount(id)
	if(amount >= 1)
		if(prob(15))
			T.mutate(GENE_DEVELOPMENT)
			T.reagents.remove_reagent(id, 1)
	else if(amount > 0)
		T.reagents.remove_reagent(id, amount)

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

/datum/reagent/hippies_delight
	name = "Hippie's Delight"
	id = HIPPIESDELIGHT
	description = "You just don't get it, maaaan."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "hippiesdelightglass"
	glass_name = "\improper Hippie's Delight"
	glass_desc = "A drink popular in the 1960s."

/datum/reagent/hippies_delight/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.druggy = max(M.druggy, 50)
	switch(tick)
		if(1 to 5)
			if(!M.stuttering)
				M.stuttering = 1
			M.Dizzy(10)
			if(prob(10))
				M.emote(pick("twitch", "giggle"))
		if(5 to 10)
			if(!M.stuttering)
				M.stuttering = 1
			M.Jitter(20)
			M.Dizzy(20)
			M.druggy = max(M.druggy, 45)
			if(prob(20))
				M.emote(pick("twitch", "giggle"))
		if(10 to INFINITY)
			if(!M.stuttering)
				M.stuttering = 1
			M.Jitter(40)
			M.Dizzy(40)
			M.druggy = max(M.druggy, 60)
			if(prob(30))
				M.emote(pick("twitch", "giggle"))

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
		M.emote(pick("twitch","blink_r","shiver")) //See movement_tally_multiplier for the rest

/datum/reagent/hyperzine/on_overdose(var/mob/living/M)
	..() //calls parent to give everyone toxin damage
	if(ishuman(M) && M.get_heart()) // Got a heart?
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/heart/damagedheart = H.get_heart()
		if(H.species.name != "Diona" && damagedheart) // Not on dionae
			if(prob(15) && M.stat == CONSCIOUS)
				to_chat(H, "<span class='danger'>You feel a sharp pain in your chest!</span>")
				damagedheart.damage += 1
		else
			M.adjustFireLoss(1) // Burn damage for dionae

/datum/reagent/hyperzine/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return
	var/amount = T.reagents.get_reagent_amount(id)
	if(amount >= 1)
		if(prob(15))
			T.mutate(GENE_METABOLISM)
			T.reagents.remove_reagent(id, 1)
		if(prob(15))
			T.mutate(GENE_METABOLISM)
	else if(amount > 0)
		T.reagents.remove_reagent(id, amount)

/datum/reagent/hyperzine/pcp
	name = "Liquid PCP"
	id = LIQUIDPCP
	description = "I didn't even know it came in liquid form!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#7a6d23" //rgb: 200, 165, 220

/datum/reagent/hyperzine/pcp/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(holder.has_reagent(CHILLWAX))
		holder.remove_reagent(CHILLWAX, REM)
	if(M)
		M.a_intent = I_HURT
		if(M?.hud_used?.action_intent)
			M.hud_used.action_intent.icon_state = "intent_hurt"
		M.hallucination += 10

/datum/reagent/hyperzine/methamphetamine //slightly better than 'zine
	name = "Methamphetamine" //Only used on the Laundromat spess vault
	id = METHAMPHETAMINE
	description = "It uses a different manufacture method but it is every bit as pure."
	color = "#89CBF0" //baby blue
	custom_metabolism = 0.01
	overdose_am = 30

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
		var/timedmg = ((tick - 60) / 2)
		if (timedmg > 0)
			dehypozine(H, timedmg, 1, 0)

/datum/reagent/hypozine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.reagents.add_reagent ("hyperzine", 0.03) //To pretend it's all okay.
	if(ishuman(M))
		if(tick<121 && !has_been_hypozined)
			has_been_hypozined = 1
			has_had_heart_explode = 0 //Fuck them UP after they're done going fast.

	switch(tick)
		if(60 to 99)	//Speed up after a minute
			if(tick==60)
				to_chat(M, "<span class='notice'>You feel faster.")
				M.movement_speed_modifier += 0.5
				oldspeed += 0.5
			if(prob(5))
				to_chat(M, "<span class='notice'>[pick("Your leg muscles pulsate", "You feel invigorated", "You feel like running")].")
		if(100 to 114)	//painfully fast
			if(tick==100)
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
			if(tick==115)
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
		tick = 0
		oldspeed = 0

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

/datum/reagent/nicotine
	name = "Nicotine"
	id = NICOTINE
	description = "A highly addictive stimulant extracted from the tobacco plant."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#181818" //rgb: 24, 24, 24
	density = 1.01

/datum/reagent/psilocybin
	name = "Psilocybin"
	id = PSILOCYBIN
	description = "A strong psycotropic derived from certain species of mushroom."
	color = "#E700E7" //rgb: 231, 0, 231

/datum/reagent/psilocybin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.druggy = max(M.druggy, 30)
	switch(tick)
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

/datum/reagent/space_drugs
	name = "Space Drugs"
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

//Solely for flavor.
/datum/reagent/tobacco
	name = "Tobacco"
	id = TOBACCO
	description = "The cured and ground leaves of a tobacco plant."
	reagent_state = REAGENT_STATE_SOLID
	color = "#4c1e00" //rgb: 76, 30, 0
	density = 1.01
