/mob/living/silicon/examine(mob/user) //Diplay's a silicon's Laws to ghosts
	if(laws && isobserver(user))
		var/mob/dead/observer/fag = user
		if(fag.mind)
			if(isAdminGhost(fag) || !(fag.mind.isScrying || fag.mind.current.ajourn))// Scrying or astral travel, fuck them.
				to_chat(fag, "<b>[src] has the following laws:</b>")
				laws.show_laws(fag)
				investigation_log(I_GHOST, "|| had its laws checked by [key_name(ghost)][ghost.locked_to ? ", who was haunting [ghost.locked_to]" : ""]")
