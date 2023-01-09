/spell/changeling/sting/paralyse
	name = "Paralysis Sting (30)"
	desc = "We sting a human, paralyzing them for 40 seconds."
	abbreviation = "PS"
	hud_state = "paralysis"

	chemcost = 30


/spell/changeling/sting/paralyse/lingsting(var/mob/user, var/mob/living/target)
	if(!target)
		return

	to_chat(target, "<span class='userdanger'>Your muscles begin to painfully tighten.</span>")
	target.SetKnockdown(20)
	target.SetStunned(20)
	feedback_add_details("changeling_powers", "PS")
