/mob
	var/obj/abstract/screen/plane/master/master_plane
	var/obj/abstract/screen/backdrop/backdrop
	var/obj/abstract/screen/plane/self_vision/self_vision
	var/obj/abstract/screen/plane/dark/dark_plane

	var/obj/abstract/screen/plane_master/overdark_planemaster/overdark_planemaster
	var/obj/abstract/screen/overdark_target/overdark_target

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

	overdark_planemaster = new
	overdark_planemaster.render_target = "night vision goggles (\ref[src])"
	overdark_target = new
	overdark_target.render_source = "night vision goggles (\ref[src])"

	client.screen |= overdark_planemaster
	client.screen |= overdark_target

	give_light_prerenders()
	//change_sight(adding = SEE_PIXELS)

	update_darkness()
	register_event(/event/before_move, src, /mob/proc/check_dark_vision)

/mob/proc/update_darkness()
	if(seedarkness)
		master_plane?.color = LIGHTING_PLANEMASTER_COLOR
	else
		master_plane?.color = ""

/mob/proc/give_light_prerenders()
	// Black and white turfs for effects
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

	// Common light ranges
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

	// Common shadows : behind the wall, blocking the light; two blocks
	// Light range4
	var/image/shadow4_hard_im_90 = image('icons/lighting/shadow2/light_range_4_shadows2.dmi', loc = hud_used.holomap_obj)
	shadow4_hard_im_90.icon_state = "1_0"
	shadow4_hard_im_90.render_target = "*shadow2_4_90_1_0_1_1_-1"
	shadow4_hard_im_90.mouse_opacity = 0
	shadow4_hard_im_90.invisibility = 101
	client.images += shadow4_hard_im_90

	var/image/shadow4_hard_im_180 = image('icons/lighting/shadow2/light_range_4_shadows2.dmi', loc = hud_used.holomap_obj)
	shadow4_hard_im_180.icon_state = "1_0"
	shadow4_hard_im_180.render_target = "*shadow2_4_180_1_0_1_1_-1"
	shadow4_hard_im_180.mouse_opacity = 0
	shadow4_hard_im_180.invisibility = 101
	var/matrix/M = new()
	M.Turn(-90)
	shadow4_hard_im_180.transform = M
	client.images += shadow4_hard_im_180

	var/image/shadow4_hard_im_0 = image('icons/lighting/shadow2/light_range_4_shadows2.dmi', loc = hud_used.holomap_obj)
	shadow4_hard_im_0.icon_state = "1_0"
	shadow4_hard_im_0.render_target = "*shadow2_4_0_1_0_1_1_-1"
	shadow4_hard_im_0.mouse_opacity = 0
	shadow4_hard_im_0.invisibility = 101
	M = new()
	M.Turn(90)
	shadow4_hard_im_0.transform = M
	client.images += shadow4_hard_im_0

	var/image/shadow4_hard_im_min90 = image('icons/lighting/shadow2/light_range_4_shadows2.dmi', loc = hud_used.holomap_obj)
	shadow4_hard_im_min90.icon_state = "1_0"
	shadow4_hard_im_min90.render_target = "*shadow2_4_-90_1_0_1_1_-1"
	shadow4_hard_im_min90.mouse_opacity = 0
	shadow4_hard_im_min90.invisibility = 101
	M = new()
	M.Scale(1, -1)
	shadow4_hard_im_min90.transform = M
	client.images += shadow4_hard_im_min90

	// Light range5
	var/image/shadow5_hard_im_90 = image('icons/lighting/shadow2/light_range_5_shadows2.dmi', loc = hud_used.holomap_obj)
	shadow5_hard_im_90.icon_state = "1_0"
	shadow5_hard_im_90.render_target = "*shadow2_5_90_1_0_1_1_-1"
	shadow5_hard_im_90.mouse_opacity = 0
	shadow5_hard_im_90.invisibility = 101
	client.images += shadow5_hard_im_90

	var/image/shadow5_hard_im_180 = image('icons/lighting/shadow2/light_range_5_shadows2.dmi', loc = hud_used.holomap_obj)
	shadow5_hard_im_180.icon_state = "1_0"
	shadow5_hard_im_180.render_target = "*shadow2_5_180_1_0_1_1_-1"
	shadow5_hard_im_180.mouse_opacity = 0
	shadow5_hard_im_180.invisibility = 101
	M = new()
	M.Turn(-90)
	shadow5_hard_im_180.transform = M
	client.images += shadow5_hard_im_180

	var/image/shadow5_hard_im_0 = image('icons/lighting/shadow2/light_range_5_shadows2.dmi', loc = hud_used.holomap_obj)
	shadow5_hard_im_0.icon_state = "1_0"
	shadow5_hard_im_0.render_target = "*shadow2_5_0_1_0_1_1_-1"
	shadow5_hard_im_0.mouse_opacity = 0
	shadow5_hard_im_0.invisibility = 101
	M = new()
	M.Turn(90)
	shadow5_hard_im_0.transform = M
	client.images += shadow5_hard_im_0

	var/image/shadow5_hard_im_min90 = image('icons/lighting/shadow2/light_range_5_shadows2.dmi', loc = hud_used.holomap_obj)
	shadow5_hard_im_min90.icon_state = "1_0"
	shadow5_hard_im_min90.render_target = "*shadow2_5_-90_1_0_1_1_-1"
	shadow5_hard_im_min90.mouse_opacity = 0
	shadow5_hard_im_min90.invisibility = 101
	M = new()
	M.Scale(1, -1)
	shadow5_hard_im_min90.transform = M
	client.images += shadow5_hard_im_min90

	// Light range 6
	var/image/shadow6_hard_im_90 = image('icons/lighting/shadow2/light_range_6_shadows2.dmi', loc = hud_used.holomap_obj)
	shadow6_hard_im_90.icon_state = "1_0"
	shadow6_hard_im_90.render_target = "*shadow2_6_90_1_0_1_1_-1"
	shadow6_hard_im_90.mouse_opacity = 0
	shadow6_hard_im_90.invisibility = 101
	client.images += shadow6_hard_im_90

	var/image/shadow6_hard_im_180 = image('icons/lighting/shadow2/light_range_6_shadows2.dmi', loc = hud_used.holomap_obj)
	shadow6_hard_im_180.icon_state = "1_0"
	shadow6_hard_im_180.render_target = "*shadow2_6_180_1_0_1_1_-1"
	shadow6_hard_im_180.mouse_opacity = 0
	shadow6_hard_im_180.invisibility = 101
	M = new()
	M.Turn(-90)
	shadow6_hard_im_180.transform = M
	client.images += shadow6_hard_im_180

	var/image/shadow6_hard_im_0 = image('icons/lighting/shadow2/light_range_6_shadows2.dmi', loc = hud_used.holomap_obj)
	shadow6_hard_im_0.icon_state = "1_0"
	shadow6_hard_im_0.render_target = "*shadow2_6_0_1_0_1_1_-1"
	shadow6_hard_im_0.mouse_opacity = 0
	shadow6_hard_im_0.invisibility = 101
	M = new()
	M.Turn(90)
	shadow6_hard_im_0.transform = M
	client.images += shadow6_hard_im_0

	var/image/shadow6_hard_im_min90 = image('icons/lighting/shadow2/light_range_6_shadows2.dmi', loc = hud_used.holomap_obj)
	shadow6_hard_im_min90.icon_state = "1_0"
	shadow6_hard_im_min90.render_target = "*shadow2_6_-90_1_0_1_1_-1"
	shadow6_hard_im_min90.mouse_opacity = 0
	shadow6_hard_im_min90.invisibility = 101
	M = new()
	M.Scale(1, -1)
	shadow6_hard_im_min90.transform = M
	client.images += shadow6_hard_im_min90

	// Common shadows : behind the wall, blocking the light; 0 blocks
	// Light range4
	var/image/shadow4_hard_im_90_soft = image('icons/lighting/shadow2/light_range_4_shadows2_soft.dmi', loc = hud_used.holomap_obj)
	shadow4_hard_im_90_soft.icon_state = "1_0"
	shadow4_hard_im_90_soft.render_target = "*shadow2_4_90_1_0_0_0_-1"
	shadow4_hard_im_90_soft.mouse_opacity = 0
	shadow4_hard_im_90_soft.invisibility = 101
	client.images += shadow4_hard_im_90_soft

	var/image/shadow4_hard_im_180_soft = image('icons/lighting/shadow2/light_range_4_shadows2_soft.dmi', loc = hud_used.holomap_obj)
	shadow4_hard_im_180_soft.icon_state = "1_0"
	shadow4_hard_im_180_soft.render_target = "*shadow2_4_180_1_0_0_0_-1"
	shadow4_hard_im_180_soft.mouse_opacity = 0
	shadow4_hard_im_180_soft.invisibility = 101
	M = new()
	M.Turn(-90)
	shadow4_hard_im_180_soft.transform = M
	client.images += shadow4_hard_im_180_soft

	var/image/shadow4_hard_im_0_soft = image('icons/lighting/shadow2/light_range_4_shadows2_soft.dmi', loc = hud_used.holomap_obj)
	shadow4_hard_im_0_soft.icon_state = "1_0"
	shadow4_hard_im_0_soft.render_target = "*shadow2_4_0_1_0_0_0_-1"
	shadow4_hard_im_0_soft.mouse_opacity = 0
	shadow4_hard_im_0_soft.invisibility = 101
	M = new()
	M.Turn(90)
	shadow4_hard_im_0_soft.transform = M
	client.images += shadow4_hard_im_0_soft

	var/image/shadow4_hard_im_min90_soft = image('icons/lighting/shadow2/light_range_4_shadows2_soft.dmi', loc = hud_used.holomap_obj)
	shadow4_hard_im_min90_soft.icon_state = "1_0"
	shadow4_hard_im_min90_soft.render_target = "*shadow2_4_-90_1_0_0_0_-1"
	shadow4_hard_im_min90_soft.mouse_opacity = 0
	shadow4_hard_im_min90_soft.invisibility = 101
	M = new()
	M.Scale(1, -1)
	shadow4_hard_im_min90_soft.transform = M
	client.images += shadow4_hard_im_min90_soft

	// Light range5
	var/image/shadow5_hard_im_90_soft = image('icons/lighting/shadow2/light_range_5_shadows2_soft.dmi', loc = hud_used.holomap_obj)
	shadow5_hard_im_90_soft.icon_state = "1_0"
	shadow5_hard_im_90_soft.render_target = "*shadow2_5_90_1_0_0_0_-1"
	shadow5_hard_im_90_soft.mouse_opacity = 0
	shadow5_hard_im_90_soft.invisibility = 101
	client.images += shadow5_hard_im_90_soft

	var/image/shadow5_hard_im_180_soft = image('icons/lighting/shadow2/light_range_5_shadows2_soft.dmi', loc = hud_used.holomap_obj)
	shadow5_hard_im_180_soft.icon_state = "1_0"
	shadow5_hard_im_180_soft.render_target = "*shadow2_5_180_1_0_0_0_-1"
	shadow5_hard_im_180_soft.mouse_opacity = 0
	shadow5_hard_im_180_soft.invisibility = 101
	M = new()
	M.Turn(-90)
	shadow5_hard_im_180_soft.transform = M
	client.images += shadow5_hard_im_180_soft

	var/image/shadow5_hard_im_0_soft = image('icons/lighting/shadow2/light_range_5_shadows2_soft.dmi', loc = hud_used.holomap_obj)
	shadow5_hard_im_0_soft.icon_state = "1_0"
	shadow5_hard_im_0_soft.render_target = "*shadow2_5_0_1_0_0_0_-1"
	shadow5_hard_im_0_soft.mouse_opacity = 0
	shadow5_hard_im_0_soft.invisibility = 101
	M = new()
	M.Turn(90)
	shadow5_hard_im_0_soft.transform = M
	client.images += shadow5_hard_im_0_soft

	var/image/shadow5_hard_im_min90_soft = image('icons/lighting/shadow2/light_range_5_shadows2_soft.dmi', loc = hud_used.holomap_obj)
	shadow5_hard_im_min90_soft.icon_state = "1_0"
	shadow5_hard_im_min90_soft.render_target = "*shadow2_5_-90_1_0_0_0_-1"
	shadow5_hard_im_min90_soft.mouse_opacity = 0
	shadow5_hard_im_min90_soft.invisibility = 101
	M = new()
	M.Scale(1, -1)
	shadow5_hard_im_min90_soft.transform = M
	client.images += shadow5_hard_im_min90_soft

	// Light range 6
	var/image/shadow6_hard_im_90_soft = image('icons/lighting/shadow2/light_range_6_shadows2_soft.dmi', loc = hud_used.holomap_obj)
	shadow6_hard_im_90_soft.icon_state = "1_0"
	shadow6_hard_im_90_soft.render_target = "*shadow2_6_90_1_0_0_0_-1"
	shadow6_hard_im_90_soft.mouse_opacity = 0
	shadow6_hard_im_90_soft.invisibility = 101
	client.images += shadow6_hard_im_90_soft

	var/image/shadow6_hard_im_180_soft = image('icons/lighting/shadow2/light_range_6_shadows2_soft.dmi', loc = hud_used.holomap_obj)
	shadow6_hard_im_180_soft.icon_state = "1_0"
	shadow6_hard_im_180_soft.render_target = "*shadow2_6_180_1_0_0_0_-1"
	shadow6_hard_im_180_soft.mouse_opacity = 0
	shadow6_hard_im_180_soft.invisibility = 101
	M = new()
	M.Turn(-90)
	shadow6_hard_im_180.transform = M
	client.images += shadow6_hard_im_180_soft

	var/image/shadow6_hard_im_0_soft = image('icons/lighting/shadow2/light_range_6_shadows2_soft.dmi', loc = hud_used.holomap_obj)
	shadow6_hard_im_0_soft.icon_state = "1_0"
	shadow6_hard_im_0_soft.render_target = "*shadow2_6_0_1_0_0_0_-1"
	shadow6_hard_im_0_soft.mouse_opacity = 0
	shadow6_hard_im_0_soft.invisibility = 101
	M = new()
	M.Turn(90)
	shadow6_hard_im_0_soft.transform = M
	client.images += shadow6_hard_im_0_soft

	var/image/shadow6_hard_im_min90_soft = image('icons/lighting/shadow2/light_range_6_shadows2_soft.dmi', loc = hud_used.holomap_obj)
	shadow6_hard_im_min90_soft.icon_state = "1_0"
	shadow6_hard_im_min90_soft.render_target = "*shadow2_6_-90_1_0_0_0_-1"
	shadow6_hard_im_min90_soft.mouse_opacity = 0
	shadow6_hard_im_min90_soft.invisibility = 101
	M = new()
	M.Scale(1, -1)
	shadow6_hard_im_min90_soft.transform = M
	client.images += shadow6_hard_im_min90_soft
