/spell/changeling/sting/dnaextract
	name = "DNA Extraction Sting (40)"
	desc = "We stealthily sting a target and extract the DNA from them."
	abbreviation = "NS"
	hud_state = "extractdna"

	chemcost = 40

	silent = 1

/spell/changeling/sting/dnaextract/lingsting(var/mob/user, var/mob/living/carbon/human/T)
	if(M_HUSK in T.mutations)	//No double-absorbing
		to_chat(user, "<span class='warning'>This creature's DNA is ruined beyond useability!</span>")
		return FALSE
	if(!T.mind)						//No monkeymen
		to_chat(user, "<span class='warning'>This creature's DNA is useless to us!</span>")
		return FALSE
	if(!istype(T))					//Humans only
		to_chat(user, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return FALSE
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if(!changeling)
		return
	if(T.species)
		changeling.absorbed_species |= T.species.name

	T.dna.real_name = T.real_name
	T.dna.flavor_text = T.flavor_text
	changeling.absorbed_dna |= T.dna
	changeling.absorbedcount++
	if(T.species && !(changeling.absorbed_species.Find(T.species.name)))
		changeling.absorbed_species += T.species.name
	user.updateChangelingHUD()

	feedback_add_details("changeling_powers", "ED")
