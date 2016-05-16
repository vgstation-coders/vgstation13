/*
 * This file handles all parallax-related business once the parallax itself is initialized with the rest of the HUD
 */

/*
Short explanation of how Space Parallax works in Space Station 13

On startup, the game generates 3 lists (space_parallax_0, space_parallax_1 and space_parallax_2) in 0.8 seconds,
Each of those lists contains 9 blank images, which in turn have a staggering 255 overlays. And each of those lists corresponds to a layer.
Since those overlays aren't blended in, this allows animated sprites (twinkling stars namely)
space_parallax_0 is the back layer, the one that doesn't move.
space_parallax_1 is the middle layer, the one that moves 1 pixel per movements
space_parallax_2 is the front layer, the one that moves 2 pixels per movements
When a player arrives, and has parallax enabled, the game will make him generate 9 /obj/screen/parallax for each of the 3 layers (so 27 in total, stored in the client's "parallax" list),
And will copy the corresponding list's images' overlays to those objects. Thus, all players share the same space backgrounds for the round.

Every time a player moves/is moved, the parallax will update. The parallax_offset client list lets the game know how much the player has moved in one direction
And this is what the game uses to update the /obj/screen/parallax's screen_loc offsets. This prevents space from "jumping" when you drift from a Z Level to the next.

The client's parallax_canvas variable is a fullscreen screen object that displays a given color. It appears behind the parallax objects.
The player can hide the space turf's "space dust" in his preferences, which will move the canvas' plane above the dust. Therefore hiding it.

Parallax will be automatically disabled in areas that have a custom "parallax_icon_state". Furthermore, parallax is disabled on the centcom Z level, so it doesn't conflict with Hyperspace.

*/

#define PARALLAX_LAYER_PLANE -3

/client/var/list/parallax = list()
/client/var/list/parallax_offset = list()
/client/var/turf/previous_turf = null
/client/var/obj/screen/parallax_void/parallax_canvas = null

/obj/screen/parallax
	var/base_offset_x = 0
	var/base_offset_y = 0
	mouse_opacity = 0
	icon = 'icons/turf/space.dmi'
	icon_state = "blank"
	name = "space parallax"
	layer = AREA_LAYER
	plane = PLANE_SPACE_PARALLAX_BACK//changing this var doesn't actually change the plane of its overlays

/obj/screen/parallax_void
	mouse_opacity = 0
	icon = 'icons/turf/space.dmi'
	icon_state = "white"
	name = "space parallax"
	layer = AREA_LAYER
	plane = PLANE_SPACE_PARALLAX_CANVAS
	screen_loc = "WEST,SOUTH to EAST,NORTH"

