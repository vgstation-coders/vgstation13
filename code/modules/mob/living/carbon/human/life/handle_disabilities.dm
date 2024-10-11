//Refer to life.dm for caller
/mob/living/carbon/human/proc/handle_disabilities()
	if(stat == DEAD)
		return
	if(disabilities & ELECTROSENSE)
		var/affect_chance = 30
		var/affected = FALSE
		if(head && istype(head,/obj/item/clothing/head/tinfoil))
			affect_chance -= 15
		if(wear_suit && istype(wear_suit,/obj/item/clothing/suit/spaceblanket))
			affect_chance -= 15
		if(prob(affect_chance))
			for(var/atom/movable/A in view(2,src))
				if(istype(A,/obj/machinery))
					var/obj/machinery/M = A
					if(!(M.stat & (NOPOWER|BROKEN|FORCEDISABLE)) && M.use_power > 0)
						affected = TRUE
						continue
				if(istype(A,/obj/item/weapon/cell))
					var/obj/item/weapon/cell/C = A.get_cell()
					if(C && C.charge)
						affected = TRUE
						continue
				if(istype(A,/obj/item/device/radio))
					affected = TRUE
					continue
		if(affected)
			to_chat(src, "<span class='warning'>The electrical devices hum loudly!</span>")
			Jitter(20)
			if(eye_blurry <= 1)
				eye_blurry = 10
			if(getHalLoss() < 40)
				adjustHalLoss(20)

	//If we have the gene for being crazy, have random events.
	if(dna.GetSEState(HALLUCINATIONBLOCK) && prob(4))
		if(hallucination < 1)
			hallucination += 20

	//avoid stunlocks
	if(paralysis > 1)
		return

	if(species.name == "Tajaran" && prob(1))
		vomit(1) //Hairball

	if(disabilities & ASTHMA && prob(0.2))
		asthma_attack()

	if(disabilities & EPILEPSY && prob(1))
		seizure(10, 1000)

	if(disabilities & ANEMIA && prob(4))
		var/blood_volume = round(vessel.get_reagent_amount(BLOOD))
		if(blood_volume > BLOOD_VOLUME_SAFE+10)
			vessel.remove_reagent(BLOOD, 10)

	if(disabilities & COUGHING && prob(5))
		drop_item()
		audible_cough(src)

	if(disabilities & TOURETTES)
		if(prob(7))
			say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
		if(prob(3))
			emote("twitch")
		if(prob(10))
			Jitter(10)

	if(getBrainLoss() >= 60 && prob(3))
		say(pick("IM A PONY NEEEEEEIIIIIIIIIGH", \
		"without oxigen blob don't evoluate?", \
		"CAPTAINS A COMDOM", \
		"[pick("", "that traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!", \
		"can u give me [pick("telikesis","halk","eppilapse")]?", \
		"THe saiyans screwed", \
		"Bi is THE BEST OF BOTH WORLDS>", \
		"I WANNA PET TEH monkeyS", \
		"stop grifing me!!!!", \
		"SOTP IT#", \
		"based and redpilled",\
		"ho now talking like a milenian piece of shit is too unralistic in the fucking",\
		"FUS RO DAH", \
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
		"TEH TRAITOR THEY KILL PEEPLE BUT I RESPAWN!!!", \
		"whats a keeper"))
	else if(getBrainLoss() >= 60 && prob(3))
		emote("drool")
	if(getBrainLoss() > 50 && prob(1.5))
		if(canmove)
			to_chat(src, "<span class='warning'>Your legs won't respond properly, you fall down.</span>")
			Knockdown(3)
	else if(getBrainLoss() > 35 && prob(1.5))
		if(get_active_hand())
			to_chat(src, "<span class='warning'>Your hand won't respond properly, you drop what you're holding.</span>")
			drop_item()
	else if(getBrainLoss() > 15 && prob(1.5))
		if(eye_blurry <= 0)
			to_chat(src, "<span class='warning'>It becomes hard to see for some reason.</span>")
			eye_blurry = 10
	else if(getBrainLoss() > 0 && prob(2))
		custom_pain("Your head feels numb and painful.")
