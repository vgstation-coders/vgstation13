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

	if(istype(location, /turf/simulated/shuttle/floor4)) // Fails tratiors if they are in the shuttle brig -- Polymorph
		if(istype(owner.current, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = owner.current
			if(!H.restrained()) // Technically, traitors will fail the objective if they are time stopped by a wizard
				return TRUE
		else if(istype(owner.current, /mob/living/carbon)) // I don't think non-humanoid carbons can get the escape objective, but I'm leaving it to be safe
			var/mob/living/carbon/C = owner.current
			if (!C.handcuffed)
				return TRUE
		return FALSE

	var/area/check_area = location.loc
	if(istype(check_area, /area/shuttle/escape/centcom))
		return TRUE
	if(istype(check_area, /area/shuttle/escape_pod1/centcom))
		return TRUE
	if(istype(check_area, /area/shuttle/escape_pod2/centcom))
		return TRUE
	if(istype(check_area, /area/shuttle/escape_pod3/centcom))
		return TRUE
	if(istype(check_area, /area/shuttle/escape_pod5/centcom))
		return TRUE
	else
		return FALSE
