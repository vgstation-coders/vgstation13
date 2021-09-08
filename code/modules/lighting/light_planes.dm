/obj/abstract/screen/plane
	name = ""
	screen_loc = "CENTER"
	blend_mode = BLEND_MULTIPLY
	layer = 1

/obj/abstract/screen/plane/New(var/client/C)
	..()
	if(istype(C))
		C.screen += src
	verbs.Cut()

/obj/abstract/screen/plane/master
	icon = 'icons/mob/screen1.dmi'
	appearance_flags = NO_CLIENT_COLOR | PLANE_MASTER | RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA
	color = LIGHTING_PLANEMASTER_COLOR  // Completely black.
	plane = LIGHTING_PLANE
	mouse_opacity = 0

//poor inheritance shitcode
/obj/abstract/screen/backdrop
	blend_mode = BLEND_OVERLAY
	icon = 'icons/mob/screen1.dmi'
	icon_state = "black"
	layer = BACKGROUND_LAYER
	screen_loc = "CENTER"
	plane = LIGHTING_PLANE

/obj/abstract/screen/backdrop/New(var/client/C)
	..()
	if(istype(C)) C.screen += src
	var/matrix/M = matrix()
	M.Scale(world.view*3)
	transform = M
	verbs.Cut()

/obj/abstract/screen/plane/self_vision
	blend_mode = BLEND_ADD
	mouse_opacity = 0
	plane = LIGHTING_PLANE
	layer = SELF_VISION_LAYER
	icon = 'icons/lighting/self_vision_default.dmi'
	icon_state = "default"
	alpha = 0
	appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA
	invisibility = INVISIBILITY_LIGHTING
	var/target_alpha = HUMAN_TARGET_ALPHA

/obj/abstract/screen/plane/dark
	blend_mode = BLEND_ADD
	mouse_opacity = 0
	plane = LIGHTING_PLANE // Just below the master plane.
	icon = 'icons/lighting/over_dark.dmi'
	alpha = 10
	appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA
	var/list/alphas = list()
	var/colours = null // will animate() to that colour next check_dark_vision()

/obj/abstract/screen/plane/dark/New()
	..()
	var/matrix/M = matrix()
	M.Scale(world.view*2.2)
	transform = M
