/mob/living/silicon/robot/mommi/emote(var/act,var/m_type=1,var/message = null, var/auto)
	if(timestopped)
		return //under effects of time magick
	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	switch(act)
		if ("help")
			to_chat(src, "Available emotes: aflap, bow, clap, custom, flap, twitch, twitch_s, salute, nod, deathgasp, me, glare, stare, shrug, beep, ping, buzz, look")
			return
		if ("salute")
			//if (!src.locked_to)
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> salutes to [param]."
			else
				message = "<B>[src]</b> salutes."
			m_type = VISIBLE
		if ("bow")
			if (!src.locked_to)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> bows to [param]."
				else
					message = "<B>[src]</B> bows."
			m_type = VISIBLE
		if ("shrug")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> shrugs at [param]."
			else
				message = "<B>[src]</B> shrugs."
			m_type = VISIBLE

		if ("clap")
			if (!incapacitated())
				message = "<B>[src]</B> clangs \his utility claws together in a crude simulation of applause."
				m_type = HEARABLE
		if ("flap")
			if (!incapacitated())
				message = "<B>[src]</B> flaps \his utility arms as through they were wings."
				m_type = HEARABLE

		if ("aflap")
			if (!incapacitated())
				message = "<B>[src]</B> flaps his utility arms ANGRILY!"
				m_type = HEARABLE

		if ("custom")
			var/input = copytext(sanitize(input("Choose an emote to display.") as text|null),1,MAX_MESSAGE_LEN)
			if (!input)
				return
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				m_type = VISIBLE
			else if (input2 == "Hearable")
				m_type = HEARABLE
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			message = "<B>[src]</B> [input]"

		if ("me")
			if (src.client)
				if(client.prefs.muted & MUTE_IC)
					to_chat(src, "You cannot send IC messages (muted).")
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			else
				message = "<B>[src]</B> [message]"

		if ("twitch")
			message = "<B>[src]</B> twitches violently."
			m_type = VISIBLE

		if ("twitch_s")
			message = "<B>[src]</B> twitches."
			m_type = VISIBLE

		if ("nod")
			message = "<B>[src]</B> bobs \his body in a rough approximation of nodding."
			m_type = VISIBLE

		if ("deathgasp")
			message = "<B>[src]</B> shudders violently for a moment, then becomes motionless, its eyes slowly darkening."
			m_type = VISIBLE

		if ("glare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> glares at [param] as best a robot spider can glare."
			else
				message = "<B>[src]</B> glares as best a robot spider can glare."

		if ("stare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> stares at [param]."
			else
				message = "<B>[src]</B> stares."

		if ("look")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
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
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> beeps at [param]."
			else
				message = "<B>[src]</B> beeps."
			playsound(src, 'sound/machines/twobeep.ogg', 50, 0)
			m_type = VISIBLE

		if("ping")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> pings at [param]."
			else
				message = "<B>[src]</B> pings."
			playsound(src, 'sound/machines/ping.ogg', 50, 0)
			m_type = VISIBLE

		if("buzz")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> buzzes at [param]."
			else
				message = "<B>[src]</B> buzzes."
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
			m_type = VISIBLE

		if("comment")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> cheerily vocalizes at [param]."
			else
				message = "<B>[src]</B> vocalizes."
			playsound(src, get_sfx("mommicomment"),50, 0)
			m_type = VISIBLE

		else
//			to_chat(custom_emote(VISIBLE, act) src, text("Invalid Emote: [], use *help", act))
	if ((message && src.stat == 0))
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return