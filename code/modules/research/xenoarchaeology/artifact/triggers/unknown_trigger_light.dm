/datum/artifact_trigger/light
	triggertype = TRIGGER_LIGHT
	scanned_trigger = SCAN_OCULAR
	var/dark_triggered = 0
	var/lum_trigger = 5

/datum/artifact_trigger/light/New()
	..()
	dark_triggered = prob(50)
	lum_trigger = rand(1,9)

/datum/artifact_trigger/light/CheckTrigger()
	var/turf/T = get_turf(my_artifact)
	var/light_available = 5
	if(T.dynamic_lighting)
		light_available = T.get_lumcount() * 10
		if(!my_effect.activated)
			if(!dark_triggered && light_available >= lum_trigger)
				Triggered(0, "LIGHT", 0)
			else if(dark_triggered && light_available <= lum_trigger)
				Triggered(0, "DARK", 0)
		else
			if(!dark_triggered && light_available <= lum_trigger)
				Triggered(0, "DARK", 0)
			else if(dark_triggered && light_available >= lum_trigger)
				Triggered(0, "LIGHT", 0)