/mob/living/silicon/robot/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is [icon2html(src, user)] \a <EM>[src]</EM>!\n"
	if(desc)
		msg += "[desc]\n"

	var/obj/act_module = get_active_held_item()
	if(act_module)
		msg += "It is holding [icon2html(act_module, user)] \a [act_module].\n"
	msg += status_effect_examines()
	msg += "<span class='warning'>"
	if (src.getBruteLoss())
		if (src.getBruteLoss() < maxHealth*0.5)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
	if (getFireLoss() || getToxLoss())
		var/overall_fireloss = getFireLoss() + getToxLoss()
		if (overall_fireloss < maxHealth * 0.5)
			msg += "It looks slightly charred.\n"
		else
			msg += "<B>It looks severely burnt and heat-warped!</B>\n"
	if (src.health < -maxHealth*0.5)
		msg += "It looks barely operational.\n"
	if (src.fire_stacks < 0)
		msg += "It's covered in water.\n"
	else if (src.fire_stacks > 0)
		msg += "It's coated in something flammable.\n"
	msg += "</span>"

	if(opened)
		msg += "<span class='warning'>Its cover is open and the power cell is [cell ? "installed" : "missing"].</span>\n"
	else
		msg += "Its cover is closed[locked ? "" : ", and looks unlocked"].\n"

	if(cell && cell.charge <= 0)
		msg += "<span class='warning'>Its battery indicator is blinking red!</span>\n"

	if(is_servant_of_ratvar(src) && get_dist(user, src) <= 1 && !stat) //To counter pseudo-stealth by using headlamps
		msg += "<span class='warning'>Its eyes are glowing a blazing yellow!</span>\n"

	switch(stat)
		if(CONSCIOUS)
			if(shell)
				msg += "It appears to be an [deployed ? "active" : "empty"] AI shell.\n"
			else if(!client)
				msg += "It appears to be in stand-by mode.\n" //afk
		if(UNCONSCIOUS)
			msg += "<span class='warning'>It doesn't seem to be responding.</span>\n"
		if(DEAD)
			msg += "<span class='deadsay'>It looks like its system is corrupted and requires a reset.</span>\n"
	msg += "*---------*</span>"

	to_chat(user, msg)

	..()
