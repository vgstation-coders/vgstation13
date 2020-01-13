/datum/artifact_effect/reagentblock
	effecttype = "reagentblock"
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	var/duration = 0
	copy_for_battery = list("duration")

/datum/artifact_effect/reagentblock/New()
	..()
	effect_type = pick(5,7)
	duration = rand(600,6000)
	if(effect == ARTIFACT_EFFECT_AURA)
		effectrange = rand(1,5)

/datum/artifact_effect/reagentblock/DoEffectTouch(var/mob/living/user)
	var/weakness = GetAnomalySusceptibility(user)
	if(iscarbon(user) && prob(weakness * 100))
		if(user.reagents.has_reagent(BLOCKIZINE))
			var/datum/reagent/existingblock = user.reagents.get_reagent(BLOCKIZINE)
			existingblock.data = world.time+duration
		else
			user.reagents.add_reagent(BLOCKIZINE,30,world.time+duration)

/datum/artifact_effect/reagentblock/DoEffectAura()
	if(holder)
		for(var/mob/living/carbon/C in range(effectrange,holder))
			var/weakness = GetAnomalySusceptibility(C)
			if(prob(weakness * 100))
				if(C.reagents.has_reagent(BLOCKIZINE))
					var/datum/reagent/existingblock = C.reagents.get_reagent(BLOCKIZINE)
					existingblock.data = world.time+duration
				else
					C.reagents.add_reagent(BLOCKIZINE,30,world.time+duration)

/datum/artifact_effect/reagentblock/DoEffectPulse()
	if(holder)
		for(var/mob/living/carbon/C in range(effectrange,holder))
			var/weakness = GetAnomalySusceptibility(C)
			if(prob(weakness * 100))
				if(C.reagents.has_reagent(BLOCKIZINE))
					var/datum/reagent/existingblock = C.reagents.get_reagent(BLOCKIZINE)
					existingblock.data = world.time+duration
				else
					C.reagents.add_reagent(BLOCKIZINE,30,world.time+duration)