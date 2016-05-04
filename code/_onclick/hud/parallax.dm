/*
 * This file handles all parallax-related business once the parallax itself is initialized with the rest of the HUD
 */

#define VOID_LAYER_PLANE -4
#define PARALLAX_LAYER_PLANE -3

/client/var/obj/screen/parallax //The parallax, basically the background
/client/var/obj/screen/parallax_void //The parallax void, must be separate from the rest

var/list/parallax_on_clients = list()

//The parallax object, this shows above "parallax_void", which is basically a black background
/obj/screen/parallax
	var/offset_x = 0
	var/offset_y = 0
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = 0
	icon = 'icons/mob/screen1_parallax.dmi'
	icon_state = "space"
	name = "space parallax"
	layer = AREA_LAYER
	plane = PARALLAX_LAYER_PLANE

//The parallax void, because freaky meta stuff happens behind that
/obj/screen/parallax_void
	plane = VOID_LAYER_PLANE
	color = list(0, 0, 0,
				 0, 0, 0,
				 0, 0, 0,
				 1, 1, 1) //This will cause space to be a white void if the parallax isn't in, needed for blending
	appearance_flags = PLANE_MASTER
	screen_loc = "WEST,SOUTH to EAST,NORTH"

/datum/hud/proc/initialize_parallax()

	var/client/C = mymob.client

	//Add the parallax void in the absolute background
	C.parallax_void = new
	C.screen += C.parallax_void

	//Now, add our glorious space parallax
	var/obj/screen/parallax/parallax = new /obj/screen/parallax()
	parallax.screen_loc = "CENTER-7:[parallax.offset_x],CENTER-7:[parallax.offset_y]" //Size of the whole screen
	C.parallax = parallax
	C.screen += C.parallax

	update_parallax()

/datum/hud/proc/update_parallax()

	var/client/C = mymob.client
	var/atom/position = get_turf(C.eye)
	//parallax_object.screen_loc = "CENTER-7:[bgobj.offset_x-position.x],CENTER-7:[bgobj.offset_y-position.y]"

	//Check if the area has a custom icon state
	var/area/A = position.loc
	if(!C.parallax || C.parallax.icon_state != A.parallax_icon_state)
		C.parallax.icon_state = A.parallax_icon_state
