/mob/living/silicon/robot/emote(var/act,var/m_type=1,var/message = null, var/auto)
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
				return custom_emote(m_type, message)

		if ("custom")
			return custom_emote(m_type, message)

		if ("salute")
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

		if ("clap")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = HEARABLE
		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings."
				m_type = HEARABLE

		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings ANGRILY!"
				m_type = HEARABLE

		if ("twitch")
			message = "<B>[src]</B> twitches violently."
			m_type = VISIBLE

		if ("twitch_s")
			message = "<B>[src]</B> twitches."
			m_type = VISIBLE

		if ("nod")
			message = "<B>[src]</B> nods."
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
				message = "<B>[src]</B> glares at [param]."
			else
				message = "<B>[src]</B> glares."

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
			playsound(get_turf(src), 'sound/machines/twobeep.ogg', 50, 0)
			m_type = VISIBLE

		if("scream")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> screams at [param]!"
			else
				message = "<B>[src]</B> screams!"
			playsound(get_turf(src), 'sound/machines/scream.ogg', 20, 0)
			m_type = HEARABLE

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
			playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 0)
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
			playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
			m_type = VISIBLE

		if("law")
			if (istype(module,/obj/item/weapon/robot_module/security))
				message = "<B>[src]</B> shows its legal authorization barcode."

				playsound(get_turf(src), 'sound/voice/biamthelaw.ogg', 50, 0)
				m_type = HEARABLE
			else
				to_chat(src, "You are not THE LAW, pal.")

		if("halt")
			if (istype(module,/obj/item/weapon/robot_module/security))
				message = "<B>[src]</B>'s speakers skreech, \"Halt! Security!\"."

				playsound(get_turf(src), 'sound/voice/halt.ogg', 50, 0)
				m_type = HEARABLE
			else
				to_chat(src, "You are not security.")

		if ("vent")
			if(world.time-lastvent >= 30 SECONDS)
				var/list/robotfarts = list("vents","shakes violently, then vents")
				var/robofart = pick(robotfarts)
				for(var/mob/living/M in loc)
					if(M != src && M.loc == src.loc && (M.lying || M.resting))
						if(istype(M, /mob/living/carbon/human/vox))
							visible_message("<span class = 'warning'><b>[src]</b> [robofart] oxygen in <b>[M]</b>'s face!</span>")
							if (M.internal != null && M.wear_mask && (M.wear_mask.clothing_flags & MASKINTERNALS))
								continue
							if(M.reagents)
								M.reagents.add_reagent(OXYGEN,rand(1,2))
								add_logs(src, M, "vented", admin = M.ckey ? TRUE : FALSE)//Only add this to the server logs if they're controlled by a player.
						else
							visible_message("<span class = 'warning'><b>[src]</b> [robofart] harmless gas in <b>[M]</b>'s face!</span>")
				message = ("<B>[src]</B> [robofart].")
				lastvent=world.time
				playsound(get_turf(src), 'sound/machines/pressurehiss.ogg', 20, 0)
				m_type = HEARABLE
			else
				message = ("<B>[src]</B>'s vents open, and nothing happens.")
				m_type = VISIBLE

		if ("help")
			to_chat(src, "salute, bow-(none)/mob, clap, flap, aflap, twitch, twitch_s, nod, deathgasp, glare-(none)/mob, scream-(none)/mob, vent, stare-(none)/mob, look, beep, ping, \nbuzz, law, halt")
		else
			to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")

	if ((message && src.stat == 0))
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return
