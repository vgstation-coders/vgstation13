/datum/disease2/effect/toxins
	name = "Hyperacidity"
	desc = "Inhibits the infected's ability to process natural toxins, producing a buildup of said toxins."
	stage = 3
	max_multiplier = 3
	badness = 4

/datum/disease2/effect/toxins/activate(var/mob/living/carbon/mob)
	mob.adjustToxLoss((2*multiplier))


/datum/disease2/effect/shakey
	name = "World Shaking Syndrome"
	desc = "Attacks the infected's motor output, giving them a sense of vertigo."
	stage = 3
	max_multiplier = 3
	badness = 3

/datum/disease2/effect/shakey/activate(var/mob/living/carbon/mob)
	shake_camera(mob,5*multiplier)


/datum/disease2/effect/telepathic
	name = "Telepathy Syndrome"
	desc = "Unlocks a portion of the infected's brain that allows for telepathic communication."
	stage = 3
	badness = 0

/datum/disease2/effect/telepathic/activate(var/mob/living/carbon/mob)
	mob.dna.check_integrity()
	mob.dna.SetSEState(REMOTETALKBLOCK,1)
	domutcheck(mob, null)

/datum/disease2/effect/mind
	name = "Lazy Mind Syndrome"
	desc = "Rots the infected's brain."
	stage = 3
	badness = 4

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
	desc = "Induces hallucination in the infected."
	stage = 3
	badness = 3

/datum/disease2/effect/hallucinations/activate(var/mob/living/carbon/mob)
	mob.hallucination += 25


/datum/disease2/effect/deaf
	name = "Hard of Hearing Syndrome"
	desc = "Attacks the infected's aural senses."
	stage = 3
	badness = 3

/datum/disease2/effect/deaf/activate(var/mob/living/carbon/mob)
	mob.ear_deaf = 5


/datum/disease2/effect/giggle
	name = "Uncontrolled Laughter Effect"
	desc = "Gives the infected a sense of humor."
	stage = 3
	badness = 1

/datum/disease2/effect/giggle/activate(var/mob/living/carbon/mob)
	mob.say("*giggle")


/datum/disease2/effect/chickenpox
	name = "Chicken Pox"
	desc = "Causes the infected to begin coughing up eggs of the poultry variety."
	stage = 3
	badness = 2

/datum/disease2/effect/chickenpox/activate(var/mob/living/carbon/mob)
	if (prob(30))
		mob.say(pick("BAWWWK!", "BAAAWWK!", "CLUCK!", "CLUUUCK!", "BAAAAWWWK!"))
	if (prob(15))
		mob.emote("me",1,"vomits up a chicken egg!")
		playsound(mob.loc, 'sound/effects/splat.ogg', 50, 1)
		new /obj/item/weapon/reagent_containers/food/snacks/egg(get_turf(mob))


/datum/disease2/effect/confusion
	name = "Topographical Cretinism"
	desc = "Attacks the infected's ability to differentiate left and right."
	stage = 3
	badness = 3

/datum/disease2/effect/confusion/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class='notice'>You have trouble telling right and left apart all of a sudden.</span>")
	mob.confused += 10


/datum/disease2/effect/mutation
	name = "DNA Degradation"
	desc = "Attacks the infected's DNA, causing it to break down."
	stage = 3
	badness = 5

/datum/disease2/effect/mutation/activate(var/mob/living/carbon/mob)
	mob.apply_damage(2, CLONE)


/datum/disease2/effect/groan
	name = "Groaning Syndrome"
	desc = "Causes the infected to groan randomly."
	stage = 3
	badness = 1

/datum/disease2/effect/groan/activate(var/mob/living/carbon/mob)
	mob.say("*groan")


/datum/disease2/effect/sweat
	name = "Hyper-perspiration Effect"
	desc = "Causes the infected's sweat glands to go into overdrive."
	stage = 3
	badness = 3

