/datum/objective/survive
	explanation_text = "Stay alive until the end."
	name = "Survive (as a carbon)"

/datum/objective/survive/IsFulfilled()
	if (..())
		return TRUE
	if(!owner.current || owner.current.isDead() || isbrain(owner.current) || isborer(owner.current || issilicon(owner.current)))
		return FALSE //Brains no longer win survive objectives. --NEO
	return TRUE
