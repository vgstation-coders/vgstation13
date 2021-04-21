/spell/changeling/hivedownload
	name = "Hivemind Absorb (20)"
	desc = "We can absorb a single DNA from the airwaves, allowing us to use more disguises with help from our fellow changelings."
	abbreviation = "HA"
	hud_state = "hivedownload"

	spell_flags = NEEDSHUMAN

	chemcost = 20
	required_dna = 1

/spell/changeling/hivedownload/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	var/datum/faction/changeling/hivemind = find_active_faction_by_type(/datum/faction/changeling)
	if(!hivemind)
		return 

	var/list/names = list()
	for(var/datum/dna/DNA in hivemind.hivemind_bank)
		if(!(DNA in changeling.absorbed_dna))
			names[DNA.real_name] = DNA

	if(names.len <= 0)
		to_chat(user, "<span class='notice'>There's no new DNA to absorb from the air.</span>")
		return

	var/S = input("Select a DNA absorb from the air: ", "Absorb DNA", null) as null|anything in names

	if(!S)
		return
	var/datum/dna/chosen_dna = names[S]
	if(!chosen_dna)
		return

	changeling.absorbed_dna += chosen_dna
	to_chat(user, "<span class='notice'>We absorb the DNA of [S] from the air.</span>")
	feedback_add_details("changeling_powers","HD")

	..()
