

//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
var/list/adminhelp_ignored_words = list("unknown","the","a","an","of","monkey","alien","as")

/client/verb/adminhelp()
	set category = "Admin"
	set name = "Adminhelp"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<span class='red'>Error: Admin-PM: You cannot send adminhelps (Muted).</span>")
		return
	var/msg = input(usr, "What message would you like to send to the administrators?", "Send a message to admins", "") as null|text
	//clean the input msg
	if(!msg)
		return
	msg = trim_left(trim_right(sanitize(copytext(msg,1,MAX_MESSAGE_LEN))))
	if(!msg)
		return
	if(src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return
	var/original_msg = msg

	//explode the input msg into a list
	var/list/msglist = splittext(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	for(var/mob/M in mob_list)
		var/list/indexing = list(M.real_name, M.name)
		if(M.mind)
			indexing += M.mind.name

		for(var/string in indexing)
			var/list/L = splittext(string, " ")
			var/surname_found = 0
			//surnames
			for(var/i=L.len, i>=1, i--)
				var/word = ckey(L[i])
				if(word)
					surnames[word] = M
					surname_found = i
					break
			//forenames
			for(var/i=1, i<surname_found, i++)
				var/word = ckey(L[i])
				if(word)
					forenames[word] = M
			//ckeys
			ckeys[M.ckey] = M

	var/ai_found = 0
	msg = ""
	var/list/mobs_found = list()
	for(var/original_word in msglist)
		var/word = ckey(original_word)
		if(word)
			if(!(word in adminhelp_ignored_words))
				if(word == "ai")
					ai_found = 1
				else
					var/mob/found = ckeys[word]
					if(!found)
						found = surnames[word]
						if(!found)
							found = forenames[word]
					if(found)
						if(!(found in mobs_found))
							mobs_found += found
							if(!ai_found && isAI(found))
								ai_found = 1
							msg += "<b><font color='black'>[original_word] (<A HREF='?_src_=holder;adminmoreinfo=\ref[found]'>?</A>)</font></b> "
							continue
			msg += "[original_word] "

	if(!mob)
		return						//this doesn't happen

	var/ref_mob = "\ref[mob]"
	msg = "<span class='notice'><b><font color=red>HELP: </font>[key_name(src, 1)] (<A HREF='?_src_=holder;adminmoreinfo=[ref_mob]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=[ref_mob]'>PP</A>) (<a href='?_src_=holder;role_panel=[ref_mob]'>RP</a>) (<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=[ref_mob]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=[ref_mob]'>JMP</A>) (<A HREF='?_src_=holder;check_antagonist=1'>CA</A>) [ai_found ? " (<A HREF='?_src_=holder;adminchecklaws=[ref_mob]'>CL</A>)" : ""]:</b> [strict_ascii(msg)]</span>"

	//send this msg to all admins
	var/admin_number_afk = 0
	for(var/client/X in admins)
		if((R_ADMIN|R_MOD) & X.holder.rights)
			if(X.is_afk())
				admin_number_afk++
			if(X.prefs.toggles & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'
			X.output_to_special_tab(msg)

	//show it to the person adminhelping too
	output_to_special_tab("<span class='notice'>PM to-<b>Admins</b>: [original_msg]</span>")

	var/admin_number_present = admins.len - admin_number_afk
	log_admin("HELP: [key_name(src)]: [original_msg] - heard by [admin_number_present] non-AFK admins.")
	if(admin_number_present <= 0)
		if(!admin_number_afk)
			send2adminirc("HELP [key_name(src)]: [original_msg] - No admins online")
			send2admindiscord("**Help**: [key_name(src)]: `[replacetext(original_msg, "`", "\\`")]` - **No admins online**", TRUE)

		else
			send2adminirc("HELP [key_name(src)]: [original_msg] - All admins AFK ([admin_number_afk])")
			send2admindiscord("**Help**: [key_name(src)]: `[replacetext(original_msg, "`", "\\`")]` - **All admins AFK** ([admin_number_afk])", TRUE)

	else
		send2adminirc("HELP [key_name(src)]: [original_msg]")
		send2admindiscord("**Help**: [key_name(src)]: `[replacetext(original_msg, "`", "\\`")]` - **[admin_number_present]** Active admins, **[admin_number_afk]** AFK admins.")

	feedback_add_details("admin_verb","AH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
