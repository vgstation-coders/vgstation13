////////////////////////////////////////////////////////////////////////////////
/// Made by Wirewraith for goonstation. Ported by mentgah with authorisation ///
////////////////////////////////////////////////////////////////////////////////


//Alignment around the turf. Any can be combined with center (top and bottom for horizontal centering, left and right for vertical).
#define TOOLTIP_BOTTOM 0
#define TOOLTIP_TOP 1
#define TOOLTIP_RIGHT 2
#define TOOLTIP_LEFT 4
#define TOOLTIP_CENTER 8

/datum/tooltips
	/// The client
	var/client/owner = null
	/// All created tooltip window IDs will have this prefix
	var/windowPrefix = "tooltip"
	/// The window ID that contains the map
	var/mapId = "mapwindow"
	/// The control ID of the map
	var/mapControl = "map"
	/// The tooltip HTML, for caching
	var/html = ""
	/// The tooltip used for hovering over a target (we assume clients can only hover over one thing at a time)
	var/datum/tooltip/hoverTip = null

/datum/tooltips/New(client/C)
	..()
	spawn(0)
		if (!C) 
			return
		owner = C
		clearAll()
		loadAssets()
		preload()

	/// Special method to remove all tooltip windows
	/// Used on client login to clean up any tooltips that might have been stuck open from a previous round
/datum/tooltips/proc/clearAll()
	//
	if (!owner) 
		return
	for (var/window,windowId in params2list(winget(owner, "[mapId].*", "id")))
		if (findtext(windowId, windowPrefix, 1, length(windowPrefix) + 1))
			winset(owner, windowId, "parent=none")

	/// Send browser assets to the client

/datum/tooltips/proc/loadAssets()

	register_asset("tooltip.css", 'code/modules/tooltip/tooltip.css')
	send_asset(owner, "tooltip.css")
	register_asset("eta.min.js", 'code/modules/tooltip/eta.min.js')
	send_asset(owner, "eta.min.js")
	register_asset("tooltip.js", 'code/modules/tooltip/tooltip.js')
	send_asset(owner, "tooltip.js")


	html = file2text('code/modules/tooltip/tooltip.html')

	/// Determine if we're allowed to show hover tooltips to a client
/datum/tooltips/proc/canShowHover()
	return owner.prefs.get_pref(/datum/preference_setting/toggle/tooltips)

/**
	* Show a tooltip
	*
	* Arguments:
	* * target (atom) - The target of the tooltip
	* * mouse (string) - Provided from MouseEntered (and similar) procs
	* * title (string) - The text to display as a title
	* * content (string) - The main content body to display
	* * theme (string) - What theme to apply. See `tooltip.css` for available themes
	* * align (list) - Bitmask representing alignment. See `_std\defines\tooltips.dm` for available flags.
	* 									Multiple flags can be combined, e.g. `TOOLTIP_TOP | TOOLTIP_CENTER`
	* * size (list) - Width and height respectively, e.g. `list(200, 300)`
	* 								 Use `0` for either to use the automatic size for that axis
	* * offset (list) - X and Y pixels respectively, e.g. `list(10, 20)`
	* * bounds (list) - Width and height respectively, e.g. `list(200, 300)`
	* * extra (list) - Any random extra stuff
	*/
/datum/tooltips/proc/show(atom/target, mouse, title, content, theme, list/align, list/size, list/offset, list/bounds, list/extra)
	var/datum/tooltip/toShow = null
	if (canShowHover())
		if (!hoverTip) 
			hoverTip = new /datum/tooltip(src)
		toShow = hoverTip
	if (!theme)
		var/pref = owner.prefs.get_pref(/datum/preference_setting/string/UI_style)
		theme = pref ? lowertext(pref) : "default"
	if (toShow)
		toShow.show(target, mouse, title, content, theme, align, size, offset, bounds, extra)

	/// Preload a tooltip by creating it ahead of time whilst remaining invisible
	/// Intended to speed up initial show times
/datum/tooltips/proc/preload()
	
	var/datum/tooltip/tooltip = null
	tooltip = new /datum/tooltip(src)
	hoverTip = tooltip
	tooltip.preloading = TRUE
	tooltip.create()
	return tooltip

	/**
	 * Hide a tooltip
	 */
/datum/tooltips/proc/hide()
	hoverTip?.hide()

