// Legacy cult

/datum/objective/spray_blood
	explanation_text = "We must prepare this place for the Geometer of Blood's coming. Spread blood and gibs over X of the Station's floor tiles."
	name = "Spray blood on the station."
	var/floor_limit = 15 // Abritary, to fix later

	flags =  FACTION_OBJECTIVE

/datum/objective/spray_blood/PostAppend()
	floor_limit = round(rand(1,5))*50
	explanation_text = "We must prepare this place for the Geometer of Blood's coming. Spread blood and gibs over [floor_limit] of the Station's floor tiles."
	return TRUE

/datum/objective/spray_blood/IsFulfilled()
	if (..())
		return TRUE
	var/datum/faction/cult/narsie/cult_fac = faction
	return (cult_fac.bloody_floors.len >= floor_limit)

/datum/objective/summon_narsie/feedbackText()
	return "<span class = 'sinister'>You succesfully defiled the floors of this station. The veil between this world and Nar'Sie grows thinner.</span>"