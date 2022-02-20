/mob/living/silicon/examine(mob/user) //Diplay's a silicon's Laws to ghosts
	if(laws && isobserver(user) && !istype(user,/mob/dead/observer/deafmute)) //Fuck off phantom mask users
		var/mob/dead/observer/obs = user
		if(!isAdminGhost(obs) && obs.mind && obs.mind.current)
			if(obs.mind.isScrying || obs.mind.current.ajourn) //Scrying or astral travel, fuck them.
				return
		to_chat(obs, "<b>[src] has the following laws:</b>")
		laws.show_laws(obs,obs.antagHUD)
		investigation_log(I_GHOST, "|| had its laws checked by [key_name(obs)][obs.locked_to ? ", who was haunting [obs.locked_to]" : ""]")
