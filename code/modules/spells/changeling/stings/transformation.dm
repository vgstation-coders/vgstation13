/spell/changeling/sting/transformation
	name = "Transformation Sting (40)"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform into another."
	abbreviation = "TS"
	hud_state = "transformsting"

	chemcost = 40
	delay = 15 SECONDS
	silent = 1

	var/selected_dna

/spell/changeling/sting/transformation/before_channel(mob/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if(!changeling)
		return FALSE
	
	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	var/S = input(user, "Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)
		return
	selected_dna = S

	..()

/spell/changeling/sting/transformation/lingsting(var/mob/user, var/mob/living/target)
	if(!target)
		return

	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if(!changeling)
		return 

	var/datum/dna/chosen_dna = changeling.GetDNA(selected_dna)
	if(!chosen_dna)
		return

	if((M_HUSK in target.mutations) || (!ishuman(target) && !ismonkey(target)))
		return 

	target.visible_message("<span class='danger'>[target] transforms!</span>")
	playsound(target, 'sound/effects/flesh_squelch.ogg', 30, 1)
	target.dna = chosen_dna.Clone()
	target.real_name = chosen_dna.real_name
	target.flavor_text = chosen_dna.flavor_text
	target.UpdateAppearance()
	domutcheck(target, null)
	feedback_add_details("changeling_powers","TS")
