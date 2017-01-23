// Make sure to use two newlines between each effect and one newline between each method.
// Fully read through the example effect below to get an idea of what attributes and procs are available.
// Babel Syndrome provides a good example of the usage of affect_voice, affect_mob_voice, etc.

/datum/disease2/effect
	var/name = "Example syndrome"
		// Try to have a self-descriptive name, eg. "Hearing Loss", "Toxin Sublimation".
		// Failing that, call it "X syndrome". It's important that effect names are consistent.
	var/stage = -1
		// Diseases start at stage 1. They slowly and cumulatively proceed their way up.
		// Try to keep more severe effects in the later stages.
	var/badness = 1
		// How damaging the virus is. Higher values are worse.

	var/chance = 3
		// Under normal conditions, the percentage chance per tick to activate.
	var/max_chance = 6
		// Maximum percentage chance per tick.

	var/multiplier = 1
		// How strong the effects are. Use this in activate().
	var/max_multiplier = 1
		// Maximum multiplier.

	var/count = 0
		// How many times the effect has activated so far.
	var/max_count = -1
		// How many times the effect should be allowed to activate. If -1, always activate.

	var/affect_voice = 0
	var/affect_voice_active = 0
		// Read through Hanging Man's / Pro-tagonista syndrome to know how to use these.

	var/datum/disease2/disease/virus
		// Parent virus. Plans to generalize these are underway.

	proc/activate(var/mob/living/carbon/mob)
		// The actual guts of the effect. Has a prob(chance)% to get called per tick.
	proc/deactivate(var/mob/living/carbon/mob)
		// If activation makes any permanent changes to the effect, this is where you undo them.
		// Will not get called if the virus has never been activated.
	proc/affect_mob_voice(var/datum/speech/speech)
		// Called by /mob/living/carbon/human/treat_speech
	proc/on_touch(var/mob/living/carbon/mob, var/toucher, var/touched, var/touch_type)
		// Called when the sufferer of the symptom bumps, is bumped, or is touched by hand.

// Most of the stuff below shouldn't be changed when you make a new effect.
/datum/disease2/effect/New(var/datum/disease2/disease/D)
	virus=D

/datum/disease2/effect/proc/can_run_effect(var/active_stage = -1)
	if((count < max_count || max_count == -1) && (stage <= active_stage || active_stage == -1) && prob(chance))
		return 1
	return 0

/datum/disease2/effect/proc/run_effect(var/mob/living/carbon/human/mob)
	activate(mob)
	count += 1

/datum/disease2/effect/proc/disable_effect(var/mob/living/carbon/human/mob)
	if (count > 0)
		deactivate(mob)

/datum/disease2/effect/proc/minormutate()
	switch(pick(1,2,3,4,5))
		if(1)
			chance = rand(0, max_chance)
		if(2)
			multiplier = rand(1, max_multiplier)

/datum/disease2/effect/proc/getcopy(var/datum/disease2/disease/disease)
	var/datum/disease2/effect/new_e = new type(disease)
	new_e.chance = chance
	new_e.multiplier = multiplier
	return new_e


////////////////////////STAGE 1/////////////////////////////////


/datum/disease2/effect/invisible
	name = "Waiting Syndrome"
	stage = 1

/datum/disease2/effect/invisible/activate(var/mob/living/carbon/mob)
		return


/datum/disease2/effect/sneeze
	name = "Coldingtons Effect"
	stage = 1

/datum/disease2/effect/sneeze/activate(var/mob/living/carbon/mob)
	mob.say("*sneeze")
	if (prob(50))
		var/obj/effect/decal/cleanable/mucus/M= locate(/obj/effect/decal/cleanable/mucus) in get_turf(mob)
		if(M==null)
			M = new(get_turf(mob))
		else
			if(M.dry)
				M.dry=0
		M.virus2 |= virus_copylist(mob.virus2)


/datum/disease2/effect/gunck
	name = "Flemmingtons"
	stage = 1

/datum/disease2/effect/gunck/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class = 'notice'> Mucous runs down the back of your throat.</span>")


/datum/disease2/effect/drool
	name = "Saliva Effect"
	stage = 1

/datum/disease2/effect/drool/activate(var/mob/living/carbon/mob)
	mob.say("*drool")


/datum/disease2/effect/twitch
	name = "Twitcher"
	stage = 1

/datum/disease2/effect/twitch/activate(var/mob/living/carbon/mob)
	mob.say("*twitch")


/datum/disease2/effect/headache
	name = "Headache"
	stage = 1

/datum/disease2/effect/headache/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class = 'notice'>Your head hurts a bit</span>")


/datum/disease2/effect/itching
	name = "Itching"
	stage = 1

/datum/disease2/effect/itching/activate(var/mob/living/carbon/mob)
	var/mob/living/carbon/human/H = mob
	if (istype(H) && H.species && H.species.anatomy_flags & NO_SKIN)
		to_chat(mob, "<span class='warning'>Your bones itch!</span>")
	else
		to_chat(mob, "<span class='warning'>Your skin itches!</span>")


