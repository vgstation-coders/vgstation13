var/datum/subsystem/lighting/SSlighting

var/list/lighting_update_lights    = list() // List of lighting sources  queued for update.
var/list/lighting_update_corners   = list() // List of lighting corners  queued for update.
var/list/lighting_update_overlays  = list() // List of lighting overlays queued for update.

/datum/subsystem/lighting
	name          = "Lighting"
	init_order    = SS_INIT_LIGHTING
	display_order = SS_DISPLAY_LIGHTING
	wait          = 1
	priority      = SS_PRIORITY_LIGHTING
	flags         = SS_TICKER

/datum/subsystem/lighting/New()
	NEW_SS_GLOBAL(SSlighting)

/datum/subsystem/lighting/stat_entry()
	..("L:[lighting_update_lights.len]|C:[lighting_update_corners.len]|O:[lighting_update_overlays.len]")

/datum/subsystem/lighting/Initialize(timeofday)
	create_all_lighting_overlays()
	..()

/datum/subsystem/lighting/fire(resumed=FALSE)
	var/real_tick_limit = CURRENT_TICKLIMIT
	CURRENT_TICKLIMIT = (real_tick_limit - world.tick_usage)/3
	var/i = 0
	for (i in 1 to lighting_update_lights.len)
		var/datum/light_source/L = lighting_update_lights[i]

		if (L.check() || L.destroyed || L.force_update)
			L.remove_lum()
			if (!L.destroyed)
				L.apply_lum()

		else if (L.vis_update) //We smartly update only tiles that became (in) visible to use.
			L.smart_vis_update()

		L.vis_update   = FALSE
		L.force_update = FALSE
		L.needs_update = FALSE

		if (TICK_CHECK)
			break
	if (i)
		lighting_update_lights.Cut(1, i+1)
		i = 0

	CURRENT_TICKLIMIT = ((real_tick_limit - world.tick_usage)/2)+world.tick_usage

	for (i in 1 to lighting_update_corners.len)
		var/datum/lighting_corner/C = lighting_update_corners[i]

		C.update_overlays()
		C.needs_update = FALSE
		if (TICK_CHECK)
			break
	if (i)
		lighting_update_corners.Cut(1, i+1)
		i = 0

	CURRENT_TICKLIMIT = real_tick_limit

	for (i in 1 to lighting_update_overlays.len)
		var/atom/movable/lighting_overlay/O = lighting_update_overlays[i]

		if (!O || O.gcDestroyed)
			continue

		O.update_overlay()
		O.needs_update = FALSE
		if (TICK_CHECK)
			break
	if (i)
		lighting_update_overlays.Cut(1, i+1)

/datum/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()