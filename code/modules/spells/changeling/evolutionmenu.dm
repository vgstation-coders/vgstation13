/spell/changeling/evolve
	name = "Evolve"
	desc = "Allows us to view and purchase evolutions."
	abbreviation = "EV"
	hud_state = "evolve"
	
	spell_flags = NEEDSHUMAN

	max_genedamage = 9999   //shouldnt be possible to get above 30 but just in case

	

/spell/changeling/evolve/cast(var/list/targets, var/mob/living/carbon/human/user)
	if(user.stat == DEAD || user.status_flags == FAKEDEATH)
		to_chat(user, "<span class='warning'>We are unable to do this right now.</span>")
	else
		var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
		changeling.power_holder.PowerMenu()

