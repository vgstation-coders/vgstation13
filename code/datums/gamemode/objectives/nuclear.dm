/datum/objective/nuclear
	explanation_text = "Destroy the station with a nuclear device."
	name = "Nuke the station"

/datum/objective/nuclear/IsFulfilled()
	if (..())
		return TRUE
	if(ticker.explosion_in_progress || ticker.station_was_nuked)
		return TRUE
	return FALSE
