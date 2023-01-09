/spell/changeling/sting/mute
	name = "Silence Sting (15)"
	desc = "We silently sting a human, completely silencing them for a minute."
	abbreviation = "MS"
	hud_state = "mutesting"

	chemcost = 15
	silent = 1


/spell/changeling/sting/mute/lingsting(var/mob/user, var/mob/living/target)
	if(!target)
		return

	feedback_add_details("changeling_powers", "SS")
	target.silent += 30
