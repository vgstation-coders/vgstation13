/**********************************************************
NANO UI FRAMEWORK

nanoui class (or whatever Byond calls classes)

nanoui is used to open and update nano browser uis
**********************************************************/


#define STATUS_INTERACTIVE 2 // GREEN Visability
#define STATUS_UPDATE 1 // ORANGE Visability
#define STATUS_DISABLED 0 // RED Visability
#define STATUS_CLOSE -1 // Close the window
/datum/nanoui
	// the user who opened this ui
	var/mob/user
	// the datum this ui "belongs" to
	//var/atom/movable/src_object
	var/datum/src_object
	// the title of this ui
	var/title
	// the key of this ui, this is to allow multiple (different) uis for each src_object
	var/ui_key
	// window_id is used as the window name/identifier for browse and onclose
	var/window_id
	// the browser window width
	var/width = 0
	// the browser window height
	var/height = 0
	// whether to use extra logic when window closes
	var/on_close_logic = 1
	// an extra ref to use when the window is closed, usually null
	var/atom/ref = null
	// options for modifying window behaviour
	var/window_options = "focus=0;can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;" // window option is set using window_id
	// the list of stylesheets to apply to this ui
	var/list/stylesheets = list()
	// the list of javascript scripts to use for this ui
	var/list/scripts = list()
	// a list of templates which can be used with this ui
	var/templates[0]
	// the layout key for this ui (this is used on the frontend, leave it as "default" unless you know what you're doing)
	var/layout_key = "default"
	// this sets whether to re-render the ui layout with each update (default 0, turning on will break the map ui if it's in use)
	var/auto_update_layout = 0
	// this sets whether to re-render the ui content with each update (default 1)
	var/auto_update_content = 1
	// the default state to use for this ui (this is used on the frontend, leave it as "default" unless you know what you're doing)
	var/state_key = "default"
	// show the map ui, this is used by the default layout
	var/show_map = 0
	// the map z level to display
	var/map_z_level = 1
	// initial data, containing the full data structure, must be sent to the ui (the data structure cannot be extended later on)
	var/list/initial_data[0]
	// set to 1 to update the ui automatically every master_controller tick
	var/is_auto_updating = 0
	// the current status/visibility of the ui
	var/status = STATUS_INTERACTIVE
	// the proc to set the status
	var/status_proc

	// Only allow users with a certain user.stat to get updates. Defaults to 0 (concious)
	var/allowed_user_stat = 0 // -1 = ignore, 0 = alive, 1 = unconcious or alive, 2 = dead concious or alive

	var/distance_check = 1
 /**
  * Create a new nanoui instance.
  *
  * @param nuser /mob The mob who has opened/owns this ui
  * @param nsrc_object /obj|/mob The obj or mob which this ui belongs to
  * @param nui_key string A string key to use for this ui. Allows for multiple unique uis on one src_oject
  * @param ntemplate string The filename of the template file from /nano/templates (e.g. "my_template.tmpl")
  * @param ntitle string The title of this ui
  * @param nwidth int the width of the ui window
  * @param nheight int the height of the ui window
  * @param nref /atom A custom ref to use if "on_close_logic" is set to 1
  *
  * @return /nanoui new nanoui object
  */
/datum/nanoui/New(nuser, nsrc_object, nui_key, ntemplate_filename, ntitle = 0, nwidth = 0, nheight = 0, var/atom/nref = null, ignore_distance = 0, nstatus_proc = /proc/nanoui_default_status_proc)
	user = nuser
	src_object = nsrc_object
	ui_key = nui_key
	window_id = "[ui_key]\ref[src_object]"
	distance_check = !ignore_distance
	status_proc = nstatus_proc
	// add the passed template filename as the "main" template, this is required
	add_template("main", ntemplate_filename)

	if (ntitle)
		title = ntitle
	if (nwidth)
		width = nwidth
	if (nheight)
		height = nheight
	if (nref)
		ref = nref

	add_common_assets()

 /**
  * Use this proc to add assets which are common to (and required by) all nano uis
  *
  * @return nothing
  */
