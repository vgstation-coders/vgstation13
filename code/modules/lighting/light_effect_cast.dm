#define BASE_PIXEL_OFFSET 224
#define BASE_TURF_OFFSET 2
#define WIDE_SHADOW_THRESHOLD 80
#define OFFSET_MULTIPLIER_SIZE 32
#define CORNER_OFFSET_MULTIPLIER_SIZE 16
#define BLUR_SIZE 4 // integer, please

#define FADEOUT_STEP		2

// Shadows over light_range 9 haven't been done yet.
#define MAX_LIGHT_RANGE 10

#define NO_POST_PROCESSING 	0
#define WALL_SHADOWS_ONLY  	1
#define ALL_SHADOWS	 		2

#define DIRECT_ILLUM_ANGLE 20

var/light_power_multiplier = 5
var/light_post_processing = ALL_SHADOWS // Use writeglobal to change this

// We actually see these "pseudo-light atoms" in order to ensure that wall shadows are only seen by people who can see the light.
// Yes, this is stupid, but it's one of the limitations of TILE_BOUND, which cannot be chosen on an overlay-per-overlay basis.
// So the "next best thing" is to divide the light atoms in two parts, one exclusively for wall shadows and one for general purpose.
// Do note that this means that everything is twice as bright, and twice as dark.
// Draw/generate your shadow masks & light spots accordingly!

// What's will all this render target nonsense?
// The icons we are trying to draw are, for the scale of BYOND, quite complex.
// In particular, the shadow trapezoids are subject to various transformation matrices and clients may struggle to render them.
// BYOND can make it so we only draw fully one of those trapezoids and, if we notice server-side that we need to draw the same shape, just copy and paste it.
// We first look at this icon has not been generated by ourselves.
// As it turns out, for wall-shadow icons and for black masks, it is possible to copy and paste the pre-rendered icon from a nearby visible light as well.
// This saves quite a bit on rendering in areas with many overlapping lights close to one another.

// cast_light() is the "master proc", shared by the two kinds.

/atom/movable/light/proc/cast_light()
	cast_light_init()
	cast_main_light()
	update_light_dir()
	cast_shadows()
	update_appearance()

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
// -- The shared procs between lights and pesudo-lights.

// Initialisation of the cast_light proc.
/atom/movable/light/proc/cast_light_init()

	filters = list()
	temp_appearance = list()
	temp_appearance_shadows = list()
	blacken_out_turf = list()
	affecting_turfs = list()
	affected_shadow_walls = list()
	pre_rendered_shadows = list()

	//cap light range to the max
	luminosity = 3*light_range
	light_range = min(MAX_LIGHT_RANGE, light_range)
	light_color = (holder.light_color || light_color)

	var/atom/location = get_turf(src)
	var/distance_to_wall_illum = get_wall_view()

	if (light_swallowed > 0)
		light_range = 1
		light_power = 1
		if (light_type != LIGHT_DIRECTIONAL)
			light_type = LIGHT_SOFT_FLICKER
		light_swallowed--

	switch (light_type)
		if (LIGHT_SOFT_FLICKER)
			alpha = initial(alpha)
			animate(src, alpha = initial(alpha) - rand(30, 60), time = 2, loop = -1, easing = SINE_EASING)
			animate(alpha = initial(alpha), time = 0)
		if (LIGHT_REGULAR_FLICKER)
			animate(src, alpha = 180, time = 5, loop = -1, easing = CIRCULAR_EASING)
			animate(alpha = 255, time = 5, loop = -1, easing = CIRCULAR_EASING)

	for (var/thing in view(min(world.view, distance_to_wall_illum), src))
		if (ismob(thing))
			var/mob/M = thing
			M.check_dark_vision()
		if (isturf(thing))
			var/turf/T = thing
			T.lumcount = -1
			affecting_turfs += T
			if (get_dist(T, location) <= distance_to_wall_illum && CHECK_OCCLUSION(T))
				affected_shadow_walls += T

	if(!isturf(loc))
		for(var/turf/T in affecting_turfs)
			T.lumcount = -1
		affecting_turfs.Cut()
		return