/datum/disease2/effect/drained
	name = "Drained Feeling"
	stage = 1

/datum/disease2/effect/drained/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class='warning'>You feel drained.</span>")


/datum/disease2/effect/eyewater
	name = "Watery Eyes"
	stage = 1

/datum/disease2/effect/eyewater/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<SPAN CLASS='warning'>Your eyes sting and water!</SPAN>")


/datum/disease2/effect/wheeze
	name = "Wheezing"
	stage = 1

/datum/disease2/effect/wheeze/activate(var/mob/living/carbon/mob)
	mob.emote("me",1,"wheezes.")


/datum/disease2/effect/optimistic
	name = "Full Glass Syndrome"
	stage = 1

/datum/disease2/effect/optimistic/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class = 'notice'>You feel optimistic!</span>")
	if (mob.reagents.get_reagent_amount(TRICORDRAZINE) < 1)
		mob.reagents.add_reagent(TRICORDRAZINE, 1)


/datum/disease2/effect/spyndrome
	name = "Gyroscopic Manipulation Syndrome"
	stage = 1

/datum/disease2/effect/spyndrome/activate(var/mob/living/carbon/mob)
	if (mob.reagents.get_reagent_amount(GYRO) < 1)
		mob.reagents.add_reagent(GYRO, 1)


////////////////////////STAGE 2/////////////////////////////////


/datum/disease2/effect/scream
	name = "Loudness Syndrome"
	stage = 2

/datum/disease2/effect/scream/activate(var/mob/living/carbon/mob)
	mob.emote("scream",,, 1)


/datum/disease2/effect/drowsness
	name = "Automated Sleeping Syndrome"
	stage = 2

/datum/disease2/effect/drowsness/activate(var/mob/living/carbon/mob)
	mob.drowsyness += 10


/datum/disease2/effect/sleepy
	name = "Resting Syndrome"
	stage = 2

/datum/disease2/effect/sleepy/activate(var/mob/living/carbon/mob)
	mob.say("*collapse")


/datum/disease2/effect/blind
	name = "Blackout Syndrome"
	stage = 2

/datum/disease2/effect/blind/activate(var/mob/living/carbon/mob)
	mob.eye_blind = max(mob.eye_blind, 4)


/datum/disease2/effect/cough
	name = "Anima Syndrome"
	stage = 2

/datum/disease2/effect/cough/activate(var/mob/living/carbon/mob)
	mob.say("*cough")
	for(var/mob/living/carbon/M in oview(2,mob))
		mob.spread_disease_to(M)


/datum/disease2/effect/hungry
	name = "Appetiser Effect"
	stage = 2

/datum/disease2/effect/hungry/activate(var/mob/living/carbon/mob)
	mob.nutrition = max(0, mob.nutrition - 200)


/datum/disease2/effect/fridge
	name = "Refridgerator Syndrome"
	stage = 2

/datum/disease2/effect/fridge/activate(var/mob/living/carbon/mob)
	mob.say("*shiver")


/datum/disease2/effect/hair
	name = "Hair Loss"
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
	stage = 2

/datum/disease2/effect/stimulant/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class='notice'>You feel a rush of energy inside you!</span>")
	if (mob.reagents.get_reagent_amount(HYPERZINE) < 10)
		mob.reagents.add_reagent(HYPERZINE, 4)
	if (prob(30))
		mob.jitteriness += 10


/datum/disease2/effect/drunk
	name = "Glasgow Syndrome"
	stage = 2

/datum/disease2/effect/drunk/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class='notice'>You feel like you had one hell of a party!</span>")
	if (mob.reagents.get_reagent_amount(ETHANOL) < 325)
		mob.reagents.add_reagent(ETHANOL, 5*multiplier)


/datum/disease2/effect/gaben
	name = "Gaben Syndrome"
	stage = 2

/datum/disease2/effect/gaben/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class='notice'>Your clothing fits a little tighter!!</span>")
	if (prob(10))
		mob.reagents.add_reagent(NUTRIMENT, 1000)
		mob.overeatduration = 1000


/datum/disease2/effect/beard
	name = "Bearding"
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
	stage = 2

/datum/disease2/effect/lantern/activate(var/mob/living/carbon/mob)
	mob.set_light(4)
	to_chat(mob, "<span class = 'notice'>You are glowing!</span>")


/datum/disease2/effect/hangman
	name = "Hanging Man's Syndrome"
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
			playsound(get_turf(H), 'sound/effects/Glassbr1.ogg', 25, 1)
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

/datum/disease2/effect/butterfly_skin
	name = "Epidermolysis Bullosa"
	stage = 3
	max_count = 1
	var/skip = FALSE

/datum/disease2/effect/butterfly_skin/activate(var/mob/living/carbon/mob,var/multiplier)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(H.species && (H.species.anatomy_flags & NO_SKIN))	//Can't have fragile skin if you don't have skin at all.
			skip = TRUE
			return
	to_chat(mob, "<span class='warning'>Your skin feels a little fragile.</span>")

/datum/disease2/effect/butterfly_skin/deactivate(var/mob/living/carbon/mob)
	if(!skip)
		to_chat(mob, "<span class='notice'>Your skin feels nice and durable again!.</span>")
	..()

