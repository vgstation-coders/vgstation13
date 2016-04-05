 /**
  * tgui state: hands_state
  *
  * Checks that the src_object is in the user's hands.
 **/

/var/datum/ui_state/hands_state/hands_state = new

/datum/ui_state/hands_state/can_use_topic(src_object, mob/user)
	. = user.shared_ui_interaction(src_object)
	if(. > UI_CLOSE)
		return min(., user.hands_can_use_topic(src_object))

/mob/proc/hands_can_use_topic(src_object)
	return UI_CLOSE

/mob/living/hands_can_use_topic(src_object)
	if(src_object == l_hand || src_object == r_hand)
		return UI_INTERACTIVE
	return UI_CLOSE
