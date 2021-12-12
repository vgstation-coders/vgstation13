/datum/disease2/effect/toxins
	name = "Hyperacidity"
	desc = "Inhibits the infected's ability to process natural toxins, producing a buildup of said toxins."
	stage = 3
	max_multiplier = 3
	badness = EFFECT_DANGER_HARMFUL

/datum/disease2/effect/toxins/activate(var/mob/living/mob)
	mob.adjustToxLoss((2*multiplier))


/datum/disease2/effect/shakey
	name = "World Shaking Syndrome"
	desc = "Attacks the infected's motor output, giving them a sense of vertigo."
	stage = 3
	max_multiplier = 3
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/shakey/activate(var/mob/living/mob)
	shake_camera(mob,5*multiplier)


/datum/disease2/effect/telepathic
	name = "Telepathy Syndrome"
	desc = "Unlocks a portion of the infected's brain that allows for telepathic communication."
	stage = 3
	max_count = 1
	badness = EFFECT_DANGER_HELPFUL

/datum/disease2/effect/telepathic/activate(var/mob/living/mob)
	if (mob.dna)
		mob.dna.check_integrity()
		mob.dna.SetSEState(REMOTETALKBLOCK,1)
		domutcheck(mob, null)

/datum/disease2/effect/mind
	name = "Lazy Mind Syndrome"
	desc = "Rots the infected's brain."
	stage = 3
	badness = EFFECT_DANGER_HARMFUL

/datum/disease2/effect/mind/activate(var/mob/living/mob)
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
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/hallucinations/activate(var/mob/living/mob)
	mob.hallucination += 25

/datum/disease2/effect/giggle
	name = "Uncontrolled Laughter Effect"
	desc = "Gives the infected a sense of humor."
	stage = 3
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/giggle/activate(var/mob/living/mob)
	mob.emote("giggle")


/datum/disease2/effect/chickenpox
	name = "Chicken Pox"
	desc = "Causes the infected to begin coughing up eggs of the poultry variety."
	stage = 3
	badness = EFFECT_DANGER_ANNOYING

/datum/disease2/effect/chickenpox/activate(var/mob/living/mob)
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
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/confusion/activate(var/mob/living/mob)
	to_chat(mob, "<span class='notice'>You have trouble telling right and left apart all of a sudden.</span>")
	mob.confused += 10


/datum/disease2/effect/mutation
	name = "DNA Degradation"
	desc = "Attacks the infected's DNA, causing it to break down."
	stage = 3
	badness = EFFECT_DANGER_DEADLY

/datum/disease2/effect/mutation/activate(var/mob/living/mob)
	mob.apply_damage(2, CLONE)


/datum/disease2/effect/groan
	name = "Groaning Syndrome"
	desc = "Causes the infected to groan randomly."
	stage = 3
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/groan/activate(var/mob/living/mob)
	mob.emote("groan")


/datum/disease2/effect/sweat
	name = "Hyper-perspiration Effect"
	desc = "Causes the infected's sweat glands to go into overdrive."
	stage = 3
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/sweat/activate(var/mob/living/mob)
	if(prob(30))
		mob.emote("me",1,"is sweating profusely!")

		if(istype(mob.loc,/turf/simulated))
			var/turf/simulated/T = mob.loc
			T.wet(800, TURF_WET_WATER)


/datum/disease2/effect/elvis
	name = "Elvisism"
	desc = "Makes the infected the king of rock and roll."
	stage = 3
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/elvis/activate(var/mob/living/mob)
	if(!ishuman(mob))
		return

	var/mob/living/carbon/human/H = mob
	var/obj/item/clothing/glasses/H_glasses = H.get_item_by_slot(slot_glasses)

	if(!istype(H_glasses, /obj/item/clothing/glasses/sunglasses/virus))
		var/obj/item/clothing/glasses/sunglasses/virus/virussunglasses = new
		mob.u_equip(H_glasses,1)
		mob.equip_to_slot(virussunglasses, slot_glasses)
	mob.confused += 10

	if(prob(50))
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

