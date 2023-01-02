/spell/changeling/sting/blind
	name = "Blind Sting (20)"
	desc = "We sting a human, worsening their vision for half a minute before amplifying its effect for 20 seconds. It is more potent against humans with bad vision."
	abbreviation = "BS"
	hud_state = "blindsting"

	chemcost = 20


/spell/changeling/sting/blind/lingsting(var/mob/user, var/mob/living/target)
	if(!target)
		return

	if(target.disabilities & NEARSIGHTED)
		to_chat(target, "<span class='userdanger'>Your eyes burn terribly!</span>")
		target.eye_blind = 10
		target.eye_blurry = 20
		return

	to_chat(target, "<span class='userdanger'>Your eyes burn terribly and you lose the ability to see!</span>")
	target.disabilities |= NEARSIGHTED
	spawn(300)
		target.disabilities &= ~NEARSIGHTED

	target.eye_blind = 10
	target.eye_blurry = 20
	feedback_add_details("changeling_powers", "BS")
