/datum/objective/ramble
	explanation_text = "Escape to a different Z-level at the end. Life is optional, but you must remain intact."
	name = "Ramble Forth"

/datum/objective/ramble/IsFulfilled()
	if (..())
		return TRUE
	//Unlike an escape objective, we are okay with being dead, arrested, siliconed, MMI'd, etc.
	if(!owner.current)
		return FALSE
	var/turf/location = get_turf(owner.current.loc)
	if(!location)
		return FALSE

	if(location.z == STATION_Z)
		return FALSE
	else
		return TRUE
