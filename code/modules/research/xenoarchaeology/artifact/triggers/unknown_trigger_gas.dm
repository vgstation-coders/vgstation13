#define MOLE_TRIGGER 10

/datum/artifact_trigger/gas
	triggertype = TRIGGER_GAS
	scanned_trigger = SCAN_ATMOS
	var/trigger_gas

/datum/artifact_trigger/gas/New()
	..()
	trigger_gas = pick(GAS_PLASMA, GAS_CARBON, GAS_NITROGEN, GAS_OXYGEN)


/datum/artifact_trigger/gas/CheckTrigger()
	var/turf/T = get_turf(my_artifact)
	var/datum/gas_mixture/env = T.return_air()
	if(env)
		if(!my_effect.activated)
			if (env.gas[trigger_gas] >= MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)

		else
			if(env.gas[trigger_gas] <= MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)

/datum/artifact_trigger/gas/Destroy()
	..()