/datum/disease2/effect/butterfly_skin/on_touch(var/mob/living/carbon/mob, var/toucher, var/touched, var/touch_type)
	if(count && !skip)
		var/datum/organ/external/E
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			while(!E || (E.status & ORGAN_ROBOT) || (E.status & ORGAN_PEG))
				E = pick(H.organs)
		if(toucher == mob)
			if(E)
				to_chat(mob, "<span class='warning'>As you bump into \the [touched], some of the skin on your [E.display_name] shears off!</span>")
				E.take_damage(10)
			else
				to_chat(mob, "<span class='warning'>As you bump into \the [touched], some of your skin shears off!</span>")
				mob.apply_damage(10)
		else
			if(E)
				to_chat(mob, "<span class='warning'>As \the [toucher] [touch_type == BUMP ? "bumps into" : "touches"] you, some of the skin on your [E.display_name] shears off!</span>")
				to_chat(toucher, "<span class='danger'>As you [touch_type == BUMP ? "bump into" : "touch"] \the [mob], some of the skin on \his [E.display_name] shears off!</span>")
				E.take_damage(10)
			else
				to_chat(mob, "<span class='warning'>As \the [toucher] [touch_type == BUMP ? "bumps into" : "touches"] you, some of your skin shears off!</span>")
				to_chat(toucher, "<span class='danger'>As you [touch_type == BUMP ? "bump into" : "touch"] \the [mob], some of \his skin shears off!</span>")
				mob.apply_damage(10)


////////////////////////STAGE 3/////////////////////////////////


/datum/disease2/effect/toxins
	name = "Hyperacidity"
	stage = 3
	max_multiplier = 3

/datum/disease2/effect/toxins/activate(var/mob/living/carbon/mob)
	mob.adjustToxLoss((2*multiplier))


/datum/disease2/effect/shakey
	name = "World Shaking Syndrome"
	stage = 3
	max_multiplier = 3

/datum/disease2/effect/shakey/activate(var/mob/living/carbon/mob)
	shake_camera(mob,5*multiplier)


/datum/disease2/effect/telepathic
	name = "Telepathy Syndrome"
	stage = 3

/datum/disease2/effect/telepathic/activate(var/mob/living/carbon/mob)
	mob.dna.check_integrity()
	mob.dna.SetSEState(REMOTETALKBLOCK,1)
	domutcheck(mob, null)


/datum/disease2/effect/mind
	name = "Lazy Mind Syndrome"
	stage = 3

