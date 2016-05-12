/*
 * This file handles all parallax-related business once the parallax itself is initialized with the rest of the HUD
 */

#define PARALLAX_LAYER_PLANE -3

/client/var/list/parallax = list()

var/list/parallax_on_clients = list()

/obj/screen/parallax
	var/offset_x = 0
	var/offset_y = 0
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = 0
	icon = 'icons/turf/screen1_parallax.dmi'
	icon_state = "space"
	name = "space parallax"
	layer = AREA_LAYER
	plane = PARALLAX_LAYER_PLANE

/datum/hud/proc/update_parallax()
	var/client/C = mymob.client

	if(C.prefs.space_parallax)
		for(var/obj/screen/parallax/bgobj in C.parallax)
			C.screen |= bgobj
	else
		for(var/obj/screen/parallax/bgobj in C.parallax)
			C.screen -= bgobj
			qdel(bgobj)
			C.parallax -= bgobj
		return

	if(!C.parallax.len)
		for(var/i in 0 to 3)
			var/obj/screen/parallax/bgobj = new /obj/screen/parallax()
			if(i & 1)
				bgobj.offset_x = 480
			if(i & 2)
				bgobj.offset_y = 480
			bgobj.screen_loc = "CENTER-7:[bgobj.offset_x],CENTER-7:[bgobj.offset_y]"
			C.parallax += bgobj
			C.screen += bgobj

	var/atom/posobj = get_turf(mymob.client.eye)
	for(var/obj/screen/parallax/bgobj in mymob.client.parallax)
		bgobj.screen_loc = "CENTER-7:[bgobj.offset_x-posobj.x],CENTER-7:[bgobj.offset_y-posobj.y]"
		var/area/A = posobj.loc
		if(A.parallax_icon_state)
			bgobj.icon_state = A.parallax_icon_state
		else
			bgobj.icon_state = "space"