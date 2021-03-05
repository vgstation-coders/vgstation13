/datum/admins/proc/toggle_tag_mode(var/mob/user)
	if (!check_rights(R_FUN))
		to_chat(user, "<span class='notice'>You need +FUN to do this.</span>")
		return

	if (ticker.tag_mode_enabled)
		var/confirm_cancel = alert(user, "Do you wish to cancel tag mode?", "Tag mode!", "Yes", "No")
		if (confirm_cancel == "Yes")
			message_admins("[key_name(user)] has cancelled tag mode.")
			log_admin("[key_name(user)] has cancelled tag mode.")
			ticker.cancel_tag_mode(user)
	else
		var/confirm = alert(user, "Do you wish to enable tag mode? All players spawn as mimes, one as a disguised clown changeling. Killing the clown changeling will grant its powers to its killer.", "Tag mode!", "Yes", "No")
		if (confirm == "Yes")
			message_admins("[key_name(user)] has cancelled tag mode.")
			log_admin("[key_name(user)] has cancelled tag mode.")
			ticker.tag_mode(user)
