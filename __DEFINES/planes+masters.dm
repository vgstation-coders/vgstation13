/* copy-pasted from planes+layers.dm because relevant I guess

What are Planesmasters?
	Planesmasters render all objects of the plane on the one object.
	Planesmasters, when in the sight of a player, will have its appearance properties (for example, colour matrices, alpha, transform, etc)
	applied to all the other objects in the plane. This is all client sided.
	Usually you would want to add the planesmaster as an invisible image in the client's screen.

What can I do with Planesmasters?
	You can: Make certain players not see an entire plane,
	Make an entire plane have a certain colour matrices,
	Make an entire plane transform in a certain way,
	Make players see a plane which is hidden to normal players - I intend to implement this with the antag HUDs for example.
	Planesmasters can be used as a neater way to deal with client images or potentially to do some neat things
*/

/obj/abstract/screen/plane_master
	appearance_flags = PLANE_MASTER
	screen_loc = "CENTER,CENTER"
	icon_state = "blank"
	globalscreen = 1

// CLICKMASTER
// Singleton implementation
// One planemaster for everybody, everybody always has it, they gain it during mob/login()
/obj/abstract/screen/plane_master/clickmaster
	plane = BASE_PLANE
	mouse_opacity = 0

var/obj/abstract/screen/plane_master/clickmaster/clickmaster = new()

/obj/abstract/screen/plane_master/clickmaster_dummy
	// this avoids a bug which means plane masters which have nothing to control get angry and mess with the other plane masters out of spite
	alpha = 0
	appearance_flags = 0
	plane = BASE_PLANE

var/obj/abstract/screen/plane_master/clickmaster_dummy/clickmaster_dummy = new()

// NOIR
// Immutable, so we use a singleton implementation
// (only one planemaster for everybody, they gain or lose the unique planemaster depending on whether they want the effect or not)
/obj/abstract/screen/plane_master/noir_master
	plane = NOIR_BLOOD_PLANE
	color = list("#0000",
				 "#0000",
				 "#0000",
				 "#000F",
				 "#A110")//turns everything in the plane to the color human blood. unfortunate side effect is the loss of detail on gibs
	appearance_flags = NO_CLIENT_COLOR|PLANE_MASTER//NO_CLIENT_COLOR sadly doesn't prevent the blood itself from turning grey, which is why it has to be recolored with the above matrix

/obj/abstract/screen/plane_master/noir_dummy
	// this avoids a bug which means plane masters which have nothing to control get angry and mess with the other plane masters out of spite
	alpha = 0
	appearance_flags = 0
	plane = NOIR_BLOOD_PLANE

var/noir_master = list(new /obj/abstract/screen/plane_master/noir_master(),new /obj/abstract/screen/plane_master/noir_dummy())

// GHOST PLANEMASTER
// One planemaster for each client, which they gain during mob/login()
// By default their planemaster has no changes, if we modify a person's planemaster, it will affect only them
/obj/abstract/screen/plane_master/ghost_planemaster
	plane = GHOST_PLANE

/obj/abstract/screen/plane_master/ghost_planemaster_dummy
	// this avoids a bug which means plane masters which have nothing to control get angry and mess with the other plane masters out of spite
	alpha = 0
	appearance_flags = 0
	plane = GHOST_PLANE

/client/proc/initialize_ghost_planemaster()
	//We want to explicitly reset the planemaster's visibility on login() so if you toggle ghosts while dead you can still see cultghosts if revived etc.
	if(ghost_planemaster)
		screen -= ghost_planemaster
		qdel(ghost_planemaster)
	if(ghost_planemaster_dummy)
		screen -= ghost_planemaster_dummy
		qdel(ghost_planemaster_dummy)
	ghost_planemaster = new /obj/abstract/screen/plane_master/ghost_planemaster
	screen |= ghost_planemaster
	ghost_planemaster_dummy = new /obj/abstract/screen/plane_master/ghost_planemaster_dummy
	screen |= ghost_planemaster_dummy

// OVERDARKNESS PLANEMASTER
// Used to move the BYOND darkness plane from SEE_BLACKNESS to a different plane so it covers things on desired planes above 0
/obj/abstract/screen/plane_master/overdark_planemaster
	plane = 0
	render_target = "*overdark"

var/obj/abstract/screen/plane_master/overdark_planemaster/overdark_planemaster = new()

