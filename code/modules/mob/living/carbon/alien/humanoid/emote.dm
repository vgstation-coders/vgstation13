/mob/living/carbon/alien/humanoid/emote(var/act,var/m_type=1,var/message = null, var/auto)
	if(timestopped)
		return //under effects of time magick
	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))
	var/muzzled = is_wearing_item(/obj/item/clothing/mask/muzzle, slot_wear_mask)

	switch(act)
		if("me")
			if(silent)
				return
			if(src.client)
				if(client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='warning>You cannot send IC messages (muted).</span>")
					return
				if(src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if(stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)

		if("custom")
			return custom_emote(m_type, message)
		if("sign")
			if(!src.restrained())
				message = text("<B>\The [src]</B> signs[(text2num(param) ? text(" the number []", text2num(param)) : null)].")
				m_type = VISIBLE
		if("burp")
			if(!muzzled)
				message = "<B>\The [src]</B> burps."
				m_type = HEARABLE
		if("deathgasp")
			message = "<B>\The [src]</B> lets out a waning guttural screech, green blood bubbling from its maw..."
			m_type = HEARABLE
		if("scratch")
			if(!src.restrained())
				message = "<B>\The [src]</B> scratches."
				m_type = VISIBLE
		if("whimper")
			if(!muzzled)
				message = "<B>\The [src]</B> whimpers."
				m_type = HEARABLE
		if("roar")
			if(!muzzled)
				message = "<B>\The [src]</B> roars."
				m_type = HEARABLE
		if("hiss")
			if(!muzzled)
				message = "<B>\The [src]</B> hisses."
				m_type = HEARABLE
		if("tail")
			message = "<B>\The [src]</B> waves its tail."
			m_type = VISIBLE
		if("gasp")
			message = "<B>\The [src]</B> gasps."
			m_type = HEARABLE
		if("shiver")
			message = "<B>\The [src]</B> shivers."
			m_type = HEARABLE
		if("drool")
			message = "<B>\The [src]</B> drools."
			m_type = VISIBLE
		if("scretch")
			if(!muzzled)
				message = "<B>\The [src]</B> scretches."
				m_type = HEARABLE
		if("choke")
			message = "<B>\The [src]</B> chokes."
			m_type = HEARABLE
		if("moan")
			message = "<B>\The [src]</B> moans!"
			m_type = HEARABLE
		if("nod")
			message = "<B>\The [src]</B> nods its head."
			m_type = VISIBLE
		if("sit")
			message = "<B>\The [src]</B> sits down."
			m_type = VISIBLE
		if("sway")
			message = "<B>\The [src]</B> sways around dizzily."
			m_type = VISIBLE
		if("sulk")
			message = "<B>\The [src]</B> sulks down sadly."
			m_type = VISIBLE
		if("twitch")
			message = "<B>\The [src]</B> twitches violently."
			m_type = VISIBLE
		if("dance")
			if(!src.restrained())
				message = "<B>\The [src]</B> dances around happily."
				m_type = VISIBLE
		if("roll")
			if(!src.restrained())
				message = "<B>\The [src]</B> rolls."
				m_type = VISIBLE
		if("shake")
			message = "<B>\The [src]</B> shakes its head."
			m_type = VISIBLE
		if("gnarl")
			if(!muzzled)
				message = "<B>\The [src]</B> gnarls and shows its teeth.."
				m_type = HEARABLE
		if("jump")
			message = "<B>\The [src]</B> jumps!"
			m_type = VISIBLE
		if("collapse")
			Paralyse(2)
			message = "<B>\The [src]</B> collapses!"
			m_type = HEARABLE
		if("help")
			to_chat(src, "burp, deathgasp, choke, collapse, dance, drool, gasp, shiver, gnarl, jump, moan, nod, roar, roll, scratch,\nscretch, shake, sign-#, sit, sulk, sway, tail, twitch, whimper")
		else
//			to_chat(custom_emote(VISIBLE, act) src, text("Invalid Emote: [act]"))
	if ((message && src.stat == 0))
		log_emote("[name]/[key] (@[x],[y],[z]): [message]")
		if (act == "roar")
			playsound(get_turf(src), 'sound/voice/hiss5.ogg', 40, 1, 1)
		if (act == "deathgasp")
			playsound(get_turf(src), 'sound/voice/hiss6.ogg', 80, 1, 1)
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return