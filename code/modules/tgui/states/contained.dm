/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * vgui state: contained_state
 *
 * Checks that the user is inside the src_object.
 */

var/datum/ui_state/contained_state/contained_state = new

/datum/ui_state/contained_state/can_use_topic(atom/src_object, mob/user)
	if(!src_object.contains(user))
		return UI_CLOSE
	return user.shared_ui_interaction(src_object)
