/obj/item/organ/stomach
	name = "stomach"
	icon_state = "stomach"
	w_class = WEIGHT_CLASS_NORMAL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_STOMACH
	attack_verb = list("gored", "squished", "slapped", "digested")
	desc = "Onaka ga suite imasu."
	var/disgust_metabolism = 1

/obj/item/organ/stomach/on_life()
	var/mob/living/carbon/human/H = owner

	if(istype(H))
		H.dna.species.handle_digestion(H)
		handle_disgust(H)

/obj/item/organ/stomach/proc/handle_disgust(mob/living/carbon/human/H)
	if(H.disgust)
		var/pukeprob = 5 + 0.05 * H.disgust
		if(H.disgust >= DISGUST_LEVEL_GROSS)
			if(prob(10))
				H.stuttering += 1
				H.confused += 2
			if(prob(10) && !H.stat)
				to_chat(H, "<span class='warning'>You feel kind of iffy...</span>")
			H.jitteriness = max(H.jitteriness - 3, 0)
		if(H.disgust >= DISGUST_LEVEL_VERYGROSS)
			if(prob(pukeprob)) //iT hAndLeS mOrE ThaN PukInG
				H.confused += 2.5
				H.stuttering += 1
				H.vomit(10, 0, 1, 0, 1, 0)
			H.Dizzy(5)
		if(H.disgust >= DISGUST_LEVEL_DISGUSTED)
			if(prob(25))
				H.blur_eyes(3) //We need to add more shit down here

		H.adjust_disgust(-0.5 * disgust_metabolism)
	switch(H.disgust)
		if(0 to DISGUST_LEVEL_GROSS)
			H.clear_alert("disgust")
			H.SendSignal(COMSIG_CLEAR_MOOD_EVENT, "disgust")
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			H.throw_alert("disgust", /obj/screen/alert/gross)
			H.SendSignal(COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/disgust/gross)
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			H.throw_alert("disgust", /obj/screen/alert/verygross)
			H.SendSignal(COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/disgust/verygross)
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			H.throw_alert("disgust", /obj/screen/alert/disgusted)
			H.SendSignal(COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/disgust/disgusted)

/obj/item/organ/stomach/Remove(mob/living/carbon/M, special = 0)
	var/mob/living/carbon/human/H = owner
	if(istype(H))
		H.clear_alert("disgust")
		H.SendSignal(COMSIG_CLEAR_MOOD_EVENT, "disgust")
	..()

/obj/item/organ/stomach/fly
	name = "insectoid stomach"
	icon_state = "stomach-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "A mutant stomach designed to handle the unique diet of a flyperson."

/obj/item/organ/stomach/plasmaman
	name = "digestive crystal"
	icon_state = "pstomach"
	desc = "A strange crystal that is responsible for metabolizing the unseen energy force that feeds plasmamen."
