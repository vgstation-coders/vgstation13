/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui state: admin_state
 *
 * Checks if the user has specific admin permissions.
 */

var/list/datum/ui_state/admin_state/admin_states = list()

/datum/ui_state/admin_state
	/// The specific admin permissions required for the UI using this state.
	VAR_FINAL/required_perms = R_ADMIN

/datum/ui_state/admin_state/New(required_perms = R_ADMIN)
	. = ..()
	src.required_perms = required_perms

/datum/ui_state/admin_state/can_use_topic(src_object, mob/user)
	if(user.check_rights(required_perms))
		return UI_INTERACTIVE
	return UI_CLOSE

/datum/ui_state/admin_state/variable_edited(variable_name, old_value, new_value)
	if(variable_name == NAMEOF(src, required_perms))
		return 1 // block var edit
	return ..()
