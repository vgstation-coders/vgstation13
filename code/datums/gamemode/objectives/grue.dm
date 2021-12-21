/datum/objective/grue/grue_basic
	explanation_text = "Lurk in the darkness and eat as many sentient beings as you can."
	name = "Lurk and Eat"

/datum/objective/grue/grue_basic/IsFulfilled()
	if (..())
		return TRUE

/datum/objective/grue/eat_sentients
	explanation_text = "Eat sentient beings."
	name = "Eat Sentients"
	var/eat_objective = 2

/datum/objective/grue/eat_sentients/PostAppend()
	. = ..()
	eat_objective = rand(2,3)
	explanation_text = "Eat [eat_objective] sentient beings."

/datum/objective/grue/eat_sentients/IsFulfilled()
	if (..())
		return TRUE
	var/datum/role/grue/G = owner.GetRole(GRUE)
	return G.eatencount >= eat_objective

