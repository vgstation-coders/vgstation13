
/datum/artifact_effect/gassleeping
	effecttype = "gassleeping"
	effect = list(EFFECT_TOUCH, EFFECT_AURA)
	var/max_pressure
	var/target_percentage
	copy_for_battery = list("max_pressure")

/datum/artifact_effect/gassleeping/New()
	..()
	max_pressure = rand(115,1000)
	effect_type = pick(6,7)

/datum/artifact_effect/gassleeping/DoEffectTouch(var/mob/user)
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env)
			var/datum/gas/sleeping_agent/trace_gas = new
			env.trace_gases += trace_gas
			trace_gas.moles = rand(2,15)
			env.update_values()


/datum/artifact_effect/gassleeping/DoEffectAura()
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env && env.total_moles < max_pressure)
			var/datum/gas/sleeping_agent/trace_gas = new
			env.trace_gases += trace_gas
			trace_gas.moles = pick(0, 0, 0.1, rand())
			env.update_values()