/datum/disease2/effect/sweat/activate(var/mob/living/carbon/mob)
	if(prob(30))
		mob.emote("me",1,"is sweating profusely!")

		if(istype(mob.loc,/turf/simulated))
			var/turf/simulated/T = mob.loc
			T.wet(800, TURF_WET_WATER)


/datum/disease2/effect/elvis
	name = "Elvisism"
	desc = "Makes the infected the king of rock and roll."
	stage = 3
	badness = 3

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

		if(H.species.name == "Human" && !(H.my_appearance.f_style == "Pompadour"))
			spawn(50)
				H.my_appearance.h_style = "Pompadour"
				H.update_hair()

		if(H.species.name == "Human" && !(H.my_appearance.f_style == "Elvis Sideburns"))
			spawn(50)
				H.my_appearance.f_style = "Elvis Sideburns"
				H.update_hair()

/datum/disease2/effect/elvis/deactivate(var/mob/living/carbon/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/dude = mob
		if(istype(dude.glasses, /obj/item/clothing/glasses/sunglasses/virus))
			dude.glasses.canremove = 1
			dude.u_equip(dude.glasses,1)


/datum/disease2/effect/pthroat
	name = "Pierrot's Throat"
	desc = "Overinduces a sense of humor in the infected, causing them to be overcome by the spirit of a clown."
	stage = 3
	badness = 3

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
	desc = "Inhibits communication from the infected through spontaneous generation of a horse mask."
	stage = 3
	badness = 3

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
	desc = "Causes the infected to believe they are the center of the universe. Outcome may vary depending on symptom strength."
	stage = 3
	var/triggered = 0
	var/given_katana = 0
	affect_voice = 1
	max_multiplier = 4
	badness = 2

/datum/disease2/effect/anime_hair/activate(var/mob/living/carbon/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/affected = mob
		if(!triggered)
			var/list/hair_colors = list("pink","red","green","blue","purple")
			var/hair_color = pick(hair_colors)

			switch(hair_color)
				if("pink")
					affected.my_appearance.b_hair = 153
					affected.my_appearance.g_hair = 102
					affected.my_appearance.r_hair = 255
				if("red")
					affected.my_appearance.b_hair = 0
					affected.my_appearance.g_hair = 0
					affected.my_appearance.r_hair = 255
				if("green")
					affected.my_appearance.b_hair = 0
					affected.my_appearance.g_hair = 255
					affected.my_appearance.r_hair = 0
				if("blue")
					affected.my_appearance.b_hair = 255
					affected.my_appearance.g_hair = 0
					affected.my_appearance.r_hair = 0
				if("purple")
					affected.my_appearance.b_hair = 102
					affected.my_appearance.g_hair = 0
					affected.my_appearance.r_hair = 102
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
	desc = "Causes the infected to synthesize industrial grade lubrication from their feet."
	stage = 3
	max_multiplier = 9.5 //Potential for 95% lube chance per step
	badness = 4
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


/datum/disease2/effect/butterfly_skin
	name = "Epidermolysis Bullosa"
	desc = "Inhibits the strength of the infected's skin, causing it to tear on contact."
	stage = 3
	max_count = 1
	badness = 4
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
		to_chat(mob, "<span class='notice'>Your skin feels nice and durable again!</span>")
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


/datum/disease2/effect/thick_blood
	name = "Hyper-Fibrinogenesis"
	desc = "Causes the infected to oversynthesize coagulant."
	stage = 3
	badness = 0
	var/skip = FALSE

/datum/disease2/effect/thick_blood/activate(var/mob/living/carbon/mob)
	if(skip)
		return
	var/mob/living/carbon/human/H = mob
	if(ishuman(H))
		if(H.species && (H.species.anatomy_flags & NO_BLOOD))	//Can't have thick blood if you don't have blood at all.
			skip = TRUE
			return
	if (H.reagents.get_reagent_amount(CLOTTING_AGENT) < 5)
		H.reagents.add_reagent(CLOTTING_AGENT, 5)
		if (ishuman(H))
			for (var/datum/organ/external/E in H.organs)
				if (E.status & ORGAN_BLEEDING)
					to_chat(mob, "<span class = 'notice'>You feel your wounds rapidly scabbing over.</span>")
					break


/datum/disease2/effect/teratoma
	name = "Teratoma Syndrome"
	desc = "Causes the infected to oversynthesize stem cells engineered towards organ generation. Said generated organs are expelled from the body upon completion."
	stage = 3
	badness = 1

/datum/disease2/effect/teratoma/activate(var/mob/living/carbon/mob)
	var/organ_type = pick(existing_typesof(/obj/item/organ/internal) + /obj/item/stack/teeth)
	var/obj/item/spawned_organ = new organ_type(get_turf(mob))
	mob.visible_message("<span class='warning'>\A [spawned_organ.name] is extruded from \the [mob]'s body and falls to the ground!</span>","<span class='warning'>\A [spawned_organ.name] is extruded from your body and falls to the ground!</span>")

/datum/disease2/effect/multiarm
	name = "Polymelia Syndrome"
	desc = "Causes the infected to oversynthesize stem cells engineered towards limb generation. This results in additional grasping organs sprouting from the infected."
	stage = 3
	max_multiplier = 3
	badness = 0
	var/activated = FALSE

/datum/disease2/effect/multiarm/activate(var/mob/living/carbon/mob)
	if(activated)
		return
	var/hand_amount = round(multiplier)
	mob.visible_message("<span class='warning'>[mob.take_blood(null, rand(4,12)) ? "With a spray of blood, " : ""][hand_amount > 1 ? "[hand_amount] more arms sprout" : "a new arm sprouts"] from \the [mob]!</span>","<span class='notice'>[hand_amount] more arms burst forth from your back!</span>")
	mob.set_hand_amount(mob.held_items.len + hand_amount)
	blood_splatter(mob.loc,mob,TRUE)
	activated = TRUE

/datum/disease2/effect/multiarm/deactivate(var/mob/living/carbon/mob)
	if(!activated)
		return
	var/hand_amount = round(multiplier)
	mob.visible_message("<span class='notice'>The arms sticking out of \the [mob]'s back shrivel up and fall off!</span>", "<span class='warning'>Your new arms begin to die off, as the virus can no longer support them.</span>")
	mob.set_hand_amount(mob.held_items.len - hand_amount)
	for(var/i = 1 to hand_amount)
		var/r_or_l = pick("right","left")
		var/obj/item/organ/external/E
		var/obj/item/organ/external/EE
		if(r_or_l == "right")
			E = new /obj/item/organ/external/r_arm(mob.loc, mob)
			EE = new /obj/item/organ/external/r_hand(mob.loc, mob)
		else
			E = new /obj/item/organ/external/l_arm(mob.loc, mob)
			EE = new /obj/item/organ/external/l_hand(mob.loc, mob)
		E.add_child(EE)
		E.throw_at(get_step(src,pick(alldirs)), rand(1,4), rand(1,3))
	..()


/datum/disease2/effect/catvision
	name = "Cattulism Syndrome"
	desc = "Optimizes the infected's ocular ability to process light, aiding in seeing in the dark."
	stage = 3
	max_count = 9
	chance = 7
	max_chance = 14
	badness = 0
	var/night_vision_strength = 0

/datum/disease2/effect/catvision/activate(var/mob/living/carbon/mob)
	night_vision_strength = mob.see_in_dark

	if (mob.see_in_dark_override < 9)
		mob.see_in_dark_override = night_vision_strength + 1
		if (count == 1)
			to_chat(mob, "<span class = 'notice'>Your pupils dilate as they adjust for low-light environments.</span>")
		else
			to_chat(mob, "<span class = 'notice'>Your pupils dilate further.</span>")

