/datum/objective/die
	explanation_text = "Die a glorious death."
	name = "Glorious Death"

/datum/objective/die/IsFulfilled()
	if (..())
		return TRUE
	if(!owner.current || owner.current.isDead() || isbrain(owner.current) || isborer(owner.current))
		return TRUE //Brains no longer win survive objectives. --NEO
	if(issilicon(owner.current) && owner.current != owner.original)
		return TRUE
	return FALSE
