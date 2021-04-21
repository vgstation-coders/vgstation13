/spell/changeling/hiveupload
	name = "Hivemind Channel (10)"
	desc = "We can channel a DNA into the airwaves, allowing our fellow changelings to absorb it and transform into it as if they acquired the DNA themselves."
	abbreviation = "HC"
	hud_state = "hiveupload"

	spell_flags = NEEDSHUMAN

	chemcost = 10
	required_dna = 1

/spell/changeling/hiveupload/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	var/datum/faction/changeling/hivemind = find_active_faction_by_type(/datum/faction/changeling)
	if(!hivemind)
		return 

	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		if(!(DNA in hivemind.hivemind_bank))
			names += DNA.real_name

	if(names.len <= 0)
		to_chat(user, "<span class='notice'>The airwaves already have all of our DNA.</span>")
		return

	var/S = input("Select a DNA to channel: ", "Channel DNA", null) as null|anything in names
	if(!S)
		return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	hivemind.hivemind_bank += chosen_dna
	to_chat(user, "<span class='notice'>We channel the DNA of [S] to the air.</span>")
	feedback_add_details("changeling_powers","HU")

	..()
