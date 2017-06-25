/obj/screen/plane
	name = ""
	screen_loc = "CENTER"
	blend_mode = BLEND_MULTIPLY
	layer = 1

/obj/screen/plane/New(var/client/C)
	..()
	if(istype(C)) C.screen += src
	verbs.Cut()

/obj/screen/plane/master
	icon = 'icons/mob/screen1.dmi'
	appearance_flags = NO_CLIENT_COLOR | PLANE_MASTER | RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA
	//list(null,null,null,"#0000","#000F")
	color = LIGHTING_PLANEMASTER_COLOR  // Completely black.
	plane = LIGHTING_PLANE_MASTER
	mouse_opacity = 0




#warn shitcode
	var/backdrop

/obj/screen/plane/master/New(var/client/C)
	..()
	var/obj/O = new
	O.blend_mode = BLEND_OVERLAY  // this is important so it doesn't inherit
	O.icon = 'icons/mob/screen1.dmi'  // a black icon using your regular world.icon_size
	O.icon_state = "black"
	O.layer = BACKGROUND_LAYER
	O.screen_loc = "CENTER"
	var/matrix/M = matrix()
	M.Scale(world.view*3)
	O.plane = LIGHTING_PLANE_MASTER
	O.transform = M
	backdrop = O
	C.screen += O





/obj/screen/plane/dark
	blend_mode = BLEND_ADD
	plane = LIGHTING_PLANE_MASTER // Just below the master plane.
	icon = 'icons/lighting/over_dark.dmi'
	alpha = 10
	appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA

/obj/screen/plane/dark/New()
	..()
	var/matrix/M = matrix()
	M.Scale(world.view*2.2)
	transform = M
