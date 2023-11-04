/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * vgui datum (represents a UI).
 */
/datum/vgui
	/// The mob who opened/is using the UI.
	var/mob/user
	/// The object which owns the UI.
	var/datum/src_object
	/// The title of te UI.
	var/title
	/// The window_id for browse() and onclose().
	var/datum/vgui_window/window
	/// Key that is used for remembering the window geometry.
	var/window_key
	/// Deprecated: Window size.
	var/window_size
	/// The interface (template) to be used for this UI.
	var/interface
	/// Update the UI every MC tick.
	var/autoupdate = TRUE
	/// If the UI has been initialized yet.
	var/initialized = FALSE
	/// Time of opening the window.
	var/opened_at
	/// Stops further updates when close() was called.
	var/closing = FALSE
	/// The status/visibility of the UI.
	var/status = UI_INTERACTIVE
	/// Topic state used to determine status/interactability.
	var/datum/ui_state/state = null

/**
 * public
 *
 * Create a new UI.
 *
 * required user mob The mob who opened/is using the UI.
 * required src_object datum The object or datum which owns the UI.
 * required interface string The interface used to render the UI.
 * optional title string The title of the UI.
 * optional ui_x int Deprecated: Window width.
 * optional ui_y int Deprecated: Window height.
 *
 * return datum/vgui The requested UI.
 */
/datum/vgui/New(mob/user, datum/src_object, interface, title, ui_x, ui_y)
	log_vgui(user,
		"new [interface] fancy [user?.client?.prefs.vgui_fancy]",
		src_object = src_object)
	src.user = user
	src.src_object = src_object
	src.window_key = "[ref(src_object)]-main"
	src.interface = interface
	if(title)
		src.title = title
	src.state = src_object.ui_state(user)
	// Deprecated
	if(ui_x && ui_y)
		src.window_size = list(ui_x, ui_y)

/datum/vgui/Destroy()
	user = null
	src_object = null
	return ..()

/**
 * public
 *
 * Open this UI (and initialize it with data).
 *
 * return bool - TRUE if a new pooled window is opened, FALSE in all other situations including if a new pooled window didn't open because one already exists.
 */
/datum/vgui/proc/open()
	if(!user.client)
		return FALSE
	if(window)
		return FALSE
	process_status()
	if(status < UI_UPDATE)
		return FALSE
	window = SSvgui.request_pooled_window(user)
	if(!window)
		return FALSE
	opened_at = world.time
	window.acquire_lock(src)
	if(!window.is_ready())
		window.initialize(
			fancy = user.client.prefs.vgui_fancy,
			inline_assets = list(/datum/asset/simple/vgui)
		)
	else
		window.send_message("ping")
	window.send_asset(/datum/asset/simple/fontawesome)
	window.send_asset(/datum/asset/simple/tgfont)
	for(var/asset in src_object.ui_assets(user))
		window.send_asset(asset)
	window.send_message("update", get_payload(
		with_data = TRUE,
		with_static_data = TRUE))
	SSvgui.on_open(src)

	return TRUE

/**
 * public
 *
 * Close the UI.
 *
 * optional can_be_suspended bool
 */
/datum/vgui/proc/close(can_be_suspended = TRUE)
	if(closing)
		return
	closing = TRUE
	// If we don't have window_id, open proc did not have the opportunity
	// to finish, therefore it's safe to skip this whole block.
	if(window)
		// Windows you want to keep are usually blue screens of death
		// and we want to keep them around, to allow user to read
		// the error message properly.
		window.release_lock()
		window.close(can_be_suspended)
		src_object.ui_close(user)
		SSvgui.on_close(src)
	state = null
	qdel(src)

/**
 * public
 *
 * Enable/disable auto-updating of the UI.
 *
 * required value bool Enable/disable auto-updating.
 */
/datum/vgui/proc/set_autoupdate(autoupdate)
	src.autoupdate = autoupdate

/**
 * public
 *
 * Replace current ui.state with a new one.
 *
 * required state datum/ui_state/state Next state
 */
/datum/vgui/proc/set_state(datum/ui_state/state)
	src.state = state

/**
 * public
 *
 * Makes an asset available to use in vgui.
 *
 * required asset datum/asset
 *
 * return bool - true if an asset was actually sent
 */
/datum/vgui/proc/send_asset(datum/asset/asset)
	if(!window)
		CRASH("send_asset() was called either without calling open() first or when open() did not return TRUE.")
	return window.send_asset(asset)

