/atom/movable/lighting_overlay
	name          = ""

	anchored      = TRUE
	ignoreinvert  = TRUE

	icon             = LIGHTING_ICON
	color            = LIGHTING_BASE_MATRIX
	plane            = LIGHTING_PLANE
	mouse_opacity    = 0
	layer            = LIGHTING_LAYER
	invisibility     = INVISIBILITY_LIGHTING

	var/needs_update = FALSE

	#if WORLD_ICON_SIZE != 32
	transform = matrix(WORLD_ICON_SIZE / 32, 0, (WORLD_ICON_SIZE - 32) / 2, 0, WORLD_ICON_SIZE / 32, (WORLD_ICON_SIZE - 32) / 2)
	#endif

/atom/movable/lighting_overlay/New(var/atom/loc, var/no_update = FALSE)
	. = ..()
	verbs.Cut()

	var/turf/T         = loc // If this runtimes atleast we'll know what's creating overlays in things that aren't turfs.
	T.lighting_overlay = src
	T.luminosity       = 0

	if (no_update)
		return

	update_overlay()

/atom/movable/lighting_overlay/Destroy()
	global.lighting_update_overlays     -= src

	var/turf/T   = loc
	if (istype(T))
		T.lighting_overlay = null
		T.luminosity = 1

	..()

/atom/movable/lighting_overlay/proc/update_overlay()
	var/turf/T = loc
	if (!istype(T)) // Erm...
		if (loc)
			warning("A lighting overlay realised its loc was NOT a turf (actual loc: [loc], [loc.type]) in update_overlay() and got pooled!")

		else
			warning("A lighting overlay realised it was in nullspace in update_overlay() and got pooled!")

		qdel(src)
		return

	if (!T.lighting_corners_initialised)//may happen due to nano paint
		T.generate_missing_corners()

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	// See LIGHTING_CORNER_DIAGONAL in lighting_corner.dm for why these values are what they are.
	// No I seriously cannot think of a more efficient method, fuck off Comic.
	var/datum/lighting_corner/cr  = T.corners[3] || dummy_lighting_corner
	var/datum/lighting_corner/cg  = T.corners[2] || dummy_lighting_corner
	var/datum/lighting_corner/cb  = T.corners[4] || dummy_lighting_corner
	var/datum/lighting_corner/ca  = T.corners[1] || dummy_lighting_corner

	var/max = max(cr.cache_mx, cg.cache_mx, cb.cache_mx, ca.cache_mx)

	if (T.paint_overlay && T.paint_overlay.nano_paint)
		var/list/RGB = rgb2num(T.paint_overlay.main_color)
		var/nano_R = RGB[1]/255
		var/nano_G = RGB[2]/255
		var/nano_B = RGB[3]/255
		max = max(max, nano_R, nano_G, nano_B)
		color  = list(
			max(nano_R, cr.cache_r), max(nano_G, cr.cache_g), max(nano_B, cr.cache_b), 0,
			max(nano_R, cg.cache_r), max(nano_G, cg.cache_g), max(nano_B, cg.cache_b), 0,
			max(nano_R, cb.cache_r), max(nano_G, cb.cache_g), max(nano_B, cb.cache_b), 0,
			max(nano_R, ca.cache_r), max(nano_G, ca.cache_g), max(nano_B, ca.cache_b), 0,
			0, 0, 0, 1
		)
	else
		color  = list(
			cr.cache_r, cr.cache_g, cr.cache_b, 0,
			cg.cache_r, cg.cache_g, cg.cache_b, 0,
			cb.cache_r, cb.cache_g, cb.cache_b, 0,
			ca.cache_r, ca.cache_g, ca.cache_b, 0,
			0, 0, 0, 1
		)
	luminosity = max > LIGHTING_SOFT_THRESHOLD

// Variety of overrides so the overlays don't get affected by weird things.

/atom/movable/lighting_overlay/ex_act(severity)
	return 0

/atom/movable/lighting_overlay/shuttle_act()
	return 0

/atom/movable/lighting_overlay/can_shuttle_move()
	return 0

/atom/movable/lighting_overlay/singularity_act()
	return

/atom/movable/lighting_overlay/singularity_pull()
	return

/atom/movable/lighting_overlay/blob_act()
	return

// Override here to prevent things accidentally moving around overlays.
/atom/movable/lighting_overlay/forceMove(atom/destination, step_x = 0, step_y = 0, no_tp = FALSE, harderforce = FALSE, glide_size_override = 0)
	if(harderforce)
		. = ..()

/atom/movable/lighting_overlay/send_to_future(var/duration)
	return

/atom/movable/lighting_overlay/send_to_past(var/duration)
	return

/atom/movable/lighting_overlay/clean_act(var/cleanliness)
	return
