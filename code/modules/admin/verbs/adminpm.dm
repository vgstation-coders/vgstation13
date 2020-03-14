//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M as mob in mob_list)
	set category = null
	set name = "Admin PM Mob"
	if(!holder)
		to_chat(src, "<span class='red'>Error: Admin-PM-Context: Only administrators may use this command.</span>")
		return
	if( !ismob(M) || !M.client )
		return
	cmd_admin_pm(M.client,null)
	feedback_add_details("admin_verb","APMM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//For blobs
/client/proc/cmd_admin_pm_context_special(var/obj/effect/blob/core/C in blob_cores)
	set category = null
	set name = "Admin PM Overmind"
	if(!holder)
		to_chat(src, "<span class='red'>Error: Admin-PM-Context: Only administrators may use this command.</span>")
		return
	if(!istype(C) || !C.overmind || !C.overmind.client)
		return
	cmd_admin_pm(C.overmind.client,null)
	feedback_add_details("admin_verb","APMCS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM"
	if(!holder)
		to_chat(src, "<span class='red'>Error: Admin-PM-Panel: Only administrators may use this command.</span>")
		return
	var/list/client/targets[0]
	for(var/client/T)
		if(T.mob)
			if(istype(T.mob, /mob/new_player))
				targets["(New Player) - [T]"] = T
			else if(istype(T.mob, /mob/dead/observer))
				targets["[T.mob.name](Ghost) - [T]"] = T
			else
				targets["[T.mob.real_name](as [T.mob.name]) - [T]"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) as null|anything in sorted
	if (!target)
		return FALSE
	cmd_admin_pm(targets[target],null)
	feedback_add_details("admin_verb","APM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client
/client/proc/cmd_admin_pm(var/client/C, var/msg)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<span class='red'>Error: Private-Message: You are unable to use PM-s (muted).</span>")
		return

	if(!istype(C,/client))
		if(holder)
			to_chat(src, "<span class='red'>Error: Private-Message: Client not found.</span>")
		else
			adminhelp(msg)	//admin we are replying to left. adminhelp instead
		return

	/*if(C && C.last_pm_recieved + config.simultaneous_pm_warning_timeout > world.time && holder)
		//send a warning to admins, but have a delay popup for mods
		if(holder.rights & R_ADMIN)
			to_chat(src, "<span class='warning'><b>Simultaneous PMs warning:</b> that player has been PM'd in the last [config.simultaneous_pm_warning_timeout / 10] seconds by: [C.ckey_last_pm]</span>")
		else
			if(alert("That player has been PM'd in the last [config.simultaneous_pm_warning_timeout / 10] seconds by: [C.ckey_last_pm]","Simultaneous PMs warning","Continue","Cancel") == "Cancel")
				return*/

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = input(src, "Message:", "Private message to [key_name(C, 0, 0, showantag = FALSE)]", "") as text | null

		if(!msg)
			return

		if(!C)
			if(holder)
				to_chat(src, "<span class='red'>Error: Admin-PM: Client not found.</span>")
			else
				adminhelp(msg)	//admin we are replying to has vanished, adminhelp instead
			return

	if (src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG,0))
		msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
		if(!msg)
			return

	var/recieve_color = "purple"
	var/send_pm_type = " "
	var/recieve_pm_type = "Player"


	if(holder)
		//mod PMs are maroon
		//PMs sent from admins and mods display their rank
		if(holder)
			if( holder.rights & R_MOD )
				recieve_color = "maroon"
			else
				recieve_color = "red"
			if(holder.fakekey)
				send_pm_type = "Admin "
				recieve_pm_type = "Admin"
			else
				send_pm_type = holder.rank + " "
				recieve_pm_type = holder.rank

	else if(!C.holder)
		to_chat(src, "<span class='red'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</span>")
		return

	var/recieve_message = ""

	if(holder && !C.holder)
		recieve_message = "<font color='[recieve_color]' size='4'><b>-- Administrator private message --</b></font>\n"

		//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
		if(config.popup_admin_pm)
			spawn(0)	//so we don't hold the caller proc up
				var/sender = src
				var/sendername = key
				var/reply = input(C, msg,"[recieve_pm_type] PM from-[sendername]", "") as text|null		//show message and await a reply
				if(C && reply)
					if(sender)
						C.cmd_admin_pm(sender,reply)										//sender is still about, let's reply to them
					else
						adminhelp(reply)													//sender has left, adminhelp instead
				return

	recieve_message = "\[[time_stamp()]] <font color='[recieve_color]'>[recieve_pm_type] PM from-<b>[key_name(src, C, C.holder ? 1 : 0)]</b>: [strict_ascii(msg)]</font>"
	C.output_to_special_tab(recieve_message, force_focus = TRUE)

	output_to_special_tab("<span class='notice'>[send_pm_type]PM to-<b>[key_name(C, src, holder ? 1 : 0)]</b>: [msg]</span>")

	/*if(holder && !C.holder)
		C.last_pm_received = world.time
		C.ckey_last_pm = ckey*/

	//Makes Dreamseeker flash on Windows, regardless of window flashing preference.
	window_flash(C, 1)

	//play the recieving admin the adminhelp sound (if they have them enabled)
	//non-admins shouldn't be able to disable this
	if(C.prefs.toggles & SOUND_ADMINHELP)
		C << 'sound/effects/adminhelp.ogg'

	/*
	if(C.holder)
		if(holder)	//both are admins
			if(holder.rank == "Moderator") //If moderator
				to_chat(C, "<font color='maroon'>Mod PM from-<b>[key_name(src, C, 1)]</b>: [msg]</font>")
				to_chat(src, "<span class='notice'>Mod PM to-<b>[key_name(C, src, 1)]</b>: [msg]</span>")
			else
				to_chat(C, "<span class='red'>Admin PM from-<b>[key_name(src, C, 1)]</b>: [msg]</span>")
				to_chat(src, "<span class='notice'>Admin PM to-<b>[key_name(C, src, 1)]</b>: [msg]</span>")

		else		//recipient is an admin but sender is not
			to_chat(C, "<span class='red'>Reply PM from-<b>[key_name(src, C, 1)]</b>: [msg]</span>")
			to_chat(src, "<span class='notice'>PM to-<b>Admins</b>: [msg]</span>")

		//play the recieving admin the adminhelp sound (if they have them enabled)
		if(C.prefs.toggles & SOUND_ADMINHELP)
			C << 'sound/effects/adminhelp.ogg'

	else
		if(holder)	//sender is an admin but recipient is not. Do BIG RED TEXT
			if(holder.rank == "Moderator")
				to_chat(C, "<font color='maroon'>Mod PM from-<b>[key_name(src, C, 0)]</b>: [msg]</font>")
				to_chat(C, "<font color='maroon'><i>Click on the moderators's name to reply.</i></font>")
				to_chat(src, "<span class='notice'>Mod PM to-<b>[key_name(C, src, 1)]</b>: [msg]</span>")
			else
				to_chat(C, "<font color='red' size='4'><b>-- Administrator private message --</b></font>")
				to_chat(C, "<span class='red'>Admin PM from-<b>[key_name(src, C, 0)]</b>: [msg]</span>")
				to_chat(C, "<span class='red'><i>Click on the administrator's name to reply.</i></span>")
				to_chat(src, "<span class='notice'>Admin PM to-<b>[key_name(C, src, 1)]</b>: [msg]</span>")

			//always play non-admin recipients the adminhelp sound
			C << 'sound/effects/adminhelp.ogg'

			//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
			if(config.popup_admin_pm)
				spawn()	//so we don't hold the caller proc up
					var/sender = src
					var/sendername = key
					var/reply = input(C, msg,"Admin PM from-[sendername]", "") as text|null		//show message and await a reply
					if(C && reply)
						if(sender)
							C.cmd_admin_pm(sender,reply)										//sender is still about, let's reply to them
						else
							adminhelp(reply)													//sender has left, adminhelp instead
					return

		else		//neither are admins
			to_chat(src, "<span class='red'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</span>")
			return
	*/

	log_admin("PM: [key_name(src)]->[key_name(C)]: [msg]")

	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/X in admins)
		//check client/X is an admin and isn't the sender or recipient
		if(X == C || X == src)
			continue
		if(X.key!=key && X.key!=C.key && (X.holder.rights & R_ADMIN) || (X.holder.rights & R_MOD) )
			X.output_to_special_tab("<B><span class='notice'>PM: [key_name(src, X, 0)]-&gt;[key_name(C, X, 0)]:</B> <span class='notice'>[msg]</span></span>")