/datum/nanoui/proc/add_common_assets()
	add_script("libraries.min.js") // A JS file comprising of jQuery, doT.js and jQuery Timer libraries (compressed together)
	add_script("JSON_parseMore.js") // Honestly I have no idea how to add to that previous file safely but someone else can do it if they want
	add_script("nano_utility.js") // The NanoUtility JS, this is used to store utility functions.
	add_script("nano_template.js") // The NanoTemplate JS, this is used to render templates.
	add_script("nano_state_manager.js") // The NanoStateManager JS, it handles updates from the server and passes data to the current state
	add_script("nano_state.js") // The NanoState JS, this is the base state which all states must inherit from
	add_script("nano_state_default.js") // The NanoStateDefault JS, this is the "default" state (used by all UIs by default), which inherits from NanoState
	add_script("nano_base_callbacks.js") // The NanoBaseCallbacks JS, this is used to set up (before and after update) callbacks which are common to all UIs
	add_script("nano_base_helpers.js") // The NanoBaseHelpers JS, this is used to set up template helpers which are common to all UIs
	add_stylesheet("shared.css") // this CSS sheet is common to all UIs
	add_stylesheet("icons.css") // this CSS sheet is common to all UIs

 /**
  * Set the current status (also known as visibility) of this ui.
  *
  * @param state int The status to set, see the defines at the top of this file
  * @param push_update int (bool) Push an update to the ui to update it's status (an update is always sent if the status has changed to red (0))
  *
  * @return nothing
  */
/datum/nanoui/proc/set_status(state, push_update)
	if (state != status) // Only update if it is different
		if (status == STATUS_DISABLED)
			status = state
			if (push_update)
				update()
		else
			status = state
			if (push_update || status == 0)
				push_data(null, 1) // Update the UI, force the update in case the status is 0, data is null so that previous data is used

 /**
  * Update the status (visibility) of this ui based on the user's status
  *
  * @param push_update int (bool) Push an update to the ui to update it's status. This is set to 0/false if an update is going to be pushed anyway (to avoid unnessary updates)
  *
  * @return nothing
  */
/datum/nanoui/proc/update_status(var/push_update = 0)
	var/status = call(status_proc)(src)

	if(status == STATUS_CLOSE)
		close()
		return

	set_status(status, push_update)

	/**
   * The default proc to be called by update_status()
   *
   * @param nano /datum/nanoui/ The nanoui datum to perform default_status_proc for
   *
   * @return nothing
   */
/proc/nanoui_default_status_proc(var/datum/nanoui/nano)
	var/can_interactive = 0
	if(nano.user.mutations && nano.user.mutations.len)
		if(M_TK in nano.user.mutations)
			can_interactive = 1
	else if(isrobot(nano.user))
		if(nano.src_object in view(7, nano.user))
			can_interactive = 1
	else
		can_interactive = (isAI(nano.user) || !nano.distance_check || isAdminGhost(nano.user))

	if (can_interactive)
		return STATUS_INTERACTIVE // interactive (green visibility)
	else
		var/dist = 0
		if(istype(nano.src_object, /atom))
			var/atom/A = nano.src_object
			if(isobserver(nano.user))
				var/mob/dead/observer/O = nano.user
				var/ghost_flags = 0
				if(A.ghost_write)
					ghost_flags |= PERMIT_ALL
				if(canGhostWrite(O,A,"",ghost_flags) || isAdminGhost(O))
					return STATUS_INTERACTIVE // interactive (green visibility)
				else if(canGhostRead(O,A,ghost_flags))
					return STATUS_UPDATE
			dist = get_dist(nano.src_object, nano.user)

		if (dist > 4)
			return STATUS_CLOSE

		if ((nano.allowed_user_stat > -1) && (nano.user.stat > nano.allowed_user_stat))
			return STATUS_DISABLED // no updates, completely disabled (red visibility)
		else if (nano.user.restrained() || nano.user.lying)
			return STATUS_UPDATE // update only (orange visibility)
		else if (istype(nano.src_object, /obj/item/device/uplink/hidden)) // You know what if they have the uplink open let them use the UI
			return STATUS_INTERACTIVE // Will build in distance checks on the topics for sanity.
		else if (!(nano.src_object in view(4, nano.user))) // If the src object is not in visable, set status to 0
			return STATUS_DISABLED // no updates, completely disabled (red visibility)
		else if (dist <= 1)
			return STATUS_INTERACTIVE // interactive (green visibility)
		else if (dist <= 2)
			return STATUS_UPDATE // update only (orange visibility)
		else if (dist <= 4)
			return STATUS_DISABLED // no updates, completely disabled (red visibility)


 /**
  * Set the ui to auto update (every master_controller tick)
  *
  * @param state int (bool) Set auto update to 1 or 0 (true/false)
  *
  * @return nothing
  */
