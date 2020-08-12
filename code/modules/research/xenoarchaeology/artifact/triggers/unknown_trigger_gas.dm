#define MOLE_TRIGGER (10 / CELL_VOLUME)

/datum/artifact_trigger/gas
	triggertype = TRIGGER_GAS
	scanned_trigger = SCAN_ATMOS
	var/trigger_gas = null

/datum/artifact_trigger/gas/New()
	..()
	trigger_gas = pick(GAS_NITROGEN, GAS_OXYGEN, GAS_CARBON, GAS_PLASMA)


/datum/artifact_trigger/gas/CheckTrigger()
	var/turf/T = get_turf(my_artifact)
	var/datum/gas_mixture/env = T.return_air()
	if(env)
		if(!my_effect.activated)
			if(env.molar_density(trigger_gas) >= MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)

		else
			if(env.molar_density(trigger_gas) < MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)
