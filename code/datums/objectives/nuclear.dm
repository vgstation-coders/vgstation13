/datum/objective/nuclear
	explanation_text = "Destroy the station with a nuclear device."

/datum/objective/nuclear/IsFulfilled()
	..()
	if(ticker.mode.explosion_in_progress || ticker.mode.station_was_nuked)
		return TRUE
	return FALSE
