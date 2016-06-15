

//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
var/list/adminhelp_ignored_words = list("unknown","the","a","an","of","monkey","alien","as")

/client/verb/adminhelp(msg as text)
	set category = "Admin"
	set name = "Adminhelp"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Admin-PM: You cannot send adminhelps (Muted).</font>")
		return
	if(src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	//clean the input msg
	if(!msg)	return
	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)	return
	var/original_msg = msg

	var/ref_mob = "\ref[mob]"
	msg = "\[[time_stamp()]] <span class='notice'><b><font color=red>HELP: </font>[key_name(src, 1)] (<A HREF='?_src_=holder;adminmoreinfo=[ref_mob]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=[ref_mob]'>PP</A>) (<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=[ref_mob]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=[ref_mob]'>JMP</A>) (<A HREF='?_src_=holder;check_antagonist=1'>CA</A>):</b> [msg]</span>"

	//send this msg to all admins
	var/admin_number_afk = 0
	for(var/client/X in admins)
		if((R_ADMIN|R_MOD) & X.holder.rights)
			if(X.is_afk())
				admin_number_afk++
			if(X.prefs.toggles & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'
			if(X.prefs.special_popup)
				X << output(msg, "window1.msay_output")
			else
				to_chat(X, msg)

	//show it to the person adminhelping too
	if(src.prefs.special_popup)
		src << output("\[[time_stamp()]] <span class='info'>PM to - <b>Admins</b>: [original_msg]</span>", "window1.msay_output")
	else
		to_chat(src, "<font color='blue'>PM to-<b>Admins</b>: [original_msg]</font>")

	var/admin_number_present = admins.len - admin_number_afk
	log_admin("HELP: [key_name(src)]: [original_msg] - heard by [admin_number_present] non-AFK admins.")
	return
