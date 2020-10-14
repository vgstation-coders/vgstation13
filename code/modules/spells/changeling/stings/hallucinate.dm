/spell/changeling/sting/hallucinate
	name = "Hallucination Sting"
	desc = "We silently sting the victim with powerful hallucinogen, causing them to hallucinate after roughly 45 seconds."
	abbreviation = "HS"

	silent = 1
	delay = 45 SECONDS


/spell/changeling/sting/hallucinate/lingsting(var/mob/user, var/mob/living/target)
	if(!target)
		return

	feedback_add_details("changeling_powers", "HS")

	if(target)
		target.hallucination += 400