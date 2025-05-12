var/datum/ui_state/debug_state/debug_state = new

/datum/ui_state/debug_state/can_use_topic(src_object, mob/user)
	if(user.check_rights(R_DEBUG))
		return UI_INTERACTIVE
	return UI_CLOSE