/atom/movable/light/smooth/cast_light_init()
	. = ..()
	light_range = 2
	var/color = rgb2num(light_color)
	light_color = rgb(round(color[1]/2), round(color[2]/2), round(color[2]/2))


/*

Commented out as this doesn't works well with performance currently.
If you feel like fixing it, try to find a way to calculate the bounds that is less retarded.

*/

///atom/movable/light/shadow/cast_light_init()
//	. = ..()
//	if (light_range < 2)
//		return
//	if (light_type == LIGHT_DIRECTIONAL)
//		return
//
//	// Basically we check if our cardinals + adjacent tiles are occluded and we adjust our bounds if we are able to.
//	var/occlusion_north = CheckOcclusion(get_step(loc, NORTH))
//	var/occlusion_south = CheckOcclusion(get_step(loc, SOUTH))
//	var/occlusion_east = CheckOcclusion(get_step(loc, EAST))
//	var/occlusion_west = CheckOcclusion(get_step(loc, WEST))
//	var/occlusion_northeast = CheckOcclusion(get_step(loc, NORTHEAST))
//	var/occlusion_northwest = CheckOcclusion(get_step(loc, NORTHWEST))
//	var/occlusion_southeast = CheckOcclusion(get_step(loc, SOUTHEAST))
//	var/occlusion_southwest = CheckOcclusion(get_step(loc, SOUTHWEST))
//
//	var/visible_top = !(occlusion_north && occlusion_northeast && occlusion_northwest)
//	var/visible_bottom = !(occlusion_south && occlusion_southeast && occlusion_southwest)
//	var/visible_left = !(occlusion_east && occlusion_northeast && occlusion_southeast)
//	var/visible_right = !(occlusion_west && occlusion_southwest && occlusion_northwest)
//
//	// If we are visible from the left or right, we have to translate one tile in order for bounds to work
//	if (visible_left || visible_bottom)
//		var/vector/V = new(-visible_left, -visible_left)
//		var/turf/T = loc.get_translated_turf(V)
//		forceMove(T)
//		pixel_x = visible_left*WORLD_ICON_SIZE
//		pixel_y = visible_bottom*WORLD_ICON_SIZE
//
//	bound_width = (visible_left + visible_right)*WORLD_ICON_SIZE
//	bound_height = (visible_top + visible_bottom)*WORLD_ICON_SIZE

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
// -- The procs related to the sources of lights

