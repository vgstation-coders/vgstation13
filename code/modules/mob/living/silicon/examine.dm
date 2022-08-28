/mob/living/silicon/examine(mob/user) //Diplay's a silicon's Laws to ghosts
	if(laws && isobserver(user) && !istype(user,/mob/dead/observer/deafmute)) //Fuck off phantom mask users
		var/mob/dead/observer/ghost = user
		if(!isAdminGhost(ghost) && ghost.mind && ghost.mind.current)
			if(ghost.mind.isScrying || ghost.mind.current.ajourn) //Scrying or astral travel, fuck them.
				return
		to_chat(ghost, "<b>[src] has the following laws:</b>")
		laws.show_laws(ghost)
		investigation_log(I_GHOST, "|| had its laws checked by [key_name(ghost)][ghost.locked_to ? ", who was haunting [ghost.locked_to]" : ""]")
