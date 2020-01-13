/datum/objective/steal_priority
	explanation_text = "Acquire a number of priority items."
	name = "(vox raiders) Acquire items"
	var/num

/datum/objective/steal_priority/PostAppend()
	. = ..()
	num = rand(1, 3)
	explanation_text = "Acquire [num] priority items."

/datum/objective/steal_priority/IsFulfilled()
	var/datum/faction/vox_shoal/VS = faction
	if (!VS)
		return FALSE
	return VS.got_items >= num