/atom/movable/light/proc/cast_main_light()

	if(light_type == LIGHT_DIRECTIONAL)

		icon = 'icons/lighting/directional_overlays.dmi'
		light_range = 2.5

	else
		if (base_light_color_state == "white")


		// An explicit call to file() is easily 1000 times as expensive than this construct, so... yeah.
		// Setting icon explicitly allows us to use byond rsc instead of fetching the file everytime.
		// The downside is, of course, that you need to cover all the cases in your switch.
			switch (light_range)
				if (1)
					icon = 'icons/lighting/light_range_1.dmi'
				if (2)
					icon = 'icons/lighting/light_range_2.dmi'
				if (3)
					icon = 'icons/lighting/light_range_3.dmi'
				if (4)
					icon = 'icons/lighting/light_range_4.dmi'
				if (5)
					icon = 'icons/lighting/light_range_5.dmi'
				if (6)
					icon = 'icons/lighting/light_range_6.dmi'
				if (7)
					icon = 'icons/lighting/light_range_7.dmi'
				if (8)
					icon = 'icons/lighting/light_range_8.dmi'
				if (9)
					icon = 'icons/lighting/light_range_9.dmi'

	if (light_type != LIGHT_DIRECTIONAL)
		pixel_x = -(world.icon_size * light_range) + holder.pixel_x
		pixel_y = -(world.icon_size * light_range) + holder.pixel_y

	// This to avoid TILE_BOUND corner light effects while keeping smooth movement for movable light sources
	// There are THREE light atoms on an object
	// - the white square + shadows (not TILE_BOUND)
	// - the wall shadow layer (TILE_BOUND)
	// - the smooth white square (also TILE_BOUND)
	icon_state = base_light_color_state

	if (icon_state == "white") // This mask only makes sense if we are casting a white light
		alpha = min(255,max(0,round(light_power*light_power_multiplier*25)))
		var/image/I = new

		// Find proper identifier
		var/white_light_identifier = "white_[light_power]_[light_range]"

		// Proper icon state for directional lights
		var/directional_light_overlay
		if(light_type == LIGHT_DIRECTIONAL)
			var/turf/next_turf = get_step(src, dir)
			for(var/i = 1 to 3)
				if(CHECK_OCCLUSION(next_turf))
					white_light_identifier = "[white_light_identifier]_[i]"
					directional_light_overlay = "overlay_[i]"
					break
				next_turf = get_step(next_turf, dir)

		// This use case will notably always be true for movable lights
		if (white_light_identifier in pre_rendered_shadows)
			I.render_source = white_light_identifier
		else
			var/found_prerendered_white_light = FALSE
			for (var/atom/movable/light/neighbour in view(max(1, light_range - 1), src)) // This light atom is rendered from point A to point B, so it's fine
				if (neighbour.light_range < light_range)
					continue
				if (white_light_identifier in neighbour.pre_rendered_shadows)
					I.render_source = white_light_identifier
					found_prerendered_white_light = TRUE
					break
			if (!found_prerendered_white_light)
				I = image(icon)
				if (light_type == LIGHT_DIRECTIONAL)
					I.icon_state = directional_light_overlay
				else
					I.icon_state = "overlay"
				I.render_target = white_light_identifier

		temp_appearance += I

// On how many turfs do we cast a shadow ?
/atom/movable/light/proc/cast_shadows()
	//no shadows
	if(light_range < 2 || light_type == LIGHT_DIRECTIONAL)
		return

	for(var/turf/T in view(light_range, src))
		if(CHECK_OCCLUSION(T))
			CastShadow(T)

/atom/movable/light/smooth/cast_shadows()
	return

/atom/movable/light/proc/CastShadow(var/turf/target_turf)
	//get the x and y offsets for how far the target turf is from the light
	var/x_offset = (target_turf.x - x)
	var/y_offset = (target_turf.y - y)
	cast_main_shadow(target_turf, x_offset, y_offset)

	if ((target_turf in affected_shadow_walls) && is_valid_turf(target_turf))
		cast_turf_shadow(target_turf, x_offset, y_offset)

