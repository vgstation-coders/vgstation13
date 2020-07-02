/datum/objective/escape
	explanation_text = "Escape on the shuttle or an escape pod alive and free."
	name = "Escape"

/datum/objective/escape/IsFulfilled()
	if (..())
		return TRUE
	if(issilicon(owner.current))
		return FALSE
	if(isbrain(owner.current) || isborer(owner.current))
		return FALSE
	if(emergency_shuttle.location != CENTCOMM_Z)
		return FALSE
	if(!owner.current || owner.current.isDead())
		return FALSE
	var/turf/location = get_turf(owner.current.loc)
	if(!location)
		return FALSE

	var/datum/shuttle/S = is_on_shuttle(owner.current)
	if(emergency_shuttle.shuttle == S || emergency_shuttle.escape_pods.Find(S))
		if(istype(location, /turf/simulated/shuttle/floor4)) // Fails traitors if they are in the shuttle brig
			if(istype(owner.current, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = owner.current
				if(!H.restrained()) // Technically, traitors will fail the objective if they are time stopped by a wizard
					return TRUE
			else if(istype(owner.current, /mob/living/carbon))
				var/mob/living/carbon/C = owner.current
				if (!C.handcuffed)
					return TRUE
			return FALSE
		return TRUE
	else
		return FALSE