/obj/abstract/screen/plane_master/overdark_planemaster_target
	appearance_flags = 0
	plane = BASE_PLANE
	mouse_opacity = 0
	screen_loc = "SOUTHWEST"
	render_source = "*overdark"

var/obj/abstract/screen/plane_master/overdark_planemaster_target/overdark_planemaster_target = new()

/obj/abstract/screen/plane_master/fakecamera_screen_planemaster
	plane = FAKE_CAMERA_SCREEN_PLANE
	alpha = 0

/obj/abstract/screen/plane_master/fakecamera_screen_planemaster_dummy
	alpha = 0
	appearance_flags = 0
	plane = FAKE_CAMERA_SCREEN_PLANE

/obj/abstract/screen/plane_master/fakecamera_button_planemaster
	plane = FAKE_CAMERA_BUTTONS_PLANE
	alpha = 0

/client/proc/initialize_fakecamera_planemaster()
	if(fakecamera_screen_planemaster)
		screen -= fakecamera_screen_planemaster
		qdel(fakecamera_screen_planemaster)
	if(fakecamera_screen_planemaster_dummy)
		screen -= fakecamera_screen_planemaster_dummy
		qdel(fakecamera_screen_planemaster_dummy)
	if(fakecamera_button_planemaster)
		screen -= fakecamera_button_planemaster
		qdel(fakecamera_button_planemaster)
	fakecamera_screen_planemaster = new /obj/abstract/screen/plane_master/fakecamera_screen_planemaster
	screen |= fakecamera_screen_planemaster
	fakecamera_screen_planemaster_dummy = new /obj/abstract/screen/plane_master/fakecamera_screen_planemaster_dummy
	screen |= fakecamera_screen_planemaster_dummy
	fakecamera_button_planemaster = new /obj/abstract/screen/plane_master/fakecamera_button_planemaster
	screen |= fakecamera_button_planemaster

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Adding planemasters for every other relevant planes so we can easily add filters over the whole screen

#define P_FILTER_IMPAIRED_VISION	(1)
#define P_FILTER_BLURRY_VISION		(1<<1)

/mob
	var/datum/perception_filters/perception_filters = null

//Storing those in a datum to not crowd up the View Variable window even further
/datum/perception_filters
	var/list/orphan_planemasters = list()
	var/list/perception_planemasters = list()
	var/list/perception_filters = list()
	var/enabled_filters = 0//bitflags

//Creating new planemasters for every plane that doesn't already have a dedicated planemaster
//BE SURE TO UPDATE THIS LIST IF YOU ADD OR REMOVE OTHER PLANEMASTERS
/mob/proc/create_orphan_planemasters()
	for (var/planemaster in perception_filters.orphan_planemasters)
		var/obj/abstract/screen/plane_master/PM = perception_filters.orphan_planemasters[planemaster]
		client.screen -= PM
		perception_filters.orphan_planemasters -= planemaster
		qdel(PM)

	var/static/list/planes_without_dedicated_planemasters = list(
		"ABOVE_PARALLAX_PLANE"	= ABOVE_PARALLAX_PLANE,
		"BELOW_PLATING_PLANE"	= BELOW_PLATING_PLANE,
		"PLATING_PLANE"			= PLATING_PLANE,
		"ABOVE_PLATING_PLANE"	= ABOVE_PLATING_PLANE,
		"BELOW_TURF_PLANE"		= BELOW_TURF_PLANE,
		"TURF_PLANE"			= TURF_PLANE,
		"GLASSTILE_PLANE"		= GLASSTILE_PLANE,
		"ABOVE_TURF_PLANE"		= ABOVE_TURF_PLANE,
		"HIDING_MOB_PLANE"		= HIDING_MOB_PLANE,
		"OBJ_PLANE"				= OBJ_PLANE,
		"LYING_MOB_PLANE"		= LYING_MOB_PLANE,
		"LYING_HUMAN_PLANE"		= LYING_HUMAN_PLANE,
		"ABOVE_OBJ_PLANE"		= ABOVE_OBJ_PLANE,
		"HUMAN_PLANE"			= HUMAN_PLANE,
		"MOB_PLANE"				= MOB_PLANE,
		"ABOVE_HUMAN_PLANE"		= ABOVE_HUMAN_PLANE,
		"BLOB_PLANE"			= BLOB_PLANE,
		"EFFECTS_PLANE"			= EFFECTS_PLANE,
		"GAS_PLANE"				= GAS_PLANE,
		"ABOVE_LIGHTING_PLANE"	= ABOVE_LIGHTING_PLANE,
		)

	for (var/orphan_plane in planes_without_dedicated_planemasters)
		var/obj/abstract/screen/plane_master/PM = new(client)
		PM.plane = planes_without_dedicated_planemasters[orphan_plane]
		perception_filters.orphan_planemasters[orphan_plane] = PM
		client.screen += PM

