#define BASE_PIXEL_OFFSET 224
#define BASE_TURF_OFFSET 2
#define WIDE_SHADOW_THRESHOLD 80
#define OFFSET_MULTIPLIER_SIZE 32
#define CORNER_OFFSET_MULTIPLIER_SIZE 16

// Shadows over light_range 5 haven't been done yet.
#define MAX_LIGHT_RANGE 5

var/light_power_multiplier = 5

// We actually see these "pseudo-light atoms" in order to ensure that wall shadows are only seen by people who can see the light.
// Yes, this is stupid, but it's one of the limitations of TILE_BOUND, which cannot be chosen on an overlay-per-overlay basis.
// So the "next best thing" is to divide the light atoms in two parts, one exclusively for wall shadows and one for general purpose.
// Do note that this means that everything is twice as bright, and twice as dark.
// Draw/generate your shadow masks & light spots accordingly!

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
	temp_appearance = list()
	affecting_turfs = list()
	luminosity = 2*light_range

	//cap light range to the max
	light_range = min(MAX_LIGHT_RANGE, light_range)
	light_color = (holder.light_color || light_color)

	if (light_swallowed > 0)
		light_range = 1
		light_power = 1
		if (light_type != LIGHT_DIRECTIONAL)
			light_type = LIGHT_SOFT_FLICKER

	if(light_type == LIGHT_SOFT_FLICKER)
		alpha = initial(alpha)
		animate(src, alpha = initial(alpha) - rand(30, 60), time = 2, loop = -1, easing = SINE_EASING)

	for (var/mob/M in view(world.view, src))
		M.check_dark_vision()

	for(var/turf/T in view(2*light_range, src))
		T.lumcount = -1
		affecting_turfs += T

	if(!isturf(loc))
		for(var/turf/T in affecting_turfs)
			T.lumcount = -1
			T.affecting_lights -= src
		affecting_turfs.Cut()
		return

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
		pixel_x = -(world.icon_size * light_range)
		pixel_y = -(world.icon_size * light_range)

	// This to avoid TILE_BOUND corner light effects while keeping smooth movement for movable light sources
	// Basically, for movable lights, we always do white square + masking
	// But for fixed lights, we wall-shadows-only lights do not cast a white square
	// Probably not the smartest way around this
	if (holder.lighting_flags & MOVABLE_LIGHT)
		icon_state = "white"
	else
		icon_state = base_light_color_state

	if (icon_state == "white") // This mask only makes sense if we are casting a white light
		alpha = min(255,max(0,round(light_power*light_power_multiplier*25)))
		var/image/I = image(icon)
		I.icon_state = "overlay"
		if(light_type == LIGHT_DIRECTIONAL)
			var/turf/next_turf = get_step(src, dir)
			for(var/i = 1 to 3)
				if(CheckOcclusion(next_turf))
					I.icon_state = "[I.icon_state]_[i]"
					break
				next_turf = get_step(next_turf, dir)

		temp_appearance += I

// On how many turfs do we cast a shadow ?
/atom/movable/light/proc/cast_shadows()
	//no shadows
	if(light_range < 2 || light_type == LIGHT_DIRECTIONAL)
		return

	for(var/turf/T in view(light_range, src))
		if(CheckOcclusion(T))
			CastShadow(T)

