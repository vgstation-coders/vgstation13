
/datum/objective/target/brig
	name = "\[Syndicate\] Brig <target>"

	// Similar to the anti-rev objective, but for traitors
/datum/objective/target/brig
	var/already_completed = FALSE

/datum/objective/target/brig/format_explanation()
	return "Have [target.current.real_name], the [target.assigned_role == "MODE" ? target.special_role : target.assigned_role] brigged for 10 minutes."

/datum/objective/target/brig/IsFulfilled()
	if (..())
		return TRUE
	if(already_completed)
		return TRUE
	if(target && target.current)
		if(target.current.stat == DEAD)
			return FALSE
		// Make the actual required time a bit shorter than the official time
		if(target.is_brigged(5 MINUTES))
			already_completed = TRUE
			return TRUE
		return FALSE
	return FALSE
