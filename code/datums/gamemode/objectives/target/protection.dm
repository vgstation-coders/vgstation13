/datum/objective/target/protect
	name = "Protect <target>"

/datum/objective/target/protect/format_explanation()
	return "Protect [target.current.real_name], the [target.assigned_role == "MODE" ? target.special_role : target.assigned_role]."

/datum/objective/target/protect/IsFulfilled()
	if (..())
		return TRUE
	if(target.current)
		if(target.current.isDead() || issilicon(target.current) || isbrain(target.current) || isborer(target.current))
			return FALSE
		return TRUE
	return FALSE
