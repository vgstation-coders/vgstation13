/*
 * This file handles all parallax-related business once the parallax itself is initialized with the rest of the HUD
 */

var/list/parallax_on_clients = list()

/obj/screen/parallax
	var/base_offset_x = 0
	var/base_offset_y = 0
	mouse_opacity = 0
	icon = 'icons/turf/space.dmi'
	icon_state = "blank"
	name = "space parallax"
	blend_mode = BLEND_ADD
	layer = AREA_LAYER
	plane = PLANE_SPACE_PARALLAX//changing this var doesn't actually change the plane of its overlays
	globalscreen = 1
	var/parallax_speed = 0

/obj/plane_master
	appearance_flags = PLANE_MASTER

/obj/plane_master/parallax_master
	plane = PLANE_SPACE_PARALLAX

/obj/plane_master/parallax_dustmaster
	plane = PLANE_SPACE_PARALLAX_DUST

/obj/screen/parallax_canvas
	mouse_opacity = 0
	icon = 'icons/turf/space.dmi'
	icon_state = "white"
	name = "space parallax"
	blend_mode = BLEND_ADD
	layer = AREA_LAYER
	plane = PLANE_SPACE_PARALLAX
	globalscreen = 1

/datum/hud/proc/update_parallax()
	var/client/C = mymob.client
	if(!parallax_initialized || C.updating_parallax) return

	for(var/turf/T in range(get_turf(C.eye),C.view))
		if(istype(T,/turf/space))
			C.updating_parallax = 1
			break

	if(!C.updating_parallax)
		return

	//multiple sub-procs for profiling purposes
	if(update_parallax1())
		update_parallax2(0)
		update_parallax3()
		C.updating_parallax = 0
	else
		C.updating_parallax = 0

/datum/hud/proc/update_parallax_and_dust()
	var/client/C = mymob.client
	if(!parallax_initialized || C.updating_parallax) return
	C.updating_parallax = 1
	if(update_parallax1())
		update_parallax2(1)
		update_parallax3()
		C.updating_parallax = 0
	else
		C.updating_parallax = 0

/datum/hud/proc/update_parallax1()
	var/client/C = mymob.client
	//DO WE UPDATE PARALLAX
	if(C.prefs.space_parallax)//have to exclude Centcom so parallax doens't appear during hyperspace
		parallax_on_clients |= C
	else
		for(var/obj/screen/parallax/bgobj in C.parallax)
			C.screen -= bgobj
		for(var/obj/screen/parallax/bgobj in C.parallax_nodust)
			C.screen -= bgobj
		parallax_on_clients -= C

		C.screen -= C.parallax_master
		C.screen -= C.parallax_canvas
		C.screen -= C.parallax_dustmaster
		return 0

	if(!C.parallax_master)
		C.parallax_master = getFromPool(/obj/plane_master/parallax_master)

	if(!C.parallax_canvas)
		C.parallax_canvas = getFromPool(/obj/screen/parallax_canvas)
		var/icon/temp = icon(parallax_canvas.icon, parallax_canvas.icon_state)
		temp.Scale((2*view+1)*32, (2*view+1)*32)
		parallax_canvas.icon = temp
		parallax_canvas.screen_loc = "WEST,SOUTH"

	if(!C.parallax_dustmaster)
		C.parallax_dustmaster = getFromPool(/obj/plane_master/parallax_dustmaster)

	C.parallax_canvas.color = space_color

	C.screen |= C.parallax_master
	C.screen |= C.parallax_canvas
	C.screen |= C.parallax_dustmaster

	return 1