/atom/movable/light/proc/cast_main_shadow(var/turf/target_turf, var/x_offset, var/y_offset)


	var/num = CORNER_SHADOW
	if((abs(x_offset) > 0 && !y_offset) || (abs(y_offset) > 0 && !x_offset))
		num = FRONT_SHADOW

	// Softer shadows for the side of the wall that's not occluded
	var/block_1 = FALSE //
	var/block_2 = FALSE //

	// Get the grazing angle between the target_turf and the light source
	var/grazing_angle = Atan2(x_offset, y_offset)

	var/delta = (abs(x_offset) - abs(y_offset))

	//TODO: rewrite this comment:
	//using scale to flip the shadow template if needed
	//horizontal (x) flip is easy, we just check if the offset is negative
	//vertical (y) flip is a little harder, if the shadow will be rotated we need to flip if the offset is positive,
	// but if it wont be rotated then we just check if its negative to flip (like the x flip)

	// For offsets. Rewriting using grazing anlge at some point...

	var/block_north = check_wall_occlusion_dir(target_turf, NORTH)
	var/block_south = check_wall_occlusion_dir(target_turf, SOUTH)
	var/block_east = check_wall_occlusion_dir(target_turf, EAST)
	var/block_west = check_wall_occlusion_dir(target_turf, WEST)

	switch(grazing_angle)
		if (-179 to -91)
			block_1 = block_north || block_east
			block_2 = block_west  || block_south

		if (-90)
			block_1 = block_west
			block_2 = block_east

		if (-89 to -1)
			block_1 = block_north || block_west
			block_2 = block_east  || block_south

		if (0)
			block_1 = block_north
			block_2 = block_south

		if (1 to 89)
			block_1 = block_west || block_north
			block_2 = block_east || block_south

		if (90)
			block_1 = block_west
			block_2 = block_east

		if (91 to 179)
			block_1 = block_south || block_east
			block_2 = block_west  || block_north

		if (180)
			block_1 = block_south
			block_2 = block_north

	// Operation order => xy flip => xy_swap.
	// Those are not commutative, and as such we have a total of 8 cases:
	// xy_swap or not (2) and then (x_flip, y_flip, xy_flip, no_flip)

	var/matrix/M = matrix() //

	// Using BYOND's render_target magick here

	var/image/I = new()
	var/shadow_image_identifier = "shadow[num]_[light_range]_[grazing_angle]_[abs(y_offset)]_[abs(x_offset)]_[block_1]_[block_2]"
	// We've done this before...
	if (shadow_image_identifier in pre_rendered_shadows)
		I.render_source = shadow_image_identifier
	// Or not!
	else
		switch(grazing_angle)
			if (-179 to -91)
				M.Scale(-1, -1)

			if (-90)
				M.Scale(1, -1)

			if (-89 to -1)
				M.Scale(1, -1)

			if (0)
				M.Turn(90)

			//if (1 to 89)

			//if (90)

			if (91 to 179)
				M.Scale(-1, 1)

			if (180)
				M.Turn(-90)

		// An explicit call to file() is easily 1000 times as expensive than this construct, so... yeah.
		// Setting icon explicitly allows us to use byond rsc instead of fetching the file everytime.
		// The downside is, of course, that you need to cover all the cases in your switch.
		var/icon/shadowicon = try_get_light_range_icon(block_1, block_2, light_range, num)
		I = image(shadowicon)

		//due to the way the offsets are named, we can just swap the x and y offsets to "rotate" the icon state
		if (num == CORNER_SHADOW)
			if(delta == 0)
				I.icon_state = "[abs(x_offset)]_[abs(y_offset)]"
			else if (delta > 0)
				I.icon_state = "[abs(x_offset)]_[abs(y_offset)]_highangle"
			else
				I.icon_state = "[abs(y_offset)]_[abs(x_offset)]_lowangle"
		else
			if (delta > 0)
				I.icon_state = "[abs(x_offset)]_[abs(y_offset)]"
			else
				I.icon_state = "[abs(y_offset)]_[abs(x_offset)]"

		I.transform = M
		I.layer = LIGHTING_LAYER
		I.render_target = shadow_image_identifier
		pre_rendered_shadows += shadow_image_identifier

	// Once that's done...
	// We caclulate the offset
	// This is basically a traduction of the old translate matrix big-bang-wahoo
	// into something more sensible and render_source friendly
	var/shadow_offset = (WORLD_ICON_SIZE/2) + (light_range*WORLD_ICON_SIZE)

	switch (grazing_angle)
		if (180)
			I.pixel_x += -shadow_offset/2
			I.pixel_y += shadow_offset/2

		if (91 to 179)
			I.pixel_y += shadow_offset

		if (90)
			I.pixel_y += shadow_offset

		if (1 to 81)
			I.pixel_x += shadow_offset
			I.pixel_y += shadow_offset

		if (0)
			I.pixel_x += shadow_offset/2
			I.pixel_y += shadow_offset/2

		if (-89 to -1)
			I.pixel_x += shadow_offset

	/*
	if (get_dist(target_turf, src) < 0.75*light_range && get_dist(target_turf, src) > 2)
		var/found_reflction = FALSE
		var/delta_x = 0
		var/delta_y = 0
		var/chosen_icon = ""
		switch (grazing_angle)
			if (90.01 to 179.99)
				if (block_south && block_north)
					delta_x += WORLD_ICON_SIZE
					chosen_icon = "west"
					found_reflction = TRUE
				else if (block_east && block_west)
					delta_y -= WORLD_ICON_SIZE
					chosen_icon = "north"
					found_reflction = TRUE

			if (0.01 to 89.99)
				if (block_south && block_north)
					delta_x -= WORLD_ICON_SIZE
					chosen_icon = "east"
					found_reflction = TRUE
				else if (block_east && block_west)
					delta_y -= WORLD_ICON_SIZE
					chosen_icon = "north"
					found_reflction = TRUE

			if (-89.99 to -0.01)
				if (block_south && block_north)
					delta_x -= WORLD_ICON_SIZE
					chosen_icon = "east"
					found_reflction = TRUE
				else if (block_east && block_west)
					I.pixel_y += WORLD_ICON_SIZE
					found_reflction = TRUE
					chosen_icon = "south"

			if (-179.99 to -89.99)
				if (block_south && block_north)
					delta_x += WORLD_ICON_SIZE
					found_reflction = TRUE
					chosen_icon = "west"
				else if (block_east && block_west)
					delta_y += WORLD_ICON_SIZE
					found_reflction = TRUE
					chosen_icon = "south"

		if (found_reflction)
			var/image/reflection_glow = image('icons/lighting/wall_lighting.dmi', loc = get_turf(src))
			var/intensity = min(150,max(0,round(light_power*light_power_multiplier*25)))
			var/fadeout = max(get_dist(src, target_turf)/2*FADEOUT_STEP, 1)
			reflection_glow.alpha =  round(intensity/fadeout)
			reflection_glow.icon_state = chosen_icon
			reflection_glow.pixel_x = (world.icon_size * light_range) + (x_offset * world.icon_size) + delta_x
			reflection_glow.pixel_y = (world.icon_size * light_range) + (y_offset * world.icon_size) + delta_y
			reflection_glow.layer = HIGHEST_LIGHTING_LAYER
			temp_appearance += reflection_glow
	*/
	//and add it to the lights overlays
	temp_appearance_shadows += I

