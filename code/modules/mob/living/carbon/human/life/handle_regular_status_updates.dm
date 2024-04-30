//Refer to life.dm for caller

/mob/living/carbon/human/handle_regular_status_updates()
	if(stat != DEAD)	//ALIVE. LIGHTS ARE ON

		//Sobering multiplier.
		//Sober block grants quadruple the alcohol metabolism.
		var/sober_str =! (M_SOBER in mutations) ? 1:4

		updatehealth() //TODO
		if(!in_stasis)
			handle_organs()	//Optimized.
			handle_blood()

		if((health <= config.health_threshold_dead || !has_brain()) && !(status_flags & BUDDHAMODE))
			emote("deathgasp", message = TRUE)
			death()
			blinded = 1
			silent = 0
			return 1

		//The analgesic effect wears off slowly
		pain_numb = max(0, pain_numb - 1)

		//UNCONSCIOUS. NO-ONE IS HOME
		if((getOxyLoss() > 50 || config.health_threshold_crit > health) && !(status_flags & BUDDHAMODE))
			species.OnCrit(src)
		else
			species.OutOfCrit(src)

		if(hallucination)
			if(hallucination >= 20 && !handling_hal)
				spawn handle_hallucinations() //The not boring kind!

		if(!paralysis && sleeping)
			handle_dreams()
			if(prob(2) && health && !hal_crit)
				spawn(0)
					emote("snore")

		//Eyes
		if(!species.has_organ["eyes"]) //Presumably if a species has no eyes, they see via something else.
			eye_blind =  0
			blinded =    0
			eye_blurry = 0
		else if(istype(glasses, /obj/item/clothing/glasses/sunglasses/blindfold)) //Resting your eyes with a blindfold heals blurry eyes faster
			eye_blurry = max(eye_blurry - 3, 0)
			blinded =    1

		handle_dizziness()
		handle_jitteriness()

	return ..()