/mob
	var/obj/abstract/screen/plane/master/lighting_planemaster
	var/obj/abstract/screen/plane/self_vision/self_vision
	var/obj/abstract/screen/plane/dark/dark_plane
	var/seedarkness = TRUE

/mob/proc/create_lighting_planes()

	if (dark_plane)
		client.screen -= dark_plane
		QDEL_NULL(dark_plane)

	if (lighting_planemaster)
		client.screen -= lighting_planemaster
		QDEL_NULL(lighting_planemaster)

	if (self_vision)
		client.screen -= self_vision
		QDEL_NULL(self_vision)

	dark_plane = new(client)
	lighting_planemaster = new(client)
	self_vision = new(client)

	// ensure these are properly cleaned up when client.reset_screen or something runs
	// lest the old mob keep a ref to them for ever (until inevitable hdel)
	dark_plane.pointer_to_var = &dark_plane
	lighting_planemaster.pointer_to_var = &lighting_planemaster
	self_vision.pointer_to_var = &self_vision

	update_darkness()
	register_event(/event/before_move, src, /mob/proc/check_dark_vision)

/mob/proc/update_darkness()
	if(seedarkness)
		lighting_planemaster?.color = LIGHTING_PLANEMASTER_COLOR
	else
		lighting_planemaster?.color = ""

