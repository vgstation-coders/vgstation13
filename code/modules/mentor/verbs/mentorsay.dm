/client/proc/cmd_mentor_say(msg as text)
	set category = "Mentor"
	set name = "Msay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	if(!check_mentor())	return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)	return

	log_mentor("[key_name(src)] : [msg]")

	if(check_rights(R_ADMIN,0))
		msg = "<span class='mentoradmin'><span class='prefix'>MENTOR:</span> <EM>[src.ckey]</EM> : <span class='message'>[msg]</span></span>"
		mentors << msg
	else
		msg = "<span class='mentor'><span class='prefix'>MENTOR:</span> <EM>[src.ckey]</EM> : <span class='message'>[msg]</span></span>"
		mentors << msg
