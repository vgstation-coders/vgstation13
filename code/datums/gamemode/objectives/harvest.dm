// Legacy cult

/datum/objective/harvest
    name = "Harvest for Nar'Sie."
    explanation_text = "The Geometer of Blood hungers for his first meal of this never-ending day. Offer him X unbelievers in sacrifice."
    var/harvest_target = 10

    flags =  FACTION_OBJECTIVE

/datum/objective/harvest/PostAppend()
	var/targets = 0
	for (var/mob/living/L in player_list)
		if (ishuman(L) || issilicon(L))
			targets++
	targets -= faction.members.len
	harvest_target = min(10, targets)
	explanation_text = "The Geometer of Blood hungers for his first meal of this never-ending day. Offer him [harvest_target] unbelievers in sacrifice."
	return TRUE

/datum/objective/harvest/IsFulfilled()
	var/datum/faction/cult/narsie/my_cult = faction
	return (my_cult.harvested >= harvest_target)