/datum/disease2/effect/elvis/deactivate(var/mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/dude = mob
		if(istype(dude.glasses, /obj/item/clothing/glasses/sunglasses/virus))
			dude.glasses.canremove = 1
			dude.u_equip(dude.glasses,1)


/datum/disease2/effect/pthroat
	name = "Pierrot's Throat"
	desc = "Overinduces a sense of humor in the infected, causing them to be overcome by the spirit of a clown."
	stage = 3
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/pthroat/activate(var/mob/living/mob)
	//
	var/obj/item/clothing/mask/gas/clown_hat/virus/virusclown_hat = new /obj/item/clothing/mask/gas/clown_hat/virus
	if(mob.wear_mask && !istype(mob.wear_mask, /obj/item/clothing/mask/gas/clown_hat/virus))
		mob.u_equip(mob.wear_mask,1)
		mob.equip_to_slot(virusclown_hat, slot_wear_mask)
	if(!mob.wear_mask)
		mob.equip_to_slot(virusclown_hat, slot_wear_mask)
	mob.reagents.add_reagent(PSILOCYBIN, 20)
	mob.say(pick("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk..."))

/datum/disease2/effect/horsethroat
	name = "Horse Throat"
	desc = "Inhibits communication from the infected through spontaneous generation of a horse mask."
	stage = 3
	badness = EFFECT_DANGER_HINDRANCE
	var/list/compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)

/datum/disease2/effect/horsethroat/activate(var/mob/living/mob)


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
	max_count = 1
	var/given_katana = 0
	affect_voice = 1
	max_multiplier = 4
	badness = EFFECT_DANGER_ANNOYING
	var/old_r = 0
	var/old_g = 0
	var/old_b = 0