/datum/nanoui/proc/set_auto_update(nstate = 1)
	is_auto_updating = nstate

 /**
  * Set the initial data for the ui. This is vital as the data structure set here cannot be changed when pushing new updates.
  *
  * @param data /list The list of data for this ui
  *
  * @return nothing
  */
/datum/nanoui/proc/set_initial_data(list/data)
	initial_data = data

 /**
  * Get config data to sent to the ui.
  *
  * @return /list config data
  */
/datum/nanoui/proc/get_config_data()
	var/list/config_data = list(
					"title" = title,
					"srcObject" = list("name" = src_object),
					"stateKey" = state_key,
					"status" = status,
					"autoUpdateLayout" = auto_update_layout,
					"autoUpdateContent" = auto_update_content,
					"showMap" = show_map,
					"mapZLevel" = map_z_level,
					"mapLongName" = map.nameLong,
					"mapName" = map.nameShort,
					"worldmaxx" = world.maxx,
					"worldmaxy" = world.maxy,
					"user" = list("name" = user.name),
			)
	return config_data

 /**
  * Get data to sent to the ui.
  *
  * @param data /list The list of general data for this ui (can be null to use previous data sent)
  *
  * @return /list data to send to the ui
  */
/datum/nanoui/proc/get_send_data(var/list/data)
	var/list/config_data = get_config_data()

	var/list/send_data = list("config" = config_data)

	if (!isnull(data))
		send_data["data"] = data

	return send_data

 /**
  * Set the browser window options for this ui
  *
  * @param nwindow_options string The new window options
  *
  * @return nothing
  */
/datum/nanoui/proc/set_window_options(nwindow_options)
	window_options = nwindow_options

 /**
  * Add a CSS stylesheet to this UI
  * These must be added before the UI has been opened, adding after that will have no effect
  *
  * @param file string The name of the CSS file from /nano/css (e.g. "my_style.css")
  *
  * @return nothing
  */
/datum/nanoui/proc/add_stylesheet(file)
	stylesheets.Add(file)

 /**
  * Add a JavsScript script to this UI
  * These must be added before the UI has been opened, adding after that will have no effect
  *
  * @param file string The name of the JavaScript file from /nano/js (e.g. "my_script.js")
  *
  * @return nothing
  */
/datum/nanoui/proc/add_script(file)
	scripts.Add(file)

 /**
  * Add a template for this UI
  * Templates are combined with the data sent to the UI to create the rendered view
  * These must be added before the UI has been opened, adding after that will have no effect
  *
  * @param key string The key which is used to reference this template in the frontend
  * @param filename string The name of the template file from /nano/templates (e.g. "my_template.tmpl")
  *
  * @return nothing
  */
/datum/nanoui/proc/add_template(key, filename)
	templates[key] = filename

 /**
  * Set the layout key for use in the frontend Javascript
  * The layout key is the basic layout key for the page
  * Two files are loaded on the client based on the layout key varable:
  *     -> a template in /nano/templates with the filename "layout_<layout_key>.tmpl
  *     -> a CSS stylesheet in /nano/css with the filename "layout_<layout_key>.css
  *
  * @param nlayout string The layout key to use
  *
  * @return nothing
  */
/datum/nanoui/proc/set_layout_key(nlayout_key)
	layout_key = lowertext(nlayout_key)

 /**
  * Set the ui to update the layout (re-render it) on each update, turning this on will break the map ui (if it's being used)
  *
  * @param state int (bool) Set update to 1 or 0 (true/false) (default 0)
  *
  * @return nothing
  */
