/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui state: always_state
 *
 * Always grants the user UI_INTERACTIVE. Period.
 */

var/datum/ui_state/always_state/always_state = new

/datum/ui_state/always_state/can_use_topic(src_object, mob/user)
	return UI_INTERACTIVE
