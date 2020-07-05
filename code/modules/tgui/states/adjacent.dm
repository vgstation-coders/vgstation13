/**
 * tgui state: adjacent_state
 *
 * Checks that the src_object is adjacent to the user, in addition to the basic sanity checks.
 */

var/datum/ui_state/adjacent_state/adjacent_state = new

/datum/ui_state/adjacent_state/can_use_topic(src_object, mob/user)
	if(!user.Adjacent(src_object))
		return UI_CLOSE
	return user.shared_ui_interaction(src_object)
