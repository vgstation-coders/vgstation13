// MEDICAL SIDE EFFECT BASE
// ========================
/datum/medical_effect/var/name = "None"
/datum/medical_effect/var/strength = 0
/datum/medical_effect/proc/on_life(mob/living/carbon/human/H, strength)
/datum/medical_effect/proc/cure(mob/living/carbon/human/H)



// MOB HELPERS
// ===========
/mob/living/carbon/human/var/list/datum/medical_effect/side_effects = list()
/mob/proc/add_side_effect(name, strength = 0)
/mob/living/carbon/human/add_side_effect(name, strength = 0)
	for(var/datum/medical_effect/M in src.side_effects) if(M.name == name)
		M.strength = max(M.strength, 10)
		return

	var/list/L = typesof(/datum/medical_effect)-/datum/medical_effect

	for(var/T in L)
		var/datum/medical_effect/M = new T
		if(M.name == name)
			M.strength = strength
			side_effects += M

/mob/living/carbon/human/proc/handle_medical_side_effects()
	if(src.reagents.has_reagent(CRYOXADONE) || src.reagents.get_reagent_amount(BICARIDINE) >= 15 || src.reagents.get_reagent_amount(TRICORDRAZINE) >= 15)
		src.add_side_effect("Headache")

	if(src.reagents.get_reagent_amount(KELOTANE) >= 30 || src.reagents.get_reagent_amount(DERMALINE) >= 15)
		src.add_side_effect("Bad Stomach")

	if(src.reagents.get_reagent_amount(TRAMADOL) >= 16 || src.reagents.get_reagent_amount(ANTI_TOXIN) >= 30)
		src.add_side_effect("Cramps")

	if(src.reagents.get_reagent_amount(SPACE_DRUGS) >= 10)
		src.add_side_effect("Itch")

	// One full cycle(in terms of strength) every 10 minutes
	var/strength_percent = sin(life_tick / 2)

	// Only do anything if the effect is currently strong enough
	if(strength_percent >= 0.4)
		for (var/datum/medical_effect/M in side_effects)
			if (M.cure(src) || M.strength > 60)
				side_effects -= M
				qdel(M)
			else
				if(life_tick % 45 == 0)
					M.on_life(src, strength_percent*M.strength)
				// Effect slowly growing stronger
				M.strength+=0.08

// HEADACHE
// ========
/datum/medical_effect/headache/name = "Headache"
/datum/medical_effect/headache/on_life(mob/living/carbon/human/H, strength)
	switch(strength)
		if(1 to 10)
			H.custom_pain("You feel a light pain in your head.",0)
		if(11 to 30)
			H.custom_pain("You feel a throbbing pain in your head!",1)
		if(31 to 50)
			H.custom_pain("You feel an excruciating pain in your head!",1)
			H.adjustBrainLoss(1)
		if(51 to INFINITY)
			H.custom_pain("It feels like your head is about to split open!",1)
			H.adjustBrainLoss(3)
			var/datum/organ/external/O = H.organs_by_name[LIMB_HEAD]
			O.take_damage(0, 1, 0, "Headache")

/datum/medical_effect/headache/cure(mob/living/carbon/human/H)
	if(H.reagents.has_reagent(ALKYSINE) || H.reagents.has_reagent(TRAMADOL))
//		to_chat(H, "<span class='warning'>Your head stops throbbing..</span>")// Halt spam.

		return 1
	return 0

// BAD STOMACH
// ===========
/datum/medical_effect/bad_stomach/name = "Bad Stomach"
/datum/medical_effect/bad_stomach/on_life(mob/living/carbon/human/H, strength)
	switch(strength)
		if(1 to 10)
			H.custom_pain("You feel a bit light around the stomach.",0)
		if(11 to 30)
			H.custom_pain("Your stomach hurts.",0)
		if(31 to 50)
			H.custom_pain("You feel sick.",1)
			H.adjustToxLoss(1)
		if(51 to INFINITY)
			H.custom_pain("You can't hold it in any longer!",1)
			H.vomit()

/datum/medical_effect/bad_stomach/cure(mob/living/carbon/human/H)
	if(H.reagents.has_any_reagents(ANTI_TOXINS))
		to_chat(H, "<span class='warning'>Your stomach feels a little better now..</span>")
		return 1
	return 0


// CRAMPS
// ======
/datum/medical_effect/cramps/name = "Cramps"
/datum/medical_effect/cramps/on_life(mob/living/carbon/human/H, strength)
	switch(strength)
		if(1 to 10)
			H.custom_pain("The muscles in your body hurt a little.",0)
		if(11 to 30)
			H.custom_pain("The muscles in your body cramp up painfully.",0)
		if(31 to 50)
			H.emote("me",1,"flinches as all the muscles in their body cramp up.")
			H.custom_pain("There's pain all over your body.",1)
			H.adjustToxLoss(1)
		if(51 to INFINITY)
			H.emote("me",1,"flinches as all the muscles in their body cramp up.")
			H.custom_pain("It feels as though your muscles are being ripped apart!",1)
			H.apply_damage(1, used_weapon = "Cramps")

/datum/medical_effect/cramps/cure(mob/living/carbon/human/H)
	if(H.reagents.has_reagent(INAPROVALINE))
		to_chat(H, "<span class='warning'>The cramps let up..</span>")
		return 1
	return 0

// ITCH
// ====
/datum/medical_effect/itch/name = "Itch"
/datum/medical_effect/itch/on_life(mob/living/carbon/human/H, strength)
	switch(strength)
		if(1 to 10)
			H.custom_pain("You feel a slight itch.",0)
		if(11 to 30)
			H.custom_pain("You want to scratch your itch badly.",0)
		if(31 to 50)
			H.emote("me",1,"shivers slightly.")
			H.custom_pain("This itch makes it really hard to concentrate.",1)
			H.adjustToxLoss(1)
		if(51 to INFINITY)
			H.emote("me",1,"shivers.")
			H.custom_pain("The itch starts hurting and oozing blood.",1)
			H.apply_damage(1, BURN, used_weapon = "Itch")
			H.drip(1)

/datum/medical_effect/itch/cure(mob/living/carbon/human/H)
	if(H.reagents.has_reagent(INAPROVALINE))
		to_chat(H, "<span class='warning'>The itching stops..</span>")
		return 1
	return 0
