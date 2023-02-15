/spell/changeling/sting/deaf
	name = "Deaf Sting (5)"
	desc = "We sting a human, completely deafening them for 30 seconds."
	abbreviation = "DS"
	hud_state = "deafsting"

	chemcost = 5


/spell/changeling/sting/deaf/lingsting(var/mob/user, var/mob/living/target)
	if(!target)
		return

	if(target.disabilities & DEAF)
		to_chat(target, "<span class='info'>You feel a weird sensation in your ears, but it quickly subsides.</span>")
		return

	to_chat(target, "<span class='notice'>The world around you suddenly becomes quiet.</span>")
	target.sdisabilities |= DEAF
	spawn(300)
		target.sdisabilities &= ~DEAF

	feedback_add_details("changeling_powers", "DS")
