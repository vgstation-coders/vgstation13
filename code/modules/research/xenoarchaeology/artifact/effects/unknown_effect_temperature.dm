
/datum/artifact_effect/temperature
	effecttype = "temperature"
	valid_artifact_styles = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_MARTIAN)
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA)
	var/target_temp = T20C
	copy_for_battery = list("target_temp")
	effect_hint = EFFECT_HINT_INTERDIMENSIONAL_BLUESPACE_PHASING

/datum/artifact_effect/temperature/New()
	..()
	target_temp = rand(0, 600)//It might freeze a zone, heat it up, or keep it at room temperature.

/datum/artifact_effect/temperature/DoEffectTouch(var/mob/user)
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env && (env.temperature != target_temp))
			if (env.temperature > target_temp)
				env.temperature = max(env.temperature - rand(5,50), target_temp)
			else
				env.temperature = min(env.temperature + rand(5,50), target_temp)
			env.update_values()

/datum/artifact_effect/temperature/DoEffectAura()
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env && (env.temperature != target_temp))
			if (env.temperature > target_temp)
				env.temperature = max(env.temperature - 1, target_temp)
			else
				env.temperature = min(env.temperature + 1, target_temp)
			env.update_values()
