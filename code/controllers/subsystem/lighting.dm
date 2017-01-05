var/datum/subsystem/lighting/SSlighting

var/list/lighting_update_lights    = list()    // List of lighting sources  queued for update.
var/list/lighting_update_corners   = list()    // List of lighting corners  queued for update.
var/list/lighting_update_overlays  = list()    // List of lighting overlays queued for update.


/datum/subsystem/lighting
	name = "Lighting"
	init_order = INIT_LIGHTING
	wait = LIGHTING_INTERVAL

	var/initialized = FALSE

	var/list/currentrun_lights
	var/list/currentrun_corners
	var/list/currentrun_overlays


/datum/subsystem/lighting/New()
	NEW_SS_GLOBAL(SSlighting)


/datum/subsystem/lighting/Initialize(timeofday)
	create_all_lighting_overlays()
	initialized = TRUE

	..()


/datum/subsystem/lighting/fire(resumed = FALSE)
	if (!resumed)
		currentrun_lights   = lighting_update_lights
		currentrun_corners  = lighting_update_corners
		currentrun_overlays = lighting_update_overlays

		lighting_update_lights   = list()
		lighting_update_corners  = list()
		lighting_update_overlays = list()


	while (currentrun_lights.len)
		var/datum/light_source/L = currentrun_lights[currentrun_lights.len]
		currentrun_lights.len--

		if (L.check() || L.destroyed || L.force_update)
			L.remove_lum()
			if (!L.destroyed)
				L.apply_lum()

		else if (L.vis_update) //We smartly update only tiles that became (in) visible to use.
			L.smart_vis_update()

		L.vis_update   = FALSE
		L.force_update = FALSE
		L.needs_update = FALSE

		if (MC_TICK_CHECK)
			return


	while (currentrun_corners.len)
		var/datum/lighting_corner/C = currentrun_corners[currentrun_corners.len]
		currentrun_corners.len--

		C.update_overlays()
		C.needs_update = FALSE
		if (MC_TICK_CHECK)
			return


	while (currentrun_overlays.len)
		var/atom/movable/lighting_overlay/O = currentrun_overlays[currentrun_overlays.len]
		currentrun_overlays.len--

		O.update_overlay()
		O.needs_update = FALSE
		if (MC_TICK_CHECK)
			return


/datum/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
