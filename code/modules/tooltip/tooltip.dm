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
	/// Whether tooltip debugging enabled
	var/debug = FALSE
	/// The tooltip used for hovering over a target (we assume clients can only hover over one thing at a time)
	var/datum/tooltip/hoverTip = null

/datum/tooltips/New(client/C)
	..()
	spawn(0)
		if (!C) return
		src.owner = C
		src.clearAll()
		src.loadAssets()
		src.preload()

	/// Special method to remove all tooltip windows
	/// Used on client login to clean up any tooltips that might have been stuck open from a previous round
/datum/tooltips/proc/clearAll()
	//
	if (!src.owner) return
	for (var/window,windowId in params2list(winget(src.owner, "[src.mapId].*", "id")))
		if (findtext(windowId, src.windowPrefix, 1, length(src.windowPrefix) + 1))
			winset(src.owner, windowId, "parent=none")

	/// Send browser assets to the client

/datum/tooltips/proc/loadAssets()

	register_asset("tooltip.css", 'code/modules/tooltip/tooltip.css')
	send_asset(src.owner, "tooltip.css")
	register_asset("eta.min.js", 'code/modules/tooltip/eta.min.js')
	send_asset(src.owner, "eta.min.js")
	register_asset("tooltip.js", 'code/modules/tooltip/tooltip.js')
	send_asset(src.owner, "tooltip.js")


	src.html = file2text('code/modules/tooltip/tooltip.html')

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
		if (!hoverTip) hoverTip = new /datum/tooltip(src)
		toShow = hoverTip
	if (theme == null)
		if(!theme && src.owner.prefs && src.owner.prefs.get_pref(/datum/preference_setting/string/UI_style))
			theme = lowertext(src.owner.prefs.get_pref(/datum/preference_setting/string/UI_style))
		if(!theme)
			theme = "default"
	if (toShow)
		toShow.show(target, mouse, title, content, theme, align, size, offset, bounds, extra)

	/// Preload a tooltip by creating it ahead of time whilst remaining invisible
	/// Intended to speed up initial show times
/datum/tooltips/proc/preload()
	
	var/datum/tooltip/tooltip = null
	tooltip = new /datum/tooltip(src)
	src.hoverTip = tooltip
	tooltip.preloading = TRUE
	tooltip.create()
	return tooltip

	/**
	 * Hide a tooltip
	 *
	 * Arguments:
	 * * target (atom) - The target of the tooltip (only required if hiding a pinned tooltip)
	 */
/datum/tooltips/proc/hide(atom/target)
	src.hoverTip?.hide()

/datum/tooltips/proc/hideAll()
	src.hide()

	/// Escape hatch to completely reset in case of a broken state
/datum/tooltips/proc/reset()
	src.loadAssets()
	src.hoverTip?.remove()
	src.clearAll()
	src.preload()

/datum/tooltips/proc/toggleDebug()
	src.debug = !src.debug
	src.reset()

	/// Called when a tooltip is deleted. Do not call manually.
/datum/tooltips/proc/onTooltipRemoved(datum/tooltip/tooltip)
	if (src.hoverTip == tooltip)
		src.hoverTip = null

	/// Called on window resize
/datum/tooltips/proc/onResize()
	src.hideAll()


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

/datum/tooltip/New(datum/tooltips/holder)
	..()
	src.holder = holder
	src.window = "[holder.windowPrefix][time2text(world.realtime, "DDhhmmss")][floor(world.time)][rand(1, 69420)]"
	src.options = new()

/datum/tooltip/Destroy()
	src.remove()
	..()