/datum/disease2/effect/mind/activate(var/mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		var/datum/organ/internal/brain/B = H.internal_organs_by_name["brain"]
		if (B && B.damage < B.min_broken_damage)
			B.take_damage(5)
	else
		mob.setBrainLoss(50)


/datum/disease2/effect/hallucinations
	name = "Hallucinational Syndrome"
	stage = 3

/datum/disease2/effect/hallucinations/activate(var/mob/living/carbon/mob)
	mob.hallucination += 25


/datum/disease2/effect/deaf
	name = "Hard of Hearing Syndrome"
	stage = 3

/datum/disease2/effect/deaf/activate(var/mob/living/carbon/mob)
	mob.ear_deaf = 5


/datum/disease2/effect/giggle
	name = "Uncontrolled Laughter Effect"
	stage = 3

/datum/disease2/effect/giggle/activate(var/mob/living/carbon/mob)
	mob.say("*giggle")


/datum/disease2/effect/chickenpox
	name = "Chicken Pox"
	stage = 3

/datum/disease2/effect/chickenpox/activate(var/mob/living/carbon/mob)
	if (prob(30))
		mob.say(pick("BAWWWK!", "BAAAWWK!", "CLUCK!", "CLUUUCK!", "BAAAAWWWK!"))
	if (prob(15))
		mob.emote("me",1,"vomits up a chicken egg!")
		playsound(mob.loc, 'sound/effects/splat.ogg', 50, 1)
		new /obj/item/weapon/reagent_containers/food/snacks/egg(get_turf(mob))


/datum/disease2/effect/confusion
	name = "Topographical Cretinism"
	stage = 3

/datum/disease2/effect/confusion/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class='notice'>You have trouble telling right and left apart all of a sudden.</span>")
	mob.confused += 10


/datum/disease2/effect/mutation
	name = "DNA Degradation"
	stage = 3

/datum/disease2/effect/mutation/activate(var/mob/living/carbon/mob)
	mob.apply_damage(2, CLONE)


/datum/disease2/effect/groan
	name = "Groaning Syndrome"
	stage = 3

/datum/disease2/effect/groan/activate(var/mob/living/carbon/mob)
	mob.say("*groan")


/datum/disease2/effect/sweat
	name = "Hyper-perspiration Effect"
	stage = 3

/datum/disease2/effect/sweat/activate(var/mob/living/carbon/mob)
	if(prob(30))
		mob.emote("me",1,"is sweating profusely!")

		if(istype(mob.loc,/turf/simulated))
			var/turf/simulated/T = mob.loc
			T.wet(800, TURF_WET_WATER)


/datum/disease2/effect/elvis
	name = "Elvisism"
	stage = 3

/datum/disease2/effect/elvis/activate(var/mob/living/carbon/mob)
	if(!istype(mob))
		return

	var/mob/living/carbon/human/H = mob
	var/obj/item/clothing/glasses/sunglasses/virus/virussunglasses = new /obj/item/clothing/glasses/sunglasses/virus
	if(H.glasses && !istype(H.glasses, /obj/item/clothing/glasses/sunglasses/virus))
		mob.u_equip(H.glasses,1)
		mob.equip_to_slot(virussunglasses, slot_glasses)
	if(!slot_glasses)
		mob.equip_to_slot(virussunglasses, slot_glasses)
	mob.confused += 10

	if(pick(0,1))
		mob.say(pick("Uh HUH!", "Thank you, Thank you very much...", "I ain't nothin' but a hound dog!", "Swing low, sweet chariot!"))
	else
		mob.emote("me",1,pick("curls his lip!", "gyrates his hips!", "thrusts his hips!"))

	if(istype(H))

		if(H.species.name == "Human" && !(H.f_style == "Pompadour"))
			spawn(50)
				H.h_style = "Pompadour"
				H.update_hair()

		if(H.species.name == "Human" && !(H.f_style == "Elvis Sideburns"))
			spawn(50)
				H.f_style = "Elvis Sideburns"
				H.update_hair()

/datum/disease2/effect/elvis/deactivate(var/mob/living/carbon/mob)
	if(ishuman(mob))
		if(mob:glasses && istype(mob:glasses, /obj/item/clothing/glasses/sunglasses/virus))
			mob:glasses.canremove = 1
			mob.u_equip(mob:glasses,1)


/datum/disease2/effect/pthroat
	name = "Pierrot's Throat"
	stage = 3

/datum/disease2/effect/pthroat/activate(var/mob/living/carbon/mob)
	//
	var/obj/item/clothing/mask/gas/clown_hat/virus/virusclown_hat = new /obj/item/clothing/mask/gas/clown_hat/virus
	if(mob.wear_mask && !istype(mob.wear_mask, /obj/item/clothing/mask/gas/clown_hat/virus))
		mob.u_equip(mob.wear_mask,1)
		mob.equip_to_slot(virusclown_hat, slot_wear_mask)
	if(!mob.wear_mask)
		mob.equip_to_slot(virusclown_hat, slot_wear_mask)
	mob.reagents.add_reagent(PSILOCYBIN, 20)
	mob.say(pick("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk..."))


var/list/compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)

/datum/disease2/effect/horsethroat
	name = "Horse Throat"
	stage = 3

/datum/disease2/effect/horsethroat/activate(var/mob/living/carbon/mob)


	if(!(mob.type in compatible_mobs))
		return


	var/obj/item/clothing/mask/horsehead/magic/magichead = new /obj/item/clothing/mask/horsehead/magic
	if(mob.wear_mask && !istype(mob.wear_mask, /obj/item/clothing/mask/horsehead/magic))
		mob.u_equip(mob.wear_mask,1)
		mob.equip_to_slot(magichead, slot_wear_mask)
	if(!mob.wear_mask)
		mob.equip_to_slot(magichead, slot_wear_mask)
	to_chat(mob, "<span class='warning'>You feel a little horse!</span>")


/datum/disease2/effect/anime_hair
	name = "Pro-tagonista Syndrome"
	stage = 3
	var/triggered = 0
	var/given_katana = 0
	affect_voice = 1
	max_multiplier = 4