/atom/movable/light/shadow/cast_main_shadow(var/turf/target_turf, var/x_offset, var/y_offset)
	return

/atom/movable/light/proc/cast_turf_shadow(var/turf/target_turf, var/x_offset, var/y_offset)


// While this proc is quite involuted, the highest it can do is :
// 8 loops in the first "for"
// 4 loops in the second "for"
/atom/movable/light/shadow/cast_turf_shadow(var/turf/target_turf, var/x_offset, var/y_offset)
	/*
	var/targ_dir = get_dir(target_turf, src)


	var/turf/turf_light_angle = get_step(target_turf, targ_dir)
	if (CHECK_OCCLUSION(turf_light_angle) || !(turf_light_angle in affecting_turfs))
		affected_shadow_walls -= src
		return
	*/
	// -- Illuminating turfs

	if (istype(target_turf, /turf/unsimulated/mineral))
		var/image/img = new
		var/roid_turf_prerender_identifier = "roid_turf_prerender_[light_power]"
		if (roid_turf_prerender_identifier in pre_rendered_shadows)
			img.render_source = roid_turf_prerender_identifier
		else
			img = image('icons/turf/rock_overlay.dmi', loc = get_turf(src))
			img.alpha = min(150,max(0,round(light_power*light_power_multiplier*25)))
			img.render_target = roid_turf_prerender_identifier
			pre_rendered_shadows += roid_turf_prerender_identifier

		img.pixel_x = 4*PIXEL_MULTIPLIER + (world.icon_size * light_range) + (x_offset * world.icon_size)
		img.pixel_y = 4*PIXEL_MULTIPLIER + (world.icon_size * light_range) + (y_offset * world.icon_size)
		img.layer = ROID_TURF_LIGHT_LAYER
		temp_appearance += img

	var/turf_shadow_image_identifier = "white_turf"
	var/image/I = new()

	if (turf_shadow_image_identifier in pre_rendered_shadows)
		I.render_source = turf_shadow_image_identifier
	else
		I = image('icons/lighting/wall_lighting.dmi', loc = get_turf(src))
		I.icon_state = "white"
		I.render_target = turf_shadow_image_identifier
		pre_rendered_shadows += turf_shadow_image_identifier
	var/intensity = min(255,max(0,round(light_power*light_power_multiplier*25)))
	var/fadeout = max(get_dist(src, target_turf)/FADEOUT_STEP, 1)
	I.alpha =  round(intensity/fadeout)
	I.pixel_x = (world.icon_size * light_range) + (x_offset * world.icon_size)
	I.pixel_y = (world.icon_size * light_range) + (y_offset * world.icon_size)
	I.layer = HIGHEST_LIGHTING_LAYER
	image_comp += I
	temp_appearance_shadows += I


