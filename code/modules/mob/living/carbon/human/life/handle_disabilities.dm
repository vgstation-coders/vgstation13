//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_disabilities()
	if(disabilities & ELECTROSENSE)
		var/affect_chance = 100
		var/affect_amount = 0
		if(head && istype(head,/obj/item/clothing/head/tinfoil))
			affect_chance /= 2
		if(wear_suit && istype(wear_suit,/obj/item/clothing/suit/spaceblanket))
			affect_chance /= 2
		for(var/obj/machinery/M in range(3,src))
			if(!(M.stat & (NOPOWER|BROKEN|FORCEDISABLE)) && M.use_power > 0 && prob(affect_chance))
				affect_amount++
		for(var/atom/movable/A in range(rand(1,2),src))
			var/obj/item/weapon/cell/C = A.get_cell()
			if(C && C.charge && prob(affect_chance))
				affect_amount++
		if(!stat)
			adjustHalLoss(affect_amount)
			if(prob(min(affect_amount,100)))
				Jitter(min(affect_amount,100))
			if(prob(min(affect_amount,100)))
				eye_blurry += min(affect_amount,100)

	if(disabilities & ASTHMA)
		if(prob(0.2))
			asthma_attack()

	if(disabilities & EPILEPSY)
		if((prob(1)) && (paralysis < 1))
			seizure(10, 1000)

	if(disabilities & ANEMIA)
		var/blood_volume = round(vessel.get_reagent_amount(BLOOD))
		if((prob(4)) && (blood_volume > BLOOD_VOLUME_SAFE+10))
			vessel.remove_reagent(BLOOD, 10)

	//If we have the gene for being crazy, have random events.
	if(dna.GetSEState(HALLUCINATIONBLOCK))
		if(prob(4) && hallucination < 1)
			hallucination += 20

	if(disabilities & COUGHING)
		if((prob(5) && paralysis <= 1))
			drop_item()
			audible_cough(src)
	if(disabilities & TOURETTES)
		if(prob(7))
			say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS", "NIGGER", "TROON")]")
		if(prob(3))
			emote("twitch")
		var/x_offset_change = rand(-2,2) * PIXEL_MULTIPLIER
		var/y_offset_change = rand(-1,1) * PIXEL_MULTIPLIER

		animate(src, pixel_x = (pixel_x + x_offset_change), pixel_y = (pixel_y + y_offset_change), time = 1)
		animate(pixel_x = (pixel_x - x_offset_change), pixel_y = (pixel_y - y_offset_change), time = 1)

	if(species.name == "Tajaran")
		if(prob(1))
			vomit(1) //Hairball
	if(stat != DEAD)
		if(getBrainLoss() >= 60)
			var/text = null
			if(prob(3))
				text = pick("IM A PONY NEEEEEEIIIIIIIIIGH", \
				"without oxigen blob don't evoluate?", \
				"CAPTAINS A COMDOM", "[pick("", "that faggot traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!", \
				"can u give me [pick("telikesis","halk","eppilapse")]?", \
				"THe saiyans screwed", "Bi is THE BEST OF BOTH WORLDS>", \
				"I WANNA PET TEH monkeyS", "stop grifing me!!!!", \
				"SOTP IT#", "based and redpilled",\
				"ho now talking like a milenian piece of shit is too unralistic in the fucking",\
				"ITS MORBIN TIME",\
				"AI ROUGE",\
				"BLOB")
			else if(prob(3))
				text = pick("FUS RO DAH", \
				"fucking 4rries!", \
				"stat me", \
				">my face", \
				"roll it easy!", \
				"waaaaaagh!!!", \
				"red wonz go fasta", \
				"FOR TEH EMPRAH", \
				"lol2cat", \
				"dem dwarfs man, dem dwarfs", \
				"SPESS MAHREENS", \
				"hwee did eet fhor khayosss", \
				"lifelike texture ;_;", \
				"luv can bloooom", \
				"PACKETS!!!", \
				"SARAH HALE DID IT!!!", \
				"Don't tell Chase", \
				"WOAH MAMA", \
				"not so tough now huh", \
				"WERE NOT BAY!!", \
				"IF YOU DONT LIKE THE CYBORGS OR SLIMES WHY DONT YU O JUST MAKE YORE OWN!", \
				"DONT TALK TO ME ABOUT BALANCE!!!!", \
				"YOU AR JUS LAZY AND DUMB JAMITORS AND SERVICE ROLLS", \
				"BLAME HOSHI!!!", \
				"ARRPEE IZ DED!!!", \
				"THERE ALL JUS MEATAFRIENDS!", \
				"SOTP MESING WITH THE ROUNS SHITMAN!!!", \
				"SKELINGTON IS 4 SHITERS!", \
				"MOMMSI R THE WURST SCUM!!", \
				"How do we engiener=", \
				"try to live freely and automatically good bye", \
				"why woud i take a pin pointner??", \
				"FUCK IT; KISSYOUR ASSES GOOD BYE DEAD MEN! I AM SELFDESTRUCKTING THE STATION!!!!", \
				"How do I set up the. SHow do I set u p the Singu. how I the scrungularity????", \
				"OMG I SED LAW 2 U FAG MOMIM LAW 2!!!", \
				"I AM BASTE", \
				"I CANT BREET")
			else if(prob(3))
				emote("drool")
			if(text)
				if(prob(50))
					say("; [text]")
				else
					say([text])
		if(getBrainLoss() > 50 && prob(1))
			if(canmove)
				to_chat(src, "<span class='warning'>Your legs won't respond properly, you fall down.</span>")
				Knockdown(3)
		else if(getBrainLoss() > 35 && prob(1))
			if(get_active_hand())
				to_chat(src, "<span class='warning'>Your hand won't respond properly, you drop what you're holding.</span>")
				drop_item()
		else if(getBrainLoss() > 15 && prob(1))
			if(eye_blurry <= 0)
				to_chat(src, "<span class='warning'>It becomes hard to see for some reason.</span>")
				eye_blurry = 10
		else if(getBrainLoss() > 0 && prob(1))
			custom_pain("Your head feels numb and painful.")