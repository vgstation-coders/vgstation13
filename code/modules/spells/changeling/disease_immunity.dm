/spell/changeling/disease_immunity
	name = "Bioimmunity"
	desc = "We become immune to the symptoms of any pathogen at will."
	abbreviation = "ID"
	hud_state = "disease_immunity"


/spell/changeling/disease_immunity/cast(list/targets, mob/living/carbon/human/user)
	var/datum/role/changeling/C = ischangeling(user)
	if(!C)
		return
	C.disease_immunity = !C.disease_immunity
	to_chat(user, "<span class='notice'>We [C.disease_immunity ? "make ourselves immune to viral symptoms" : "are now vulnerable to viral symptoms"].</span>")