//Adding all the planemasters we want to add filters on top to a single list so it's easier to manipulate
/mob/proc/list_perception_planemasters()
	perception_filters.perception_planemasters.len = 0

	for (var/plane in perception_filters.orphan_planemasters)
		var/P = perception_filters.orphan_planemasters[plane]
		perception_filters.perception_planemasters += P

	//We're not adding filters to the parallax planemasters for now. It's tough to make it look good.


/mob/proc/init_perception_filters()
	perception_filters.perception_filters.len = 0

	//////////////////////////////
	//							//
	//		Nearsightedness		//
	//							//
	//////////////////////////////
	//By combining an angular and a radial blur, we get kind of a gaussian blur that intensifies in a circle the further away you get from the focal point
	var/nearsightedness_angular = filter(type="angular_blur", name="nearsightedness_angular", x = 0, y = 0, size = 0, offset = 256)
	perception_filters.perception_filters += "nearsightedness_angular"

	var/nearsightedness_radial = filter(type="radial_blur", name="nearsightedness_radial", x = 0, y = 0, size = 0, offset = 256)
	perception_filters.perception_filters += "nearsightedness_radial"

	for (var/obj/planemaster in perception_filters.perception_planemasters)
		planemaster.filters += nearsightedness_angular
		planemaster.filters += nearsightedness_radial

	overlay_fullscreen("impaired_crit", /obj/abstract/screen/fullscreen/impaired_crit)//displayed right from the start, and scaled up so that its out of view


	//////////////////////////////
	//							//
	//		Blurriness			//
	//							//
	//////////////////////////////
	//The displacement makes the blurriness "move" a bit.
	var/bluriness_blur = filter(type="blur", name="blurriness_blur", size=0)
	perception_filters.perception_filters += "blurriness_blur"

	var/bluriness_displacement = filter(type="displace", name="blurriness_displace", x=0, y=0, size=0, icon='icons/mob/blurry_icon_large_alt.dmi', flags=FILTER_OVERLAY)
	perception_filters.perception_filters += "blurriness_displace"

	for (var/obj/planemaster in perception_filters.perception_planemasters)
		planemaster.filters += bluriness_blur
		planemaster.filters += bluriness_displacement


/mob/proc/login_perception_filters_update()

/mob/living/login_perception_filters_update()
	var/impaired_vision = get_impaired_vision_range()
	if(impaired_vision > 0)
		enable_nearsightedness(impaired_vision, FALSE)

/mob/proc/remove_perception_filters()
	for (var/obj/planemaster in perception_filters.perception_planemasters)
		for (var/filter in perception_filters.perception_filters)
			planemaster.filters -= filter



#define IMPAIRED_VISION_RADIUS_OUT_OF_VIEW 	512	//we go this high when impairment is at 0 to prevent it showing up for players with farsight, binoculars, etc
#define IMPAIRED_VISION_RADIUS_START 		192 //the minimal radius blurriness starts at, when impairment is at least 1

var/static/impaired_scale = list(40, 40, 40, 20, 16, 12, 9, 6, 3, 1)

/mob
	var/filter_update_delay = -1//This prevents crashes!! Don't ask me why...

//use when setting eye_blind if you want your mob to be immediately blinded without waiting for enable_nearsightedness() and animate() to do their job
//remember that only _blind values of 10 and above cover the whole screen.
/mob/living/proc/instant_blindness(var/_blind)
	eye_blind = max(eye_blind, _blind)

	var/_modifiers	= get_impaired_vision_modifiers()
	if (_modifiers[1] > 0)//only do the thing if our mob actually can get blinded
		overlay_fullscreen("blind", /obj/abstract/screen/fullscreen/blind)
		spawn(40)
		clear_fullscreen("blind")