/datum/hud/proc/update_parallax2(forcerecalibrate = 0)
	var/client/C = mymob.client
	//DO WE HAVE TO REPLACE ALL THE LAYERS

	if(!C.parallax.len)
		var/list/wantDatParallax = list()
		wantDatParallax |= space_parallax_dust_0 + space_parallax_dust_1 + space_parallax_dust_2
		for(var/obj/screen/parallax/bgobj in wantDatParallax)
			var/obj/screen/parallax/parallax_layer = getFromPool(/obj/screen/parallax)
			parallax_layer.appearance = bgobj.appearance
			parallax_layer.base_offset_x = bgobj.base_offset_x
			parallax_layer.base_offset_y = bgobj.base_offset_y
			parallax_layer.parallax_speed = bgobj.parallax_speed
			C.parallax += parallax_layer

	if(!C.parallax_nodust.len)
		var/list/wantDatParallax = list()
		wantDatParallax |= space_parallax_0 + space_parallax_1 + space_parallax_2
		for(var/obj/screen/parallax/bgobj in wantDatParallax)
			var/obj/screen/parallax/parallax_layer = getFromPool(/obj/screen/parallax)
			parallax_layer.appearance = bgobj.appearance
			parallax_layer.base_offset_x = bgobj.base_offset_x
			parallax_layer.base_offset_y = bgobj.base_offset_y
			parallax_layer.parallax_speed = bgobj.parallax_speed
			C.parallax_nodust += parallax_layer

	var/parallax_loaded = 0
	for(var/obj/screen/S in C.screen)
		if(istype(S,/obj/screen/parallax))
			parallax_loaded = 1
			break

	if(forcerecalibrate || !parallax_loaded)
		for(var/obj/screen/parallax/bgobj in C.parallax)
			C.screen -= bgobj
		for(var/obj/screen/parallax/bgobj in C.parallax_nodust)
			C.screen -= bgobj

		if(C.prefs.space_dust)
			for(var/obj/screen/parallax/bgobj in C.parallax)
				C.screen += bgobj
		else
			for(var/obj/screen/parallax/bgobj in C.parallax_nodust)
				C.screen += bgobj

		if(C.prefs.space_dust)
			C.parallax_canvas.plane = PLANE_SPACE_PARALLAX_DUST
			C.parallax_dustmaster.screen_loc = "WEST,SOUTH to EAST,NORTH"
		else
			C.parallax_canvas.plane = PLANE_SPACE_PARALLAX
			C.parallax_master.screen_loc = "WEST,SOUTH to EAST,NORTH"

	if(!C.parallax_offset.len)
		C.parallax_offset["horizontal"] = 0
		C.parallax_offset["vertical"] = 0

/datum/hud/proc/update_parallax3()
	var/client/C = mymob.client
	//ACTUALLY MOVING THE PARALLAX
	var/turf/posobj = get_turf(C.eye)

	if(!C.previous_turf || (C.previous_turf.z != posobj.z))
		C.previous_turf = posobj

	//Doing it this way prevents parallax layers from "jumping" when you change Z-Levels.
	C.parallax_offset["horizontal"] += posobj.x - C.previous_turf.x
	C.parallax_offset["vertical"] += posobj.y - C.previous_turf.y

	C.previous_turf = posobj

	if(C.prefs.space_dust)
		for(var/obj/screen/parallax/bgobj in C.parallax)
			if(bgobj.parallax_speed)//only the middle and front layers actually move
				var/accumulated_offset_x = bgobj.base_offset_x - round(C.parallax_offset["horizontal"] * bgobj.parallax_speed * (C.prefs.parallax_speed/2))
				var/accumulated_offset_y = bgobj.base_offset_y - round(C.parallax_offset["vertical"] * bgobj.parallax_speed * (C.prefs.parallax_speed/2))

				while(accumulated_offset_x > 720)
					accumulated_offset_x -= 1440
				while(accumulated_offset_x < -720)
					accumulated_offset_x += 1440

				while(accumulated_offset_y > 720)
					accumulated_offset_y -= 1440
				while(accumulated_offset_y < -720)
					accumulated_offset_y += 1440

				bgobj.screen_loc = "CENTER-7:[accumulated_offset_x],CENTER-7:[accumulated_offset_y]"
			else
				bgobj.screen_loc = "CENTER-7:[bgobj.base_offset_x],CENTER-7:[bgobj.base_offset_y]"
	else
		for(var/obj/screen/parallax/bgobj in C.parallax_nodust)
			if(bgobj.parallax_speed)//only the middle and front layers actually move
				var/accumulated_offset_x = bgobj.base_offset_x - round(C.parallax_offset["horizontal"] * bgobj.parallax_speed * (C.prefs.parallax_speed/2))
				var/accumulated_offset_y = bgobj.base_offset_y - round(C.parallax_offset["vertical"] * bgobj.parallax_speed * (C.prefs.parallax_speed/2))

				while(accumulated_offset_x > 720)
					accumulated_offset_x -= 1440
				while(accumulated_offset_x < -720)
					accumulated_offset_x += 1440

				while(accumulated_offset_y > 720)
					accumulated_offset_y -= 1440
				while(accumulated_offset_y < -720)
					accumulated_offset_y += 1440

				bgobj.screen_loc = "CENTER-7:[accumulated_offset_x],CENTER-7:[accumulated_offset_y]"
			else
				bgobj.screen_loc = "CENTER-7:[bgobj.base_offset_x],CENTER-7:[bgobj.base_offset_y]"

/proc/calibrate_parallax(var/obj/screen/parallax/p_layer,var/i)
	if(!p_layer || !i) return

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
