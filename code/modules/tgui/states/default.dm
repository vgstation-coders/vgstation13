/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui state: default_state
 *
 * Checks a number of things -- mostly physical distance for humans
 * and view for robots.
 */

var/datum/ui_state/default/default_state = new

/datum/ui_state/default/can_use_topic(src_object, mob/user)
	return user.default_can_use_topic(src_object) // Call the individual mob-overridden procs.

/mob/proc/default_can_use_topic(src_object)
	return UI_CLOSE // Don't allow interaction by default.

/mob/living/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. > UI_CLOSE && loc) //must not be in nullspace.
		. = min(., shared_living_ui_distance(src_object)) // Check the distance...
	if(. == UI_INTERACTIVE && !ishigherbeing(src)) // unhandy living mobs can only look, not touch.
		return UI_UPDATE

/mob/living/silicon/robot/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. <= UI_DISABLED)
		return

	// Robots can interact with anything they can see.
	var/list/clientviewlist = getviewsize(client.view)
	if(get_dist(src, src_object) <= min(clientviewlist[1],clientviewlist[2]))
		return UI_INTERACTIVE
	return UI_DISABLED // Otherwise they can keep the UI open.

/mob/living/silicon/ai/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. < UI_INTERACTIVE)
		return

	// The AI can interact with anything it can see nearby, or with cameras while wireless control is enabled.
	if(!control_disabled && cameranet.checkTurfVis(get_turf(src_object)))
		return UI_INTERACTIVE
	return UI_CLOSE

/mob/living/silicon/pai/default_can_use_topic(src_object)
	// pAIs can only use themselves and itself.
	var/atom/src_atom = src_object
	if((src_object == src || istype(src_atom) && src_atom.loc == src) && !stat)
		return UI_INTERACTIVE
	else
		return min(..(), UI_UPDATE)
