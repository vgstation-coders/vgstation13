#define MOLE_TRIGGER (10 / CELL_VOLUME)

/datum/artifact_trigger/gas
	triggertype = TRIGGER_GAS
	scanned_trigger = SCAN_ATMOS
	var/trigger_gas = 0

/datum/artifact_trigger/gas/New()
	..()
	trigger_gas = pick("PLASMA", "CARBON_DIOXIDE", "NITROGEN", "OXYGEN") //TODO: See if these can be replaced with the defines without fucking up


/datum/artifact_trigger/gas/CheckTrigger()
	var/turf/T = get_turf(my_artifact)
	var/datum/gas_mixture/env = T.return_air()
	if(env)
		if(!my_effect.activated)
			if(env.molar_density(lowertext(trigger_gas)) >= MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)

		else
			if(env.molar_density(lowertext(trigger_gas)) < MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)
