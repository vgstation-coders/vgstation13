/datum/objective/siliconsurvive
	explanation_text = "Remain functional until the end."

/datum/objective/siliconsurvive/IsFulfilled()
	..()
	if(!owner.current || owner.current.isDead() || !issilicon(owner.current))
		return FALSE
	return TRUE
