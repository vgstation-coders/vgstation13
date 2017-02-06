/datum/artifact_trigger/gas
	triggertype = "gas"
	var/trigger_gas = 0

/datum/artifact_trigger/gas/New()
	..()
	trigger_gas = pick("toxins","carbon_dioxide","nitrogen","oxygen")


/datum/artifact_trigger/gas/CheckTrigger()
	var/turf/T = get_turf(my_artifact)
	var/datum/gas_mixture/env = T.return_air()
	if(env)
		if(!my_effect.activated)
			if(trigger_gas == "toxins" && env.toxins > 10)
				Triggered()
				my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [trigger_gas]([my_effect.trigger]).")
			if(trigger_gas == "carbon_dioxide" && env.carbon_dioxide > 10)
				Triggered()
				my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [trigger_gas]([my_effect.trigger]).")
			if(trigger_gas == "nitrogen" && env.nitrogen > 10)
				Triggered()
				my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [trigger_gas]([my_effect.trigger]).")
			if(trigger_gas == "oxygen" && env.oxygen > 10)
				Triggered()
				my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [trigger_gas]([my_effect.trigger]).")

		else
			if(trigger_gas == "toxins" && env.toxins < 10)
				Triggered()
				my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [trigger_gas]([my_effect.trigger]).")
			if(trigger_gas == "carbon_dioxide" && env.carbon_dioxide < 10)
				Triggered()
				my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [trigger_gas]([my_effect.trigger]).")
			if(trigger_gas == "nitrogen" && env.nitrogen < 10)
				Triggered()
				my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [trigger_gas]([my_effect.trigger]).")
			if(trigger_gas == "oxygen" && env.oxygen < 10)
				Triggered()
				my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [trigger_gas]([my_effect.trigger]).")
