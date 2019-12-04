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
			if(prob(66)) //All of those REALLY ought to be variable lists, but that would be too smart I guess
				var/message = pick("IM A PONY NEEEEEEIIIIIIIIIGH",
					"without oxigen blob don't evoluate?",
					"CAPTAINS A [pick("COMDOM","CONDOM")]",
					"[pick("", "that faggot traitor")] is grifing me HAL;P!!!",
					"can u give me [pick("telikesis","halk","eppilapse")]?",
					"THe saiyans screwed",
					"Bi is THE BEST OF BOTH WORLDS>",
					"I WANNA PET TEH monkeyS",
					"stop grifing me!!!!",
					"SOTP IT#",
					"ho now talking like a milenian piece of shit is too unralistic in the fucking",
					"FUS RO DAH",
					"fucking [pick("chemsts","chif","genticests","chaplin")]!",
					"waaaaaagh!!!",
					"red wonz go fasta",
					"FOR TEH EMPRAH",
					"heeeeh, tuu kat",
					"dem dwarfs man, dem dwarfs",
					"SPESS MAHREENS",
					"hwee did eet fhor khayosss",
					"lifelike teksture!",
					"luv can bloooom",
					"PACKETS!!!",
					"[pick("CLOWN","MIME","CAPTAIN","HOP","JANITOR","BARTENDER","I")] DID IT!!!",
					"WERE NOT BAY!!",
					"IF YOU DONT LIKE THE CYBORGS OR SLIMES WHY DONT YU O JUST MAKE YORE OWN!",
					"DONT TALK TO ME ABOUT BALANCE!!!!",
					"YOU AR JUS LAZY AND DUMB JAMITORS AND SERVICE ROLLS",
					"BLAME [pick("CLOWN","MIME","CAPTAIN","HOP","JANITOR","BARTENDER","VIRALAGY")]!!!",
					"SKELINGTON [pick("IS","ARE","BE","WERE","AM")] SHITERS!",
					"MOMMSI R THE WURST SCUM!!",
					"How do we engiener=",
					"why woud i take a pin pointner??",
					"FUCK IT; KISSYOUR ASSES GOOD BYE DEAD MEN! I AM SELFDESTRUCKTING THE STATION!!!!",
					"How do I set up the. SHow do I set u p the Singu. how I the scrungularity????",
					"OMG I SED LAW 2 U FAG MOMIM LAW 2!!!",
					"f[pick("r","w")]ee the d[pick("a","4","e","@")]b!")
				if(prob(50))
					message = uppertext(replacetext(message, ".", "!")) //Shout it
				say(message)
			else
				emote("drool")

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
