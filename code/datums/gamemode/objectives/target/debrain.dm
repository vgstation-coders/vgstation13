/datum/objective/target/debrain
	name = "Steal the brain of <target>"

/datum/objective/target/debrain/format_explanation()
	return "Steal the brain of [target.current.real_name] the [target.assigned_role == "MODE" ? target.special_role : target.assigned_role]."


/datum/objective/target/debrain/IsFulfilled()
	if (..())
		return TRUE
	if(!owner.current || owner.current.isDead())//If you're otherwise dead.
		return FALSE
	if(!target.current || !isbrain(target.current))
		return FALSE
	var/atom/A = target.current
	while(A.loc)//check to see if the brainmob is on our person
		A = A.loc
		if(A == owner.current)
			return 1
	return FALSE
