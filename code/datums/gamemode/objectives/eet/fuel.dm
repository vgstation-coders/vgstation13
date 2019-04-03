/datum/objective/eet/fuel
	explanation_text = "Fill your ship's core with 10,000 welding fuel."
	name = "Refuel ship (EET)"

/datum/objective/eet/fuel/IsFulfilled()
	if (..())
		return TRUE
	if(!eet_core)
		return FALSE
	if(eet_core.reagents.has_reagent(FUEL,10000))
		return TRUE
	return FALSE

/datum/objective/eet/fuel/DatacoreQuery()
	return ..() + "; Fuel: [eet_core.reagents.get_reagent_amount(FUEL)]/10000"