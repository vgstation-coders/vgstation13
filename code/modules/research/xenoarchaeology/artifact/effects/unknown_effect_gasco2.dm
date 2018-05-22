
/datum/artifact_effect/gasco2
	effecttype = "gasco2"
	effect = list(EFFECT_TOUCH, EFFECT_AURA)
	var/max_pressure
	var/target_percentage
	copy_for_battery = list("max_pressure")

/datum/artifact_effect/gasco2/New()
	..()
	max_pressure = rand(115,1000)

/datum/artifact_effect/gasco2/DoEffectTouch(var/mob/user)
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env)
			env.carbon_dioxide += rand(2,15)

/datum/artifact_effect/gasco2/DoEffectAura()
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env && env.total_moles < max_pressure)
			env.carbon_dioxide += pick(0, 0, 0.1, rand())
