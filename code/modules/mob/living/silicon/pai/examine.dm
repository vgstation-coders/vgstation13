/mob/living/silicon/pai/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] <EM>[src]</EM>!\n"
	//expand on PAI status here
	msg += "*---------*</span>"
	to_chat(user, msg)
	if(pai_law0 && isobserver(user) && !istype(user,/mob/dead/observer/deafmute))
		var/mob/dead/observer/Soy = user
		if(!isAdminGhost(Soy) && Soy.mind && Soy.mind.current)
			if(Soy.mind.isScrying || Soy.mind.current.ajourn)
				return
		to_chat(Soy, "<b>[src] has the following directives:</b>")
		show_directives(Soy)
		investigation_log(I_GHOST, "|| had its pAI directives checked by [key_name(Soy)][Soy.locked_to ? ", who was haunting [Soy.locked_to]" : ""]")
