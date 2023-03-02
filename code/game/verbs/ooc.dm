/// If non-null, all non-admin OOC messages will be this color.
/// Format: "#RRBBGG"
var/adminbus_ooc_color

/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return
	if(IsGuestKey(key))
		to_chat(src, "Guests may not use OOC.")
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	msg = parse_emoji(msg, ooc_mode = TRUE)
	if(!msg)
		return

	if(!(prefs.toggles & CHAT_OOC))
		to_chat(src, "<span class='warning'>You have OOC muted.</span>")
		return

	if(!holder)
		if(!ooc_allowed)
			to_chat(src, "<span class='warning'>OOC is globally muted</span>")
			return
		if(!dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='warning'>OOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='warning'>You cannot use OOC (muted).</span>")
			return
		if(oocban_isbanned(ckey) || iscluwnebanned(mob))
			to_chat(src, "<span class='warning'>You cannot use OOC (banned).</span>")
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		/*if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return
		*/
		if(!isnewplayer(mob) && ((copytext(msg, 1, 2) in list(".",";",":","#")) || (findtext(lowertext(copytext(msg, 1, 5)), "say"))))
			if(alert("Your message \"[msg]\" looks like it was meant for in game communication, say it in OOC?", "Meant for OOC?", "No", "Yes") != "Yes")
				return
	log_ooc("[mob.name]/[key] (@[mob.x],[mob.y],[mob.z]): [msg]")

	// browserOutput.css and browserOutput_dark.css determine the default OOC color.
	// adminbus_ooc_color is set by adminbus.
	var/admin_color

	if(global.adminbus_ooc_color)
		admin_color = global.adminbus_ooc_color

	if(holder && !holder.fakekey && (holder.rights & R_ADMIN) && config.allow_admin_ooccolor)
		admin_color = src.prefs.ooccolor

	for(var/client/C in clients)
		if(!(C.prefs.toggles & CHAT_OOC) || iscluwnebanned(C.mob))
			continue

		var/display_name = src.key
		if(holder && holder.fakekey)
			if(C.holder)
				display_name = "[holder.fakekey]/([src.key])"
			else
				display_name = holder.fakekey

		var/output = "<span class='bold'>OOC: [display_name]: [msg]</span>"
		if(admin_color)
			output = "<font color='[admin_color]'>[output]</font>"
		else
			output = "<span class='ooc'>[output]</span>"
		to_chat(C, output)

/client/proc/set_ooc()
	set name = "Set Player OOC Colour"
	set desc = "Set the OOC color for all players."
	set category = "Fun"

	switch(alert(usr, "", "Set Player OOC Colour", "Reset", "Set"))
		if("Reset")
			global.adminbus_ooc_color = null
		if("Set")
			global.adminbus_ooc_color = input(usr, "Set the OOC color for all players.", "Set Player OOC Colour", global.adminbus_ooc_color) as null|color

// Stealing it back :3c -Nexypoo
/client/verb/looc(msg as text)
	set name = "LOOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return
	if(IsGuestKey(key))
		to_chat(src, "Guests may not use OOC.")
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	msg = parse_emoji(msg, ooc_mode = TRUE)
	if(!msg)
		return

	if(!(prefs.toggles & CHAT_LOOC))
		to_chat(src, "<span class='warning'>You have LOOC muted.</span>")
		return

	if(!holder)
		if(!looc_allowed)
			to_chat(src, "<span class='warning'>LOOC is globally muted</span>")
			return
		if(!dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='warning'>LOOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='warning'>You cannot use LOOC (muted).</span>")
			return
		if(oocban_isbanned(ckey) || iscluwnebanned(mob))
			to_chat(src, "<span class='warning'>You cannot use LOOC (banned).</span>")
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		/*if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in LOOC: [msg]")
			return
		*/
		if((copytext(msg, 1, 2) in list(".",";",":","#")) || (findtext(lowertext(copytext(msg, 1, 5)), "say")))
			if(alert("Your message \"[msg]\" looks like it was meant for in game communication, say it in LOOC?", "Meant for LOOC?", "No", "Yes") != "Yes")
				return
	log_ooc("(LOCAL) [mob.name]/[key] (@[mob.x],[mob.y],[mob.z]): [msg]")
	var/list/heard
	var/mob/living/silicon/ai/AI
	if(!isAI(src.mob))
		heard = get_hearers_in_view(7, src.mob)
	else
		AI = src.mob
		heard = get_hearers_in_view(7, (istype(AI.eyeobj) ? AI.eyeobj : AI)) //if it doesn't have an eye somehow give it just the AI mob itself
	for(var/mob/M in heard)
		if(AI == M)
			continue
		if(!M.client)
			continue
		var/client/C = M.client
		if (C in admins)
			continue //they are handled after that
		if(isAIEye(M))
			var/mob/camera/aiEye/E = M
			if(E.ai)
				C = E.ai.client
		if(C.prefs.toggles & CHAT_LOOC)
			var/display_name = src.key
			var/is_living = isliving(src.mob) //Ghosts will show up with their ckey, living people show up with their names
			if(holder)
				if(holder.fakekey)
					if(C.holder)
						display_name = "[holder.fakekey]/([src.key])"
					else
						display_name = holder.fakekey
			to_chat(C, "<font color='#6699CC'><span class='looc'><span class='prefix'>LOOC:</span> <EM>[is_living ? src.mob.name : display_name]:</EM> <span class='message'>[msg]</span></span></font>")

	for(var/client/C in admins)
		if(C.prefs.toggles & CHAT_LOOC)
			var/prefix = "(R)LOOC"
			if (C.mob in heard)
				prefix = "LOOC"
			to_chat(C, "<font color='#6699CC'><span class='looc'><span class='prefix'>[prefix]:</span> <EM>[src.key]/[src.mob.name]:</EM> <span class='message'>[msg]</span></span></font>")
	if(istype(AI))
		var/client/C = AI.client
		if (C in admins)
			return //already been handled

		if(C.prefs.toggles & CHAT_LOOC)
			var/display_name = src.key
			var/is_living = isliving(src.mob)
			if(holder)
				if(holder.fakekey)
					if(C.holder)
						display_name = "[holder.fakekey]/([src.key])"
					else
						display_name = holder.fakekey
			to_chat(C, "<font color='#6699CC'><span class='looc'><span class='prefix'>LOOC:</span> <EM>[is_living ? src.mob.name : display_name]:</EM> <span class='message'>[msg]</span></span></font>")
