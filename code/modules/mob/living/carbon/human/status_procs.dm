
/mob/living/carbon/human/Stun(amount, updating = 1, ignore_canstun = 0)
	amount = dna.species.spec_stun(src,amount)
	return ..()

/mob/living/carbon/human/Knockdown(amount, updating = 1, ignore_canknockdown = 0)
	amount = dna.species.spec_stun(src,amount)
	return ..()

/mob/living/carbon/human/Unconscious(amount, updating = 1, ignore_canunconscious = 0)
	amount = dna.species.spec_stun(src,amount)
	if(has_trait(TRAIT_HEAVY_SLEEPER))
		amount *= rand(1.25, 1.3)
	return ..()

/mob/living/carbon/human/Sleeping(amount, updating = 1, ignore_sleepimmune = 0)
	if(has_trait(TRAIT_HEAVY_SLEEPER))
		amount *= rand(1.25, 1.3)
	return ..()

/mob/living/carbon/human/cure_husk(list/sources)
	. = ..()
	if(.)
		update_hair()

/mob/living/carbon/human/become_husk(source)
	if(istype(dna.species, /datum/species/skeleton)) //skeletons shouldn't be husks.
		cure_husk()
		return
	. = ..()
	if(.)
		update_hair()

/mob/living/carbon/human/set_drugginess(amount)
	..()
	if(!amount)
		remove_language(/datum/language/beachbum)

/mob/living/carbon/human/adjust_drugginess(amount)
	..()
	if(!dna.check_mutation(STONER))
		if(druggy)
			grant_language(/datum/language/beachbum)
		else
			remove_language(/datum/language/beachbum)
