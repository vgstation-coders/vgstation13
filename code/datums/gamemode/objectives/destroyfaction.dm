/datum/objective/destroyfaction
	explanation_text = "Kill all members of ENEMY FACTION."
	name = "Destroy Faction"
	var/datum/faction/targetfaction

/datum/objective/destroyfaction/PostAppend()
	explanation_text = "Kill all members of \the [targetfaction.name]."
	return TRUE

/datum/objective/destroyfaction/IsFulfilled()
	if (..())
		return TRUE
	if(!targetfaction)
		return TRUE
	if(!targetfaction.members.len)
		return TRUE
	for(var/datum/role/R in targetfaction.members)
		if(R.antag.current.stat != DEAD)
			return FALSE

	return TRUE