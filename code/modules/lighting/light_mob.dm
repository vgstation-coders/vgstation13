/mob
	var/obj/abstract/screen/plane/master/master_plane
	var/obj/abstract/screen/backdrop/backdrop
	var/obj/abstract/screen/plane/self_vision/self_vision
	var/obj/abstract/screen/plane/dark/dark_plane
	var/seedarkness = 1

/mob/proc/create_lighting_planes()

	if (dark_plane)
		client.screen -= dark_plane
		QDEL_NULL(dark_plane)

	if (master_plane)
		client.screen -= master_plane
		QDEL_NULL(master_plane)

	if (backdrop)
		client.screen -= backdrop
		qdel(backdrop)
		backdrop = null

	if (self_vision)
		client.screen -= self_vision
		QDEL_NULL(self_vision)

	dark_plane = new(client)
	master_plane = new(client)
	backdrop = new(client)
	self_vision = new(client)

	var/image/black_turf = image('icons/lighting/wall_lighting.dmi', loc = src)
	black_turf.icon_state = "black"
	black_turf.render_target = "*black_turf_prerender"
	client.images += black_turf

	var/image/white_turf = image('icons/lighting/wall_lighting.dmi', loc = src)
	white_turf.icon_state = "white"
	white_turf.render_target = "*white_turf_prerender"
	client.images += white_turf

	update_darkness()
	register_event(/event/before_move, src, /mob/proc/check_dark_vision)

/mob/proc/update_darkness()
	if(seedarkness)
		master_plane?.color = LIGHTING_PLANEMASTER_COLOR
	else
		master_plane?.color = ""
