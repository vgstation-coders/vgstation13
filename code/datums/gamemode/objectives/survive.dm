/datum/objective/survive
	explanation_text = "Stay alive until the end."
	name = "Survive (as a carbon)"

/datum/objective/survive/IsFulfilled()
	if (..())
		return TRUE
	if(!owner.current || owner.current.isDead() || isbrain(owner.current) || isborer(owner.current || issilicon(owner.current)))
		return FALSE //Brains no longer win survive objectives. --NEO
	return TRUE

/datum/objective/survive/potions	//You still get greentext if you survive
	explanation_text = "Sell some potions and make loads of money."
	name = "Sell potions"

/datum/objective/survive/tag_mode_mime
	explanation_text = "You are an ordinary Mime living in a space station. Your goal is to survive to the end of the shift... or become something more, if you dare."
