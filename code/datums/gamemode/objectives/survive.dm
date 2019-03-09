/datum/objective/survive
	explanation_text = "Stay alive until the end."
	name = "Survive (as a carbon)"

/datum/objective/survive/IsFulfilled()
	if (..())
		return TRUE
	if(!owner.current || owner.current.isDead() || isbrain(owner.current) || isborer(owner.current || issilicon(owner.current)))
		return FALSE //Brains no longer win survive objectives. --NEO
	return TRUE

/datum/objective/survive/saboteur // Emag survivor
	name = "Sabotage! (And survive as a carbon)"
	explanation_text = "Stay alive until the end, and sabotage as much as you can!"

/datum/objective/survive/bomber // Bomber survivor
	name = "Bomb! (And survive as a carbon)"
	explanation_text = "You're enthralled by the legend of Cuban Pete. Follow in his footsteps, but you should try staying alive until the end at the same time!"

/datum/objective/survive/mech // Mech survivor
	name = "Challenge! (And survive as a carbon)"
	explanation_text = "You're looking for the best contenders! People with mechs are a priority over those with no mechs! Try to stay alive until the end!"