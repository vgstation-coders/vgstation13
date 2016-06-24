/mob/living/carbon/monkey/emote(var/act,var/m_type=1,var/message = null)
	if(timestopped) return //under effects of time magick
	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	var/muzzled = istype(wear_mask, /obj/item/clothing/mask/muzzle)

	switch(act)
		if ("me")
			if(silent)
				return
			if (client)
				if (client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='warning'>You cannot send IC messages (muted).</span>")
					return
				if (client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)


		if ("custom")
			return custom_emote(m_type, message)

		if ("airguitar")
			if (!restrained())
				message = "<B>\The [src]</B> is strumming the air and headbanging like a safari chimp."
				m_type = VISIBLE

		if ("blink_r")
			message = "<B>\The [src]</B> blinks rapidly."
			m_type = VISIBLE

		if("sign")
			if (!restrained())
				message = text("<B>\The [name]</B> signs[].", (text2num(param) ? text(" the number []", text2num(param)) : null))
				m_type = VISIBLE
		if("scratch")
			if (!restrained())
				message = "<B>\The [name]</B> scratches."
				m_type = VISIBLE
		if("whimper")
			if (!muzzled)
				message = "<B>\The [name]</B> whimpers."
				m_type = HEARABLE
		if("roar")
			if (!muzzled)
				message = "<B>\The [name]</B> roars."
				m_type = HEARABLE
		if("tail")
			message = "<B>\The [name]</B> waves his tail."
			m_type = VISIBLE
		if("gasp")
			message = "<B>\The [name]</B> gasps."
			m_type = HEARABLE
		if("shiver")
			message = "<B>\The [name]</B> shivers."
			m_type = HEARABLE
		if("drool")
			message = "<B>\The [name]</B> drools."
			m_type = VISIBLE
		if("paw")
			if (!restrained())
				message = "<B>\The [name]</B> flails his paw."
				m_type = VISIBLE
		if("scretch")
			if (!muzzled)
				message = "<B>\The [name]</B> scretches."
				m_type = HEARABLE
		if("choke")
			message = "<B>\The [name]</B> chokes."
			m_type = HEARABLE
		if("moan")
			message = "<B>\The [name]</B> moans!"
			m_type = HEARABLE
		if("nod")
			message = "<B>\The [name]</B> nods his head."
			m_type = VISIBLE
		if("sit")
			message = "<B>\The [name]</B> sits down."
			m_type = VISIBLE
		if("sway")
			message = "<B>\The [name]</B> sways around dizzily."
			m_type = VISIBLE
		if("sulk")
			message = "<B>\The [name]</B> sulks down sadly."
			m_type = VISIBLE
		if("twitch")
			message = "<B>\The [name]</B> twitches violently."
			m_type = VISIBLE
		if("dance")
			if (!restrained())
				message = "<B>\The [name]</B> dances around happily."
				m_type = VISIBLE
		if("roll")
			if (!restrained())
				message = "<B>\The [name]</B> rolls."
				m_type = VISIBLE
		if("shake")
			message = "<B>\The [name]</B> shakes his head."
			m_type = VISIBLE
		if("gnarl")
			if (!muzzled)
				message = "<B>\The [name]</B> gnarls and shows his teeth.."
				m_type = HEARABLE
		if("jump")
			message = "<B>\The [name]</B> jumps!"
			m_type = VISIBLE
		if ("spin")
			message = "<B>\The [src]</B> spins out of control!"
			m_type = VISIBLE
		if("collapse")
			Paralyse(2)
			message = text("<B>\The []</B> collapses!", src)
			m_type = HEARABLE
		if("deathgasp")
			message = "<b>\The [name]</b> lets out a faint chimper as it collapses and stops moving..."
			m_type = VISIBLE

		if ("cough")
			if (!muzzled)
				message = "<B>[src]</B> coughs!"
			else
				message = "<B>[src]</B> makes a strong noise."
			m_type = HEARABLE
		if("help")
			to_chat(src, "choke, collapse, cough, dance, deathgasp, drool, gasp, shiver, gnarl, jump, paw, moan, nod, roar, roll, scratch,\nscretch, shake, sign-#, sit, sulk, sway, tail, twitch, whimper")
		else
//			to_chat(custom_emote(VISIBLE, act) src, text("Invalid Emote: []", act))
	if ((message && stat == 0))
		if(client)
			log_emote("[name]/[key] (@[x],[y],[z]): [message]")
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(703)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(746)
	return