/datum/disease2/effect/anime_hair/activate(var/mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/affected = mob
		var/list/hair_colors = list("pink","red","green","blue","purple")
		var/hair_color = pick(hair_colors)

		old_r = affected.my_appearance.b_hair
		old_g = affected.my_appearance.g_hair
		old_b = affected.my_appearance.r_hair

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
					var/obj/item/clothing/head/kitty/anime/cursed/kitty_c = new /obj/item/clothing/head/kitty/anime/cursed
					if(affected.head && !istype(affected.head, /obj/item/clothing/head/kitty/anime/cursed))
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

/datum/disease2/effect/anime_hair/deactivate(var/mob/living/mob)
	to_chat(mob, "<span class = 'notice'>You no longer feel quite like the main character. </span>")
	if (ishuman(mob))
		var/mob/living/carbon/human/affected = mob
		if(affected.shoes && istype(affected.shoes, /obj/item/clothing/shoes/kneesocks))
			affected.shoes.canremove = 1
		if(affected.w_uniform && istype(affected.w_uniform, /obj/item/clothing/under/schoolgirl))
			affected.w_uniform.canremove = 1

		affected.my_appearance.b_hair = old_r
		affected.my_appearance.g_hair = old_g
		affected.my_appearance.r_hair = old_b

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
	badness = EFFECT_DANGER_HARMFUL
	max_count = 1

/datum/disease2/effect/lubefoot/activate(var/mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/affected = mob
		if(multiplier > 1.5 && !count)
			to_chat(affected, "You feel slightly more inept than usual.")
			affected.dna.check_integrity()
			affected.dna.SetSEState(CLUMSYBLOCK,1)
			domutcheck(mob, null)
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

/datum/disease2/effect/lubefoot/deactivate(var/mob/living/mob)
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
	badness = EFFECT_DANGER_HARMFUL
	var/skip = FALSE

/datum/disease2/effect/butterfly_skin/activate(var/mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(H.species && (H.species.anatomy_flags & NO_SKIN))	//Can't have fragile skin if you don't have skin at all.
			skip = TRUE
			return
	to_chat(mob, "<span class='warning'>Your skin feels a little fragile.</span>")

/datum/disease2/effect/butterfly_skin/deactivate(var/mob/living/mob)
	if(!skip)
		to_chat(mob, "<span class='notice'>Your skin feels nice and durable again!</span>")
	..()

/datum/disease2/effect/butterfly_skin/on_touch(var/mob/living/mob, var/toucher, var/touched, var/touch_type)
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
	badness = EFFECT_DANGER_HELPFUL
	var/skip = FALSE

/datum/disease2/effect/thick_blood/activate(var/mob/living/mob)
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
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/teratoma/activate(var/mob/living/mob)
	var/organ_type = pick(existing_typesof(/obj/item/organ/internal) + /obj/item/stack/teeth)
	var/obj/item/spawned_organ = new organ_type(get_turf(mob))
	mob.visible_message("<span class='warning'>\A [spawned_organ.name] is extruded from \the [mob]'s body and falls to the ground!</span>","<span class='warning'>\A [spawned_organ.name] is extruded from your body and falls to the ground!</span>")

/datum/disease2/effect/multiarm
	name = "Polymelia Syndrome"
	desc = "Causes the infected to oversynthesize stem cells engineered towards limb generation. This results in additional grasping organs sprouting from the infected."
	stage = 3
	max_multiplier = 3
	badness = EFFECT_DANGER_HELPFUL
	max_count = 1

/datum/disease2/effect/multiarm/activate(var/mob/living/mob)
	var/hand_amount = round(multiplier)
	mob.visible_message("<span class='warning'>[mob.take_blood(null, rand(4,12)) ? "With a spray of blood, " : ""][hand_amount > 1 ? "[hand_amount] more arms sprout" : "a new arm sprouts"] from \the [mob]!</span>","<span class='notice'>[hand_amount] more arms burst forth from your back!</span>")
	mob.set_hand_amount(mob.held_items.len + hand_amount)
	blood_splatter(mob.loc,mob,TRUE)

/datum/disease2/effect/multiarm/deactivate(var/mob/living/mob)
	if(!count)
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
	badness = EFFECT_DANGER_HELPFUL
	var/night_vision_strength = 0

/datum/disease2/effect/catvision/activate(var/mob/living/mob)
	night_vision_strength = mob.see_in_dark

	if (mob.see_in_dark_override < 9)
		mob.see_in_dark_override = night_vision_strength + 1
		if (count == 0)
			to_chat(mob, "<span class = 'notice'>Your pupils dilate as they adjust for low-light environments.</span>")
		else if (count == 6)
			to_chat(mob, "<span class = 'notice'>Your pupils reach their maximum dilation.</span>")
			mob.see_in_dark_override = 9
		else
			to_chat(mob, "<span class = 'notice'>Your pupils dilate further.</span>")

/datum/disease2/effect/colorsmoke
	name = "Colorful Syndrome"
	desc = "Causes the infected to synthesize smoke & rainbow colourant."
	stage = 3
	badness = EFFECT_DANGER_HINDRANCE

/datum/disease2/effect/colorsmoke/activate(var/mob/living/mob)
	if (ismouse(mob))//people don't like infected mice ruining maint
		var/mob/living/simple_animal/mouse/M = mob
		if (!initial(M.infectable))
			return
	to_chat(mob, "<span class='notice'>You feel colorful!</span>")
	mob.reagents.add_reagent(COLORFUL_REAGENT, 5)
	mob.reagents.add_reagent(PAISMOKE, 5)

/datum/disease2/effect/cleansmoke
	name = "Cleaning Syndrome"
	desc = "Causes the infected to synthesize smoke & space cleaner."
	stage = 3
	badness = EFFECT_DANGER_HELPFUL

/datum/disease2/effect/cleansmoke/activate(var/mob/living/mob)
	to_chat(mob, "<span class='notice'>You feel clean!</span>")
	mob.reagents.add_reagent(CLEANER, 5)
	mob.reagents.add_reagent(PAISMOKE, 5)

/datum/disease2/effect/chimera
	name = "Chimeral Xenosis"
	desc = "Causes the infected's body to gradually mutate into a chimera of different alien species."
	encyclopedia = "Stronger strains will cause more gruesome mutations in the infected. Extremely strong strains will mutate internal organs."
	stage = 3
	badness = EFFECT_DANGER_HINDRANCE
	chance = 1
	max_multiplier = 3

/datum/disease2/effect/chimera/activate(var/mob/living/mob)
	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/H = mob

	var/list/valid_species = list("Human", "Unathi", "Tajaran", "Grey", "Skrell", "Vox", "Diona", "Slime", "Mushroom")
	var/list/species_rare = list("Manifested", "Skellington", "Skeletal Vox", "Muton", "Golem", "Grue", "Ghoul", "Lich")
	var/species_mult = clamp(multiplier - 1, 0, 1)
	for(var/S in species_rare)
		if(prob(100*species_mult))
			valid_species += S
	valid_species.Remove(H.species.name)

	var/limb_probability = min(100, 160 - (30*multiplier))

	if(prob(limb_probability)) //most of the time, depending on the multiplier, we'll replace limbs
		var/list/valid_organs = new()
		for(var/datum/organ/external/E in H.organs)
			if((!E.species || E.species == H.species) && !E.is_robotic())
				valid_organs += E
		if(!valid_organs.len)
			return //all our organs are already replaced
		var/datum/organ/external/E = pick(valid_organs)
		E.species = all_species[pick(valid_species)]
		H.update_body()
		//to_chat(mob, "<span class='notice'>Your [E.display_name] feels foreign.</span>")
	else //the rest of the time we replace internal organs
		var/list/valid_organs = new()
		for(var/datum/organ/internal/I in H.internal_organs)
			if(I.name != "brain" && !I.robotic && ispath(H.species.has_organ[I.organ_type], I))
				valid_organs += I
		if(!valid_organs.len)
			return //all our organs are already replaced

		var/datum/organ/internal/old_organ = pick(valid_organs)
		var/list/valid_replacement_organs = new()
		for(var/I_type in subtypesof(/datum/organ/internal))
			var/datum/organ/internal/I = new I_type()
			if((I.organ_type == old_organ.organ_type) && (I.type != old_organ.type) && !I.robotic)
				valid_replacement_organs += I
		if(!valid_replacement_organs.len)
			return //nothing interesting to replace with

		var/datum/organ/internal/new_organ = pick(valid_replacement_organs)

		//remove the old organ
		var/obj/item/organ/internal/old_organ_item = H.remove_internal_organ(H, old_organ, H.organs_by_name[old_organ.parent_organ])
		qdel(old_organ_item)

		//insert the new organ
		new_organ.transplant_data = list()
		new_organ.transplant_data["species"] =    H.species.name
		new_organ.transplant_data["blood_type"] = H.dna.b_type
		new_organ.transplant_data["blood_DNA"] =  H.dna.unique_enzymes
		new_organ.owner = H
		H.internal_organs_by_name[new_organ.organ_type] = new_organ
		H.internal_organs |= new_organ
		H.organs_by_name[new_organ.parent_organ].internal_organs |= new_organ
		new_organ.Insert(H)

		to_chat(mob, "<span class='warning'>You feel a foreign sensation in your [new_organ.parent_organ].")


/datum/disease2/effect/damage_converter
	name = "Toxic Compensation"
	desc = "Stimulates cellular growth within the body, causing it to regenerate tissue damage. Repair done by these cells causes toxins to build up in the body."
	encyclopedia = "Manipulation of the symptom's strength can be used to either reduce or amplify the toxic feedback."
	badness = EFFECT_DANGER_FLAVOR
	stage = 3
	chance = 10
	max_chance = 50
	multiplier = 5
	max_multiplier = 10

/datum/disease2/effect/damage_converter/activate(var/mob/living/mob)
	if(mob.getFireLoss() > 0 || mob.getBruteLoss() > 0)
		var/get_damage = rand(1, 3)
		mob.adjustFireLoss(-get_damage)
		mob.adjustBruteLoss(-get_damage)
		mob.adjustToxLoss(max(1,get_damage * multiplier / 5))

/datum/disease2/effect/cyborg_limbs
	name = "Metallica Syndrome"
	desc = "Rapidly replaces some organic tissue in the body, causing limbs and other organs to become robotic."
	stage = 3
	badness = EFFECT_DANGER_HARMFUL
	restricted = 2

/datum/disease2/effect/cyborg_limbs/activate(var/mob/living/mob)
	if(!ishuman(mob))
		return

	var/mob/living/carbon/human/H = mob

	var/list/valid_external_organs = list()
	for(var/datum/organ/external/E in H.organs)
		if(!E.is_robotic())
			valid_external_organs += E

	var/list/valid_internal_organs = list()
	for(var/datum/organ/internal/I in H.internal_organs)
		if(I.name != "brain" && !I.robotic)
			valid_internal_organs += I

	if(prob(75) && valid_external_organs.len)
		var/datum/organ/external/E = pick(valid_external_organs)
		E.robotize()
		H.update_body()
	else if(valid_internal_organs.len)

		var/datum/organ/internal/I = pick(valid_internal_organs)
		I.mechanize()
		to_chat(mob, "<span class='warning'>You feel a foreign sensation in your [I.parent_organ].")

/datum/disease2/effect/mommi_hallucination
	name = "Supermatter Syndrome"	//names suck
	desc = "Causes the infected to experience engineering-related hallucinations."
	stage = 3
	badness = EFFECT_DANGER_ANNOYING
	restricted = 2

/datum/disease2/effect/mommi_hallucination/activate(var/mob/living/mob)
	if(prob(50))
		mob << sound('sound/effects/supermatter.ogg')

	var/mob/living/silicon/robot/mommi/mommi = /mob/living/silicon/robot/mommi
	for(var/mob/living/M in viewers(mob))
		if(M == mob)
			continue

		var/image/crab = image(icon = null)
		crab.appearance = initial(mommi.appearance)

		crab.icon_state = "mommi-withglow"
		crab.loc = M
		crab.override = 1

		var/client/C = mob.client
		if(C)
			C.images += crab
		var/duration = rand(60 SECONDS, 120 SECONDS)

		spawn(duration)
			if(C)
				C.images.Remove(crab)

	var/list/turf_list = list()
	for(var/turf/T in spiral_block(get_turf(mob), 40))
		if(prob(4))
			turf_list += T
	if(turf_list.len)
		for(var/turf/simulated/floor/T in turf_list)
			var/image/supermatter = image('icons/obj/engine.dmi', T ,"darkmatter_shard", ABOVE_HUMAN_PLANE)

			var/client/C = mob.client
			if(C)
				C.images += supermatter
			var/duration = rand(60 SECONDS, 120 SECONDS)

			spawn(duration)
				if(C)
					C.images.Remove(supermatter)


/datum/disease2/effect/xenomorph_traits
	name = "Plasmatic Adaptation"
	desc = "Induces heavy mutation and optimization in the infected's cellular structure. The infected gains several physical abilities and an affinity for plasma."
	badness = EFFECT_DANGER_HELPFUL
	stage = 3
	restricted = 2
	var/datum/species/old_species
	var/activated

/datum/disease2/effect/xenomorph_traits/activate(var/mob/living/mob)
	if(!ishuman(mob))
		return
	if(activated)
		return
	var/mob/living/carbon/human/H = mob
	var/datum/species/S = H.species

	old_species = new S.type
	old_species.flags = S.flags
	old_species.attack_verb = S.attack_verb
	old_species.blood_color = S.blood_color
	old_species.punch_damage = S.punch_damage

	S.flags |= PLASMA_IMMUNE
	S.attack_verb = "claws"
	S.blood_color = "#05EE05"
	S.punch_damage = 12

	H.species = S
	H.mutations.Add(M_CLAWS, M_RUN, M_THERMALS)
	domutcheck(H,null,MUTCHK_FORCED)
	H.UpdateDamageIcon()
	H.copy_dna_data_to_blood_reagent()
	to_chat(mob, "<span class='sinister'>You feel different.</span>")
	activated = 1

/datum/disease2/effect/xenomorph_traits/deactivate(var/mob/living/mob)
	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/H = mob
	H.species = old_species
	H.change_sight(removing = SEE_MOBS)
	H.mutations.Remove(M_CLAWS, M_RUN, M_THERMALS)
	domutcheck(H,null,MUTCHK_FORCED)
	H.UpdateDamageIcon()
	H.copy_dna_data_to_blood_reagent()
	to_chat(mob, "<span class='warning'>You feel like your old self again.</span>")
	activated = 0


/datum/disease2/effect/wendigo_hallucination
	name = "Eldritch Mind Syndrome"
	desc = "UNKNOWN"
	badness = EFFECT_DANGER_HARMFUL
	stage = 3
	restricted = 2
	var/activated = 0

/datum/disease2/effect/wendigo_hallucination/activate(var/mob/living/mob)
	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/H = mob
	H.Jitter(100)
	if(!activated)
		mob.overlay_fullscreen("wendigoblur", /obj/abstract/screen/fullscreen/snowfall_blizzard)
		activated = 1
		if(!isskellington(H) && !islich(H))	//ignore skellingtons since they can only eat meat anyway
			H.species.chem_flags |= NO_EAT




	//creepy sounds copypasted from hallucination code
	var/list/possible_sounds = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/heart_beat_single.ogg', 'sound/effects/ear_ring_single.ogg', 'sound/effects/screech.ogg',\
		'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
		'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
		'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
		'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')
	mob << pick(possible_sounds)


/datum/disease2/effect/wendigo_hallucination/deactivate(var/mob/living/mob)
	mob.clear_fullscreen("wendigoblur", animate = 0)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(!isskellington(H) && !islich(H))	//ignore skellingtons since they can only eat meat anyway
			H.species.chem_flags &= ~NO_EAT
	activated = 0


/datum/disease2/effect/wendigo_hallucination/affect_mob_voice(var/datum/speech/speech)
	var/message = speech.message
	message = replacetext(message,"I","we")
	message = replacetext(message,"me","us")
	speech.message = message

/datum/disease2/effect/toothdecay
	name = "Piratitis Syndrome"
	desc = "Causes the infected to progressively lose their teeth and speak like a pirate."
	encyclopedia = "Symptom strength increases the chance of losing teeth, but the chance also goes down the less teeth the infected has."
	stage = 3
	badness = EFFECT_DANGER_HARMFUL
	affect_voice = 1
	multiplier = 1
	max_multiplier = 3

/datum/disease2/effect/toothdecay/activate(var/mob/living/mob)
	if (!count)
		to_chat(mob, "<span class='warning'>[pick("You feel like you could use a bottle o' rhum.","You feel like kidnapping the princess of Canada.")]</span>")
		affect_voice_active = 1
	if (ishuman(mob))
		var/mob/living/carbon/human/H = mob
		var/datum/butchering_product/teeth/T = locate(/datum/butchering_product/teeth) in H.butchering_drops
		if (prob((5 * T.amount / 32) * multiplier))
			H.knock_out_teeth()

/datum/disease2/effect/toothdecay/affect_mob_voice(var/datum/speech/speech)
	speech.message = piratespeech(speech.message)
