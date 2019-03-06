/datum/disease2/effect/scream
	name = "Loudness Syndrome"
	desc = "Causes the infected to scream at random."
	stage = 2

/datum/disease2/effect/scream/activate(var/mob/living/carbon/mob)
	mob.audible_scream()


/datum/disease2/effect/drowsness
	name = "Automated Sleeping Syndrome"
	desc = "Makes the infected feel more drowsy."
	stage = 2

/datum/disease2/effect/drowsness/activate(var/mob/living/carbon/mob)
	mob.drowsyness += 10


/datum/disease2/effect/sleepy
	name = "Resting Syndrome"
	desc = "Causes the infected to collapse in random fits of narcolepsy"
	stage = 2

/datum/disease2/effect/sleepy/activate(var/mob/living/carbon/mob)
	mob.say("*collapse")


/datum/disease2/effect/blind
	name = "Blackout Syndrome"
	desc = "Inhibits the infected's ability to see."
	stage = 2

/datum/disease2/effect/blind/activate(var/mob/living/carbon/mob)
	mob.eye_blind = max(mob.eye_blind, 4)


/datum/disease2/effect/cough
	name = "Anima Syndrome"
	desc = "Causes the infected to cough rapidly, infecting people in their surroundings."
	stage = 2

/datum/disease2/effect/cough/activate(var/mob/living/carbon/mob)
	mob.say("*cough")
	for(var/mob/living/M in oview(2,mob))
		if(can_be_infected(M))
			spread_disease_to(mob, M)


/datum/disease2/effect/hungry
	name = "Appetiser Effect"
	desc = "Starves the infected."
	stage = 2

/datum/disease2/effect/hungry/activate(var/mob/living/carbon/mob)
	mob.nutrition = max(0, mob.nutrition - 200)


/datum/disease2/effect/fridge
	name = "Refridgerator Syndrome"
	desc = "Causes the infected to shiver at random."
	stage = 2

/datum/disease2/effect/fridge/activate(var/mob/living/carbon/mob)
	mob.say("*shiver")


/datum/disease2/effect/hair
	name = "Hair Loss"
	desc = "Causes rapid hairloss in the infected."
	stage = 2