/datum/hud/proc/update_parallax()
	if(!parallax_initialized) return

	var/client/C = mymob.client

	if((mymob.z != map.zCentcomm) && C.prefs.space_parallax)//have to exclude Centcom so parallax doens't appear during hyperspace
		for(var/obj/screen/parallax/bgobj in C.parallax)
			C.screen |= bgobj
	else
		for(var/obj/screen/parallax/bgobj in C.parallax)
			C.screen -= bgobj
			C.parallax -= bgobj
			qdel(bgobj)
		qdel(C.parallax_canvas)
		C.parallax_canvas = null
		return

	if(!C.parallax_canvas)
		C.parallax_canvas = new

	C.parallax_canvas.color = space_color
	C.screen |= C.parallax_canvas

	var/recalibrate = 0
	if(!C.parallax.len)
		recalibrate = 1
	else
		var/obj/screen/parallax/sample = C.parallax[1]
		if(!sample.overlays.len)
			recalibrate = 1

	if(recalibrate)
		for(var/i=1;i<=9;i++)
			var/obj/screen/parallax/bgobj = new /obj/screen/parallax()
			var/image/parallax_layer = space_parallax_0[i]
			bgobj.overlays |= parallax_layer.overlays
			bgobj.plane = PLANE_SPACE_PARALLAX_BACK
			calibrate_parallax(C,bgobj,i)
		for(var/i=1;i<=9;i++)
			var/obj/screen/parallax/bgobj = new /obj/screen/parallax()
			var/image/parallax_layer = space_parallax_1[i]
			bgobj.overlays |= parallax_layer.overlays
			bgobj.plane = PLANE_SPACE_PARALLAX_MIDDLE
			calibrate_parallax(C,bgobj,i)
		for(var/i=1;i<=9;i++)
			var/obj/screen/parallax/bgobj = new /obj/screen/parallax()
			var/image/parallax_layer = space_parallax_2[i]
			bgobj.overlays |= parallax_layer.overlays
			bgobj.plane = PLANE_SPACE_PARALLAX_FRONT
			calibrate_parallax(C,bgobj,i)

	if(C.prefs.space_dust)
		C.parallax_canvas.plane = PLANE_SPACE_PARALLAX_CANVAS
	else
		C.parallax_canvas.plane = PLANE_SPACE_PARALLAX_NODUST_CANVAS

	if(!C.parallax_offset.len)
		C.parallax_offset["horizontal"] = 0
		C.parallax_offset["vertical"] = 0

	var/turf/posobj = get_turf(mymob.client.eye)

	if(!C.previous_turf || (C.previous_turf.z != posobj.z))
		C.previous_turf = posobj

	//Doing it this way prevents parallax layers from "jumping" when you change Z-Levels.
	C.parallax_offset["horizontal"] += posobj.x - C.previous_turf.x
	C.parallax_offset["vertical"] += posobj.y - C.previous_turf.y

	C.previous_turf = posobj

	for(var/obj/screen/parallax/bgobj in C.parallax)
		if(C.prefs.space_parallax >= 2)
			switch(bgobj.plane)//only the middle and front layers actually move
				if(PLANE_SPACE_PARALLAX_MIDDLE)
					var/accumulated_offset_x = bgobj.base_offset_x + C.parallax_offset["horizontal"]
					var/accumulated_offset_y = bgobj.base_offset_y + C.parallax_offset["vertical"]

					while(accumulated_offset_x > 720)
						bgobj.base_offset_x -= 1440
						accumulated_offset_x -= 1440
					while(accumulated_offset_x < -720)
						bgobj.base_offset_x += 1440
						accumulated_offset_x += 1440

					while(accumulated_offset_y > 720)
						bgobj.base_offset_y -= 1440
						accumulated_offset_y -= 1440
					while(accumulated_offset_y < -720)
						bgobj.base_offset_y += 1440
						accumulated_offset_y += 1440
					bgobj.screen_loc = "CENTER-7:[bgobj.base_offset_x-C.parallax_offset["horizontal"]],CENTER-7:[bgobj.base_offset_y-C.parallax_offset["vertical"]]"
				if(PLANE_SPACE_PARALLAX_FRONT)
					var/accumulated_offset_x = bgobj.base_offset_x + (C.parallax_offset["horizontal"] * 2)
					var/accumulated_offset_y = bgobj.base_offset_y + (C.parallax_offset["vertical"] * 2)

					while(accumulated_offset_x > 720)
						bgobj.base_offset_x -= 1440
						accumulated_offset_x -= 1440
					while(accumulated_offset_x < -720)
						bgobj.base_offset_x += 1440
						accumulated_offset_x += 1440

					while(accumulated_offset_y > 720)
						bgobj.base_offset_y -= 1440
						accumulated_offset_y -= 1440
					while(accumulated_offset_y < -720)
						bgobj.base_offset_y += 1440
						accumulated_offset_y += 1440
					bgobj.screen_loc = "CENTER-7:[bgobj.base_offset_x-(C.parallax_offset["horizontal"] * 2)],CENTER-7:[bgobj.base_offset_y-(C.parallax_offset["vertical"] * 2)]"
				else
					bgobj.screen_loc = "CENTER-7:[bgobj.base_offset_x],CENTER-7:[bgobj.base_offset_y]"
		else
			bgobj.screen_loc = "CENTER-7:[bgobj.base_offset_x],CENTER-7:[bgobj.base_offset_y]"

/datum/hud/proc/calibrate_parallax(var/client/C,var/obj/screen/parallax/p_layer,var/i)
	if(!C || !p_layer || !i) return

	/*
	1	2	3
	4	5	6
	7	8	9
	*/

	switch(i)
		if(1,4,7)
			p_layer.base_offset_x = -480
		if(3,6,9)
			p_layer.base_offset_x = 480
	switch(i)
		if(1,2,3)
			p_layer.base_offset_y = 480
		if(7,8,9)
			p_layer.base_offset_y = -480
	C.parallax += p_layer
	C.screen += p_layer
