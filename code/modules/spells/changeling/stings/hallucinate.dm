/spell/changeling/sting/hallucinate
	name = "Hallucination Sting (15)"
	desc = "We silently sting the victim with powerful hallucinogen, causing them to hallucinate after roughly 45 seconds."
	abbreviation = "HS"
	hud_state = "hallucinatesting"

	chemcost = 15
	silent = 1
	charge_max = 45 SECONDS
	cooldown_min = 45 SECONDS


/spell/changeling/sting/hallucinate/lingsting(var/mob/user, var/mob/living/target)
	if(!target)
		return

	feedback_add_details("changeling_powers", "HS")

	if(target)
		target.hallucination += 400