/datum/disease2/effect/hair/activate(var/mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		if(H.species.name == "Human" && !(H.h_style == "Bald") && !(H.h_style == "Balding Hair"))
			to_chat(H, "<span class='danger'>Your hair starts to fall out in clumps...</span>")
			spawn(50)
				H.h_style = "Balding Hair"
				H.update_hair()


/datum/disease2/effect/stimulant
	name = "Adrenaline Extra"
	desc = "Causes the infected to synthesize artificial adrenaline (Hyperzine)."
	stage = 2

/datum/disease2/effect/stimulant/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class='notice'>You feel a rush of energy inside you!</span>")
	if (mob.reagents.get_reagent_amount(HYPERZINE) < 10)
		mob.reagents.add_reagent(HYPERZINE, 4)
	if (prob(30))
		mob.jitteriness += 10


/datum/disease2/effect/drunk
	name = "Glasgow Syndrome"
	desc = "Causes the infected to synthesize pure ethanol."
	stage = 2

/datum/disease2/effect/drunk/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class='notice'>You feel like you had one hell of a party!</span>")
	if (mob.reagents.get_reagent_amount(ETHANOL) < 325)
		mob.reagents.add_reagent(ETHANOL, 5*multiplier)


/datum/disease2/effect/gaben
	name = "Gaben Syndrome"
	desc = "Makes the infected incredibly fat."
	stage = 2

/datum/disease2/effect/gaben/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class='notice'>Your clothing fits a little tighter!!</span>")
	if (prob(10))
		mob.reagents.add_reagent(NUTRIMENT, 1000)
		mob.overeatduration = 1000


/datum/disease2/effect/beard
	name = "Bearding"
	desc = "Causes the infected to spontaneously grow a beard, regardless of gender. Only affects humans."
	stage = 2

/datum/disease2/effect/beard/activate(var/mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		if(H.species.name == "Human" && !(H.f_style == "Full Beard"))
			to_chat(H, "<span class='warning'>Your chin and neck itch!.</span>")
			spawn(50)
				H.f_style = "Full Beard"
				H.update_hair()


/datum/disease2/effect/bloodynose
	name = "Intranasal Hemorrhage"
	desc = "Causes the infected's nasal pathways to hemorrhage, causing a nosebleed that acts as a valid pathogen carrier. (Note: Does not affect the users blood pressure.)"
	stage = 2

/datum/disease2/effect/bloodynose/activate(var/mob/living/carbon/mob)
	if (prob(30))
		var/obj/effect/decal/cleanable/blood/D= locate(/obj/effect/decal/cleanable/blood) in get_turf(mob)
		if(D==null)
			D = getFromPool(/obj/effect/decal/cleanable/blood, get_turf(mob))
			D.New(D.loc)

		D.virus2 |= virus_copylist(mob.virus2)


/datum/disease2/effect/viralsputum
	name = "Respiratory Putrification"
	desc = "Causes the infected to cough up viral sputum, which acts as a valid pathogen carrier."
	stage = 2

/datum/disease2/effect/viralsputum/activate(var/mob/living/carbon/mob)

	if (prob(30))
		mob.say("*cough")
		var/obj/effect/decal/cleanable/blood/viralsputum/D= locate(/obj/effect/decal/cleanable/blood/viralsputum) in get_turf(mob)
		if(!D)
			D = getFromPool(/obj/effect/decal/cleanable/blood/viralsputum, get_turf(mob))
			D.New(D.loc)

		D.virus2 |= virus_copylist(mob.virus2)


/datum/disease2/effect/lantern
	name = "Lantern Syndrome"
	desc = "Causes the infected to glow."
	stage = 2

/datum/disease2/effect/lantern/activate(var/mob/living/carbon/mob)
	mob.set_light(4)
	to_chat(mob, "<span class = 'notice'>You are glowing!</span>")


/datum/disease2/effect/hangman
	name = "Hanging Man's Syndrome"
	desc = "Inhibits a portion of the infected's brain that controls speech, removing the infected's ability to speak vowels."
	stage = 2
	var/triggered = 0
	affect_voice = 1

/datum/disease2/effect/hangman/activate(var/mob/living/carbon/mob)
//Add filters to change a,A,e,E,i,I,o,O,u,U to _
	if(!triggered)
		to_chat(mob, "<span class='warning'>Y__ f__l _ b_t str_ng _p.</span>")
		affect_voice_active = 1
		triggered = 1

/datum/disease2/effect/hangman/affect_mob_voice(var/datum/speech/speech)
	var/message=speech.message
	message = replacetext(message, "a", "_")
	message = replacetext(message, "A", "_")
	message = replacetext(message, "e", "_")
	message = replacetext(message, "E", "_")
	message = replacetext(message, "i", "_")
	message = replacetext(message, "I", "_")
	message = replacetext(message, "o", "_")
	message = replacetext(message, "O", "_")
	message = replacetext(message, "u", "_")
	message = replacetext(message, "U", "_")

	speech.message = message


/datum/disease2/effect/vitreous
	name = "Vitreous resonance"
	desc = "Causes the infected to shake uncontrollably, at the same frequency that is required to break glass."
	stage = 2
	chance = 25
	max_chance = 75
	max_multiplier = 2

/datum/disease2/effect/vitreous/activate(var/mob/living/carbon/human/H)
	if(istype(H))
		var/hand_to_use = rand(1, H.held_items.len)
		var/obj/item/weapon/reagent_containers/glass_to_shatter = H.get_held_item_by_index(hand_to_use)
		var/datum/organ/external/glass_hand = H.find_organ_by_grasp_index(hand_to_use)
		if (istype(glass_to_shatter, /obj/item/weapon/reagent_containers/glass/) || istype(glass_to_shatter, /obj/item/weapon/reagent_containers/syringe))
			to_chat(H, "<span class='warning'>Your [glass_hand.display_name] resonates with the glass in \the [glass_to_shatter], shattering it to bits!</span>")
			glass_to_shatter.reagents.reaction(H.loc, TOUCH)
			new/obj/effect/decal/cleanable/generic(get_turf(H))
			playsound(H, 'sound/effects/Glassbr1.ogg', 25, 1)
			spawn(1 SECONDS)
				if (H && glass_hand)
					if (prob(50 * multiplier))
						to_chat(H, "<span class='notice'>Your [glass_hand.display_name] deresonates, healing completely!</span>")
						glass_hand.rejuvenate()
					else
						to_chat(H, "<span class='warning'>Your [glass_hand.display_name] deresonates, sustaining burns!</span>")
						glass_hand.take_damage(0, 30 * multiplier)
			qdel(glass_to_shatter)
		else if (prob(1))
			to_chat(H, "Your [glass_hand.display_name] aches for the cold, smooth feel of container-grade glass...")
			// So I don't have to deal with actual glass and glass accessories


/datum/disease2/effect/opposite
	name = "Opposite Syndrome"
	desc = "Inhibits a portion of the infected's brain that affects speech, causing the infected to speak counter to what they wish to say."
	stage = 2
	affect_voice = 1
	max_count = 1
	var/list/virus_opposite_word_list

/datum/disease2/effect/opposite/activate(var/mob/living/carbon/mob,var/multiplier)
	to_chat(mob, "<span class='warning'>You feel completely fine.</span>")
	affect_voice_active = 1
	if(!virus_opposite_word_list)
		initialize_word_list()

/datum/disease2/effect/opposite/affect_mob_voice(var/datum/speech/speech)
	var/message=speech.message
	var/list/word_list = splittext(message," ")		//split message into list of words
	for(var/i = 1 to word_list.len)
		var/punct = ""								//take punctuation into account
		if(findtext(word_list[i], ",", -1))
			punct = ","
		if(findtext(word_list[i], ".", -1))
			punct = "."
		if(findtext(word_list[i], "!", -1))
			punct = "!"
		if(findtext(word_list[i], "?", -1))
			punct = "?"
		if(findtext(word_list[i], "~", -1))
			punct = "~"
		for(var/x in virus_opposite_word_list)
			var/word = word_list[i]
			if(punct)
				word = copytext(word_list[i], 1, length(word_list[i]))
			if(uppertext(word) == uppertext(x))
				word_list[i] = virus_opposite_word_list[x] + punct
			else if(uppertext(word) == uppertext(virus_opposite_word_list[x]))
				word_list[i] = x + punct

	message = ""
	for(var/z = 1 to word_list.len)
		if(z == word_list.len)
			message += word_list[z]
		else
			message += "[word_list[z]] "

	speech.message = message

/datum/disease2/effect/opposite/deactivate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class='warning'>You feel terrible.</span>")
	affect_voice_active = 0
	..()


/datum/disease2/effect/spiky_skin
	name = "Porokeratosis Acanthus"
	desc = "Causes the infected to generate keratin spines along their skin."
	stage = 2
	max_count = 1
	var/skip = FALSE

/datum/disease2/effect/spiky_skin/activate(var/mob/living/carbon/mob,var/multiplier)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(H.species && (H.species.anatomy_flags & NO_SKIN))	//Can't have spiky skin if you don't have skin at all.
			skip = TRUE
			return
	to_chat(mob, "<span class='warning'>Your skin feels a little prickly.</span>")

/datum/disease2/effect/spiky_skin/deactivate(var/mob/living/carbon/mob)
	if(!skip)
		to_chat(mob, "<span class='notice'>Your skin feels nice and smooth again!</span>")
	..()

/datum/disease2/effect/spiky_skin/on_touch(var/mob/living/carbon/mob, var/toucher, var/touched, var/touch_type)
	if(!count || skip)
		return
	if(!istype(toucher, /mob) || !istype(touched, /mob))
		return
	var/datum/organ/external/E
	var/mob/living/carbon/human/H
	if(toucher == mob)	//we bumped into someone else
		if(ishuman(touched))
			H = touched
	else	//someone else bumped into us
		if(ishuman(toucher))
			H = toucher
	if(H)
		var/list/have_checked = list()
		while(!E || (E.status & ORGAN_ROBOT) || (E.status & ORGAN_PEG))
			E = pick(H.organs)
			if(!(E in have_checked))
				have_checked.Add(E)
			if(have_checked.len == H.organs.len)
				E = null
				break
	if(toucher == mob)
		if(E)
			to_chat(mob, "<span class='warning'>As you bump into \the [touched], your spines dig into \his [E.display_name]!</span>")
			E.take_damage(5)
		else
			to_chat(mob, "<span class='warning'>As you bump into \the [touched], your spines dig into \him!</span>")
			var/mob/living/L = touched
			if(istype(L) && !istype(L, /mob/living/silicon))
				L.apply_damage(5)
		var/mob/M = touched
		add_attacklogs(mob, M, "damaged with keratin spikes",addition = "([mob] bumped into [M])", admin_warn = FALSE)
	else
		if(E)
			to_chat(mob, "<span class='warning'>As \the [toucher] [touch_type == BUMP ? "bumps into" : "touches"] you, your spines dig into \his [E.display_name]!</span>")
			to_chat(toucher, "<span class='danger'>As you [touch_type == BUMP ? "bump into" : "touch"] \the [mob], \his spines dig into your [E.display_name]!</span>")
			E.take_damage(5)
		else
			to_chat(mob, "<span class='warning'>As \the [toucher] [touch_type == BUMP ? "bumps into" : "touches"] you, your spines dig into \him!</span>")
			to_chat(toucher, "<span class='danger'>As you [touch_type == BUMP ? "bump into" : "touch"] \the [mob], \his spines dig into you!</span>")
			var/mob/living/L = toucher
			if(istype(L) && !istype(L, /mob/living/silicon))
				L.apply_damage(5)
		var/mob/M = touched
		add_attacklogs(mob, M, "damaged with keratin spikes",addition = "([M] bumped into [mob])", admin_warn = FALSE)

/datum/disease2/effect/vegan
	name = "Vegan Syndrome"
	stage = 2

/datum/disease2/effect/vegan/activate(var/mob/living/carbon/mob)
	mob.dna.check_integrity()
	mob.dna.SetSEState(VEGANBLOCK,1)
	domutcheck(mob, null)

/datum/disease2/effect/famine
	name = "Faminous Potation"
	desc = "The infected emanates a field that kills off plantlife. Lethal to species descended from plants."
	stage = 2
	max_multiplier = 3

/datum/disease2/effect/famine/activate(var/mob/living/carbon/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(H.dna)
			if(H.species.flags & IS_PLANT) //Plantmen take a LOT of damage
				H.adjustCloneLoss(5 * multiplier)

	for(var/obj/machinery/portable_atmospherics/hydroponics/H in range(3*multiplier,mob))
		if(H.seed && !H.dead) // Get your xenobotanist/vox trader/hydroponist mad with you in less than 1 minute with this simple trick.
			switch(rand(1,3))
				if(1)
					if(H.waterlevel >= 10)
						H.waterlevel -= rand(1,10)
					if(H.nutrilevel >= 5)
						H.nutrilevel -= rand(1,5)
				if(2)
					if(H.toxins <= 50)
						H.toxins += rand(1,50)
				if(3)
					H.weed_coefficient++
					H.weedlevel++
					H.pestlevel++
					if(prob(5))
						H.dead = 1


	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in range(2*multiplier,mob))
		G.visible_message("<span class = 'warning'>\The [G] rots at an alarming rate!</span>")
		new /obj/item/weapon/reagent_containers/food/snacks/badrecipe(get_turf(G))
		qdel(G)
		if(prob(30/multiplier))
			break

/datum/disease2/effect/calorieburn
	name = "Caloric expenditure overefficiency"
	desc = "Causes the infected to burn calories at a higher rate."
	stage = 2
	multiplier = 1.5
	max_multiplier = 4
	var/activated = FALSE

/datum/disease2/effect/calorieburn/activate(var/mob/living/carbon/mob)
	if(!activated)
		if(ishuman(mob))
			var/mob/living/carbon/human/H
			H.calorie_burn_rate *= multiplier
		activated = TRUE

/datum/disease2/effect/calorieburn/deactivate(var/mob/living/carbon/mob)
	if(activated)
		if(ishuman(mob))
			var/mob/living/carbon/human/H
			H.calorie_burn_rate /= multiplier

/datum/disease2/effect/calorieconserve
	name = "Caloric expenditure defficiency"
	desc = "Causes the infected to burn calories at a lower rate."
	stage = 2
	multiplier = 1.5
	max_multiplier = 4
	var/activated = FALSE

/datum/disease2/effect/calorieconserve/activate(var/mob/living/carbon/mob)
	if(!activated)
		if(ishuman(mob))
			var/mob/living/carbon/human/H
			H.calorie_burn_rate /= multiplier
		activated = TRUE

/datum/disease2/effect/calorieconserve/deactivate(var/mob/living/carbon/mob)
	if(activated)
		if(ishuman(mob))
			var/mob/living/carbon/human/H
			H.calorie_burn_rate *= multiplier


/datum/disease2/effect/yelling
	name = "Plankton's Syndrome"
	desc = "Attacks a portion of the infected's brain that controls speech, causing them to be more dramatic."
	stage = 2
	var/triggered = 0
	affect_voice = 1

/datum/disease2/effect/yelling/activate(var/mob/living/carbon/mob)
	if(!triggered)
		to_chat(mob, "<span class='notice'>You feel like what you have to say is more important.</span>")
		affect_voice_active = 1
		triggered = 1

/datum/disease2/effect/yelling/affect_mob_voice(var/datum/speech/speech)
	var/message=speech.message
	message = uppertext(message + "!")
	speech.message = message
