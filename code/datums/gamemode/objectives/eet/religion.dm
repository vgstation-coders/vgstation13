/datum/objective/eet/religion
	explanation_text = "Spread your culture (religion) to 10 crewmembers."
	name = "Spread religion (EET)"
	var/amount = 10
	var/last_reported_count = 0

/datum/objective/eet/religion/PostAppend()
	var/living = 0
	for(var/mob/living/M in player_list)
		if(!M.client)
			continue
		if(!ishuman(M))
			continue
		var/turf/T = get_turf(M)
		if(T.z != STATION_Z)
			continue
		if(M.stat != DEAD)
			living++
	amount = round(living/2)
	explanation_text = "Spread your culture (religion) to [amount] crewmembers."
	return TRUE

/datum/objective/eet/religion/IsFulfilled()
	if(!owner || !owner.faith)
		return FALSE
	var/datum/religion/R = owner.faith
	var/count = 0
	for(var/datum/mind/M in R.adepts)
		if(!M.GetRole(EET))
			count++
	last_reported_count = count
	return count >= amount

/datum/objective/eet/photograph/DatacoreQuery()
	IsFulfilled()
	return ..() + "; [last_reported_count]/[amount]"