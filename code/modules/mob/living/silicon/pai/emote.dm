/mob/living/silicon/pai/emote(var/act,var/m_type=1,var/message = null, var/auto)
	if(timestopped)
		return //under effects of time magick
	var/param = null
	var/regex/reg = regex("(.+?)-(.+)")
	if(reg.Find(act, 1))
		param = reg.group[2]
		act = reg.group[1]

	var/regex/reg2 = regex("(.*?)s")
	var/regex/reg3 = regex("(.*?)_(.*)")
	if(reg2.Find(act, -1) && !reg3.Find(act, -2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	switch(act)
		if ("me")
			if (src.client)
				if(client.prefs.muted & MUTE_IC)
					to_chat(src, "You cannot send IC messages (muted).")
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!message)
				return
			else
				return custom_emote(1, message)

		if ("custom")
			return custom_emote(m_type, message)

		if ("deathgasp")
			message = "<span class='notice'>[src] flashes a message across its screen, \"Wiping core files. Please acquire a new personality to continue using pAI device functions.\"</span>"
			m_type = VISIBLE

		if ("glare")
			var/M = null
			if (param)
				var/H = get_holder_at_turf_level(src)
				for (var/mob/A in view(H))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> glares at [param]."
			else
				message = "<B>[src]</B> glares."

		if ("stare")
			var/M = null
			if (param)
				var/H = get_holder_at_turf_level(src)
				for (var/mob/A in view(H))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> stares at [param]."
			else
				message = "<B>[src]</B> stares."
			m_type = VISIBLE

		if ("look")
			var/M = null
			if (param)
				var/H = get_holder_at_turf_level(src)
				for (var/mob/A in view(H))
					if (param == A.name)
						M = A
						break

			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> looks at [param]."
			else
				message = "<B>[src]</B> looks."
			m_type = VISIBLE

		if("beep")
			var/M = null
			if(param)
				var/H = get_holder_at_turf_level(src)
				for (var/mob/A in view(H))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> beeps at [param]."
			else
				message = "<B>[src]</B> beeps."
			playsound(get_turf(src), 'sound/machines/twobeep.ogg', 50, 0)
			m_type = VISIBLE

		if("ping")
			var/M = null
			if(param)
				var/H = get_holder_at_turf_level(src)
				for (var/mob/A in view(H))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> pings at [param]."
			else
				message = "<B>[src]</B> pings."
			playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 0)
			m_type = VISIBLE

		if("buzz")
			var/M = null
			if(param)
				var/H = get_holder_at_turf_level(src)
				for (var/mob/A in view(H))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> buzzes at [param]."
			else
				message = "<B>[src]</B> buzzes."
			playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
			m_type = VISIBLE

		if("law")
			if (software.Find(SOFT_SS))
				message = "<B>[src]</B> shows its legal authorization barcode."

				playsound(get_turf(src), 'sound/voice/biamthelaw.ogg', 50, 0)
				m_type = VISIBLE
			else
				to_chat(src, "You don't have the right software to be THE LAW.")

		if("halt")
			if (software.Find(SOFT_SS))
				message = "<B>[src]</B>'s speakers skreech, \"Halt! Security!\"."

				playsound(get_turf(src), 'sound/voice/halt.ogg', 50, 0)
				m_type = HEARABLE
			else
				to_chat(src, "You have no Security software.")

		if ("help")
			to_chat(src, "deathgasp, glare-(none)/mob, stare-(none)/mob, look, beep, ping, buzz, law, halt")
		else
			to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")

	if (message && !isUnconscious())
		if (m_type & VISIBLE)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
