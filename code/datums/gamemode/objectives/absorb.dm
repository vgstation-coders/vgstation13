/datum/objective/absorb
	explanation_text = "Absorb a number of genomes."
	name = "(changeling) Absorb genomes"
	var/genomes_to_absorb

/datum/objective/absorb/PostAppend()
	genomes_to_absorb = rand(2,3)
	explanation_text = "Absorb [genomes_to_absorb] genomes."
	return TRUE

/datum/objective/absorb/IsFulfilled()
	if (..())
		return TRUE
	if(owner)
		var/datum/role/changeling/C = owner.GetRole(CHANGELING)
		if(C && C.absorbedcount >= genomes_to_absorb)
			return TRUE
	return FALSE