/datum/tooltip/proc/create()
	var/isDisabled = !src.pinned
	if (src.holder.debug) isDisabled = FALSE
	winset(src.holder.owner, src.window, list2params(alist(
		"parent" = src.holder.mapId,
		"type" = "browser",
		"pos" = "0,0",
		"size" = "1x1",
		"anchor1" = "0,0",
		"is-visible" = FALSE,
		"is-disabled" = isDisabled,
		"background-color" = "#000",
		"use-title" = TRUE,
	)))

	var/html = replacetext(src.holder.html, "<!-- TOOLTIP_CONFIG -->", {"
		<script>
			window.tooltip_config = {
				ref: '\ref[src]',
				windowId: '[src.window]',
				mapControlId: '[src.holder.mapId].[src.holder.mapControl]',
				debug: [src.holder.debug ? "true" : "false"],
			};
		</script>
	"})

	src.holder.owner << browse(html, list2params(list("window" = src.window)))
	src.focusMap()



/datum/tooltip/proc/getIconSize()
	
	var/iconW = world.icon_size
	var/iconH = world.icon_size
	if (istext(world.icon_size))
		var/list/iconSizes = splittext(world.icon_size, "x")
		iconW = text2num(iconSizes[1])
		iconH = text2num(iconSizes[2])
	return alist("width" = iconW, "height" = iconH)

/datum/tooltip/proc/getView()
	
	var/viewX = src.holder.owner.view
	var/viewY = src.holder.owner.view
	if (istext(src.holder.owner.view))
		var/list/viewSizes = splittext(src.holder.owner.view, "x")
		viewX = (text2num(viewSizes[1]) - 1) / 2
		viewY = (text2num(viewSizes[2]) - 1) / 2
	return alist("x" = viewX, "y" = viewY)

/datum/tooltip/proc/setMouseWithoutParams(list/clientView, list/iconSize)
	
	var/atom/refTarget = src.target.get()
	var/pixloc/clientLoc = bound_pixloc(src.holder.owner.virtual_eye, SOUTHWEST)
	var/pixloc/targetLoc = bound_pixloc(refTarget, SOUTHWEST)
	var/tilesLeft = clientView["x"] + 1 - ((clientLoc.x - targetLoc.x) / iconSize["width"])
	var/tilesBottom = clientView["y"] + 1 - ((clientLoc.y - targetLoc.y) / iconSize["height"])
	src.options.mouse = alist(
		"left" = alist("tiles" = tilesLeft, "pixels" = 1, "icon" = refTarget.pixel_x * -1),
		"bottom" = alist("tiles" = tilesBottom, "pixels" = 1, "icon" = refTarget.pixel_y * -1),
	)

/datum/tooltip/proc/shouldUpdate(atom/target)
	
	if (!src.target) return FALSE
	var/atom/refTarget = src.target.get()
	return src.showing && !src.hiding && src.loaded && target == refTarget

/datum/tooltip/proc/build()
	
	var/atom/refTarget = src.target.get()
	if (!refTarget) return

	if (!src.options.bounds["width"] && !src.options.bounds["height"])
		var/icon/targetIcon = icon(refTarget.icon)
		src.options.setBounds(list(targetIcon.Width(), targetIcon.Height()))

	src.options.pinned = src.pinned
	src.options.transform = refTarget.transform
	src.options.hud = !refTarget.z

	var/list/iconSize = src.getIconSize()
	var/list/clientView = src.getView()

	if (length(src.options.mouse["left"]) == 0)
		src.setMouseWithoutParams(clientView, iconSize)

	var/params = list2params(list(
		json_encode(alist(
			"options" = src.options.toList(),
			"world" = alist(
				"maxx" = world.maxx,
				"maxy" = world.maxy,
				"icon_size" = iconSize,
			),
			"client" = alist(
				"view" = clientView,
				"bounds" = alist(
					"width" = src.holder.owner.bound_width,
					"height" = src.holder.owner.bound_height,
				),
			),
		))
	))

	if (src.hiding) return
	src.holder.owner << output(params, "[src.window]:tooltip.init")

/datum/tooltip/proc/update()
	
	if (src.hiding) return
	src.holder.owner << output(list2params(list(json_encode(alist(
		"options" = src.options.toList(),
	)))), "[src.window]:tooltip.update")


/datum/tooltip/proc/show(atom/target, mouse, title, content, theme, list/align, list/size, list/offset, list/bounds, list/extra)
	if (!src.holder) return

	var/update = src.shouldUpdate(target)
	src.preloading = FALSE
	src.hiding = FALSE
	src.target = makeweakref(target)

	if (!update) src.options.reset()
	if (mouse) src.options.setMouse(mouse)
	if (title) src.options.title = title
	if (content) src.options.setContent(content)
	if (theme) src.options.theme = theme
	if (align) src.options.setAlign(align)
	if (size) src.options.setSize(size)
	if (offset) src.options.setOffset(offset)
	if (bounds) src.options.setBounds(bounds)
	if (extra) src.options.extra = extra

	if (update)
		src.update()
	else
		usr.register_event(/event/death, src.holder.owner.mob, nameof(src::hide()))

		src.loaded ? src.build() : src.create()

/datum/tooltip/proc/hide()
	if (src.hiding || !src.holder) return
	src.hiding = TRUE
	src.holder.owner << output("", "[src.window]:tooltip.hide")

/datum/tooltip/proc/onHidden()
	src.showing = FALSE
	if (src.holder?.owner?.mob)
		usr.unregister_event(/event/death, src.holder.owner.mob, nameof(src::hide()))


/datum/tooltip/proc/remove()
	src.hiding = TRUE
	winset(src.holder.owner, src.window, "parent=null")
	src.onHidden()
	src.holder.onTooltipRemoved(src)

/datum/tooltip/proc/focusMap()
	winset(src.holder.owner, "[src.holder.mapId].[src.holder.mapControl]", "focus=1")

/datum/tooltip/Topic(href, href_list)
	switch (href_list["action"])
		if ("loaded")
			src.loaded = TRUE
			if (!src.preloading) src.build()
		if ("showing")
			src.showing = TRUE
		if ("hidden")
			src.onHidden()

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
	src.title = null
	src.content = null
	src.theme = null
	src.transform = null
	src.pinned = FALSE
	src.hud = FALSE
	src.mouse = alist("left" = alist(), "bottom" = alist())
	src.align = alist("x" = "left", "y" = "bottom")
	src.size = alist("width" = 0, "height" = 0)
	src.offset = alist("x" = 0, "y" = 0, "tiles" = alist())
	src.bounds = alist("width" = 0, "height" = 0)
	src.extra = alist()

/datum/tooltipOptions/proc/toList()
	return alist(
		"title" = src.title,
		"content" = src.content,
		"theme" = src.theme,
		"transform" = src.transform,
		"pinned" = src.pinned,
		"hud" = src.hud,
		"mouse" = src.mouse,
		"align" = src.align,
		"size" = src.size,
		"offset" = src.offset,
		"bounds" = src.bounds,
		"extra" = src.extra,
	)

/datum/tooltipOptions/proc/setContent(content)
	src.content = content

	/**
	 * Parse and set the mouse target position
	 *
	 * Arguments:
	 * * params (string) - Provided from MouseEntered (and similar) procs
	 */
/datum/tooltipOptions/proc/setMouse(params)
	src.mouse = alist("left" = alist(), "bottom" = alist())
	if (!params) return
	params = params2list(params)

	src.mouse["left"]["icon"] = text2num(params["icon-x"])
	src.mouse["bottom"]["icon"] = text2num(params["icon-y"])

	if (params["vis-x"]) src.mouse["left"]["vis"] = text2num(params["vis-x"])
	if (params["vis-y"]) src.mouse["bottom"]["vis"] = text2num(params["vis-y"])

	var/list/screenLoc = splittext(params["screen-loc"], ",")
	var/list/screenLocLeft = splittext(screenLoc[1], ":")
	src.mouse["left"]["tiles"] = text2num(screenLocLeft[1])
	src.mouse["left"]["pixels"] = text2num(screenLocLeft[2])
	var/list/screenLocBottom = splittext(screenLoc[2], ":")
	src.mouse["bottom"]["tiles"] = text2num(screenLocBottom[1])
	src.mouse["bottom"]["pixels"] = text2num(screenLocBottom[2])

	/**
	 * Set the position of the tooltip around the target
	 *
	 * Arguments:
	 * * flags (int) - Bitmask representing alignment. See `_std\defines\tooltips.dm` for available flags.
	 * 					 			 Multiple flags can be combined, e.g. `TOOLTIP_TOP | TOOLTIP_CENTER`
	 */
/datum/tooltipOptions/proc/setAlign(flags)
	src.align = alist("x" = "left", "y" = "bottom")
	if (!flags) return

	var/list/newAlign = alist("x" = "", "y" = "")
	if (flags & TOOLTIP_TOP) newAlign["y"] = "top"
	else if (flags & TOOLTIP_BOTTOM) newAlign["y"] = "bottom"
	if (flags & TOOLTIP_RIGHT) newAlign["x"] = "right"
	else if (flags & TOOLTIP_LEFT) newAlign["x"] = "left"
	if (flags & TOOLTIP_CENTER)
		if (newAlign["x"]) newAlign["y"] = "center"
		else newAlign["x"] = "center"

	if (!newAlign["x"]) newAlign["x"] = "left"
	if (!newAlign["y"]) newAlign["y"] = "bottom"
	src.align = newAlign

	/**
	 * Override the size of the tooltip.
	 * Note that dimensions will still not exceed maximums set in `tooltip.css`, and are still subject to window/dpi scaling.
	 *
	 * Arguments:
	 * * newSize (list) - Width and height respectively, e.g. `list(200, 300)`
	 * 										Use `0` for either to use the automatic size for that axis
	 */
/datum/tooltipOptions/proc/setSize(list/newSize)
	src.size = alist(
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
	src.offset["x"] = newOffset.len >= 1 ? newOffset[1] : 0
	src.offset["y"] = newOffset.len >= 2 ? newOffset[2] : 0

	/**
	 * Set the dimensions of the target, required for tooltip positioning.
	 * Unlikely you will need to use this directly.
	 *
	 * Arguments:
	 * * newBounds (list) - Width and height respectively, e.g. `list(200, 300)`
	 */
/datum/tooltipOptions/proc/setBounds(list/newBounds)
	src.bounds = alist(
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
	src.offset["tiles"][direction] = amount
