/datum/artifact_trigger/electricity
	triggertype = TRIGGER_ELECTRIC
	scanned_trigger = SCAN_CONSTANT_ENERGETIC
	var/power_load = 7500
	var/datum/power_connection/consumer/cable/power_connection = null

/datum/artifact_trigger/electricity/New()
	. = ..()
	power_connection = new(src)
	power_connection.power_priority = POWER_PRIORITY_BYPASS

/datum/artifact_trigger/electricity/Destroy()
	if(power_connection)
		qdel(power_connection)
		power_connection = null
	. = ..()

/datum/artifact_trigger/electricity/CheckTrigger()

	if(!power_connection.connected && !power_connection.connect())
		if(my_effect.activated)
			Triggered(0, "NOCABLE", 0)
		return

	var/datum/powernet/PN = power_connection.get_powernet()
	if(!PN) //Powernet is dead
		if(my_effect.activated)
			Triggered(0, "NOPOWERNET", 0)
		return
	else if(power_connection.get_satisfaction() < 1.0) //Cannot drain enough power
		if(my_effect.activated)
			Triggered(0, "NOTENOUGHELECTRICITY", 0)
		return
	else if(!my_effect.activated)
		power_connection.add_load(power_load)
		Triggered(0, "ELECTRICITY", 0)
		return
	else //makes sure the powernet stays under load if the artifact is moving
		power_connection.add_load(power_load)
