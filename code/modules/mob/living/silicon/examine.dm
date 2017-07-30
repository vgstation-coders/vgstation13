/mob/living/silicon/examine(mob/user) //Diplay's a silicon's Laws to ghosts
	if(laws && isobserver(user))//As a bastard child of robots, we don't call our parent's examine()
		var/mob/dead/observer/fag = user
		if(fag.mind)
			if(isAdminGhost(fag) || !(fag.mind.isScrying || fag.mind.current.ajourn))// Scrying or astral travel, fuck them.
				to_chat(fag, "<b>[src] has the following laws:</b>")
				laws.show_laws(fag)