/datum/nanoui/proc/set_auto_update_layout(nstate)
	auto_update_layout = nstate

 /**
  * Set the ui to update the main content (re-render it) on each update
  *
  * @param state int (bool) Set update to 1 or 0 (true/false) (default 1)
  *
  * @return nothing
  */
/datum/nanoui/proc/set_auto_update_content(nstate)
	auto_update_content = nstate

 /**
  * Set the state key for use in the frontend Javascript
  *
  * @param nstate_key string The key of the state to use
  *
  * @return nothing
  */
/datum/nanoui/proc/set_state_key(nstate_key)
	state_key = nstate_key

 /**
  * Toggle showing the map ui
  *
  * @param nstate_key boolean 1 to show map, 0 to hide (default is 0)
  *
  * @return nothing
  */
/datum/nanoui/proc/set_show_map(nstate)
	show_map = nstate

 /**
  * Toggle showing the map ui
  *
  * @param nstate_key boolean 1 to show map, 0 to hide (default is 0)
  *
  * @return nothing
  */
/datum/nanoui/proc/set_map_z_level(nz)
	map_z_level = nz


 /**
  * Set whether or not to use the "old" on close logic (mainly unset_machine())
  *
  * @param state int (bool) Set on_close_logic to 1 or 0 (true/false)
  *
  * @return nothing
  */
/datum/nanoui/proc/use_on_close_logic(state)
	on_close_logic = state

 /**
  * Return the HTML for this UI
  *
  * @return string HTML for the UI
  */
