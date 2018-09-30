/mob/living/silicon/examine(mob/user) //Diplay's a silicon's Laws to ghosts
	if(laws && isobserver(user) && !istype(user,/mob/dead/observer/deafmute)) //Fuck off phantom mask users
		var/mob/dead/observer/fag = user
		if(!isAdminGhost(fag) && fag.mind && fag.mind.current)
			if(fag.mind.isScrying || fag.mind.current.ajourn) //Scrying or astral travel, fuck them.
				return
		to_chat(fag, "<b>[src] has the following laws:</b>")
		laws.show_laws(fag)
		investigation_log(I_GHOST, "|| had its laws checked by [key_name(fag)][fag.locked_to ? ", who was haunting [fag.locked_to]" : ""]")
