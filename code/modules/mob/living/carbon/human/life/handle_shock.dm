//Refer to life.dm for caller

/mob/living/carbon/human/handle_shock()
	..()
	if(status_flags & GODMODE)
		return 0 //Godmode
	if(analgesic || !feels_pain())
		return //Analgesic avoids all traumatic shock temporarily

	if(health < config.health_threshold_softcrit) //Going under the crit threshold makes you immediately collapse
		shock_stage = max(shock_stage, 61)

	if(traumatic_shock >= 80)
		shock_stage += 1
	else if(health < config.health_threshold_softcrit)
		shock_stage = max(shock_stage, 61)
	else
		shock_stage = min(shock_stage, 160)
		shock_stage = max(shock_stage - 1, 0)
		return

	if(shock_stage == 10)
		to_chat(src, "<span class='danger'>[pick("It hurts so much!", "You really need some painkillers.", "Dear god, the pain!")]</span>")

	if(shock_stage >= 30)
		if(shock_stage == 30)
			if(!isUnconscious())
				visible_message("<B>[src]</B> is having trouble keeping their eyes open.")
		eye_blurry = max(2, eye_blurry)
		stuttering = max(stuttering, 5)

	if(shock_stage == 40)
		to_chat(src, "<span class='danger'>[pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")

	if(shock_stage >= 60)
		if(shock_stage == 60)
			if(!isUnconscious())
				visible_message("<B>[src]</B>'s body becomes limp.")
		if(prob(2))
			to_chat(src, "<span class='danger'>[pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")
			Knockdown(20)

	if(shock_stage >= 80)
		if(prob(5))
			to_chat(src, "<span class='danger'>[pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")
			Knockdown(20)

	if(shock_stage >= 120)
		if(prob(2))
			to_chat(src, "<span class='danger'>[pick("You black out!", "You feel like you could die any moment now.", "You're about to lose consciousness.")]</span>")
			Paralyse(5)

	if(shock_stage == 150)
		if(!isUnconscious())
			visible_message("<B>[src]</b> can no longer stand, collapsing!")
		Knockdown(20)

	if(shock_stage >= 150)
		Knockdown(20)
