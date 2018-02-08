//The Pray verb. Often known as the IC adminhelp, or the crayon for cool shit trade
/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	if(say_disabled) //This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return

	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			to_chat(usr, "<span class='warning'>You cannot pray (muted).</span>")
			return
		if(src.client.handle_spam_prevention(msg, MUTE_PRAY))
			return

	var/orig_message = msg
	var/image/cross = image('icons/obj/storage/storage.dmi',"bible")
	msg = "<span class='notice'>[bicon(cross)] <b><font color='purple'>PRAY (DEITY:[ticker.Bible_deity_name]): </font>[key_name(src, 1)] (<A HREF='?_src_=holder;adminmoreinfo=[REF(src)]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=[REF(src)]'>PP</A>) (<A HREF='?_src_=vars;Vars=[REF(src)]'>VV</A>) (<A HREF='?_src_=holder;adminplayerobservejump=[REF(src)]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;adminspawncookie=[REF(src)]'>SC</a>) (<A HREF='?_src_=holder;BlueSpaceArtillery=[REF(src)]'>BSA</A>) (<A HREF='?_src_=holder;Assplode=[REF(src)]'>ASS</A>) (<A HREF='?_src_=holder;DealBrainDam=[REF(src)]'>BRAIN</A>) (<A HREF='?_src_=holder;PrayerReply=[REF(src)]'>RPLY</A>):</b> [msg]</span>"

	send_prayer_to_admins(msg, 'sound/effects/prayer.ogg')

	log_admin("PRAYER: [key_name(usr)] at [formatJumpTo(get_turf(usr))]: [orig_message]")
	if(!stat)
		usr.whisper(orig_message)
	to_chat(usr, "Your prayers have been received by the gods.")

	feedback_add_details("admin_verb", "PR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/Centcomm_announce(var/text , var/mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = "<span class='notice'><b>  CENTCOMM: [key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=[REF(Sender)]'>PP</A>) (<A HREF='?_src_=vars;Vars=[REF(Sender)]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=[REF(Sender)]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=[REF(Sender)]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=[REF(Sender)]'>BSA</A>) (<A HREF='?_src_=holder;CentcommReply=[REF(Sender)]'>RPLY</A>):</b> [msg]</span>"
	send_prayer_to_admins(msg, 'sound/effects/msn.ogg')

/proc/Syndicate_announce(var/text , var/mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = "<span class='notice'><b>  SYNDICATE: [key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=[REF(Sender)]'>PP</A>) (<A HREF='?_src_=vars;Vars=[REF(Sender)]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=[REF(Sender)]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=[REF(Sender)]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=[REF(Sender)]'>BSA</A>) (<A HREF='?_src_=holder;SyndicateReply=[REF(Sender)]'>RPLY</A>):</b> [msg]</span>"
	send_prayer_to_admins(msg, 'sound/effects/inception.ogg')

/proc/send_prayer_to_admins(var/msg,var/sound)
	for(var/client/C in admins)
		if(C.prefs.toggles & CHAT_PRAYER)
			if(C.prefs.special_popup)
				C << output(msg, "window1.msay_output") //If i get told to make this a proc imma be fuckin mad
			else
				to_chat(C, msg)
			C << sound
