/datum/objective/target/debrain/find_target() //I want braaaainssss
	..()
	if(target && target.current)
		explanation_text = "Steal the brain of [target.current.real_name]."
	return target

/datum/objective/target/debrain/find_target_by_role(role, role_type=FALSE)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Steal the brain of [target.current.real_name] the [!role_type ? target.assigned_role : target.special_role]."
	return target

/datum/objective/target/debrain/IsFulfilled()
	..()
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