/atom/movable/light/proc/update_appearance()
	if (light_post_processing)
		post_processing()
	else
		temp_appearance += temp_appearance_shadows
	overlays = temp_appearance
	temp_appearance = null
	color = light_color

// -- Smoothing out shadows
/atom/movable/light/proc/post_processing()
	if (light_post_processing == ALL_SHADOWS)
		var/image/shadow_overlay/image_result = new()
		for (var/image/image_component in temp_appearance_shadows)
			image_result.temp_appearance += image_component

		image_result.overlays = image_result.temp_appearance
		// Apply a filter
		image_result.filters = filter(type = "blur", size = BLUR_SIZE)
		temp_appearance += image_result
	else
		temp_appearance += temp_appearance_shadows

	if (light_range < 3)
		return

	// And then blacken out what's unvisible
	// -- eliminating the underglow

	for (var/turf/T in affected_shadow_walls)

		var/image/black_turf = new()

		if ("postprocess_black_turf_prerender" in pre_rendered_shadows)
			black_turf.render_source = "postprocess_black_turf_prerender"
		else
			black_turf = image('icons/lighting/wall_lighting.dmi', loc = get_turf(src))
			black_turf.icon_state = "black"
			black_turf.render_target = "postprocess_black_turf_prerender" // Cannot use the previous black_turf_prerender as it has been squeezed to make a filter.
			pre_rendered_shadows += "postprocess_black_turf_prerender"

		black_turf.icon_state = "black"
		var/x_offset = T.x - x
		var/y_offset = T.y - y
		black_turf.pixel_x = (world.icon_size * light_range) + (x_offset * world.icon_size)
		black_turf.pixel_y = (world.icon_size * light_range) + (y_offset * world.icon_size)
		black_turf.layer = ANTI_GLOW_PASS_LAYER
		temp_appearance += black_turf


// Smooth out shadows and then blacken out the wall glow
/atom/movable/light/shadow/post_processing()
	//consolidate_shadows()
	var/image/shadow_overlay/combined_shadow_walls = new()
	for (var/image/I in temp_appearance_shadows)
		combined_shadow_walls.temp_appearance += I

	combined_shadow_walls.overlays = combined_shadow_walls.temp_appearance
	combined_shadow_walls.filters = filter(type = "blur", size = BLUR_SIZE)
	temp_appearance += combined_shadow_walls

	// -- eliminating the underglow
	for (var/turf/T in affected_shadow_walls)
		for (var/dir in cardinal)

			var/turf/neighbour = get_step(T, dir)
			if (neighbour && !CHECK_OCCLUSION(neighbour))
				var/image/black_turf = new()

				if ("postprocess_black_turf_prerender" in pre_rendered_shadows)
					black_turf.render_source = "postprocess_black_turf_prerender"
				else
					black_turf = image('icons/lighting/wall_lighting.dmi', loc = get_turf(src))
					black_turf.icon_state = "black"
					black_turf.render_target = "postprocess_black_turf_prerender" // Cannot use the previous black_turf_prerender as it has been squeezed to make a filter.
					pre_rendered_shadows += "postprocess_black_turf_prerender"

				var/x_offset = (neighbour.x - x)
				var/y_offset = (neighbour.y - y)
				black_turf.pixel_x = (world.icon_size * light_range) + (x_offset * world.icon_size)
				black_turf.pixel_y = (world.icon_size * light_range) + (y_offset * world.icon_size)
				black_turf.layer = ANTI_GLOW_PASS_LAYER
				temp_appearance += black_turf

