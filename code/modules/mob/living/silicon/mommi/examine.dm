/mob/living/silicon/robot/mommi/examine(mob/user)

	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n"

	msg += {"<p>[desc]</p>"}

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
			msg += "<B>It looks severely burnt and heat-warped!</B>\n"
	if (health < -maxHealth*0.5)
		msg += "It looks barely operational.\n"
	msg += "</span>"

	if(head_state)
		msg += "It is wearing [bicon(head_state)] [head_state] on its head.\n"
	if(tool_state)
		var/obj/item/I = tool_state
		msg += "Its utility claw is gripping [bicon(I)] [I.gender==PLURAL?"some":"a"] [I.name].\n"

	if(opened)
		msg += "<span class='warning'>Its cover is open and the power cell is [cell ? "installed" : "missing"].</span>\n"
	else
		msg += "Its cover is closed.\n"

	if(cell && cell.charge <= 0)
		msg += "<span class='warning'>Its battery indicator is blinking red!</span>\n"

	switch(src.stat)
		if(CONSCIOUS)
			if(!src.client)
				msg += "It appears to be in stand-by mode.\n" //afk
		if(UNCONSCIOUS)
			msg += "<span class='warning'>It doesn't seem to be responding.</span>\n"
		if(DEAD)
			msg += "<span class='deadsay'>It looks completely unsalvageable.</span>\n"
	msg += "*---------*</span>"

	to_chat(user, msg)

	if(laws && isobserver(user) && !istype(user,/mob/dead/observer/deafmute)) //As a bastard child of robots, we don't call our parent's examine()
		var/mob/dead/observer/fag = user
		if(!isAdminGhost(fag) && fag.mind && fag.mind.current)
			if(fag.mind.isScrying || fag.mind.current.ajourn)// Scrying or astral travel, fuck them.
				return
		to_chat(fag, "<b>[src] has the following laws:</b>")
		laws.show_laws(fag)
		investigation_log(I_GHOST, "|| had its laws checked by [key_name(fag)][fag.locked_to ? ", who was haunting [fag.locked_to]" : ""]")
