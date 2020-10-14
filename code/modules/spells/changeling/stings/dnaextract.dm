/spell/changeling/sting/dnaextract
	name = "DNA Extraction Sting"
	desc = "We stealthily sting a target and extract the DNA from them."
	abbreviation = "DS"

	silent = 1

/spell/changeling/sting/dnaextract/lingsting(var/mob/user, var/mob/living/carbon/human/target)
	if(!target || istype(target))
		return
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if(!changeling)
		return 

	target.dna.real_name = target.real_name
	target.dna.flavor_text = target.flavor_text
	changeling.absorbed_dna |= target.dna
	if(target.species && !(changeling.absorbed_species.Find(target.species.name)))
		changeling.absorbed_species += target.species.name

	feedback_add_details("changeling_powers", "ED")