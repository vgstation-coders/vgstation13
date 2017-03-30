/datum/artifact_trigger/speed
	triggertype = TRIGGER_SPEED
	scanned_trigger = SCAN_CONSTANT_ENERGETIC
	var/needed_distance
	var/toggles = 0
	var/turf/old_T
	var/cooldown = 10
	var/last_moved

/datum/artifact_trigger/speed/New()
	..()
	needed_distance = rand(1,9) //needed distance to traverse per process()
	old_T = get_turf(my_artifact)
	toggles = prob(80)
	last_moved = world.time

/datum/artifact_trigger/speed/CheckTrigger()
	var/turf/T = get_turf(my_artifact)

	if(T)
		var/distance = get_dist(T, old_T)

		if(toggles) //moving at speed toggles it, it can then stopped until it needs to be toggled again
			if((world.time - last_moved) > cooldown && distance >= needed_distance)
				if(!my_effect.activated)
					Triggered(0, "SPEEDTOGGLE", 0)
				else
					Triggered(0, "SLOWTOGGLE", 0)
			last_moved = world.time
		else //has to be constantly moving to be active
			if(distance >= needed_distance && !my_effect.activated)
				Triggered(0, "SPEED", 0)
			else if(distance < needed_distance && my_effect.activated)
				Triggered(0, "SLOW", 0)

		old_T = T


/datum/artifact_trigger/speed/Destroy()
	..()