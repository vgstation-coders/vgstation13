/datum/artifact_effect/darkness
	effecttype = "darkness"
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	var/dark_level
	copy_for_battery = list("dark_level")

/datum/artifact_effect/darkness/New()
	..()
	effect_type = pick(0,3,4)
	effectrange = rand(2,12)
	dark_level = rand(2,7)

/datum/artifact_effect/darkness/ToggleActivate()
	..()
	if(holder)
		if(!activated)
			holder.set_light(effectrange, -dark_level)
		else
			holder.set_light(0)