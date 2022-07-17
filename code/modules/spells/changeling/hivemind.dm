/spell/changeling/hivemind
	name = "Hivemind (25)"
	desc = "We can transmit and receive DNA. We can use this DNA to transform as if we acquired the DNA ourselves."
	abbreviation = "HC"
	hud_state = "hivemind"

	spell_flags = NEEDSHUMAN
	horrorallowed = 0
	chemcost = 25

/spell/changeling/hivemind/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	var/datum/faction/changeling/hivemind = find_active_faction_by_type(/datum/faction/changeling)
	if(!hivemind)
		return 

	var/list/names
	//Transmit DNA
	names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		if(!(DNA in hivemind.hivemind_bank))
			names += DNA.real_name
	if(names.len <= 0)
		to_chat(user, "<span class='notice'>We have transmitted all of our DNA.</span>")
	else
		for(var/S in names)
			var/datum/dna/chosen_dna = changeling.GetDNA(S)
			if(chosen_dna)
				hivemind.hivemind_bank += chosen_dna
				to_chat(user, "<span class='notice'>We transmit the DNA of [S].</span>")
	feedback_add_details("changeling_powers","HU")

	//Receive DNA
	names = list()
	for(var/datum/dna/DNA in hivemind.hivemind_bank)
		if(!(DNA in changeling.absorbed_dna))
			names[DNA.real_name] = DNA
	if(names.len <= 0)
		to_chat(user, "<span class='notice'>There's no new DNA transmitted.</span>")
	else
		for(var/S in names)
			var/datum/dna/chosen_dna = names[S]
			if(chosen_dna)
				changeling.absorbed_dna += chosen_dna
				to_chat(user, "<span class='notice'>We receive the DNA of [S].</span>")
	feedback_add_details("changeling_powers","HD")
	..()