/atom/movable/light/proc/update_light_dir()
	if(light_type == LIGHT_DIRECTIONAL)
		follow_holder_dir()

/atom/movable/light/proc/CheckOcclusion(var/turf/T)
	if(!istype(T))
		return 0
	return T.check_blocks_light()

// -- This is the UGLY part.

/atom/movable/light/proc/is_valid_turf(var/turf/target_turf)
	return FALSE

/atom/movable/light/shadow/is_valid_turf(var/turf/target_turf)
	return TRUE

// -- "moody lights", small glow overlays for APCs, etc
// They do not cast shadows nor have to do a colour averaging.
/atom/movable/light/moody/cast_light(var/update_color_only)
	if (update_color_only)
		light_color = holder.light_color
		color = light_color
	cast_light_init()
	cast_main_light()

/atom/movable/light/moody/cast_light_init()
	// Light is kill
	if (!light_range || !light_power)
		qdel(src)
		return

	light_color = (holder.light_color || light_color)
	dir = holder.dir

	temp_appearance = list()
	if (holder.lighting_flags & NO_LUMINOSITY)
		luminosity = 3
	else
		luminosity = max(3, 2*light_range)

	//cap light range to 5
	light_range = min(5, light_range)

	alpha = min(255,max(0,round(light_power*light_power_multiplier*25)))
	light_color = (holder.light_color || light_color)

	for (var/mob/M in view(world.view, src))
		M.check_dark_vision()

	for(var/turf/T in view(2*light_range, src))
		T.lumcount = -1
		affecting_turfs += T

	switch (light_type)
		if (LIGHT_SOFT_FLICKER)
			alpha = initial(alpha)
			animate(src, alpha = initial(alpha) - rand(30, 60), time = 2, loop = -1, easing = SINE_EASING)
			animate(alpha = initial(alpha), time = 0)
		if (LIGHT_REGULAR_FLICKER)
			animate(src, alpha = 180, time = 5, loop = -1, easing = CIRCULAR_EASING)
			animate(alpha = 255, time = 5, loop = -1, easing = CIRCULAR_EASING)

/atom/movable/light/moody/cast_main_light()
	if (gcDestroyed)
		return
	if (holder.lighting_flags & FOLLOW_PIXEL_OFFSET)
		pixel_x = holder.pixel_x
		pixel_y = holder.pixel_y

	icon_state = "white"
	var/image/I = image(icon)
	I.layer = HIGHEST_LIGHTING_LAYER
	I.icon_state = "overlay[overlay_state]"
	overlays += I

// -- debug & shit

