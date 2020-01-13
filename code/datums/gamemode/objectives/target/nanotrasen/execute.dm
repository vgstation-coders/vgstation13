
/datum/objective/target/anti_revolution/execute
	name = "\[Nanotrasen\] Execute <target>"

/datum/objective/target/anti_revolution/execute/format_explanation()
	return "[target.current.real_name], the [target.assigned_role] has extracted confidential information above their clearance. Execute \him[target.current]."

/datum/objective/target/anti_revolution/execute/IsFulfilled()
	if (..())
		return TRUE
	if(target && target.current)
		if(target.current.isDead() || !ishuman(target.current))
			return TRUE
		return FALSE
	return TRUE
