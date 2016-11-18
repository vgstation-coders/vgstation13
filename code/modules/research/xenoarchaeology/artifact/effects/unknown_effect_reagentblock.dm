/datum/artifact_effect/reagentblock
	effecttype = "reagentblock"
	var/duration = 0
	copy_for_battery = list("duration")

/datum/artifact_effect/reagentblock/New()
	..()
	effect_type = pick(5,7)
	duration = rand(600,6000)
	if(effect == EFFECT_AURA)
		effectrange = rand(1,5)

/datum/artifact_effect/reagentblock/DoEffectTouch(var/mob/living/user)
	var/weakness = GetAnomalySusceptibility(user)
	if(ishuman(user) && prob(weakness * 100))
		if(user.reagents.has_reagent(BLOCKIZINE))
			var/datum/reagent/existingblock = user.reagents.get_reagent(BLOCKIZINE)
			existingblock.data = world.time+duration
		else
			user.reagents.add_reagent(BLOCKIZINE,30,world.time+duration)

/datum/artifact_effect/reagentblock/DoEffectAura()
	if(holder)
		for(var/mob/living/carbon/human/H in range(effectrange,holder))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				if(H.reagents.has_reagent(BLOCKIZINE))
					var/datum/reagent/existingblock = H.reagents.get_reagent(BLOCKIZINE)
					existingblock.data = world.time+duration
				else
					H.reagents.add_reagent(BLOCKIZINE,30,world.time+duration)

/datum/artifact_effect/reagentblock/DoEffectPulse()
	if(holder)
		for(var/mob/living/carbon/human/H in range(effectrange,holder))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				if(H.reagents.has_reagent(BLOCKIZINE))
					var/datum/reagent/existingblock = H.reagents.get_reagent(BLOCKIZINE)
					existingblock.data = world.time+duration
				else
					H.reagents.add_reagent(BLOCKIZINE,30,world.time+duration)