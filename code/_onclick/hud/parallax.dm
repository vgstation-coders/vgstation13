/*
 * This file handles all parallax-related business once the parallax itself is initialized with the rest of the HUD
 */

#define PARALLAX_LAYER_PLANE -3

/client/var/list/parallax = list()
/client/var/list/parallax_offset = list()
/client/var/turf/previous_turf = null

var/list/parallax_on_clients = list()

/obj/screen/parallax
	var/base_offset_x = 0
	var/base_offset_y = 0
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
		/*
		1	2	3
		4	5	6
		7	8	9
		*/
		for(var/i=1;i<=9;i++)
			var/obj/screen/parallax/bgobj = new /obj/screen/parallax()
			switch(i)
				if(1,4,7)
					bgobj.base_offset_x = -480
				if(3,6,9)
					bgobj.base_offset_x = 480
			switch(i)
				if(1,2,3)
					bgobj.base_offset_y = 480
				if(7,8,9)
					bgobj.base_offset_y = -480
			C.parallax += bgobj
			C.screen += bgobj

	if(!C.parallax_offset.len)
		C.parallax_offset["horizontal"] = 0
		C.parallax_offset["vertical"] = 0

	var/turf/posobj = get_turf(mymob.client.eye)

	if(!C.previous_turf || (C.previous_turf.z != posobj.z))
		C.previous_turf = posobj

	C.parallax_offset["horizontal"] += posobj.x - C.previous_turf.x
	C.parallax_offset["vertical"] += posobj.y - C.previous_turf.y

	C.previous_turf = posobj

	for(var/obj/screen/parallax/bgobj in C.parallax)
		var/accumulated_offset_x = bgobj.base_offset_x + C.parallax_offset["horizontal"]
		var/accumulated_offset_y = bgobj.base_offset_y + C.parallax_offset["vertical"]

		if(accumulated_offset_x > 720)
			bgobj.base_offset_x -= 1440
		else if(accumulated_offset_x < -720)
			bgobj.base_offset_x += 1440

		if(accumulated_offset_y > 720)
			bgobj.base_offset_y -= 1440
		else if(accumulated_offset_y < -720)
			bgobj.base_offset_y += 1440

		bgobj.screen_loc = "CENTER-7:[bgobj.base_offset_x-C.parallax_offset["horizontal"]],CENTER-7:[bgobj.base_offset_y-C.parallax_offset["vertical"]]"
		var/area/A = posobj.loc
		if(A.parallax_icon_state)
			bgobj.icon_state = A.parallax_icon_state
		else
			bgobj.icon_state = "space"