/datum/tooltips/proc/hideAll()
	hide()

	/// Escape hatch to completely reset in case of a broken state
/datum/tooltips/proc/reset()
	loadAssets()
	hoverTip?.remove()
	clearAll()
	preload()


	/// Called when a tooltip is deleted. Do not call manually.
/datum/tooltips/proc/onTooltipRemoved(datum/tooltip/tooltip)
	if (hoverTip == tooltip)
		hoverTip = null

	/// Called on window resize
/datum/tooltips/proc/onResize()
	hideAll()


/datum/tooltip
	var/datum/tooltips/holder
	var/datum/weakref/target
	var/datum/tooltipOptions/options
	var/window = ""
	var/preloading = FALSE
	var/loaded = FALSE
	var/showing = FALSE
	var/hiding = FALSE
	var/pinned = FALSE

/datum/tooltip/New(datum/tooltips/_holder)
	..()
	holder = _holder
	window = "[_holder.windowPrefix][time2text(world.realtime, "DDhhmmss")][floor(world.time)][rand(1, 69420)]"
	options = new()

/datum/tooltip/Destroy()
	remove()
	..()

/datum/tooltip/proc/create()
	var/isDisabled = !pinned
	winset(holder.owner, window, list2params(alist(
		"parent" = holder.mapId,
		"type" = "browser",
		"pos" = "0,0",
		"size" = "1x1",
		"anchor1" = "0,0",
		"is-visible" = FALSE,
		"is-disabled" = isDisabled,
		"background-color" = "#000",
		"use-title" = TRUE,
	)))

	var/html = replacetext(holder.html, "<!-- TOOLTIP_CONFIG -->", {"
		<script>
			window.tooltip_config = {
				ref: '\ref[src]',
				windowId: '[window]',
				mapControlId: '[holder.mapId].[holder.mapControl]',
			};
		</script>
	"})

	holder.owner << browse(html, list2params(list("window" = window)))
	focusMap()



/datum/tooltip/proc/getIconSize()
	
	var/iconW = world.icon_size
	var/iconH = world.icon_size
	if (istext(world.icon_size))
		var/list/iconSizes = splittext(world.icon_size, "x")
		iconW = text2num(iconSizes[1])
		iconH = text2num(iconSizes[2])
	return alist("width" = iconW, "height" = iconH)

/datum/tooltip/proc/getView()
	
	var/viewX = holder.owner.view
	var/viewY = holder.owner.view
	if (istext(holder.owner.view))
		var/list/viewSizes = splittext(holder.owner.view, "x")
		viewX = (text2num(viewSizes[1]) - 1) / 2
		viewY = (text2num(viewSizes[2]) - 1) / 2
	return alist("x" = viewX, "y" = viewY)

/datum/tooltip/proc/setMouseWithoutParams(list/clientView, list/iconSize)
	
	var/atom/refTarget = target.get()
	var/pixloc/clientLoc = bound_pixloc(holder.owner.virtual_eye, SOUTHWEST)
	var/pixloc/targetLoc = bound_pixloc(refTarget, SOUTHWEST)
	var/tilesLeft = clientView["x"] + 1 - ((clientLoc.x - targetLoc.x) / iconSize["width"])
	var/tilesBottom = clientView["y"] + 1 - ((clientLoc.y - targetLoc.y) / iconSize["height"])
	options.mouse = alist(
		"left" = alist("tiles" = tilesLeft, "pixels" = 1, "icon" = refTarget.pixel_x * -1),
		"bottom" = alist("tiles" = tilesBottom, "pixels" = 1, "icon" = refTarget.pixel_y * -1),
	)

/datum/tooltip/proc/shouldUpdate(atom/_target)
	
	if (!target) 
		return FALSE
	var/atom/refTarget = target.get()
	return showing && !hiding && loaded && _target == refTarget

/datum/tooltip/proc/build()
	
	var/atom/refTarget = target.get()
	if (!refTarget) 
		return

	if (!options.bounds["width"] && !options.bounds["height"])
		var/icon/targetIcon = icon(refTarget.icon)
		options.setBounds(list(targetIcon.Width(), targetIcon.Height()))

	options.pinned = pinned
	options.transform = refTarget.transform
	options.hud = !refTarget.z

	var/list/iconSize = getIconSize()
	var/list/clientView = getView()

	if (length(options.mouse["left"]) == 0)
		setMouseWithoutParams(clientView, iconSize)

	var/params = list2params(list(
		json_encode(alist(
			"options" = options.toList(),
			"world" = alist(
				"maxx" = world.maxx,
				"maxy" = world.maxy,
				"icon_size" = iconSize,
			),
			"client" = alist(
				"view" = clientView,
				"bounds" = alist(
					"width" = holder.owner.bound_width,
					"height" = holder.owner.bound_height,
				),
			),
		))
	))

	if (hiding) 
		return
	holder.owner << output(params, "[window]:tooltip.init")

/datum/tooltip/proc/update()
	
	if (hiding) 
		return
	holder.owner << output(list2params(list(json_encode(alist(
		"options" = options.toList(),
	)))), "[window]:tooltip.update")


/datum/tooltip/proc/show(atom/_target, _mouse, _title, _content, _theme, list/_align, list/_size, list/_offset, list/_bounds, list/_extra)
	if (!holder) 
		return

	var/update = shouldUpdate(_target)
	preloading = FALSE
	hiding = FALSE
	target = makeweakref(_target)

	if (!update) 
		options.reset()
	if (_mouse) 
		options.setMouse(_mouse)
	if (_title) 
		options.title = _title
	if (_content) 
		options.setContent(_content)
	if (_theme) 
		options.theme = _theme
	if (_align) 
		options.setAlign(_align)
	if (_size) 
		options.setSize(_size)
	if (_offset) 
		options.setOffset(_offset)
	if (_bounds) 
		options.setBounds(_bounds)
	if (_extra) 
		options.extra = _extra

	if (update)
		update()
	else
		usr.register_event(/event/death, holder.owner.mob, nameof(src::hide()))

		loaded ? build() : create()

/datum/tooltip/proc/hide()
	if (hiding || !holder) 
		return
	hiding = TRUE
	holder.owner << output("", "[window]:tooltip.hide")

/datum/tooltip/proc/onHidden()
	showing = FALSE
	if (holder?.owner?.mob)
		usr.unregister_event(/event/death, holder.owner.mob, nameof(src::hide()))


/datum/tooltip/proc/remove()
	hiding = TRUE
	winset(holder.owner, window, "parent=null")
	onHidden()
	holder.onTooltipRemoved(src)

/datum/tooltip/proc/focusMap()
	winset(holder.owner, "[holder.mapId].[holder.mapControl]", "focus=1")

/datum/tooltip/Topic(href, href_list)
	switch (href_list["action"])
		if ("loaded")
			loaded = TRUE
			if (!preloading)
				build()
		if ("showing")
			showing = TRUE
		if ("hidden")
			onHidden()

/datum/tooltipOptions
	/// The text to display as a title
	var/title
	/// The main content body to display
	var/content
	/// What theme to apply. See `tooltip.css` for available themes
	var/theme
	/// The transform matrix applied to the target atom
	var/transform
	/// Pinned means the tooltip requires clicking to open and close
	var/pinned = FALSE
	/// Whether the target is a non-map atom
	var/hud = FALSE
	/// Parsed coordinate data as provided from MouseEntered etc procs in params
	var/list/mouse
	/// Computed axis alignment
	var/list/align
	/// Computed tooltip size overrides
	var/list/size
	/// Computed tooltip positioning offsets
	var/list/offset
	/// Parsed target dimensions
	var/list/bounds
	/// Any random extra stuff
	var/list/extra

/datum/tooltipOptions/proc/reset()
	title = null
	content = null
	theme = null
	transform = null
	pinned = FALSE
	hud = FALSE
	mouse = alist("left" = alist(), "bottom" = alist())
	align = alist("x" = "left", "y" = "bottom")
	size = alist("width" = 0, "height" = 0)
	offset = alist("x" = 0, "y" = 0, "tiles" = alist())
	bounds = alist("width" = 0, "height" = 0)
	extra = alist()

/datum/tooltipOptions/proc/toList()
	return alist(
		"title" = title,
		"content" = content,
		"theme" = theme,
		"transform" = transform,
		"pinned" = pinned,
		"hud" = hud,
		"mouse" = mouse,
		"align" = align,
		"size" = size,
		"offset" = offset,
		"bounds" = bounds,
		"extra" = extra,
	)

/datum/tooltipOptions/proc/setContent(_content)
	content = _content

	/**
	 * Parse and set the mouse target position
	 *
	 * Arguments:
	 * * params (string) - Provided from MouseEntered (and similar) procs
	 */
/datum/tooltipOptions/proc/setMouse(params)
	mouse = alist("left" = alist(), "bottom" = alist())
	if (!params) 
		return
	params = params2list(params)

	mouse["left"]["icon"] = text2num(params["icon-x"])
	mouse["bottom"]["icon"] = text2num(params["icon-y"])

	if (params["vis-x"]) 
		mouse["left"]["vis"] = text2num(params["vis-x"])
	if (params["vis-y"]) 
		mouse["bottom"]["vis"] = text2num(params["vis-y"])

	var/list/screenLoc = splittext(params["screen-loc"], ",")
	var/list/screenLocLeft = splittext(screenLoc[1], ":")
	mouse["left"]["tiles"] = text2num(screenLocLeft[1])
	mouse["left"]["pixels"] = text2num(screenLocLeft[2])
	var/list/screenLocBottom = splittext(screenLoc[2], ":")
	mouse["bottom"]["tiles"] = text2num(screenLocBottom[1])
	mouse["bottom"]["pixels"] = text2num(screenLocBottom[2])

	/**
	 * Set the position of the tooltip around the target
	 *
	 * Arguments:
	 * * flags (int) - Bitmask representing alignment. See `_std\defines\tooltips.dm` for available flags.
	 * 					 			 Multiple flags can be combined, e.g. `TOOLTIP_TOP | TOOLTIP_CENTER`
	 */
/datum/tooltipOptions/proc/setAlign(flags)
	align = alist("x" = "left", "y" = "bottom")
	if (!flags) 
		return

	var/list/newAlign = alist("x" = "", "y" = "")
	if (flags & TOOLTIP_TOP) 
		newAlign["y"] = "top"
	else if (flags & TOOLTIP_BOTTOM) 
		newAlign["y"] = "bottom"
	if (flags & TOOLTIP_RIGHT) 
		newAlign["x"] = "right"
	else if (flags & TOOLTIP_LEFT) 
		newAlign["x"] = "left"
	if (flags & TOOLTIP_CENTER)
		if (newAlign["x"]) 
			newAlign["y"] = "center"
		else 
			newAlign["x"] = "center"

	if (!newAlign["x"]) 
		newAlign["x"] = "left"
	if (!newAlign["y"]) 
		newAlign["y"] = "bottom"
	align = newAlign

	/**
	 * Override the size of the tooltip.
	 * Note that dimensions will still not exceed maximums set in `tooltip.css`, and are still subject to window/dpi scaling.
	 *
	 * Arguments:
	 * * newSize (list) - Width and height respectively, e.g. `list(200, 300)`
	 * 										Use `0` for either to use the automatic size for that axis
	 */
/datum/tooltipOptions/proc/setSize(list/newSize)
	size = alist(
		"width" = newSize.len >= 1 ? newSize[1] : 0,
		"height" = newSize.len >= 2 ? newSize[2] : 0,
	)

	/**
	 * Set positioning offsets around the target, for example to push the tooltip down further away.
	 *
	 * Arguments:
	 * * newOffset (list) - X and Y pixels respectively, e.g. `list(10, 20)`
	 */
/datum/tooltipOptions/proc/setOffset(list/newOffset)
	offset["x"] = newOffset.len >= 1 ? newOffset[1] : 0
	offset["y"] = newOffset.len >= 2 ? newOffset[2] : 0

	/**
	 * Set the dimensions of the target, required for tooltip positioning.
	 * Unlikely you will need to use this directly.
	 *
	 * Arguments:
	 * * newBounds (list) - Width and height respectively, e.g. `list(200, 300)`
	 */
/datum/tooltipOptions/proc/setBounds(list/newBounds)
	bounds = alist(
		"width" = newBounds.len >= 1 ? newBounds[1] : 0,
		"height" = newBounds.len >= 2 ? newBounds[2] : 0,
	)

	/**
	 * Apply an extra positioning offset to the tooltip.
	 *
	 * Arguments:
	 * * direction (int) - Which way to push the tooltip, e.g. `NORTH`
	 * * amount (int) - How many tiles to move
	 */
/datum/tooltipOptions/proc/pushTiles(direction, amount)
	offset["tiles"][direction] = amount
