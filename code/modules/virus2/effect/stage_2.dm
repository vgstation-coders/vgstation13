/datum/disease2/effect/scream
	name = "Loudness Syndrome"
	desc = "Causes the infected to scream at random."
	encyclopedia = ""
	stage = 2
	badness = EFFECT_DANGER_ANNOYING

/datum/disease2/effect/scream/activate(var/mob/living/mob)
	mob.audible_scream()


/datum/disease2/effect/drowsness
	name = "Automated Sleeping Syndrome"
	desc = "Makes the infected feel more drowsy."
	encyclopedia = "This may cause the infected to randomly fall asleep at times."
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE
	multiplier = 5
	max_multiplier = 10

/datum/disease2/effect/drowsness/activate(var/mob/living/mob)
	mob.drowsyness += multiplier


/datum/disease2/effect/sleepy
	name = "Resting Syndrome"
	desc = "Causes the infected to collapse in random fits of narcolepsy"
	encyclopedia = ""
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/sleepy/activate(var/mob/living/mob)
	mob.emote("collapse")


/datum/disease2/effect/blind
	name = "Blackout Syndrome"
	desc = "Inhibits the infected's ability to see."
	encyclopedia = "Turning them blind for a few seconds."
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE
	multiplier = 4
	max_multiplier = 10
	max_chance = 8

/datum/disease2/effect/blind/activate(var/mob/living/mob)
	mob.eye_blind = max(mob.eye_blind, multiplier)


/datum/disease2/effect/cough//creates pathogenic clouds that may contain even non-airborne viruses.
	name = "Anima Syndrome"
	desc = "Causes the infected to cough rapidly, releasing pathogenic clouds."
	encyclopedia = "This symptom enables even diseases that lack the Airborne vector to spread through the air."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING
	max_chance = 10

