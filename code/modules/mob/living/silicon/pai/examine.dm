/mob/living/silicon/pai/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] <EM>[src]</EM>!\n"
	//expand on PAI status here
	msg += "*---------*</span>"
	to_chat(user, msg)
	if(pai_law0 && isobserver(user) && !istype(user,/mob/dead/observer/deafmute))
		var/mob/dead/observer/fag = user
		if(!isAdminGhost(fag) && fag.mind && fag.mind.current)
			if(fag.mind.isScrying || fag.mind.current.ajourn)
				return
		to_chat(fag, "<b>[src] has the following directives:</b>")
		show_directives(fag)
		investigation_log(I_GHOST, "|| had its pAI directives checked by [key_name(fag)][fag.locked_to ? ", who was haunting [fag.locked_to]" : ""]")