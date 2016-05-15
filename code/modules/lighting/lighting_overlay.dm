/var/list/all_lighting_overlays = list() // Global list of lighting overlays.

/atom/movable/lighting_overlay
	name             = ""

	icon             = LIGHTING_ICON
	color            = LIGHTING_BASE_MATRIX

	mouse_opacity    = 0
	layer            = LIGHTING_LAYER
	invisibility     = INVISIBILITY_LIGHTING

	blend_mode       = BLEND_MULTIPLY

	var/needs_update = FALSE

/atom/movable/lighting_overlay/New(var/atom/loc, var/no_update = FALSE)
	. = ..()
	verbs.Cut()
	global.all_lighting_overlays += src

	var/turf/T         = loc // If this runtimes atleast we'll know what's creating overlays in things that aren't turfs.
	T.lighting_overlay = src
	T.luminosity       = 0

	if(no_update)
		return

	update_overlay()

/atom/movable/lighting_overlay/Destroy()
	var/turf/T   = loc
	if(istype(T))
		T.lighting_overlay = null

	T.luminosity = 1

	lighting_update_overlays -= src;

	..()

/atom/movable/lighting_overlay/proc/update_overlay()
	var/turf/T = loc
	if(!istype(T)) // Erm...
		if(loc)
			warning("A lighting overlay realised its loc was NOT a turf (actual loc: [loc], [loc.type]) in update_overlay() and got pooled!")

		else
			warning("A lighting overlay realised it was in nullspace in update_overlay() and got pooled!")

		returnToPool(src)

	var/list/L = src.color:Copy() // For some dumb reason BYOND won't allow me to use [] on a colour matrix directly.
	var/max    = 0

	for(var/datum/lighting_corner/C in T.corners)
		var/i = 0

		// Huge switch to determine i based on D.
		switch(turn(C.masters[T], 180))
			if(NORTHEAST)
				i = CL_MATRIX_AR

			if(SOUTHEAST)
				i = CL_MATRIX_GR

			if(SOUTHWEST)
				i = CL_MATRIX_RR

			if(NORTHWEST)
				i = CL_MATRIX_BR

		var/mx = max(C.lum_r, C.lum_g, C.lum_b) // Scale it so 1 is the strongest lum, if it is above 1.
		. = 1 // factor
		if(mx > 1)
			. = 1 / mx

		max = max(., mx)

		L[i + 0]   = C.lum_r * .
		L[i + 1]   = C.lum_g * .
		L[i + 2]   = C.lum_b * .

	src.color  = L
	luminosity = (max > LIGHTING_SOFT_THRESHOLD)
