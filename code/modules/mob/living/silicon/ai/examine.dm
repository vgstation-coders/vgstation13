/mob/living/silicon/ai/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] <EM>[src]</EM>!\n"
	msg += "<span class='warning'>"
	if (getBruteLoss())
		if (getBruteLoss() < maxHealth*0.5)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
	if (getFireLoss())
		if (getFireLoss() < maxHealth*0.5)
			msg += "It looks slightly charred.\n"
		else
			msg += "<B>Its casing is melted and heat-warped!</B>\n"
	if (health < -maxHealth*0.5)
		msg += "It looks barely operational.\n"
	msg += "</span>"

	switch(stat)
		if(UNCONSCIOUS)
			msg += "<span class='warning'>It is non-responsive and displaying the text: \"RUNTIME: Sensory Overload, stack 26/3\".</span>\n"
		if(DEAD)
			msg += "<span class='deadsay'>[name] E_UNEXPECTED 0x8000FFFF. If you are experiencing difficulty with an A.I. you are installing or running, contact central command with this displaying the error message.</span>\n"
	msg += "*---------*</span>"

	to_chat(user, msg)

	..()
