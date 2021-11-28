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
	if(emergency_shuttle.location != map.zCentcomm)
		return FALSE
	if(!owner.current || owner.current.isDead())
		return FALSE
	var/turf/location = get_turf(owner.current.loc)
	if(!location)
		return FALSE

	var/datum/shuttle/S = is_on_shuttle(owner.current)
	if(emergency_shuttle.shuttle == S || emergency_shuttle.escape_pods.Find(S))
		if(istype(location, /turf/simulated/floor/shuttle/brig)) // Fails traitors if they are in the shuttle brig
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


//Prisoner Escapes. Same as above, except you don't have to be on the shuttle and you can't be in the brig roundend.

/datum/objective/escape_prisoner
	explanation_text = "Win, talk, or fight your way out of prison through whichever means you see fit. You do not need to escape on the shuttle."
	name = "Escape Custody"

	var/list/failure_areas = list(
		/area/prison,
		/area/security
	)

/datum/objective/escape_prisoner/IsFulfilled()
	if (..())
		return TRUE
	if(issilicon(owner.current))
		return FALSE
	if(isbrain(owner.current) || isborer(owner.current))
		return FALSE
	if(!owner.current || owner.current.isDead())
		return FALSE
	var/area/A = get_area(owner.current)
	if(is_type_in_list(A, failure_areas))
		return FALSE

	var/turf/T = get_turf(owner.current)
	if(istype(T, /turf/simulated/floor/shuttle/brig)) //red shuttle floors grant redtext
		return FALSE

	if(istype(owner.current, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner.current
		if(H.restrained()) 
			return FALSE
	else if (istype(owner.current, /mob/living/carbon))
		var/mob/living/carbon/C = owner.current
		if (C.handcuffed)
			return FALSE

	return TRUE