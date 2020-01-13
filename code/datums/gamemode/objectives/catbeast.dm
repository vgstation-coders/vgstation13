/datum/objective/catbeast/survive5
	explanation_text = "Stay alive on the station for five minutes."
	name = "Survive (as a catbeast)"

/datum/objective/catbeast/survive5/IsFulfilled()
	if (..())
		return TRUE
	var/datum/role/catbeast/C = owner.GetRole(CATBEAST)
	return C.ticks_survived > 150

/datum/objective/catbeast/defile
	explanation_text = "Defile 30 rooms by entering them."
	name = "Defile Rooms"

/datum/objective/catbeast/defile/IsFulfilled()
	if (..())
		return TRUE
	var/datum/role/catbeast/C = owner.GetRole(CATBEAST)
	return C.areas_defiled.len > 30