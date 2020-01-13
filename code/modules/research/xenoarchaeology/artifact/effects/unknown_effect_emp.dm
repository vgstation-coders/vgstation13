
/datum/artifact_effect/emp
	effecttype = "emp"
	effect = ARTIFACT_EFFECT_PULSE
	effect_type = 3

/datum/artifact_effect/emp/DoEffectPulse()
	if(holder)
		empulse(get_turf(holder), effectrange/2, effectrange)
		return 1
