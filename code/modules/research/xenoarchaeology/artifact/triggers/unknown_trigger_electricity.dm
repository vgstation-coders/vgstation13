/datum/artifact_trigger/electricity
	triggertype = TRIGGER_ELECTRIC
	scanned_trigger = SCAN_CONSTANT_ENERGETIC
	var/power_load = 7500

/datum/artifact_trigger/electricity/New()
	..()

/datum/artifact_trigger/electricity/CheckTrigger()

	var/turf/T = get_turf(my_artifact)
	var/obj/structure/cable/cable = locate() in T
	if(!cable || !istype(cable))
		if(my_effect.activated)
			Triggered(0, "NOCABLE", 0)
		return

	var/datum/powernet/PN = cable.get_powernet()
	if(!PN) //Powernet is dead
		if(my_effect.activated)
			Triggered(0, "NOPOWERNET", 0)
		return
	else if(PN.avail < power_load) //Cannot drain enough power
		if(my_effect.activated)
			Triggered(0, "NOTENOUGHELECTRICITY", 0)
		return
	else if(!my_effect.activated)
		PN.load += power_load
		Triggered(0, "ELECTRICITY", 0)
		return
	else //makes sure the powernet stays under load if the artifact is moving
		PN.load += power_load