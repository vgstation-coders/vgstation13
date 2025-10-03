/spell/changeling/sting/chem
	name = "Chemical Sting (5)"
	desc = "We sting a human with chemicals learned."
	abbreviation = "CS"
	hud_state = "chem-sting"
	chemcost = 5

	var/current_chem

/spell/changeling/sting/chem/before_channel(mob/user)
	. = ..()
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if(!changeling)
		return 1
	if(!changeling.absorbed_chems?.len)
		to_chat(user,"<span class='warning'>We have not learned any chemicals to inject! Learn some by consuming them.</span>")
		return 1
	if(changeling.absorbed_chems.len == 1)
		current_chem = changeling.absorbed_chems[1]
		return

	current_chem = input(user,"Select a chemical to inject with:","Learned chemicals",current_chem) as null|anything in changeling.absorbed_chems

/spell/changeling/sting/chem/lingsting(var/mob/user, var/mob/living/target)
	if(!current_chem)
		return

	target.reagents.add_reagent(current_chem,5)

	feedback_add_details("changeling_powers", "CS")
