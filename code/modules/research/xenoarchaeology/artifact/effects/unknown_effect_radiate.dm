
/datum/artifact_effect/radiate
	effecttype = "radiate"
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	var/radiation_amount
	copy_for_battery = list("radiation_amount")

/datum/artifact_effect/radiate/New()
	..()
	radiation_amount = rand(1, 10)
	effect_type = pick(4,5)

/datum/artifact_effect/radiate/DoEffectTouch(var/mob/living/user)
	if(user)
		user.apply_radiation(radiation_amount * 5,RAD_INTERNAL)
		user.updatehealth()
		return 1

/datum/artifact_effect/radiate/DoEffectAura()
	if(holder)
		for (var/mob/living/M in range(src.effectrange,holder))
			M.apply_radiation(radiation_amount,RAD_INTERNAL)
			M.updatehealth()
		return 1

/datum/artifact_effect/radiate/DoEffectPulse()
	if(holder)
		for (var/mob/living/M in range(src.effectrange,holder))
			M.apply_radiation(radiation_amount * 25,RAD_INTERNAL)
			M.updatehealth()
		return 1
