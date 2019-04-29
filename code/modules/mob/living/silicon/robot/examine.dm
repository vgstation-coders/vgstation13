/mob/living/silicon/robot/examine(mob/user)
	var/msg = {"<span class='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>[custom_name ? ", [modtype] [braintype]" : ""]!\n"}
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

	if(module_active)
		var/obj/item/I = module_active
		msg += "It's using [I.gender==PLURAL?"some":"a"] [bicon(I)] [I.name] as its active module.\n"
		if(isgripper(I))
			var/obj/item/weapon/gripper/G = module_active
			if(G.wrapped)
				msg += "Its [G.name] is gripping [G.wrapped.gender==PLURAL?"some":"a"] [bicon(G.wrapped)] [G.wrapped.name].\n"

	if(opened)
		msg += "<span class='warning'>Its cover is open and the power cell is [cell ? "installed" : "missing"].</span>\n"
	else
		msg += "Its cover is closed.\n"

	if(!cell || (cell && cell.charge <= 0))
		msg += "<span class='warning'>Its battery indicator is blinking red!</span>\n"

	switch(stat)
		if(CONSCIOUS)
			if(!client)
				msg += "It appears to be in stand-by mode.\n" //afk
		if(UNCONSCIOUS)
			msg += "<span class='warning'>It doesn't seem to be responding.</span>\n"
		if(DEAD)
			msg += "<span class='warning'>It is broken beyond functioning.</span>\n"
			if(!client)
				msg += "<span class='deadsay'>It looks completely unsalvageable.</span>\n" //ghosted
	msg += "*---------*</span>"

	to_chat(user, msg)

	..()
