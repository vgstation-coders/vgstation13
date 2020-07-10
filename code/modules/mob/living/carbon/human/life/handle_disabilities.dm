//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_disabilities()
	if(disabilities & ASTHMA)
		if(prob(0.2))
			asthma_attack()

	if(disabilities & EPILEPSY)
		if((prob(1)) && (paralysis < 1))
			seizure(10, 1000)

	//If we have the gene for being crazy, have random events.
	if(dna.GetSEState(HALLUCINATIONBLOCK))
		if(prob(1) && hallucination < 1)
			hallucination += 20

	if(disabilities & COUGHING)
		if((prob(5) && paralysis <= 1))
			drop_item()
			audible_cough(src)
	if(disabilities & TOURETTES)
		if((prob(10) && paralysis <= 1))
			//Stun(10)
			switch(rand(1, 3))
				if(1)
					emote("twitch")
				if(2 to 3)
					say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")

			var/x_offset_change = rand(-2,2) * PIXEL_MULTIPLIER
			var/y_offset_change = rand(-1,1) * PIXEL_MULTIPLIER

			animate(src, pixel_x = (pixel_x + x_offset_change), pixel_y = (pixel_y + y_offset_change), time = 1)
			animate(pixel_x = (pixel_x - x_offset_change), pixel_y = (pixel_y - y_offset_change), time = 1)

	if(getBrainLoss() >= 60 && stat != DEAD)
		if(prob(3))
			brain_damage_line()

	if(species.name == "Tajaran")
		if(prob(1)) //Was 3
			vomit(1) //Hairball

	if(stat != DEAD)
		var/rn = rand(0, 200) //This is fucking retarded, but I'm only doing sanitization, I don't have three months to spare to fix everything
		if(getBrainLoss() >= 5)
			if(0 <= rn && rn <= 3)
				custom_pain("Your head feels numb and painful.")
		if(getBrainLoss() >= 15)
			if(4 <= rn && rn <= 6)
				if(eye_blurry <= 0)
					to_chat(src, "<span class='warning'>It becomes hard to see for some reason.</span>")
					eye_blurry = 10
		if(getBrainLoss() >= 35)
			if(7 <= rn && rn <= 9)
				if(get_active_hand())
					to_chat(src, "<span class='warning'>Your hand won't respond properly, you drop what you're holding.</span>")
					drop_item()
		if(getBrainLoss() >= 50)
			if(10 <= rn && rn <= 12)
				if(canmove)
					to_chat(src, "<span class='warning'>Your legs won't respond properly, you fall down.</span>")
					Knockdown(3)
