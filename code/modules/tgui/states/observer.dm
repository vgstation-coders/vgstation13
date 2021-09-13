/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui state: observer_state
 *
 * Checks that the user is an observer/ghost.
 */

var/datum/ui_state/observer_state/observer_state = new

/datum/ui_state/observer_state/can_use_topic(src_object, mob/user)
	if(isobserver(user))
		return UI_INTERACTIVE
	return UI_CLOSE