/**
 * public
 *
 * Send a full update to the client (includes static data).
 *
 * optional custom_data list Custom data to send instead of ui_data.
 * optional force bool Send an update even if UI is not interactive.
 */
/datum/vgui/proc/send_full_update(custom_data, force)
	if(!user.client || !initialized || closing)
		return
	var/should_update_data = force || status >= UI_UPDATE
	window.send_message("update", get_payload(
		custom_data,
		with_data = should_update_data,
		with_static_data = TRUE))

/**
 * public
 *
 * Send a partial update to the client (excludes static data).
 *
 * optional custom_data list Custom data to send instead of ui_data.
 * optional force bool Send an update even if UI is not interactive.
 */
/datum/vgui/proc/send_update(custom_data, force)
	if(!user.client || !initialized || closing)
		return
	var/should_update_data = force || status >= UI_UPDATE
	window.send_message("update", get_payload(
		custom_data,
		with_data = should_update_data))

/**
 * private
 *
 * Package the data to send to the UI, as JSON.
 *
 * return list
 */
/datum/vgui/proc/get_payload(custom_data, with_data, with_static_data)
	var/list/json_data = list()
	json_data["config"] = list(
		"title" = title,
		"status" = status,
		"interface" = interface,
		"window" = list(
			"key" = window_key,
			"size" = window_size,
			"fancy" = user.client.prefs.vgui_fancy,
			"locked" = TRUE,
		),
		"client" = list(
			"ckey" = user.client.ckey,
			"address" = user.client.address,
			"computer_id" = user.client.computer_id,
		),
		"user" = list(
			"name" = "[user]",
			"observer" = isobserver(user),
		),
	)
	var/data = custom_data || with_data && src_object.ui_data(user)
	if(data)
		json_data["data"] = data
	var/static_data = with_static_data && src_object.ui_static_data(user)
	if(static_data)
		json_data["static_data"] = static_data
	if(src_object.vgui_shared_states)
		json_data["shared"] = src_object.vgui_shared_states
	return json_data

/**
 * private
 *
 * Run an update cycle for this UI. Called internally by SSvgui
 * every second or so.
 */
/datum/vgui/proc/process(delta_time, force = FALSE)
	if(closing)
		return
	var/datum/host = src_object.ui_host(user)
	// If the object or user died (or something else), abort.
	if(!src_object || !host || !user || !window)
		close(can_be_suspended = FALSE)
		return
	// Validate ping
	if(!initialized && world.time - opened_at > VGUI_PING_TIMEOUT)
		log_vgui(user, "Error: Zombie window detected, closing.",
			window = window,
			src_object = src_object)
		close(can_be_suspended = FALSE)
		return
	// Update through a normal call to vgui_interact
	if(status != UI_DISABLED && (autoupdate || force))
		src_object.vgui_interact(user, src)
		return
	// Update status only
	var/needs_update = process_status()
	if(status <= UI_CLOSE)
		close()
		return
	if(needs_update)
		window.send_message("update", get_payload())

/**
 * private
 *
 * Updates the status, and returns TRUE if status has changed.
 */
/datum/vgui/proc/process_status()
	var/prev_status = status
	status = src_object.ui_status(user, state)
	return prev_status != status

/**
 * private
 *
 * Callback for handling incoming vgui messages.
 */
/datum/vgui/proc/on_message(type, list/payload, list/href_list)
	// Pass act type messages to ui_act
	if(type && copytext(type, 1, 5) == "act/")
		var/act_type = copytext(type, 5)
		log_vgui(user, "Action: [act_type] [href_list["payload"]]",
			window = window,
			src_object = src_object)
		process_status()
		if(src_object.ui_act(act_type, payload, src, state))
			SSvgui.update_uis(src_object)
		return FALSE
	switch(type)
		if("ready")
			initialized = TRUE
		if("pingReply")
			initialized = TRUE
		if("suspend")
			close(can_be_suspended = TRUE)
		if("close")
			close(can_be_suspended = FALSE)
		if("log")
			if(href_list["fatal"])
				close(can_be_suspended = FALSE)
		if("setSharedState")
			if(status != UI_INTERACTIVE)
				return
			if(!src_object.vgui_shared_states)
				src_object.vgui_shared_states = list()
			src_object.vgui_shared_states[href_list["key"]] = href_list["value"]
			SSvgui.update_uis(src_object)