/datum/disease2/effect/anime_hair/activate(var/mob/living/carbon/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/affected = mob
		if(!triggered)
			var/list/hair_colors = list("pink","red","green","blue","purple")
			var/hair_color = pick(hair_colors)

			switch(hair_color)
				if("pink")
					affected.b_hair = 153
					affected.g_hair = 102
					affected.r_hair = 255
				if("red")
					affected.b_hair = 0
					affected.g_hair = 0
					affected.r_hair = 255
				if("green")
					affected.b_hair = 0
					affected.g_hair = 255
					affected.r_hair = 0
				if("blue")
					affected.b_hair = 255
					affected.g_hair = 0
					affected.r_hair = 0
				if("purple")
					affected.b_hair = 102
					affected.g_hair = 0
					affected.r_hair = 102
			affected.update_hair()
			triggered = 1

		if(multiplier)
			if(multiplier >= 1.5)
				//Give them schoolgirl outfits /obj/item/clothing/under/schoolgirl
				var/obj/item/clothing/under/schoolgirl/schoolgirl = new /obj/item/clothing/under/schoolgirl
				schoolgirl.canremove = 0
				if(affected.w_uniform && !istype(affected.w_uniform, /obj/item/clothing/under/schoolgirl))
					affected.u_equip(affected.w_uniform,1)
					affected.equip_to_slot(schoolgirl, slot_w_uniform)
				if(!affected.w_uniform)
					affected.equip_to_slot(schoolgirl, slot_w_uniform)
			if(multiplier >= 1.8)
				//Kneesocks /obj/item/clothing/shoes/kneesocks
				var/obj/item/clothing/shoes/kneesocks/kneesock = new /obj/item/clothing/shoes/kneesocks
				kneesock.canremove = 0
				if(affected.shoes && !istype(affected.shoes, /obj/item/clothing/shoes/kneesocks))
					affected.u_equip(affected.shoes,1)
					affected.equip_to_slot(kneesock, slot_shoes)
				if(!affected.w_uniform)
					affected.equip_to_slot(kneesock, slot_shoes)

			if(multiplier >= 2)
				if(multiplier >=2.3)
					//Cursed, pure evil cat ears that should not have been created
					var/obj/item/clothing/head/kitty/cursed/kitty_c = new /obj/item/clothing/head/kitty/cursed
					if(affected.head && !istype(affected.head, /obj/item/clothing/head/kitty/cursed))
						affected.u_equip(affected.head,1)
						affected.equip_to_slot(kitty_c, slot_head)
					if(!affected.head)
						affected.equip_to_slot(kitty_c, slot_head)
				else
					//Regular cat ears /obj/item/clothing/head/kitty
					var/obj/item/clothing/head/kitty/kitty = new /obj/item/clothing/head/kitty
					if(affected.head && !istype(affected.head, /obj/item/clothing/head/kitty))
						affected.u_equip(affected.head,1)
						affected.equip_to_slot(kitty, slot_head)
					if(!affected.head)
						affected.equip_to_slot(kitty, slot_head)
				affect_voice_active = 1

			if(multiplier >= 2.5 && !given_katana)
				if(multiplier >= 3)
					//REAL katana /obj/item/weapon/katana
					var/obj/item/weapon/katana/real_katana = new /obj/item/weapon/katana
					affected.put_in_hands(real_katana)
				else
					//Toy katana /obj/item/toy/katana
					var/obj/item/toy/katana/fake_katana = new /obj/item/toy/katana
					affected.put_in_hands(fake_katana)
				given_katana = 1

datum/disease2/effect/anime_hair/deactivate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class = 'notice'>You no longer feel quite like the main character. </span>")
	var/mob/living/carbon/human/affected = mob
	if(affected.shoes && istype(affected.shoes, /obj/item/clothing/shoes/kneesocks))
		affected.shoes.canremove = 1
	if(affected.w_uniform && istype(affected.w_uniform, /obj/item/clothing/under/schoolgirl))
		affected.w_uniform.canremove = 1

/datum/disease2/effect/anime_hair/affect_mob_voice(var/datum/speech/speech)
	var/message=speech.message

	if(prob(20))
		message += pick(" Nyaa", "  nya", "  Nyaa~", "~")

	speech.message = message


/datum/disease2/effect/lubefoot
	name = "Self-lubricating Footstep Syndrome"
	stage = 3
	max_multiplier = 9.5 //Potential for 95% lube chance per step
	var/triggered

/datum/disease2/effect/lubefoot/activate(var/mob/living/carbon/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/affected = mob
		if(multiplier > 1.5 && !triggered)
			to_chat(affected, "You feel slightly more inept than usual.")
			affected.dna.check_integrity()
			affected.dna.SetSEState(CLUMSYBLOCK,1)
			domutcheck(mob, null)
			triggered = 1
		var/obj/item/clothing/shoes/clown_shoes/slippy/honkers = new /obj/item/clothing/shoes/clown_shoes/slippy
		if(affected.shoes && !istype(affected.shoes, /obj/item/clothing/shoes/clown_shoes))//Clown shoes may save you
			affected.u_equip(affected.shoes,1)
			affected.equip_to_slot(honkers, slot_shoes)
		else if(affected.shoes && istype(affected.shoes, /obj/item/clothing/shoes/clown_shoes/slippy))
			var/obj/item/clothing/shoes/clown_shoes/slippy/worn_honkers = affected.shoes
			if(worn_honkers.lube_chance < 10*multiplier)
				worn_honkers.lube_chance = 10*multiplier
		if(!affected.shoes)
			affected.equip_to_slot(honkers, slot_shoes)

		honkers.lube_chance = 10*multiplier
	if(prob(15))
		to_chat(mob, "Your feet feel slippy!")

datum/disease2/effect/lubefoot/deactivate(var/mob/living/carbon/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/affected = mob

		if(affected.shoes && istype(affected.shoes, /obj/item/clothing/shoes/clown_shoes/slippy))
			var/obj/item/clothing/shoes/clown_shoes/slippy/honkers = affected.shoes
			to_chat(mob, "Your shoes now don't feel quite as slippery")
			honkers.lube_chance = 0
			honkers.canremove = 1


////////////////////////STAGE 4/////////////////////////////////


/datum/disease2/effect/minttoxin
	name = "Creosote Syndrome"
	stage = 4

/datum/disease2/effect/minttoxin/activate(var/mob/living/carbon/mob)
	if(istype(mob) && mob.reagents.get_reagent_amount(MINTTOXIN) < 5)
		to_chat(mob, "<span class='notice'>You feel a minty freshness</span>")
		mob.reagents.add_reagent(MINTTOXIN, 5)


/datum/disease2/effect/gibbingtons
	name = "Gibbingtons Syndrome"
	stage = 4
	badness = 2

/datum/disease2/effect/gibbingtons/activate(var/mob/living/carbon/mob)
	mob.gib()


/datum/disease2/effect/radian
	name = "Radian's Syndrome"
	stage = 4
	max_multiplier = 3

/datum/disease2/effect/radian/activate(var/mob/living/carbon/mob)
	mob.radiation += (2*multiplier)


/datum/disease2/effect/deaf
	name = "Dead Ear Syndrome"
	stage = 4

/datum/disease2/effect/deaf/activate(var/mob/living/carbon/mob)
	mob.ear_deaf += 20


/datum/disease2/effect/monkey
	name = "Monkism Syndrome"
	stage = 4
	badness = 2

/datum/disease2/effect/monkey/activate(var/mob/living/carbon/mob)
	if(istype(mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/h = mob
		h.monkeyize()


/datum/disease2/effect/catbeast
	name = "Kingston Syndrome"
	stage = 4
	badness = 2

/datum/disease2/effect/catbeast/activate(var/mob/living/carbon/mob)
	if(istype(mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/h = mob
		if(h.species.name != "Tajaran")
			if(h.set_species("Tajaran"))
				h.regenerate_icons()


/datum/disease2/effect/voxpox
	name = "Vox Pox"
	stage = 4
	badness = 2

/datum/disease2/effect/voxpox/activate(var/mob/living/carbon/mob)
	if(istype(mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/h = mob
		if(h.species.name != "Vox")
			if(h.set_species("Vox"))
				h.regenerate_icons()


/datum/disease2/effect/suicide
	name = "Suicidal Syndrome"
	stage = 4
	badness = 2

/datum/disease2/effect/suicide/activate(var/mob/living/carbon/mob)
	mob.suiciding = 1
	//instead of killing them instantly, just put them at -175 health and let 'em gasp for a while
	to_chat(viewers(mob), "<span class='danger'>[mob.name] is holding \his breath. It looks like \he's trying to commit suicide.</span>")
	mob.adjustOxyLoss(175 - mob.getToxLoss() - mob.getFireLoss() - mob.getBruteLoss() - mob.getOxyLoss())
	mob.updatehealth()
	spawn(200) //in case they get revived by cryo chamber or something stupid like that, let them suicide again in 20 seconds
		mob.suiciding = 0


/datum/disease2/effect/killertoxins
	name = "Toxification Syndrome"
	stage = 4

/datum/disease2/effect/killertoxins/activate(var/mob/living/carbon/mob)
	mob.adjustToxLoss(15*multiplier)


/datum/disease2/effect/dna
	name = "Reverse Pattern Syndrome"
	stage = 4

/datum/disease2/effect/dna/activate(var/mob/living/carbon/mob)
	mob.bodytemperature = max(mob.bodytemperature, 350)
	scramble(0,mob,10)
	mob.apply_damage(10, CLONE)


/datum/disease2/effect/organs
	name = "Shutdown Syndrome"
	stage = 4

/datum/disease2/effect/organs/activate(var/mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		var/organ = pick(list(LIMB_RIGHT_ARM,LIMB_LEFT_ARM,LIMB_RIGHT_LEG,LIMB_RIGHT_LEG))
		var/datum/organ/external/E = H.organs_by_name[organ]
		if (!(E.status & ORGAN_DEAD))
			E.status |= ORGAN_DEAD
			to_chat(H, "<span class='notice'>You can't feel your [E.display_name] anymore...</span>")
			for (var/datum/organ/external/C in E.children)
				C.status |= ORGAN_DEAD
		H.update_body(1)
		if(multiplier < 1)
			multiplier = 1
		H.adjustToxLoss(15*multiplier)

/datum/disease2/effect/organs/vampire
	stage = 3 //For use with vampires?

/datum/disease2/effect/organs/deactivate(var/mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		for (var/datum/organ/external/E in H.organs)
			E.status &= ~ORGAN_DEAD
			for (var/datum/organ/external/C in E.children)
				C.status &= ~ORGAN_DEAD
		H.update_body(1)


/datum/disease2/effect/immortal
	name = "Longevity Syndrome"
	stage = 4

/datum/disease2/effect/immortal/activate(var/mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		for (var/datum/organ/external/E in H.organs)
			if (E.status & ORGAN_BROKEN && prob(30))
				E.status ^= ORGAN_BROKEN
	var/heal_amt = -5*multiplier
	mob.apply_damages(heal_amt,heal_amt,heal_amt,heal_amt)

/datum/disease2/effect/immortal/deactivate(var/mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		to_chat(H, "<span class='notice'>You suddenly feel hurt and old...</span>")
		H.age += 8
	var/backlash_amt = 5*multiplier
	mob.apply_damages(backlash_amt,backlash_amt,backlash_amt,backlash_amt)


/datum/disease2/effect/bones
	name = "Fragile Bones Syndrome"
	stage = 4

/datum/disease2/effect/bones/activate(var/mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		for (var/datum/organ/external/E in H.organs)
			E.min_broken_damage = max(5, E.min_broken_damage - 30)

/datum/disease2/effect/bones/deactivate(var/mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		for (var/datum/organ/external/E in H.organs)
			E.min_broken_damage = initial(E.min_broken_damage)


/datum/disease2/effect/scc
	name = "Spontaneous Cellular Collapse"
	stage = 4

/datum/disease2/effect/scc/activate(var/mob/living/carbon/mob)
	//
	if(!ishuman(mob))
		return 0
	var/mob/living/carbon/human/H = mob
	mob.reagents.add_reagent(PACID, 10)
	to_chat(mob, "<span class = 'warning'>Your body burns as your cells break down.</span>")
	shake_camera(mob,5*multiplier)

	for (var/datum/organ/external/E in H.organs)
		if(pick(1,0))
			//
			E.createwound(CUT, pick(2,4,6,8,10))
			E.fracture()


/datum/disease2/effect/necrosis
	name = "Necrosis"
	stage = 4

/datum/disease2/effect/necrosis/activate(var/mob/living/carbon/mob)

	if(ishuman(mob)) //Only works on humans properly since it needs to do organ work
		var/mob/living/carbon/human/H = mob
		var/inst = pick(1, 2, 3)

		switch(inst)

			if(1)
				to_chat(H, "<span class='warning'>A chunk of meat falls off of you!</span>")
				var/totalslabs = 1
				var/obj/item/weapon/reagent_containers/food/snacks/meat/allmeat[totalslabs]
				var/sourcename = H.real_name
				var/sourcejob = H.job
				var/sourcenutriment = H.nutrition / 15
				//var/sourcetotalreagents = mob.reagents.total_volume

				for(var/i = 1 to totalslabs)
					var/obj/item/weapon/reagent_containers/food/snacks/meat/human/newmeat = new
					newmeat.name = sourcename + newmeat.name
					newmeat.subjectname = sourcename
					newmeat.subjectjob = sourcejob
					newmeat.reagents.add_reagent(NUTRIMENT, sourcenutriment / totalslabs) //Thehehe. Fat guys go first
					//src.occupant.reagents.trans_to(newmeat, round (sourcetotalreagents / totalslabs, 1)) // Transfer all the reagents from the
					allmeat[i] = newmeat

					var/obj/item/meatslab = allmeat[i]
					var/turf/Tx = locate(mob.x, mob.y, mob.z)
					meatslab.forceMove(get_turf(H))
					meatslab.throw_at(Tx, i, 3)

					if(!Tx.density)
						var/obj/effect/decal/cleanable/blood/gibs/D = getFromPool(/obj/effect/decal/cleanable/blood/gibs, Tx)
						D.New(Tx,i)

			if(2)
				for(var/datum/organ/external/E in H.organs)
					if(pick(1, 0))
						E.droplimb(1)

			if(3)
				if(H.species.name != "Skellington")
					to_chat(H, "<span class='warning'>Your necrotic skin ruptures!</span>")

					for(var/datum/organ/external/E in H.organs)
						if(pick(1,0))
							E.createwound(CUT, pick(2, 4, 6, 8, 10))

					if(prob(30))
						if(H.species.name != "Skellington")
							if(H.set_species("Skellington"))
								to_chat(mob, "<span class='warning'>A massive amount of flesh sloughs off your bones!</span>")
								H.regenerate_icons()
				else
					return


/datum/disease2/effect/fizzle
	name = "Fizzle Effect"
	stage = 4

/datum/disease2/effect/fizzle/activate(var/mob/living/carbon/mob)
	mob.emote("me",1,pick("sniffles...", "clears their throat..."))


/datum/disease2/effect/delightful
	name = "Delightful Effect"
	stage = 4

/datum/disease2/effect/delightful/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class = 'notice'>You feel delightful!</span>")
	if (mob.reagents.get_reagent_amount(DOCTORSDELIGHT) < 1)
		mob.reagents.add_reagent(DOCTORSDELIGHT, 1)


/datum/disease2/effect/spawn
	name = "Arachnogenesis Effect"
	stage = 4
	var/spawn_type=/mob/living/simple_animal/hostile/giant_spider/spiderling
	var/spawn_name="spiderling"

/datum/disease2/effect/spawn/activate(var/mob/living/carbon/mob)
	playsound(mob.loc, 'sound/effects/splat.ogg', 50, 1)

	new spawn_type(get_turf(mob))
	mob.emote("me",1,"vomits up a live [spawn_name]!")

/datum/disease2/effect/spawn/roach
	name = "Blattogenesis Effect"
	stage = 4
	spawn_type=/mob/living/simple_animal/cockroach
	spawn_name="cockroach"


/datum/disease2/effect/orbweapon
	name = "Biolobulin Effect"
	stage = 4
/datum/disease2/effect/orbweapon/activate(var/mob/living/carbon/mob)
	var/obj/item/toy/snappop/virus/virus = new /obj/item/toy/snappop/virus
	mob.put_in_hands(virus)


/datum/disease2/effect/plasma
	name = "Toxin Sublimation"
	stage = 4

/datum/disease2/effect/plasma/activate(var/mob/living/carbon/mob)
	//var/src = mob
	var/hack = mob.loc
	var/turf/simulated/T = get_turf(hack)
	if(!T)
		return
	var/datum/gas_mixture/GM = new
	if(prob(10))
		GM.toxins += 100
		//GM.temperature = 1500+T0C //should be enough to start a fire
		to_chat(mob, "<span class='warning'>You exhale a large plume of toxic gas!</span>")
	else
		GM.toxins += 10
		GM.temperature = istype(T) ? T.air.temperature : T20C
		to_chat(mob, "<span class = 'warning'> A toxic gas emanates from your pores!</span>")
	T.assume_air(GM)
	return


/datum/disease2/effect/babel
	name = "Babel Syndrome"
	stage = 4
	max_count = 1

	var/list/original_languages = list()

/datum/disease2/effect/babel/activate(var/mob/living/carbon/mob)
	if(mob.languages.len <= 1)
		to_chat(mob, "Your knowledge of language is just fine.")
		return

	for(var/datum/language/L in mob.languages)
		original_languages += L.name
		mob.remove_language(L.name)

	var/list/new_languages = list()
	for(var/L in all_languages)
		var/datum/language/lang = all_languages[L]
		if(!(lang.flags & RESTRICTED))
			new_languages += lang.name

	var/picked_lang = pick(new_languages)
	mob.add_language(picked_lang)
	mob.default_language = mob.languages[1]

	to_chat(mob, "You can't seem to remember any language but [picked_lang]. Odd.")

/datum/disease2/effect/babel/deactivate(var/mob/living/carbon/mob)
	if(original_languages.len)
		for(var/forgotten in original_languages)
			mob.add_language(forgotten)

		to_chat(mob, "Suddenly, your knowledge of languages comes back to you.")


/datum/disease2/effect/gregarious
	name = "Gregarious Impetus"
	stage = 4
	max_chance = 25
	max_multiplier = 4

/datum/disease2/effect/gregarious/activate(var/mob/living/carbon/mob)
	var/others_count = 0
	for(var/mob/living/carbon/m in oview(5, mob))
		if (airborne_can_reach(mob.loc, m.loc, 9)) // Apparently mobs physically block airborne viruses
			others_count += 1
	if (others_count >= multiplier)
		to_chat(mob, "<span class='notice'>A friendly sensation is satisfied with how many are near you - for now.</span>")
		mob.adjustBrainLoss(-multiplier)
		mob.reagents.add_reagent(OXYCODONE, multiplier) // ADDICTED TO HAVING FRIENDS
		if (multiplier < max_multiplier)
			multiplier += 0.15 // The virus gets greedier
	else
		to_chat(mob, "<span class='warning'>A hostile sensation in your brain stings you... it wants more of the living near you.</span>")
		mob.adjustBrainLoss(multiplier / 2)
		mob.AdjustParalysis(multiplier) // This practically permaparalyzes you at higher multipliers but
		mob.AdjustKnockdown(multiplier) // that's your fucking fault for not being near enough people
		mob.AdjustStunned(multiplier)   // You'll have to wait until the multiplier gets low enough
		if (multiplier > 1)
			multiplier -= 0.3 // The virus tempers expectations



////////////////////////SPECIAL/////////////////////////////////


/*/datum/disease2/effect/alien
	name = "Unidentified Foreign Body"
	stage = 4
	activate(var/mob/living/carbon/mob)
		to_chat(mob, "<span class='warning'>You feel something tearing its way out of your stomach...</span>")
		mob.adjustToxLoss(10)
		mob.updatehealth()
		if(prob(40))
			if(mob.client)
				mob.client.mob = new/mob/living/carbon/alien/larva(mob.loc)
			else
				new/mob/living/carbon/alien/larva(mob.loc)
			var/datum/disease2/disease/D = mob:virus2
			mob:gib()
			del D*/


/datum/disease2/effect/spaceadapt
	name = "Space Adaptation Effect"
	stage = 5

/datum/disease2/effect/spaceadapt/activate(var/mob/living/carbon/mob)
	var/mob/living/carbon/human/H = mob
	if (mob.reagents.get_reagent_amount(DEXALINP) < 10)
		mob.reagents.add_reagent(DEXALINP, 4)
	if (mob.reagents.get_reagent_amount(LEPORAZINE) < 10)
		mob.reagents.add_reagent(LEPORAZINE, 4)
	if (mob.reagents.get_reagent_amount(BICARIDINE) < 10)
		mob.reagents.add_reagent(BICARIDINE, 4)
	if (mob.reagents.get_reagent_amount(DERMALINE) < 10)
		mob.reagents.add_reagent(DERMALINE, 4)
	mob.emote("me",1,"exhales slowly.")

	if(ishuman(H))
		var/datum/organ/external/chest/chest = H.get_organ(LIMB_CHEST)
		for(var/datum/organ/internal/I in chest.internal_organs)
			I.damage = 0