/datum/nanoui/proc/get_html()


	// before the UI opens, add the layout files based on the layout key
	add_stylesheet("layout_[layout_key].css")
	add_template("layout", "layout_[layout_key].tmpl")

	var/head_content = ""

	for (var/filename in scripts)
		head_content += "<script type='text/javascript' src='[filename]'></script> "

	for (var/filename in stylesheets)
		head_content += "<link rel='stylesheet' type='text/css' href='[filename]'> "

	var/template_data_json = "{}" // An empty JSON object
	if (templates.len > 0)
		template_data_json = replacetext(json_encode(templates), "'", "&#39;")

	var/list/send_data = get_send_data(initial_data)
	var/initial_data_json = replacetext(json_encode(send_data), "'", "&#39;")

	var/url_parameters_json = json_encode(list("src" = "\ref[src]"))

	return {"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<head>
		<script type='text/javascript'>
			function receiveUpdateData(jsonString)
			{
				// We need both jQuery and NanoStateManager to be able to recieve data
				// At the moment any data received before those libraries are loaded will be lost
				if (typeof NanoStateManager != 'undefined' && typeof jQuery != 'undefined')
				{
					NanoStateManager.receiveUpdateData(jsonString);
				}
			}
		</script>
		[head_content]
	</head>
	<body scroll=auto data-template-data='[template_data_json]' data-url-parameters='[url_parameters_json]' data-initial-data='[initial_data_json]'>
		<div id='uiLayout'>
		</div>
		<noscript>
			<div id='uiNoScript'>
				<h2>JAVASCRIPT REQUIRED</h2>
				<p>Your Internet Explorer's Javascript is disabled (or broken).<br/>
				Enable Javascript and then open this UI again.</p>
			</div>
		</noscript>
	</body>
</html>
	"}

 /**
  * Open this UI
  *
  * @return nothing
  */
/datum/nanoui/proc/open()
	if(!user.client)
		return

	var/window_size = ""
	if (width && height)
		window_size = "size=[width]x[height];"
	update_status(0)
	user << browse(get_html(), "window=[window_id];[window_size][window_options]")
	winset(user, "mapwindow.map", "focus=true") // return keyboard focus to map
	on_close_winset()
	//onclose(user, window_id)
	nanomanager.ui_opened(src)

 /**
  * Move window up front.
  *
  * @return nothing
  */
/datum/nanoui/proc/focus()
	winset(user, window_id, "focus=true")
	winset(user, "mapwindow.map", "focus=true") // return keyboard focus to map

 /**
  * Close this UI
  *
  * @return nothing
  */
/datum/nanoui/proc/close()
	is_auto_updating = 0
	nanomanager.ui_closed(src)
	user << browse(null, "window=[window_id]")

 /**
  * Set the UI window to call the nanoclose verb when the window is closed
  * This allows Nano to handle closed windows
  *
  * @return nothing
  */
/datum/nanoui/proc/on_close_winset()
	set waitfor = FALSE // winexists sleeps
	for(var/i in 1 to WINSET_MAX_ATTEMPTS)
		if(user && winexists(user, window_id))
			var/params = "\ref[src]"
			winset(user, window_id, "on-close=\"nanoclose [params]\"")
			return
	close()

 /**
  * Push data to an already open UI window
  *
  * @return nothing
  */
/datum/nanoui/proc/push_data(data, force_push = 0)
	update_status(0)
	if (status == STATUS_DISABLED && !force_push)
		return // Cannot update UI, no visibility

	var/list/send_data = get_send_data(data)

//	to_chat(user, json_encode(data))// used for debugging

	user << output(list2params(list(json_encode(send_data))),"[window_id].browser:receiveUpdateData")

 /**
  * This Topic() proc is called whenever a user clicks on a link within a Nano UI
  * If the UI status is currently STATUS_INTERACTIVE then call the src_object Topic()
  * If the src_object Topic() returns 1 (true) then update all UIs attached to src_object
  *
  * @return nothing
  */
/datum/nanoui/Topic(href, href_list)
	update_status(0) // update the status
	if (status != STATUS_INTERACTIVE || user != usr) // If UI is not interactive or usr calling Topic is not the UI user
		return

	// This is used to toggle the nano map ui
	var/map_update = 0
	if(href_list["showMap"])
		set_show_map(text2num(href_list["showMap"]))
		map_update = 1

	if(href_list["zlevel"])
		var/listed_zlevels = list(map.zMainStation, map.zTCommSat, map.zDerelict, map.zAsteroid, map.zDeepSpace)
		var/newz = input("Choose Z-Level to view.","Z-Levels",1) as null|anything in listed_zlevels
		if(!newz || isnull(newz))
			return 0
		if(!(newz in listed_zlevels))
			to_chat(usr, "<span class='danger'>Unable to establish a connection</span>")
			return 0
		if(newz != map_z_level)
			set_map_z_level(newz)
			map_update = 1

	if ((src_object && src_object.Topic(href, href_list)) || map_update)
		nanomanager.update_uis(src_object) // update all UIs attached to src_object

 /**
  * Process this UI, updating the entire UI or just the status (aka visibility)
  * This process proc is called by the master_controller
  *
  * @param update string For this UI to update
  *
  * @return nothing
  */
/datum/nanoui/proc/process(update = 0)
	set waitfor = FALSE
	if (!src_object || !user)
		close()
		return

	if (status && (update || is_auto_updating))
		update() // Update the UI (update_status() is called whenever a UI is updated)
	else
		update_status(1) // Not updating UI, so lets check here if status has changed

 /**
  * Update the UI
  *
  * @return nothing
  */
/datum/nanoui/proc/update(var/force_open = 0)
	src_object.ui_interact(user, ui_key, src, force_open)

 /**
  * Sends a message to the client-side JS.
  *
  * @param js_function string The name of the JS function to execute.
  * @param data string URL-encoded list of args as made by list2params.
  *
  * @return nothing
  */
/datum/nanoui/proc/send_message(js_function, data)
    user << output(data, "[window_id].browser:[js_function]")

/mob/verb/fix_nanoui()
	set name = "Fix NanoUI"
	set category = "OOC"

	world.log << "[key_name(src)] used the Fix NanoUI verb. Open UIs: [length(open_uis)]"
	for(var/datum/nanoui/ui in open_uis)
		CHECK_TICK
		world.log << url_decode(winget(ui.user, ui.window_id, "*"))
		ui.close()
	to_chat(src, "<span class='notice'>All Nano UIs should be closed now.</span>")
