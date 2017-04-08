
/datum/artifact_effect/gassleeping
	effecttype = "gassleeping"
	var/max_pressure
	var/target_percentage
	copy_for_battery = list("max_pressure")

/datum/artifact_effect/gassleeping/New()
	..()
	effect = pick(EFFECT_TOUCH, EFFECT_AURA)
	max_pressure = rand(115,1000)
	effect_type = pick(6,7)

/datum/artifact_effect/gassleeping/DoEffectTouch(var/mob/user)
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env)
			env.adjust_gas(GAS_SLEEPING, rand(2,15))

/datum/artifact_effect/gassleeping/DoEffectAura()
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env && env.return_pressure() < max_pressure)
			env.adjust_gas(GAS_SLEEPING, pick(0, 0, 0.1, rand()))
