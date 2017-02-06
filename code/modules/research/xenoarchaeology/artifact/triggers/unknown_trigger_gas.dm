/datum/artifact_trigger/gas
	triggertype = "gas"
	var/trigger_gas = 0

/datum/artifact_trigger/gas/New()
	..()
	trigger_gas = pick("TOXINS","CARBON_DIOXIDE","NITROGEN","OXYGEN")


/datum/artifact_trigger/gas/CheckTrigger()
	var/turf/T = get_turf(my_artifact)
	var/datum/gas_mixture/env = T.return_air()
	if(env)
		if(!my_effect.activated)
			if(trigger_gas == "TOXINS" && env.toxins > 10)
				Triggered(0, trigger_gas, 0)
			if(trigger_gas == "CARBON_DIOXIDE" && env.carbon_dioxide > 10)
				Triggered(0, trigger_gas, 0)
			if(trigger_gas == "NITROGEN" && env.nitrogen > 10)
				Triggered(0, trigger_gas, 0)
			if(trigger_gas == "OXYGEN" && env.oxygen > 10)
				Triggered(0, trigger_gas, 0)

		else
			if(trigger_gas == "TOXINS" && env.toxins < 10)
				Triggered(0, trigger_gas, 0)
			if(trigger_gas == "CARBON_DIOXIDE" && env.carbon_dioxide < 10)
				Triggered(0, trigger_gas, 0)
			if(trigger_gas == "NITROGEN" && env.nitrogen < 10)
				Triggered(0, trigger_gas, 0)
			if(trigger_gas == "OXYGEN" && env.oxygen < 10)
				Triggered(0, trigger_gas, 0)