/datum/disease2/effect/cough/activate(var/mob/living/mob)
	mob.emote("cough")

	if (mob.locked_to && istype(mob.locked_to, /obj/item/critter_cage))
		return

	var/datum/gas_mixture/breath
	if (ishuman(mob))
		var/mob/living/carbon/human/H = mob
		breath = H.get_breath_from_internal(BREATH_VOLUME)
	if (ismonkey(mob))
		var/mob/living/carbon/monkey/M = mob
		breath = M.get_breath_from_internal(BREATH_VOLUME)
	if(!breath)//not wearing internals
		var/head_block = 0
		if (ishuman(mob))
			var/mob/living/carbon/human/H = mob
			if (H.head && (H.head.clothing_flags & BLOCK_BREATHING))
				head_block = 1
		if (ismonkey(mob))
			var/mob/living/carbon/monkey/M = mob
			if (M.hat && (M.hat.clothing_flags & BLOCK_BREATHING))
				head_block = 1
		if(!head_block)
			if(!mob.wear_mask || !(mob.wear_mask.clothing_flags & BLOCK_BREATHING))
				if(isturf(mob.loc))
					var/list/blockers = list()
					if (ishuman(mob))
						var/mob/living/carbon/human/H = mob
						blockers = list(H.wear_mask,H.glasses,H.head)
					if (ismonkey(mob))
						var/mob/living/carbon/monkey/M = mob
						blockers = list(M.wear_mask,M.glasses,M.hat)
					for (var/item in blockers)
						var/obj/item/I = item
						if (!istype(I))
							continue
						if (I.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
							return
					if(mob.check_airborne_sterility())
						return
					var/strength = 0
					for (var/ID in mob.virus2)
						var/datum/disease2/disease/V = mob.virus2[ID]
						strength += V.infectionchance
					strength = round(strength/mob.virus2.len)
					var/i = 1
					while (strength > 0 && i < 10) //stronger viruses create more clouds at once, max limit of 10 clouds
						getFromPool(/obj/effect/effect/pathogen_cloud/core,get_turf(src), mob, virus_copylist(mob.virus2))
						strength -= 30
						i++

/datum/disease2/effect/hungry
	name = "Appetiser Effect"
	desc = "Starves the infected."
	encyclopedia = "Symptom strength determines how quickly one becomes hungry."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING
	multiplier = 10
	max_multiplier = 20

/datum/disease2/effect/hungry/activate(var/mob/living/mob)
	mob.nutrition = max(0, mob.nutrition - 20*multiplier)


/datum/disease2/effect/fridge
	name = "Refridgerator Syndrome"
	desc = "Causes the infected to shiver at random."
	encyclopedia = "No matter whether the room is cold or hot. This has no effect on their body temperature."
	stage = 2
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/fridge/activate(var/mob/living/mob)
	mob.emote("shiver")


/datum/disease2/effect/hair
	name = "Hair Loss"
	desc = "Causes rapid hairloss in the infected."
	encyclopedia = "Nothing that a trip in front of a mirror can't fix."
	stage = 2
	badness = EFFECT_DANGER_FLAVOR
	multiplier = 1
	max_multiplier = 5

/datum/disease2/effect/hair/activate(var/mob/living/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		if(H.species.name == "Human" && H.my_appearance.h_style != "Bald")
			if (H.my_appearance.h_style != "Balding Hair")
				to_chat(H, "<span class='danger'>Your hair starts to fall out in clumps...</span>")
				if (prob(multiplier*20))
					H.my_appearance.h_style = "Balding Hair"
					H.update_hair()
			else
				to_chat(H, "<span class='danger'>You have almost no hair left...</span>")
				if (prob(multiplier*20))
					H.my_appearance.h_style = "Bald"
					H.update_hair()


/datum/disease2/effect/stimulant
	name = "Adrenaline Extra"
	desc = "Causes the infected to synthesize artificial adrenaline (Hyperzine)."
	encyclopedia = "Thankfully the pathogen keeps the production bellow overdose levels."
	stage = 2
	badness = EFFECT_DANGER_HELPFUL

/datum/disease2/effect/stimulant/activate(var/mob/living/mob)
	to_chat(mob, "<span class='notice'>You feel a rush of energy inside you!</span>")
	if (mob.reagents.get_reagent_amount(HYPERZINE) < 10)
		mob.reagents.add_reagent(HYPERZINE, 4)
	if (prob(30))
		mob.jitteriness += 10


/datum/disease2/effect/drunk
	name = "Glasgow Syndrome"
	desc = "Causes the infected to synthesize pure ethanol."
	encyclopedia = "Without a cure, the infected's liver is sure to die, also effect strength increases the rate at which ethanol is synthesized."
	stage = 2
	badness = EFFECT_DANGER_HARMFUL
	multiplier = 3
	max_multiplier = 7

/datum/disease2/effect/drunk/activate(var/mob/living/mob)
	to_chat(mob, "<span class='notice'>You feel like you had one hell of a party!</span>")
	if (mob.reagents.get_reagent_amount(GLASGOW) < multiplier*5)
		mob.reagents.add_reagent(GLASGOW, multiplier*5)


/datum/disease2/effect/gaben
	name = "Gaben Syndrome"
	desc = "Makes the infected incredibly fat."
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/gaben/activate(var/mob/living/mob)
	to_chat(mob, "<span class='notice'>Your clothing fits a little tighter!!</span>")
	if (mob.reagents && prob(10))
		mob.reagents.add_reagent(NUTRIMENT, 1000)
		mob.overeatduration = 1000


/datum/disease2/effect/beard
	name = "Bearding"
	desc = "Causes the infected to spontaneously grow a beard, regardless of gender. Only affects humans."
	stage = 2
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/beard/activate(var/mob/living/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		if(H.species.name == "Human" && !(H.my_appearance.f_style == "Full Beard"))
			to_chat(H, "<span class='warning'>Your chin and neck itch!.</span>")
			spawn(50)
				H.my_appearance.f_style = "Full Beard"
				H.update_hair()


/datum/disease2/effect/bloodynose
	name = "Intranasal Hemorrhage"
	desc = "Causes the infected's nasal pathways to hemorrhage, causing a nosebleed, potentially carrying the pathogen."
	encyclopedia = "People lingering on top of the dropped blood may accidentally become infected if they're not properly protected."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING

/datum/disease2/effect/bloodynose/activate(var/mob/living/mob)
	if (prob(30))
		if (ishuman(mob))
			var/mob/living/carbon/human/H = mob
			if (!(H.species.anatomy_flags & NO_BLOOD))
				H.drip(1)
		else
			var/obj/effect/decal/cleanable/blood/D= locate(/obj/effect/decal/cleanable/blood) in get_turf(mob)
			if(D==null)
				D = getFromPool(/obj/effect/decal/cleanable/blood, get_turf(mob))
				D.New(D.loc)
			D.virus2 |= virus_copylist(mob.virus2)

/datum/disease2/effect/viralsputum
	name = "Respiratory Putrification"
	desc = "Causes the infected to cough up viral sputum over the floor, which acts as a pathogen carrier."
	encyclopedia = "People lingering on top of the dropped blood may accidentally become infected if they're not properly protected."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING

/datum/disease2/effect/viralsputum/activate(var/mob/living/mob)
	if (prob(30) && isturf(mob.loc))
		mob.emote("cough")
		var/obj/effect/decal/cleanable/blood/viralsputum/D= locate(/obj/effect/decal/cleanable/blood/viralsputum) in get_turf(mob)
		if(!D)
			D = getFromPool(/obj/effect/decal/cleanable/blood/viralsputum, get_turf(mob))
			D.New(D.loc)
		D.virus2 |= virus_copylist(mob.virus2)


/datum/disease2/effect/lantern
	name = "Lantern Syndrome"
	desc = "Causes the infected to glow."
	encyclopedia = "While useful at first glance, this also hinders the infected's capacity at hiding."
	stage = 2
	badness = EFFECT_DANGER_HELPFUL
	multiplier = 4
	max_multiplier = 10

/datum/disease2/effect/lantern/activate(var/mob/living/mob)
	mob.set_light(multiplier)
	to_chat(mob, "<span class = 'notice'>You are glowing!</span>")


/datum/disease2/effect/hangman
	name = "Hanging Man's Syndrome"
	desc = "Inhibits a portion of the infected's brain that controls speech, removing the infected's ability to speak vowels."
	encyclopedia = "Highly irritating."
	stage = 2
	affect_voice = 1
	max_count = 1
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/hangman/activate(var/mob/living/mob)
//Add filters to change a,A,e,E,i,I,o,O,u,U to _
	to_chat(mob, "<span class='warning'>Y__ f__l _ b_t str_ng _p.</span>")
	affect_voice_active = 1

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
	encyclopedia = "They may accidentally break syringes, beakers, bottles and other glass containers they try to hold, which may harm or mysteriously heal your hand."
	stage = 2
	chance = 25
	max_chance = 75
	max_multiplier = 2
	badness = EFFECT_DANGER_ANNOYING

/datum/disease2/effect/vitreous/activate(var/mob/living/carbon/human/H)
	if(istype(H))
		var/hand_to_use = rand(1, H.held_items.len)
		var/obj/item/weapon/reagent_containers/glass_to_shatter = H.get_held_item_by_index(hand_to_use)
		var/datum/organ/external/glass_hand = H.find_organ_by_grasp_index(hand_to_use)
		if (is_type_in_list(glass_to_shatter, list(/obj/item/weapon/reagent_containers/glass/, /obj/item/weapon/reagent_containers/syringe)))
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
	badness = EFFECT_DANGER_HINDRANCE
	var/list/virus_opposite_word_list

/datum/disease2/effect/opposite/activate(var/mob/living/mob,var/multiplier)
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

/datum/disease2/effect/opposite/deactivate(var/mob/living/mob)
	to_chat(mob, "<span class='warning'>You feel terrible.</span>")
	affect_voice_active = 0
	..()


/datum/disease2/effect/spiky_skin
	name = "Porokeratosis Acanthus"
	desc = "Causes the infected to generate keratin spines along their skin."
	encyclopedia = "Touching or bumping into people may now severly injure them."
	stage = 2
	max_count = 1
	badness = EFFECT_DANGER_HINDRANCE
	var/skip = FALSE
	multiplier = 4
	max_multiplier = 8

/datum/disease2/effect/spiky_skin/activate(var/mob/living/mob,var/multiplier)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(H.species && (H.species.anatomy_flags & NO_SKIN))	//Can't have spiky skin if you don't have skin at all.
			skip = TRUE
			return
	to_chat(mob, "<span class='warning'>Your skin feels a little prickly.</span>")

/datum/disease2/effect/spiky_skin/deactivate(var/mob/living/mob)
	if(!skip)
		to_chat(mob, "<span class='notice'>Your skin feels nice and smooth again!</span>")
	..()

/datum/disease2/effect/spiky_skin/on_touch(var/mob/living/mob, var/mob/living/toucher, var/mob/living/touched, var/touch_type)
	if(!count || skip)
		return
	if(!istype(toucher) || !istype(touched))
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
			E.take_damage(multiplier)
		else
			to_chat(mob, "<span class='warning'>As you bump into \the [touched], your spines dig into \him!</span>")
			var/mob/living/L = touched
			if(istype(L) && !istype(L, /mob/living/silicon))
				L.apply_damage(multiplier)
		var/mob/M = touched
		add_attacklogs(mob, M, "damaged with keratin spikes",addition = "([mob] bumped into [M])", admin_warn = FALSE)
	else
		if(E)
			to_chat(mob, "<span class='warning'>As \the [toucher] [touch_type == BUMP ? "bumps into" : "touches"] you, your spines dig into \his [E.display_name]!</span>")
			to_chat(toucher, "<span class='danger'>As you [touch_type == BUMP ? "bump into" : "touch"] \the [mob], \his spines dig into your [E.display_name]!</span>")
			E.take_damage(multiplier)
		else
			to_chat(mob, "<span class='warning'>As \the [toucher] [touch_type == BUMP ? "bumps into" : "touches"] you, your spines dig into \him!</span>")
			to_chat(toucher, "<span class='danger'>As you [touch_type == BUMP ? "bump into" : "touch"] \the [mob], \his spines dig into you!</span>")
			var/mob/living/L = toucher
			if(istype(L) && !istype(L, /mob/living/silicon))
				L.apply_damage(multiplier)
		var/mob/M = touched
		add_attacklogs(mob, M, "damaged with keratin spikes",addition = "([M] bumped into [mob])", admin_warn = FALSE)

/datum/disease2/effect/vegan
	name = "Vegan Syndrome"
	desc = "Infected people will fall ill if they try to eat meat."
	encyclopedia = ""
	stage = 2
	max_count = 1
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/vegan/activate(var/mob/living/mob)
	if (mob.dna)
		mob.dna.check_integrity()
		mob.dna.SetSEState(VEGANBLOCK,1)
		domutcheck(mob, null)

/datum/disease2/effect/famine
	name = "Faminous Potation"
	desc = "The infected emanates a field that kills off plantlife. Lethal to species descended from plants."
	encyclopedia = "Do not linger near Hydroponics or you will become the sworn enemy of all botanists."
	stage = 2
	max_multiplier = 3
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/famine/activate(var/mob/living/mob)
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
	encyclopedia = "Higher Strength means accelerated metabolism."
	stage = 2
	multiplier = 1.5
	max_multiplier = 4
	max_count = 1
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/calorieburn/activate(var/mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		H.calorie_burn_rate *= multiplier

/datum/disease2/effect/calorieburn/deactivate(var/mob/living/mob)
	if (count)
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			H.calorie_burn_rate /= multiplier

/datum/disease2/effect/calorieconserve
	name = "Caloric expenditure defficiency"
	desc = "Causes the infected to burn calories at a lower rate."
	encyclopedia = "Higher Strength means decelerated metabolism."
	stage = 2
	multiplier = 1.5
	max_multiplier = 4
	max_count = 1
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/calorieconserve/activate(var/mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		H.calorie_burn_rate /= multiplier

/datum/disease2/effect/calorieconserve/deactivate(var/mob/living/mob)
	if(count)
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			H.calorie_burn_rate *= multiplier


/datum/disease2/effect/yelling
	name = "Plankton's Syndrome"
	desc = "Attacks a portion of the infected's brain that controls speech, causing them to be more dramatic."
	stage = 2
	max_count = 1
	affect_voice = 1
	badness = EFFECT_DANGER_ANNOYING

/datum/disease2/effect/yelling/activate(var/mob/living/mob)
	to_chat(mob, "<span class='notice'>You feel like what you have to say is more important.</span>")
	affect_voice_active = 1

/datum/disease2/effect/yelling/affect_mob_voice(var/datum/speech/speech)
	var/message=speech.message
	message = uppertext(message + "!")
	speech.message = message
