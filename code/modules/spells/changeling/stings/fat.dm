/spell/changeling/sting/fat
	name = "Fat Sting (5)"
	desc = "We silently sting a human or ourselves, forcing them to rapidly accumulate fat."
	abbreviation = "FS"
	hud_state = "fatsting"

	silent = 1
	chemcost = 5
	delay = 15 SECONDS

/spell/changeling/sting/fat/lingsting(var/mob/user, var/mob/living/target)
	if(!target)
		return
	if(target.overeatduration < 100)
		to_chat(target, "<span class='danger'>Your stomach churns violently and you begin to feel bloated.</span>")
		target.overeatduration += 600 // 500 is minimum fat threshold.
	else
		to_chat(target, "<span class='notice'>Your stomach feels uneasy, but the feeling quickly subsides.</span>")

	feedback_add_details("changeling_powers", "FS")

/spell/changeling/sting/unfat
	name = "Unfat Sting (5)"
	desc = "We quietly sting a human or ourselves, forcing them to rapidly metabolize their fat."
	abbreviation = "UF"
	hud_state = "unfatsting"

	silent = 1
	chemcost = 5
	delay = 15 SECONDS

/spell/changeling/sting/unfat/lingsting(var/mob/user, var/mob/living/target)
	if(!target)
		return
	if(target.overeatduration > 100)
		to_chat(target, "<span class='danger'>Your stomach churns violently and you begin to feel skinnier.</span>")
		target.overeatduration = 0
		target.nutrition = max(target.nutrition - 200, 0)
	else
		to_chat(target, "<span class='notice'>Your stomach feels uneasy, but the feeling quickly subsides.</span>")

	feedback_add_details("changeling_powers", "US")
