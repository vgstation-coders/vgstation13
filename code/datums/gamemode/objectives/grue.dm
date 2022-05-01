/datum/objective/grue/grue_basic
	explanation_text = "Lurk in the darkness and eat as many sentient beings as you can."
	name = "Lurk and Eat"

/datum/objective/grue/grue_basic/IsFulfilled()
	if (..())
		return TRUE
	var/datum/role/grue/G = owner.GetRole(ROLE_GRUE)
	return !(G.antag.current?.isDead())

/datum/objective/grue/eat_sentients
	explanation_text = "Eat sentient beings."
	name = "Eat Sentients"
	var/eat_objective = 2

/datum/objective/grue/eat_sentients/PostAppend()
	. = ..()
	eat_objective = rand(2,3)
	explanation_text = "Eat [eat_objective] sentient being[(eat_objective>1) ? "s" : ""]."

/datum/objective/grue/eat_sentients/IsFulfilled()
	if (..())
		return TRUE
	var/datum/role/grue/G = owner.GetRole(ROLE_GRUE)
	return (G.eatencount >= eat_objective)

/datum/objective/grue/spawn_offspring
	explanation_text = "Lay eggs and spawn offspring."
	name = "Spawn Offspring"
	var/spawn_objective = 2

/datum/objective/grue/spawn_offspring/PostAppend()
	. = ..()
	spawn_objective = rand(1,2)
	explanation_text = "Lay [(spawn_objective>1) ? "eggs" : "an egg"] and spawn [spawn_objective] offspring."

/datum/objective/grue/spawn_offspring/IsFulfilled()
	if (..())
		return TRUE
	var/datum/role/grue/G = owner.GetRole(ROLE_GRUE)
	return (G.spawncount >= spawn_objective)




