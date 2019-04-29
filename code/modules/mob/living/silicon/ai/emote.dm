/mob/living/silicon/ai/emote(var/act,var/m_type=1,var/message  =null, var/auto)
	if(timestopped)
		return // time is frozen
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
			playsound(src, 'sound/machines/twobeep.ogg', 50, 0)
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
			playsound(src, 'sound/machines/ping.ogg', 50, 0)
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
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
			m_type = VISIBLE

	if (message && !isUnconscious())
		if (m_type & VISIBLE)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
