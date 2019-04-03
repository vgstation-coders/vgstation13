/datum/objective/eet/food
	explanation_text = "Devour 1,000 nutrition worth of food as an enigmatic extraterrestrial."
	name = "Sample food (EET)"
	var/amount = 1000

/datum/objective/eet/food/PostAppend()
	amount = rand(800,1200)
	explanation_text = "Devour [amount] nutrition worth of food as an enigmatic extraterrestrial."
	return TRUE

/datum/objective/eet/food/IsFulfilled()
	var/datum/role/eet/E = owner.GetRole(EET)
	if(!istype(E))
		return FALSE
	return E.nutriment_metabolized >= amount

/datum/objective/eet/food/DatacoreQuery()
	var/datum/role/eet/E = owner.GetRole(EET)
	if(!istype(E))
		return ..()
	return ..() + "; [E.nutriment_metabolized]/[amount]"