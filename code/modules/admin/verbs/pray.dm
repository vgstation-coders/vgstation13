//The Pray verb. Often known as the IC adminhelp, or the crayon for cool shit trade
/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	if(say_disabled) //This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	msg = strip_html_simple(msg)
	if(!msg)
		return

	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			to_chat(usr, "<span class='warning'>You cannot pray (muted).</span>")
			return
		if(src.client.handle_spam_prevention(msg, MUTE_PRAY))
			return

	var/orig_message = msg
	var/deity = DecidePrayerGod(usr)

	for(var/datum/religion/R in ticker.religions)
		if(R.interceptPrayer(src, deity, orig_message))
			return

	var/image/cross = image('icons/obj/storage/bibles.dmi',"bible")
	msg = "<span class='notice'>[bicon(cross)] <b><font color='purple'>PRAY (DEITY:[deity]): </font>[key_name(src, 1)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[src]'>VV</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[src]'>JMP</A>) (<A HREF='?_src_=holder;sound_reply=\ref[src]'>SR</A>) (<a href='?_src_=holder;role_panel=\ref[src]'>RP</a>) (<A HREF='?_src_=holder;adminspawncookie=\ref[src]'>SC</a>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[src]'>BSA</A>) (<A HREF='?_src_=holder;Assplode=\ref[src]'>ASS</A>) (<A HREF='?_src_=holder;DealBrainDam=\ref[src]'>BRAIN</A>) (<A HREF='?_src_=holder;PrayerReply=\ref[src]'>RPLY</A>):</b> [msg]</span>"

	send_prayer_to_admins(msg, orig_message, 'sound/effects/prayer.ogg', "Prayer", key_name(usr), get_turf(usr))

	if(!stat)
		usr.whisper(orig_message)
	to_chat(usr, "Your prayers have been received by the gods.")

	feedback_add_details("admin_verb", "PR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/Centcomm_announce(var/text , var/mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	var/admin_msg = msg
	msg = "<span class='notice'><b>  CENTCOMM: [key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;check_antagonist=1'>CA</A>) (<a href='?_src_=holder;role_panel=\ref[Sender]'>RP</a>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;CentcommReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	send_prayer_to_admins(msg, admin_msg, 'sound/effects/msn.ogg', "Centcomm", key_name(Sender), get_turf(Sender))

/proc/Syndicate_announce(var/text , var/mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	var/admin_msg = msg
	msg = "<span class='notice'><b>  SYNDICATE: [key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;SyndicateReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	send_prayer_to_admins(msg, admin_msg, 'sound/effects/inception.ogg', "Syndicate", key_name(Sender), get_turf(Sender))

/proc/NarSie_announce(var/text , var/mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	var/admin_msg = msg
	msg = "<span class='notice'><b>  NAR-SIE: [key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;NarSieDevour=\ref[Sender]'>GIB</A>) (<A HREF='?_src_=holder;NarSieReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	send_prayer_to_admins(msg, admin_msg, 'sound/effects/commune.ogg', "Nar-Sie", key_name(Sender), get_turf(Sender))

/proc/send_prayer_to_admins(var/msg,var/admin_msg,var/sound,var/type,var/key,var/jumploc)
	var/admin_number_afk = 0
	for(var/client/C in admins)
		if((R_ADMIN|R_MOD) & C.holder.rights)
			if(C.is_afk())
				admin_number_afk++
		if(C.prefs.toggles & CHAT_PRAYER)
			C.output_to_special_tab(msg)
			C << sound

	var/admin_number_present = admins.len - admin_number_afk
	if(admin_number_present <= 0)
		if(!admin_number_afk)
			send2adminirc("[uppertext(type)] [key]: [admin_msg] - No admins online")
			send2admindiscord("**[type]**: [key]: `[replacetext(admin_msg, "`", "\\`")]` - **No admins online**", TRUE)

		else
			send2adminirc("[uppertext(type)] [key]: [admin_msg] - All admins AFK ([admin_number_afk])")
			send2admindiscord("**[type]**: [key]: `[replacetext(admin_msg, "`", "\\`")]` - **All admins AFK** ([admin_number_afk])", TRUE)

	else
		send2adminirc("[uppertext(type)] [key]: [admin_msg]")
		send2admindiscord("**[type]**: [key]: `[replacetext(admin_msg, "`", "\\`")]` - **[admin_number_present]** Active admins, **[admin_number_afk]** AFK admins.")

	log_admin("[uppertext(type)]: [key] at [formatJumpTo(jumploc)]: [admin_msg]")
