/datum/objective/chem_sample
	explanation_text = "Learn a number of chemicals"
	name = "(Changeling) Learn chemicals"
	var/number_of_chems_to_learn

/datum/objective/chem_sample/PostAppend()
	number_of_chems_to_learn = rand(5,30)
	explanation_text = "Learn [number_of_chems_to_learn] different chemicals."
	return TRUE

/datum/objective/chem_sample/IsFulfilled()
	if (..())
		return TRUE
	if(owner)
		var/datum/role/changeling/C = owner.GetRole(CHANGELING)
		if(C && C.absorbed_chems.len >= number_of_chems_to_learn)
			return TRUE
	return FALSE