/datum/objective/grue/eat_basic
	explanation_text = "Eat as many sentient beings as you can!"
	name = "Eat Sentients"

/datum/objective/grue/eat_basic/IsFulfilled()
	if (..())
		return TRUE



///datum/objective/grue/eat_sentients
//	explanation_text = "Eat sentient beings."
//	name = "Eat"
//	var/eat_objective

///datum/objective/grue/eat_sentients/PostAppend()
//	. = ..()
//	eat_objective = 3
//	explanation_text = "Eat [eat_objective] sentient beings."

///datum/objective/grue/eat_sentients/IsFulfilled()
//	if (..())
//		return TRUE
//	var/datum/role/grue/G = owner.GetRole(GRUE)
//	return G.eatencount >= eat_objective

