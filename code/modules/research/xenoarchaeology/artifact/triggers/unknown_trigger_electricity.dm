/datum/artifact_trigger/electricity
	triggertype = TRIGGER_ELECTRIC
	scanned_trigger = SCAN_CONSTANT_ENERGETIC
	var/power_load = 7500
	var/power_requested = FALSE
	var/datum/power_connection/consumer/cable/power_connection = null

/datum/artifact_trigger/electricity/New()
	. = ..()
	power_connection = new(my_artifact)
	power_connection.power_priority = POWER_PRIORITY_BYPASS

/datum/artifact_trigger/electricity/Destroy()
	if(power_connection)
		QDEL_NULL(power_connection)
	. = ..()

/datum/artifact_trigger/electricity/CheckTrigger()

	var/turf/T = get_turf(my_artifact)
	var/obj/structure/cable/cable = locate() in T
	if(!cable || !istype(cable))
		power_requested = FALSE
		if(my_effect.activated)
			Triggered(0, "NOCABLE", 0)
		return

	power_connection.connect(cable)
	var/datum/powernet/PN = power_connection.get_powernet()

	if(!PN) //Powernet is dead
		power_requested = FALSE
		if(my_effect.activated)
			Triggered(0, "NOPOWERNET", 0)
		return
	else
		power_connection.add_load(power_load)
		if (!power_requested)        // Skip the first power check to make sure satisfaction includes our load, instead of being the satisfaction from before our load
			power_requested = TRUE   // This ensures artifacts stay off when on a net with less than 7500W, instead of first turning on once and then staying off
		else
			if(power_connection.get_satisfaction() < 1.0) //Cannot drain enough power
				if(my_effect.activated)
					Triggered(0, "NOTENOUGHELECTRICITY", 0)
				return
			else if(!my_effect.activated)
				Triggered(0, "ELECTRICITY", 0)
				return
