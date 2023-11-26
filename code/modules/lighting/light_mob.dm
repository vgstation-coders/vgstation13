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


	var/image/black_turf = image('icons/lighting/wall_lighting.dmi', loc = hud_used.holomap_obj)
	black_turf.icon_state = "black"
	black_turf.render_target = "*black_turf_prerender"
	black_turf.mouse_opacity = 0
	black_turf.invisibility = 101
	client.images += black_turf

	var/image/white_turf = image('icons/lighting/wall_lighting.dmi', loc = hud_used.holomap_obj)
	white_turf.icon_state = "white"
	white_turf.render_target = "*white_turf_prerender"
	white_turf.mouse_opacity = 0
	white_turf.invisibility = 101
	client.images += white_turf

	// Common atoms
	var/image/light_range_1_im = image('icons/lighting/light_range_1.dmi', loc = hud_used.holomap_obj)
	light_range_1_im.icon_state = "overlay"
	light_range_1_im.render_target = "*light_range_1_prerender"
	light_range_1_im.mouse_opacity = 0
	light_range_1_im.invisibility = 101
	client.images += light_range_1_im

	// Fires
	var/image/light_range_4_im = image('icons/lighting/light_range_4.dmi', loc = hud_used.holomap_obj)
	light_range_4_im.icon_state = "overlay"
	light_range_4_im.render_target = "*light_range_4_prerender"
	light_range_4_im.mouse_opacity = 0
	light_range_4_im.invisibility = 101
	client.images += light_range_4_im

	var/image/light_range_5_im = image('icons/lighting/light_range_5.dmi', loc = hud_used.holomap_obj)
	light_range_5_im.icon_state = "overlay"
	light_range_5_im.render_target = "*light_range_5_prerender"
	light_range_5_im.mouse_opacity = 0
	light_range_5_im.invisibility = 101
	client.images += light_range_5_im

	var/image/light_range_6_im = image('icons/lighting/light_range_6.dmi', loc = hud_used.holomap_obj)
	light_range_6_im.icon_state = "overlay"
	light_range_6_im.render_target = "*light_range_6_prerender"
	light_range_6_im.mouse_opacity = 0
	light_range_6_im.invisibility = 101
	client.images += light_range_6_im

	update_darkness()
	register_event(/event/before_move, src, /mob/proc/check_dark_vision)

/mob/proc/update_darkness()
	if(seedarkness)
		master_plane?.color = LIGHTING_PLANEMASTER_COLOR
	else
		master_plane?.color = ""
