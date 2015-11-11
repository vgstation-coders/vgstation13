/datum/clockcult_power/sentinels_comprimise
	name				= "Sentinel's Comprimise"
	desc				= "Before reciting, a nearby allied cultist must be selected from a list. Heals all brute and burn damage and mends wounds on the given target, but causes debilitating pain based on how much was healed, and converts 45% of the basic damage healed to toxins."

	invocation			= "Zraq zr vawhel."
	cast_time			= 3 SECONDS
	req_components		= list(CLOCK_VANGUARD = 2)

/datum/clockcult_power/sentinels_comprimise/activate(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
	var/list/possible_cultists = list()
	for(var/mob/living/M in range(8, user)) //Add potential candidates.
		if(!isclockcult(M))
			continue

		if(M.stat == DEAD)
			continue

		possible_cultists += M
	
	if(!possible_cultists.len) //Nobody found.
		user << "<span class='clockwork'>You need to stand next to someone to heal!</span>"
		return 1

	var/mob/living/selected = input(user, "Who do you want do heal?", "Sentinel's Comprimise") as null | mob in possible_cultists
	if(!selected || !isclockcult(selected))
		return 1 //No message, they'll know what happened.

	var/damage = selected.getBruteLoss() + selected.getFireLoss()
	if(!damage) // No point.
		user << "<span class='clockwork'>[selected] is not injured!</span>"
		return 1

	selected.adjustBruteLoss(selected.getBruteLoss())
	selected.adjustFireLoss(selected.getFireLoss())
	selected.adjustToxLoss(damage * 0.45)

	if(ishuman(selected))
		var/mob/living/carbon/human/H = selected
		for(var/datum/organ/external/O in H.organs)
			if(O.brute_dam || O.burn_dam)
				H.pain(O, (O.brute_dam + O.burn_dam), 1, 1)
				O.heal_damage(O.brute_dam, O.burn_dam, 1, 1)

	user << "<span class='clockwork'>You mend [selected]'s wounds.</span>"
	selected << "<span class='clockwork'>[user] painfully mends your wounds, and a strong desire to vomit arises.</span>"
	if(prob(25))
		if(ishuman(selected))
			var/mob/living/carbon/human/H = selected
			H.vomit()
		selected << "<span class='warning'>...and so, you do.</span>"
