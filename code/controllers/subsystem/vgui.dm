/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

var/datum/subsystem/vgui/SSvgui

/datum/subsystem/vgui
	name     = "vgui"
	flags    = SS_FIRE_IN_LOBBY
	wait     = 0.9 SECONDS
	priority = SS_PRIORITY_VGUI

	/// A list of UIs scheduled to process
	var/list/current_run = list()
	/// A list of open UIs
	var/list/open_uis = list()
	/// A list of open UIs, grouped by src_object.
	var/list/open_uis_by_src = list()
	/// The HTML base used for all UIs.
	var/basehtml

/datum/subsystem/vgui/New()
	NEW_SS_GLOBAL(SSvgui)

/datum/subsystem/vgui/Initialize(timeofday)
	basehtml = file2text('vgui/public/vgui.html')
	..()

/datum/subsystem/vgui/Shutdown()
	close_all_uis()

/datum/subsystem/vgui/stat_entry()
	..("P:[length(open_uis)]")

/datum/subsystem/vgui/fire(resumed = FALSE)
	if(!resumed)
		src.current_run = open_uis.Copy()
	// Cache for sanic speed (lists are references anyways)
	var/list/current_run = src.current_run
	while(current_run.len)
		var/datum/vgui/ui = current_run[current_run.len]
		current_run.len--
		// TODO: Move user/src_object check to process()
		if(ui?.user && ui.src_object)
			ui.process(wait * 0.1)
		else
			open_uis.Remove(ui)
		if(MC_TICK_CHECK)
			return

/**
 * public
 *
 * Requests a usable vgui window from the pool.
 * Returns null if pool was exhausted.
 *
 * required user mob
 * return datum/vgui
 */
/datum/subsystem/vgui/proc/request_pooled_window(mob/user)
	if(!user.client)
		return null
	var/list/windows = user.client.vgui_windows
	var/window_id
	var/datum/vgui_window/window
	var/window_found = FALSE
	// Find a usable window
	for(var/i in 1 to VGUI_WINDOW_HARD_LIMIT)
		window_id = VGUI_WINDOW_ID(i)
		window = windows[window_id]
		// As we are looping, create missing window datums
		if(!window)
			window = new(user.client, window_id, pooled = TRUE)
		// Skip windows with acquired locks
		if(window.locked)
			continue
		if(window.status == VGUI_WINDOW_READY)
			return window
		if(window.status == VGUI_WINDOW_CLOSED)
			window.status = VGUI_WINDOW_LOADING
			window_found = TRUE
			break
	if(!window_found)
		log_vgui(user, "Error: Pool exhausted",
			context = "SSvgui/request_pooled_window")
		return null
	return window

/**
 * public
 *
 * Force closes all vgui windows.
 *
 * required user mob
 */
/datum/subsystem/vgui/proc/force_close_all_windows(mob/user)
	log_vgui(user, context = "SSvgui/force_close_all_windows")
	if(user.client)
		user.client.vgui_windows = list()
		for(var/i in 1 to VGUI_WINDOW_HARD_LIMIT)
			var/window_id = VGUI_WINDOW_ID(i)
			user << browse(null, "window=[window_id]")

/**
 * public
 *
 * Force closes the vgui window by window_id.
 *
 * required user mob
 * required window_id string
 */
/datum/subsystem/vgui/proc/force_close_window(mob/user, window_id)
	log_vgui(user, context = "SSvgui/force_close_window")
	// Close all vgui datums based on window_id.
	for(var/datum/vgui/ui in user.vgui_open_uis)
		if(ui.window && ui.window.id == window_id)
			ui.close(can_be_suspended = FALSE)
	// Unset machine just to be sure.
	user.unset_machine()
	// Close window directly just to be sure.
	user << browse(null, "window=[window_id]")

/**
 * public
 *
 * Try to find an instance of a UI, and push an update to it.
 *
 * required user mob The mob who opened/is using the UI.
 * required src_object datum The object/datum which owns the UI.
 * optional ui datum/vgui The UI to be updated, if it exists.
 * optional force_open bool If the UI should be re-opened instead of updated.
 *
 * return datum/vgui The found UI.
 */
/datum/subsystem/vgui/proc/try_update_ui(
		mob/user,
		datum/src_object,
		datum/vgui/ui)
	// Look up a UI if it wasn't passed
	if(isnull(ui))
		ui = get_open_ui(user, src_object)
	// Couldn't find a UI.
	if(isnull(ui))
		return null
	ui.process_status()
	// UI ended up with the closed status
	// or is actively trying to close itself.
	// FIXME: Doesn't actually fix the paper bug.
	if(ui.status <= UI_CLOSE)
		ui.close()
		return null
	ui.send_update()
	return ui

/**
 * public
 *
 * Get a open UI given a user and src_object.
 *
 * required user mob The mob who opened/is using the UI.
 * required src_object datum The object/datum which owns the UI.
 *
 * return datum/vgui The found UI.
 */
/datum/subsystem/vgui/proc/get_open_ui(mob/user, datum/src_object)
	var/key = "[ref(src_object)]"
	// No UIs opened for this src_object
	if(isnull(open_uis_by_src[key]) || !istype(open_uis_by_src[key], /list))
		return null
	for(var/datum/vgui/ui in open_uis_by_src[key])
		// Make sure we have the right user
		if(ui.user == user)
			return ui
	return null

