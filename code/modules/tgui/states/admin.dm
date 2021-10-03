/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui state: admin_state
 *
 * Checks that the user is an admin, end-of-story.
 */

var/datum/ui_state/admin_state/admin_state = new

/datum/ui_state/admin_state/can_use_topic(src_object, mob/user)
	if(user.check_rights(R_ADMIN))
		return UI_INTERACTIVE
	return UI_CLOSE