/turf/proc/get_attack_dir(var/atom/movable/light/light_source)
	var/turf/target_turf = src
	var/targ_dir = get_dir(target_turf, light_source)
	var/turf/turf_light_angle = get_step(target_turf, targ_dir)
	var/list/closest_attack_angles = list()
	if (light_source.CheckOcclusion(turf_light_angle) || !(turf_light_angle in light_source.affecting_turfs))
		var/direction = targ_dir
		for (var/i = 1 to alldirs.len)
			message_admins("[i]-th dir is [direction]")
			var/turf/new_source = get_step(target_turf, direction)
			var/occluded = light_source.CheckOcclusion(new_source)
			if (!occluded && (new_source in light_source.affecting_turfs))
				message_admins("[direction] is chosen")
				closest_attack_angles += direction
				if (closest_attack_angles.len == 2)
					break
			var/i_th_angle = ((-1)**i)*i*45
			direction = turn(direction, i_th_angle)
	message_admins("attack dirs are:")
	for (var/x in closest_attack_angles)
		message_admins("[x]")

	var/blocking_dirs = 0
	for(var/d in cardinal)
		var/turf/T = get_step(target_turf, d)
		if(light_source.CheckOcclusion(T) && (T in light_source.affected_shadow_walls))
			blocking_dirs |= d

	message_admins("blocking dirs are: [blocking_dirs]")

	if (closest_attack_angles.len)
		if ((blocking_dirs == (NORTH|SOUTH)) || (blocking_dirs == (EAST|WEST)))
			targ_dir = pick(closest_attack_angles & cardinal)
		else
			targ_dir = pick(closest_attack_angles & diagonal)

	message_admins("final targ_dir is: [targ_dir]")

// Just explicitly checks if something is a wall... we don't want to cast the hard shadow if the neighbouring occluding obj. is a door, as it will force us to update it
/proc/check_wall_occlusion(var/turf/T)
	return iswallturf(T)

/proc/check_wall_occlusion_dir(var/turf/T, var/direction)
	return iswallturf(get_step(T, direction))

/turf/proc/check_double_occluded(var/atom/movable/light/source)
	var/x_offset = source.x - x
	var/y_offset = source.y - y
	var/xy_swap = 0
	if(abs(x_offset) > abs(y_offset))
		xy_swap = 1
	if (xy_swap)
		return check_wall_occlusion(get_step(src, NORTH)) && check_wall_occlusion(get_step(src, SOUTH))
	else
		return check_wall_occlusion(get_step(src, EAST)) && check_wall_occlusion(get_step(src, WEST))

/atom/movable/light/proc/simulate_wall_illum()
	var/distance_to_wall_illum = get_wall_view()
	for (var/thing in view(min(world.view, distance_to_wall_illum), src))
		if (isturf(thing))
			var/turf/T = thing
			T.lumcount = -1
			affecting_turfs += T
			if (get_dist(T, get_turf(src)) <= distance_to_wall_illum && CHECK_OCCLUSION(T))
				var/intensity = min(255,max(0,round(light_power*light_power_multiplier*25)))
				var/fadeout = max(get_dist(src, T)/FADEOUT_STEP, 1)
				var/x = round(intensity/fadeout)
				var/obj/item/weapon/paper/P = new(T)
				P.name = "[x]"

/turf/proc/check_sum_lighting()
	var/i = 0
	for (var/atom/movable/light/shadow/S in range(src, 7))
		i++
		var/dist = S.get_wall_view()
		S.holder.name = "[S.holder.name] #[i]"
		if (get_dist(get_turf(S), src) <= dist)
			var/intensity = min(255,max(0,round(S.light_power*light_power_multiplier*25)))
			var/fadeout = max(get_dist(src, S)/FADEOUT_STEP, 1)
			var/x = round(intensity/fadeout)
			var/obj/item/weapon/paper/P = new(src)
			var/active = (usr in viewers(S))
			P.name = "([S.x],[S.y];[S.holder.name]):[x] [active? "YES":"NO"]"

#undef MAX_LIGHT_RANGE
#undef BASE_PIXEL_OFFSET
#undef BASE_TURF_OFFSET
#undef WIDE_SHADOW_THRESHOLD
#undef OFFSET_MULTIPLIER_SIZE
#undef CORNER_OFFSET_MULTIPLIER_SIZE
#undef BLUR_SIZE

#undef FADEOUT_STEP
#undef DIRECT_ILLUM_ANGLE

#undef NO_POST_PROCESSING
#undef WALL_SHADOWS_ONLY
#undef ALL_SHADOWS