/mob/proc/enable_nearsightedness(var/_severity, var/_animate = TRUE)//actually handles blindess too
	perception_filters.enabled_filters |= P_FILTER_IMPAIRED_VISION

	var/_a = 9 - _severity
	var/_nearsightedness_offset = 0
	if (_a >= 0)
		_nearsightedness_offset = min(IMPAIRED_VISION_RADIUS_START, 2 ** (_a))


	if (_animate)
		filter_update_delay++
		spawn(filter_update_delay)
			for (var/obj/planemaster in perception_filters.perception_planemasters)
				var/F1 = planemaster.filters["nearsightedness_angular"]
				animate(F1, size = 0.5, offset = _nearsightedness_offset, time = 20)
		filter_update_delay++
		spawn(filter_update_delay)
			for (var/obj/planemaster in perception_filters.perception_planemasters)
				var/F2 = planemaster.filters["nearsightedness_radial"]
				animate(F2, size = 0.01, offset = _nearsightedness_offset, time = 20)
	else
		filter_update_delay++
		spawn(filter_update_delay)
			for (var/obj/planemaster in perception_filters.perception_planemasters)
				var/F1 = planemaster.filters["nearsightedness_angular"]
				F1:offset = _nearsightedness_offset
		filter_update_delay++
		spawn(filter_update_delay)
			for (var/obj/planemaster in perception_filters.perception_planemasters)
				var/F2 = planemaster.filters["nearsightedness_radial"]
				F2:offset = _nearsightedness_offset


	var/_b = 10 - _severity
	var/_nearsightedness_scale = 1
	if (_b > 0)
		_nearsightedness_scale = min(40, 3 * _b)

	var/obj/abstract/screen/fullscreen/screen = screens["impaired_crit"]
	var/matrix/M = matrix()
	M.Scale(_nearsightedness_scale, _nearsightedness_scale)
	if (_animate)
		animate(screen, transform = M, time = 20)
	else
		screen.transform = M

/mob/proc/disable_nearsightedness()
	perception_filters.enabled_filters &= ~P_FILTER_IMPAIRED_VISION

	filter_update_delay++
	spawn(filter_update_delay)
		for (var/obj/planemaster in perception_filters.perception_planemasters)
			var/F1 = planemaster.filters["nearsightedness_angular"]
			animate(F1, size = 0.5, offset = IMPAIRED_VISION_RADIUS_OUT_OF_VIEW, time = 20)
	filter_update_delay++
	spawn(filter_update_delay)
		for (var/obj/planemaster in perception_filters.perception_planemasters)
			var/F2 = planemaster.filters["nearsightedness_radial"]
			animate(F2, size = 0.01, offset = IMPAIRED_VISION_RADIUS_OUT_OF_VIEW, time = 20)

	var/obj/abstract/screen/fullscreen/screen = screens["impaired_crit"]
	var/matrix/M = matrix()
	M.Scale(40, 40)
	animate(screen, transform = M, time = 20)

#undef IMPAIRED_VISION_RADIUS_OUT_OF_VIEW
#undef IMPAIRED_VISION_RADIUS_START

/mob/proc/enable_blurriness(var/_blurriness)
	perception_filters.enabled_filters |= P_FILTER_BLURRY_VISION

	filter_update_delay++
	spawn(filter_update_delay)
		for (var/obj/planemaster in perception_filters.perception_planemasters)
			var/F1 = planemaster.filters["blurriness_blur"]
			var/_blur_size = clamp(_blurriness / 10, 0.7, 1.1)
			animate(F1, size = _blur_size, time = 10)
	filter_update_delay++
	spawn(filter_update_delay)//seems like it won't work here either unless we wait here
		for (var/obj/planemaster in perception_filters.perception_planemasters)
			var/F2 = planemaster.filters["blurriness_displace"]
			animate(F2, size = 2, time = 5)//a subtle displacement of 2, barely noticeable
			animate(size = -2, time = 10)
			animate(size = 0, time = 5)

/mob/proc/disable_blurriness()
	perception_filters.enabled_filters &= ~P_FILTER_BLURRY_VISION

	filter_update_delay++
	spawn(filter_update_delay)
		for (var/obj/planemaster in perception_filters.perception_planemasters)
			var/F1 = planemaster.filters["blurriness_blur"]
			animate(F1, size = 0, time = 60)
	filter_update_delay++
	spawn(filter_update_delay)
		for (var/obj/planemaster in perception_filters.perception_planemasters)
			var/F2 = planemaster.filters["blurriness_displace"]
			animate(F2, size = 0, time = 60)
