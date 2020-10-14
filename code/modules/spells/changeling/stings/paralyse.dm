/spell/changeling/sting/paralyse
	name = "Paralysis Sting"
	desc = "We quietly sting a human, paralyzing them for a short time."
	abbreviation = "PS"


/spell/changeling/sting/paralyse/lingsting(var/mob/user, var/mob/living/target)
	if(!target)
		return

	to_chat(target, "<span class='userdanger'>Your muscles begin to painfully tighten.</span>")
	target.Knockdown(20)
	feedback_add_details("changeling_powers", "PS")