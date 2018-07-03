/mob/living/silicon/robot/emote(var/act,var/m_type=1,var/message = null, var/auto)
	if(timestopped)
		return //under effects of time magick
	var/param = null
	if(findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	switch(act)
		if("me")
			if(client)
				if(client.prefs.muted & MUTE_IC)
					to_chat(src, "You cannot send IC messages (muted).")
					return
				if(client.handle_spam_prevention(message,MUTE_IC))
					return
			if(stat)
				return
			if(!(message))
				return
			else
				return custom_emote(m_type, message)

		if("custom")
			return custom_emote(m_type, message)

		if("salute")
			if(!locked_to)
				var/M = null
				if(param)
					for (var/mob/A in view(null, null))
						if(param == A.name)
							M = A
							break
				if(!M)
					param = null

				if(param)
					message = "<B>[src]</B> salutes to [param]."
				else
					message = "<B>[src]</b> salutes."
			m_type = VISIBLE
		if("bow")
			if(!locked_to)
				var/M = null
				if(param)
					for (var/mob/A in view(null, null))
						if(param == A.name)
							M = A
							break
				if(!M)
					param = null

				if(param)
					message = "<B>[src]</B> bows to [param]."
				else
					message = "<B>[src]</B> bows."
			m_type = VISIBLE

		if("clap")
			if(!incapacitated())
				message = "<B>[src]</B> clangs its modules together in a crude simulation of applause."
				m_type = HEARABLE
		if("flap")
			if(!incapacitated())
				if(module_active)
					var/obj/item/I = module_active
					message = "<B>[src]</B> flaps its [I.name]."
				else
					message = "<B>[src]</B> flaps its modules as though they were wings."
				m_type = VISIBLE

		if("aflap")
			if(!incapacitated())
				if(module_active)
					var/obj/item/I = module_active
					message = "<B>[src]</B> flaps its [I.name] ANGRILY!"
				else
					message = "<B>[src]</B> flaps its modules ANGRILY!"
				m_type = VISIBLE

		if("twitch")
			message = "<B>[src]</B> twitches violently."
			m_type = VISIBLE

		if("twitch_s")
			message = "<B>[src]</B> twitches."
			m_type = VISIBLE

		if("nod")
			message = "<B>[src]</B> nods."
			m_type = VISIBLE

		if("deathgasp")
			message = "<B>[src]</B> shudders violently for a moment, then becomes motionless, its eyes slowly darkening."
			m_type = VISIBLE

		if("glare")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if(param == A.name)
						M = A
						break
			if(!M)
				param = null

			if(param)
				message = "<B>[src]</B> glares at [param]."
			else
				message = "<B>[src]</B> glares."

		if("stare")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if(param == A.name)
						M = A
						break
			if(!M)
				param = null

			if(param)
				message = "<B>[src]</B> stares at [param]."
			else
				message = "<B>[src]</B> stares."

		if("look")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if(param == A.name)
						M = A
						break

			if(!M)
				param = null

			if(param)
				message = "<B>[src]</B> looks at [param]."
			else
				message = "<B>[src]</B> looks."
			m_type = VISIBLE

		if("beep")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if(param == A.name)
						M = A
						break
			if(!M)
				param = null

			if(param)
				message = "<B>[src]</B> beeps at [param]."
			else
				message = "<B>[src]</B> beeps."
			playsound(src, 'sound/machines/twobeep.ogg', 50, 0)
			m_type = VISIBLE

		if("ping")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if(param == A.name)
						M = A
						break
			if(!M)
				param = null

			if(param)
				message = "<B>[src]</B> pings at [param]."
			else
				message = "<B>[src]</B> pings."
			playsound(src, 'sound/machines/ping.ogg', 50, 0)
			m_type = VISIBLE

		if("buzz")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if(param == A.name)
						M = A
						break
			if(!M)
				param = null

			if(param)
				message = "<B>[src]</B> buzzes at [param]."
			else
				message = "<B>[src]</B> buzzes."
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
			m_type = VISIBLE

		if("law")
			if(module && (module.quirk_flags & MODULE_IS_THE_LAW))
				message = "<B>[src]</B> shows its legal authorization barcode."

				playsound(src, 'sound/voice/biamthelaw.ogg', 50, 0)
				m_type = HEARABLE
			else
				to_chat(src, "You are not THE LAW, pal.")

		if("halt")
			if(module && (module.quirk_flags & MODULE_IS_THE_LAW))
				message = "<B>[src]</B>'s speakers skreech, \"Halt! Security!\"."

				playsound(src, 'sound/voice/halt.ogg', 50, 0)
				m_type = HEARABLE
			else
				to_chat(src, "You are not security.")

		if("help")
			to_chat(src, "salute, bow-(none)/mob, clap, flap, aflap, twitch, twitch_s, nod, deathgasp, glare-(none)/mob, stare-(none)/mob, look, beep, ping, \nbuzz, law, halt")
		else
			to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")

	if (message && (src.stat == CONSCIOUS || act == "deathgasp"))
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return
