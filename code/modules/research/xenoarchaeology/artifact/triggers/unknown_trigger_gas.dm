#define MOLE_TRIGGER 10

/datum/artifact_trigger/gas
	triggertype = TRIGGER_GAS
	scanned_trigger = SCAN_ATMOS
	var/trigger_gas = 0

/datum/artifact_trigger/gas/New()
	..()
	trigger_gas = pick("TOXINS","CARBON_DIOXIDE","NITROGEN","OXYGEN")


/datum/artifact_trigger/gas/CheckTrigger()
	var/turf/T = get_turf(my_artifact)
	var/datum/gas_mixture/env = T.return_air()
	if(env)
		if(!my_effect.activated)
			if(trigger_gas == "TOXINS" && env.toxins >= MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)
			if(trigger_gas == "CARBON_DIOXIDE" && env.carbon_dioxide >= MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)
			if(trigger_gas == "NITROGEN" && env.nitrogen >= MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)
			if(trigger_gas == "OXYGEN" && env.oxygen >= MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)

		else
			if(trigger_gas == "TOXINS" && env.toxins < MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)
			if(trigger_gas == "CARBON_DIOXIDE" && env.carbon_dioxide < MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)
			if(trigger_gas == "NITROGEN" && env.nitrogen < MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)
			if(trigger_gas == "OXYGEN" && env.oxygen < MOLE_TRIGGER)
				Triggered(0, trigger_gas, 0)

/datum/artifact_trigger/gas/Destroy()
	..()