/**
 * public
 *
 * Update all UIs attached to src_object.
 *
 * required src_object datum The object/datum which owns the UIs.
 *
 * return int The number of UIs updated.
 */
/datum/subsystem/vgui/proc/update_uis(datum/src_object)
	var/count = 0
	var/key = "[ref(src_object)]"
	// No UIs opened for this src_object
	if(isnull(open_uis_by_src[key]) || !istype(open_uis_by_src[key], /list))
		return count
	for(var/datum/vgui/ui in open_uis_by_src[key])
		// Check if UI is valid.
		if(ui?.src_object && ui.user && ui.src_object.ui_host(ui.user))
			ui.process(wait * 0.1, force = 1)
			count++
	return count

/**
 * public
 *
 * Close all UIs attached to src_object.
 *
 * required src_object datum The object/datum which owns the UIs.
 *
 * return int The number of UIs closed.
 */
/datum/subsystem/vgui/proc/close_uis(datum/src_object)
	var/count = 0
	var/key = "[ref(src_object)]"
	// No UIs opened for this src_object
	if(isnull(open_uis_by_src[key]) || !istype(open_uis_by_src[key], /list))
		return count
	for(var/datum/vgui/ui in open_uis_by_src[key])
		// Check if UI is valid.
		if(ui?.src_object && ui.user && ui.src_object.ui_host(ui.user))
			ui.close()
			count++
	return count

/**
 * public
 *
 * Close all UIs regardless of their attachment to src_object.
 *
 * return int The number of UIs closed.
 */
/datum/subsystem/vgui/proc/close_all_uis()
	var/count = 0
	for(var/key in open_uis_by_src)
		for(var/datum/vgui/ui in open_uis_by_src[key])
			// Check if UI is valid.
			if(ui?.src_object && ui.user && ui.src_object.ui_host(ui.user))
				ui.close()
				count++
	return count

/**
 * public
 *
 * Update all UIs belonging to a user.
 *
 * required user mob The mob who opened/is using the UI.
 * optional src_object datum If provided, only update UIs belonging this src_object.
 *
 * return int The number of UIs updated.
 */
/datum/subsystem/vgui/proc/update_user_uis(mob/user, datum/src_object)
	var/count = 0
	if(length(user?.vgui_open_uis) == 0)
		return count
	for(var/datum/vgui/ui in user.vgui_open_uis)
		if(isnull(src_object) || ui.src_object == src_object)
			ui.process(wait * 0.1, force = 1)
			count++
	return count

/**
 * public
 *
 * Close all UIs belonging to a user.
 *
 * required user mob The mob who opened/is using the UI.
 * optional src_object datum If provided, only close UIs belonging this src_object.
 *
 * return int The number of UIs closed.
 */
/datum/subsystem/vgui/proc/close_user_uis(mob/user, datum/src_object)
	var/count = 0
	if(length(user?.vgui_open_uis) == 0)
		return count
	for(var/datum/vgui/ui in user.vgui_open_uis)
		if(isnull(src_object) || ui.src_object == src_object)
			ui.close()
			count++
	return count

/**
 * private
 *
 * Add a UI to the list of open UIs.
 *
 * required ui datum/vgui The UI to be added.
 */
/datum/subsystem/vgui/proc/on_open(datum/vgui/ui)
	var/key = "[ref(ui.src_object)]"
	if(isnull(open_uis_by_src[key]) || !istype(open_uis_by_src[key], /list))
		open_uis_by_src[key] = list()
	ui.user.vgui_open_uis |= ui
	var/list/uis = open_uis_by_src[key]
	uis |= ui
	open_uis |= ui

/**
 * private
 *
 * Remove a UI from the list of open UIs.
 *
 * required ui datum/vgui The UI to be removed.
 *
 * return bool If the UI was removed or not.
 */
/datum/subsystem/vgui/proc/on_close(datum/vgui/ui)
	var/key = "[ref(ui.src_object)]"
	if(isnull(open_uis_by_src[key]) || !istype(open_uis_by_src[key], /list))
		return FALSE
	// Remove it from the list of processing UIs.
	open_uis.Remove(ui)
	// If the user exists, remove it from them too.
	if(ui.user)
		ui.user.vgui_open_uis.Remove(ui)
	var/list/uis = open_uis_by_src[key]
	uis.Remove(ui)
	if(length(uis) == 0)
		open_uis_by_src.Remove(key)
	return TRUE

/**
 * private
 *
 * Handle client logout, by closing all their UIs.
 *
 * required user mob The mob which logged out.
 *
 * return int The number of UIs closed.
 */
/datum/subsystem/vgui/proc/on_logout(mob/user)
	close_user_uis(user)

/**
 * private
 *
 * Handle clients switching mobs, by transferring their UIs.
 *
 * required user source The client's original mob.
 * required user target The client's new mob.
 *
 * return bool If the UIs were transferred.
 */
/datum/subsystem/vgui/proc/on_transfer(mob/source, mob/target)
	// The old mob had no open UIs.
	if(length(source?.vgui_open_uis) == 0)
		return FALSE
	if(isnull(target.vgui_open_uis) || !istype(target.vgui_open_uis, /list))
		target.vgui_open_uis = list()
	// Transfer all the UIs.
	for(var/datum/vgui/ui in source.vgui_open_uis)
		// Inform the UIs of their new owner.
		ui.user = target
		target.vgui_open_uis.Add(ui)
	// Clear the old list.
	source.vgui_open_uis.Cut()
	return TRUE
