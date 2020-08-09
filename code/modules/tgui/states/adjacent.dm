/**
 * tgui state: adjacent_state
 *
 * Checks that the src_object is adjacent to the user, in addition to the basic sanity checks.
 *
 * Copyright (c) 2020 /vg/station coders
 * SPDX-License-Identifier: MIT
 */

var/datum/ui_state/adjacent_state/adjacent_state = new

/datum/ui_state/adjacent_state/can_use_topic(atom/src_object, mob/user)
	if(!src_object.Adjacent(user))
		return UI_CLOSE
	return user.shared_ui_interaction(src_object)