/atom/movable/light/proc/cast_main_shadow(var/turf/target_turf, var/x_offset, var/y_offset)

	var/num = 1
	if((abs(x_offset) > 0 && !y_offset) || (abs(y_offset) > 0 && !x_offset))
		num = 2

	//due to only having one set of shadow templates, we need to rotate and flip them for up to 8 different directions
	//first check is to see if we will need to "rotate" the shadow template
	var/xy_swap = 0
	if(abs(x_offset) > abs(y_offset))
		xy_swap = 1

	var/shadowoffset = WORLD_ICON_SIZE/2 + (WORLD_ICON_SIZE*light_range)

	// An explicit call to file() is easily 1000 times as expensive than this construct, so... yeah.
	// Setting icon explicitly allows us to use byond rsc instead of fetching the file everytime.
	// The downside is, of course, that you need to cover all the cases in your switch.
	var/icon/shadowicon
	switch(light_range)
		if(2)
			if(num == 1)
				shadowicon = 'icons/lighting/light_range_2_shadows1.dmi'
			else
				shadowicon = 'icons/lighting/light_range_2_shadows2.dmi'
		if(3)
			if(num == 1)
				shadowicon = 'icons/lighting/light_range_3_shadows1.dmi'
			else
				shadowicon = 'icons/lighting/light_range_3_shadows2.dmi'
		if(4)
			if(num == 1)
				shadowicon = 'icons/lighting/light_range_4_shadows1.dmi'
			else
				shadowicon = 'icons/lighting/light_range_4_shadows2.dmi'
		if(5)
			if(num == 1)
				shadowicon = 'icons/lighting/light_range_5_shadows1.dmi'
			else
				shadowicon = 'icons/lighting/light_range_5_shadows2.dmi'
		if(6)
			if(num == 1)
				shadowicon = 'icons/lighting/light_range_6_shadows1.dmi'
			else
				shadowicon = 'icons/lighting/light_range_6_shadows2.dmi'
		if(7)
			if(num == 1)
				shadowicon = 'icons/lighting/light_range_7_shadows1.dmi'
			else
				shadowicon = 'icons/lighting/light_range_7_shadows2.dmi'
		if(8)
			if(num == 1)
				shadowicon = 'icons/lighting/light_range_8_shadows1.dmi'
			else
				shadowicon = 'icons/lighting/light_range_8_shadows2.dmi'
		if(9)
			if(num == 1)
				shadowicon = 'icons/lighting/light_range_9_shadows1.dmi'
			else
				shadowicon = 'icons/lighting/light_range_9_shadows2.dmi'

	var/image/I = image(shadowicon)

	//due to the way the offsets are named, we can just swap the x and y offsets to "rotate" the icon state
	if(xy_swap)
		I.icon_state = "[abs(y_offset)]_[abs(x_offset)]"
	else
		I.icon_state = "[abs(x_offset)]_[abs(y_offset)]"

	var/matrix/M = matrix()

	//TODO: rewrite this comment:
	//using scale to flip the shadow template if needed
	//horizontal (x) flip is easy, we just check if the offset is negative
	//vertical (y) flip is a little harder, if the shadow will be rotated we need to flip if the offset is positive,
	// but if it wont be rotated then we just check if its negative to flip (like the x flip)
	var/x_flip
	var/y_flip
	if(xy_swap)
		x_flip = y_offset > 0 ? -1 : 1
		y_flip = x_offset < 0 ? -1 : 1
	else
		x_flip = x_offset < 0 ? -1 : 1
		y_flip = y_offset < 0 ? -1 : 1

	M.Scale(x_flip, y_flip)

	//here we do the actual rotate if needed
	if(xy_swap)
		M.Turn(90)

	//warning: you are approaching shitcode (this is where we move the shadow to the correct quadrant based on its rotation and flipping)
	//shadows are only as big as a quarter or half of the light for optimization

	//please for the love of god change this if there's a better way

	if(num == 1)
		if((x_flip == 1 && y_flip == 1 && xy_swap == 0) || (x_flip == -1 && y_flip == 1 && xy_swap == 1))
			M.Translate(shadowoffset, shadowoffset)
		else if((x_flip == 1 && y_flip == -1 && xy_swap == 0) || (x_flip == 1 && y_flip == 1 && xy_swap == 1))
			M.Translate(shadowoffset, 0)
		else if((xy_swap == 0 && x_flip == -y_flip) || (xy_swap == 1 && x_flip == -1 && y_flip == -1))
			M.Translate(0, shadowoffset)
	else
		if(x_flip == 1 && y_flip == 1 && xy_swap == 0)
			M.Translate(0, shadowoffset)
		else if(x_flip == 1 && y_flip == 1 && xy_swap == 1)
			M.Translate(shadowoffset / 2, shadowoffset / 2)
		else if(x_flip == 1 && y_flip == -1 && xy_swap == 1)
			M.Translate(-shadowoffset / 2, shadowoffset / 2)

	//apply the transform matrix
	I.transform = M
	I.layer = LIGHTING_LAYER
	//and add it to the lights overlays
	temp_appearance += I
	for(var/turf/T in affecting_turfs)
		T.affecting_lights |= src

/atom/movable/light/shadow/cast_main_shadow(var/turf/target_turf, var/x_offset, var/y_offset)
	return

/atom/movable/light/proc/cast_turf_shadow(var/turf/target_turf, var/x_offset, var/y_offset)
	var/targ_dir = get_dir(target_turf, src)
	// CHECK: may not actually smoothout that well.
	var/blocking_dirs = 0
	for(var/d in cardinal)
		var/turf/T = get_step(target_turf, d)
		if(CheckOcclusion(T) && (T in view(light_range, src)))
			blocking_dirs |= d

	// The "edge" of the light, with images consisting of directional sprites from wall_lighting.dmi "pushed" in the correct direction.
	var/image/I = image('icons/lighting/wall_lighting.dmi', loc = get_turf(src))
	I.icon_state = "[blocking_dirs]-[targ_dir]"
	I.pixel_x = (world.icon_size * light_range) + (x_offset * world.icon_size)
	I.pixel_y = (world.icon_size * light_range) + (y_offset * world.icon_size)
	I.layer = HIGHEST_LIGHTING_LAYER
	temp_appearance += I

/atom/movable/light/proc/update_appearance()
	overlays = temp_appearance
	temp_appearance = null
	// Because movable lights do this two-lights-sources thing
	if (holder.lighting_flags & MOVABLE_LIGHT)
		var/list/RGB = rgb2num(light_color)
		color = rgb(round(RGB[1]/2), round(RGB[2]/2), round(RGB[3]/2))
	else
		color = light_color

/atom/movable/light/proc/CastShadow(var/turf/target_turf)
	//get the x and y offsets for how far the target turf is from the light
	var/x_offset = target_turf.x - x
	var/y_offset = target_turf.y - y
	cast_main_shadow(target_turf, x_offset, y_offset)

	if (is_valid_turf(target_turf))
		cast_turf_shadow(target_turf, x_offset, y_offset)

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

	if(light_type == LIGHT_SOFT_FLICKER)
		alpha = initial(alpha)
		animate(src, alpha = initial(alpha) - rand(30, 60), time = 2, loop = -1, easing = SINE_EASING)

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

#undef MAX_LIGHT_RANGE
#undef BASE_PIXEL_OFFSET
#undef BASE_TURF_OFFSET
#undef WIDE_SHADOW_THRESHOLD
#undef OFFSET_MULTIPLIER_SIZE
#undef CORNER_OFFSET_MULTIPLIER_SIZE
