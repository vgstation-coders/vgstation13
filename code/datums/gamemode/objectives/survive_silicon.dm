/datum/objective/siliconsurvive
	explanation_text = "Remain functional until the end."
	name = "Survive (as a silicon)"

/datum/objective/siliconsurvive/IsFulfilled()
	if (..())
		return TRUE
	if(!owner.current || owner.current.isDead() || !issilicon(owner.current))
		return FALSE
	return TRUE
