// Legacy cult

/datum/objective/convert_people
	explanation_text = "We must increase our influence before we can summon Nar-Sie. Convert X crew members. Take it slowly to avoid raising suspicions."
	name = "Convert people to the Cult of the Geometer of blood."
	var/cultists_target = 3

	flags =  FACTION_OBJECTIVE

/datum/objective/convert_people/proc/get_number()
	var/living_cultists = faction.members.len
	var/living_crew = 0
	for(var/mob/living/L in player_list)
		if(istype(L, /mob/living/carbon))
			living_crew++

	var/total = living_crew + living_cultists

	if((living_cultists * 2) < total)
		if (total < 15)
			message_admins("There are [total] players, too little for the mass convert objective!")
			return FALSE
		else if (total > 50)
			message_admins("There are [total] players, too many for the mass convert objective!")
			return FALSE
		return round(total / 2)

/datum/objective/convert_people/PostAppend()
	cultists_target = get_number()
	explanation_text = "We must increase our influence before we can summon Nar-Sie. Convert [cultists_target] crew members. Take it slowly to avoid raising suspicions."
	return TRUE

/datum/objective/convert_people/IsFulfilled()
	if (..())
		return TRUE
	return (faction.members.len >= cultists_target)

/datum/objective/summon_narsie/feedbackText()
	return "<span class = 'sinister'>You succesfully converted enough people to server the Geometer of Blood. The veil between this world and Nar'Sie grows thinner.</span>"