#define BASE_PIXEL_OFFSET 224
#define BASE_TURF_OFFSET 2
#define WIDE_SHADOW_THRESHOLD 80
#define OFFSET_MULTIPLIER_SIZE 32
#define CORNER_OFFSET_MULTIPLIER_SIZE 16
#define BLUR_SIZE 4 // integer, please

#define FADEOUT_STEP		3
#define FULL_BRIGHT_WIDTH	3

// Shadows over light_range 9 haven't been done yet.
#define MAX_LIGHT_RANGE 10

#define NO_POST_PROCESSING 	0
#define WALL_SHADOWS_ONLY  	1
#define ALL_SHADOWS	 		2

#define DIRECT_ILLUM_ANGLE 20

var/light_power_multiplier = 5
var/light_post_processing = ALL_SHADOWS // Use writeglobal to change this. Not recommended: without blur, shadows look like shit.

// --------------
// READ THIS BEOFRE READING THIS CODE
// --------------

// We actually see these "pseudo-light atoms" in order to ensure that wall shadows are only seen by people who can see the light.
// Yes, this is stupid, but it's one of the limitations of TILE_BOUND, which cannot be chosen on an overlay-per-overlay basis.
// So the "next best thing" is to divide the light atoms in two parts, one exclusively for wall shadows and one for general purpose.
// The secondary_source atoms are what contains the actual shadow icons, wheras /atom/movable/light/wall_lighting is just a container object.

// How does light/wall_lighting work?
// We look following a spiral_block pattern of length light_range. Whenever we see a occlusion turf, we add it to a turf group.
// If the next occluded turf is not adjacent, or if the current turf group is longer than 6, we create a new one.
// At the time of `cast_shadows`, we use vector mathematics to draw a line from the middle turf to the light source.
// We try different angles.
// The first non-wall turf in view of the light_obj is where the wall_lighting is "located". This is important because the location needs to be close to the actual walls being lit.
// This is because the wall_lighting atom has `TILE_BOUND`, and as such, is only rendered if there's a clear line of sight between the player and turf location.
// By having the turf location close to the actual walls, we minise the risks of them not being rendered, while keeping the benefits of TILE_BOUND.

// What's will all this render target nonsense?
// The icons we are trying to draw are, for the scale of BYOND, quite complex.
// In particular, the shadow trapezoids are subject to various transformation matrices and clients may struggle to render them.
// BYOND can make it so we only draw fully one of those trapezoids and, if we notice server-side that we need to draw the same shape, just copy and paste it.
// The list of pre-rendered icons is in ubiquitous_light_ranges and ubiquitous_shadow_renders.
// We can also see if we didn't already render one ourself.
// This saves quite a bit on rendering in areas with many overlapping lights close to one another.

// NB: as per Lummox himself, using mutable_appearances do not change much as far the client is concerned.
// It is also why there's a bunch of incompressible lagsrelated to big icons: grouping them is the most expensive part, and that's not something we can easily play with.

var/list/ubiquitous_light_ranges = list(1, 4, 5, 6)

// -- "shadow[num]_[light_range]_[grazing_angle]_[abs(y_offset)]_[abs(x_offset)]_[block_1]_[block_2]_[delta]" --
var/list/ubiquitous_shadow_renders = list("*shadow2_4_90_1_0_1_1_-1", "*shadow2_4_180_1_0_1_1_-1", "*shadow2_4_0_1_0_1_1_-1", "*shadow2_4_-90_1_0_1_1_-1",
										"*shadow2_5_90_1_0_1_1_-1", "*shadow2_5_180_1_0_1_1_-1", "*shadow2_5_0_1_0_1_1_-1", "*shadow2_5_-90_1_0_1_1_-1",
										"*shadow2_6_90_1_0_1_1_-1", "*shadow2_6_180_1_0_1_1_-1", "*shadow2_6_0_1_0_1_1_-1", "*shadow2_6_-90_1_0_1_1_-1",

										"*shadow2_4_90_1_0_0_0_-1", "*shadow2_4_180_1_0_0_0_-1", "*shadow2_4_0_1_0_0_0_-1", "*shadow2_4_-90_1_0_0_0_-1",
										"*shadow2_5_90_1_0_0_0_-1", "*shadow2_5_180_1_0_0_0_-1", "*shadow2_5_0_1_0_0_0_-1", "*shadow2_5_-90_1_0_0_0_-1",
										"*shadow2_6_90_1_0_0_0_-1", "*shadow2_6_180_1_0_0_0_-1", "*shadow2_6_0_1_0_0_0_-1", "*shadow2_6_-90_1_0_0_0_-1")

#define TURF_GROUP_LENGTH 6
#define TURF_GROUP_MIDPOINT round(TURF_GROUP_LENGTH/2)

/atom/movable/light
	var/found_prerendered_white_light_glob = FALSE


// Cast_light() is the "master proc". It does everything in order.
/atom/movable/light/proc/cast_light()
	cast_light_init() // -- Clean up old vars, initialise stuff, in particular, selects the walls to draw shadows on.
	cast_main_light() // -- Casts the main light source - a square - and the circular mask overlay.
	update_light_dir() // -- Updates dir. Only useful for some cases.
	cast_shadows() // -- Casts the masking shadows on the walls.
	update_appearance() // -- Wrap up everything. Apply filters, apply colours, and voilà.

/atom/movable/light/secondary_shadow/cast_light()
	return // We don't cast light ourself!

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
// -- Main light atom

// Initialisation of the cast_light proc.
/atom/movable/light/proc/cast_light_init()

	filters = list()
	temp_appearance = list()
	temp_appearance_shadows = list()
	cull_light_turfs()
	affected_shadow_walls = list()
	pre_rendered_shadows = list()
	found_prerendered_white_light_glob = FALSE

	//cap light range to the max
	luminosity = 3*light_range
	light_range = min(MAX_LIGHT_RANGE, light_range)
	//light_color = (holder.light_color || light_color)

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

	var/list/cached_view = view(distance_to_wall_illum, src)
	for (var/thing in cached_view)
		if (ismob(thing))
			var/mob/M = thing
			M.check_dark_vision()
		if (isturf(thing))
			var/turf/T = thing
			add_light_turf(T) // wall_lighting objects do not need to keep a list of turfs.
			if (CHECK_OCCLUSION(T))
				affected_shadow_walls += T
				/*
				for (var/dir in cardinal)
					var/turf/T2 = get_step(T, dir)
					if (!(T2 in cached_view) && CHECK_OCCLUSION(T2))
						affected_shadow_walls += T2
				*/

	if(!isturf(loc))
		for(var/turf/T in affecting_turfs)
			T.lumcount = -1
			T.luminosity = 0
		affecting_turfs.Cut()
		return

// -- DIFFERENCE: We look at turfs in a particular spiral order
// We don't add turfs to `affecting_turfs`.
/atom/movable/light/wall_lighting/cast_light_init()
	. = ..()

	shadow_component_turfs = list()
	for (var/stuff in shadow_component_atoms)
		qdel(stuff)
		shadow_component_atoms -= stuff

	var/turf/last_turf_in_group = null
	var/list/turf_group = list()
	// Need to do it in a spiral to ensure our group_turfs are connex.
	for (var/turf/T in spiral_block(get_turf(src), light_range, only_view = TRUE))

		if (!CHECK_OCCLUSION(T))
			continue

		// See header comment for explanation
		if (last_turf_in_group && ((get_dist(T, last_turf_in_group) > 1) || (turf_group.len >= TURF_GROUP_LENGTH)))
			shadow_component_turfs += list(turf_group)
			turf_group = list()

		last_turf_in_group = T
		turf_group += last_turf_in_group

	shadow_component_turfs += list(turf_group)

// ------- Adding turfs

/atom/movable/light/proc/add_light_turf(var/turf/T)
	// The luminosity cast over distant turfs thing is only going to be a problem for very, very big light sources.
	// The light overlays will only be rendered IF the turf has `luminosity` or if the light source is 9 tiles away from the player.
	// These checks are here for optimisation and not do unnecessary work:
	// only light sources whose outer edge can be more than 9 tiles away from the player need to be considered.
	if (light_range > 6 && get_dist(T, src) > 3)
		T.lumcount = -1
		T.luminosity = 1
		T.light_sources += src
		affecting_turfs += T

/atom/movable/light/wall_lighting/add_light_turf(var/turf/T)
	return

// We need to remove luminosity from the turf, otherwise, it is right-clickable.
/atom/movable/light/proc/cull_light_turfs()
	for (var/turf/T in affecting_turfs)
		T.light_sources -= src
		if (!(T.light_sources.len))
			T.luminosity = 0
	affecting_turfs = list()

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
// -- The procs related to the source of light

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
		pixel_x = -(world.icon_size * light_range)
		pixel_y = -(world.icon_size * light_range)
	if (lighting_flags & FOLLOW_PIXEL_OFFSET)
		pixel_x += holder.pixel_x
		pixel_y += holder.pixel_y

	// This to avoid TILE_BOUND corner light effects while keeping smooth movement for movable light sources
	// There are THREE light atoms on an object
	// - the white square + shadows (not TILE_BOUND)
	// - the wall shadow layer (TILE_BOUND)
	// - the smooth white square (also TILE_BOUND)
	icon_state = base_light_color_state

	if (light_type == LIGHT_SOLID_TURF)
		var/image/I = new(icon)
		I.icon_state = "white"
		temp_appearance += I
		return

	if (icon_state == "white") // This mask only makes sense if we are casting a white light
		alpha = min(255,max(0,round(light_power*light_power_multiplier*25)))
		var/image/I = new

		// Find proper identifier
		var/white_light_identifier = "white_[light_range]"

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

		if (white_light_identifier in pre_rendered_shadows)
			I.render_source = white_light_identifier
		else
			var/found_prerendered_white_light = FALSE
			if (light_range > 1)
				for (var/atom/movable/light/neighbour in get_turf(src)) // This is explicitly targetted at 300 flares on the same tile.
					if (white_light_identifier in neighbour.pre_rendered_shadows)
						I.render_source = white_light_identifier
						I.icon_state = "overlay"
						found_prerendered_white_light = TRUE
						found_prerendered_white_light_glob = TRUE
						break
			if (!found_prerendered_white_light)
				if (light_range in ubiquitous_light_ranges)
					I.render_source = "*light_range_[light_range]_prerender"
				else
					I = image(icon)
				if (light_type == LIGHT_DIRECTIONAL)
					I.icon_state = directional_light_overlay
				else
					I.icon_state = "overlay"
				I.render_target = white_light_identifier
				pre_rendered_shadows += white_light_identifier

		I.blend_mode = BLEND_INSET_OVERLAY
		temp_appearance += I

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
// -- The procs related to the shadow

// On every turf that's affected, we cast a shadow.
/atom/movable/light/proc/cast_shadows()
	//no shadows for these small lights.
	if(light_range == 1 || light_type == LIGHT_DIRECTIONAL)
		return

	for(var/turf/T in affected_shadow_walls)
		if(CHECK_OCCLUSION(T))
			CastShadow(T)

// We take out our turf chunks and cast secondary sources on the middle ones.
/atom/movable/light/wall_lighting/cast_shadows()
	// Aggressive optimisation against stacked light sources on the same tile.
	// We simply don't cast any wall lighting in this case.
	if (holder.light_obj.found_prerendered_white_light_glob)
		shadow_component_turfs = list()
		return

	for (var/list/L in shadow_component_turfs)
		// Picking the middle element in the list
		if (!L.len)
			continue
		var/index = min(TURF_GROUP_MIDPOINT, 1)
		var/turf/wanted_turf = L[index]

		/*
		 * Mathematics to get the right source
		 */

		// Getting the direction towards the light
		var/vector/direction_vec = atoms2vector(wanted_turf, get_turf(src))
		var/angle_to_light = direction_vec.toAngle()
		var/dir_to_light
		var/turf/new_source_turf
		// We are on the same turf as the light source
		if (angle_to_light == -1)
			dir_to_light = 0
			new_source_turf = get_step(wanted_turf, dir_to_light)
		// We aren't, so we point towards it
		else
			dir_to_light = angle2dir(angle_to_light)
			new_source_turf = get_step(wanted_turf, dir_to_light)
			// Need to check if it's not a wall
			if (CHECK_OCCLUSION(new_source_turf))
				// We turn 45 deg in hopes of finding the light again
				new_source_turf = get_step(wanted_turf, turn(dir_to_light, 45))
				// If we can't, then we just turn in the opposite direction.
				if (!(new_source_turf in view(light_range, src)) || CHECK_OCCLUSION(new_source_turf))
					new_source_turf = get_step(wanted_turf, turn(dir_to_light, -45))

		// Create a secondary light source, located on that direction towards the light
		var/atom/movable/light/secondary_shadow/secondary_source = new(new_source_turf, newholder = src.holder)
		secondary_source.source_turf = new_source_turf
		shadow_component_atoms += secondary_source

		secondary_source.loc = secondary_source.source_turf

		// Initialise it
		secondary_source.icon = 'icons/lighting/light_range_3.dmi'
		secondary_source.dir_to_source = dir_to_light
		secondary_source.parent = src
		secondary_source.affected_shadow_walls = L
		secondary_source.temp_appearance = list()
		secondary_source.temp_appearance_shadows = list()

		// Then cast the shadows!
		for (var/turf/target_turf in secondary_source.affected_shadow_walls)
			var/x_offset = (target_turf.x - secondary_source.x)
			var/y_offset = (target_turf.y - secondary_source.y)
			secondary_source.cast_turf_shadow(target_turf, x_offset, y_offset, src)

// Wrapper proc to get the correct offsets once and for all.
/atom/movable/light/proc/CastShadow(var/turf/target_turf)
	//get the x and y offsets for how far the target turf is from the light
	var/x_offset = (target_turf.x - x)
	var/y_offset = (target_turf.y - y)
	cast_main_shadow(target_turf, x_offset, y_offset)

// Heavy lifting: chose the correct image depending on distance
// Rotate it depending on angle.
// Calculate correct offsets depending on angles.
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

	// Select which kind of icon we want.
	// Two blocks, block to one side, no blocks.
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
			block_2 = block_south || block_east

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

	var/mutable_appearance/I = new() // This technically doesn't really matter.

	var/found_shadow_identif = 0

	var/shadow_image_identifier = "shadow[num]_[light_range]_[grazing_angle]_[abs(y_offset)]_[abs(x_offset)]_[block_1]_[block_2]_[delta]"

	// We've done this before...
	if (shadow_image_identifier in ubiquitous_shadow_renders)
		I.render_source = "*[shadow_image_identifier]"
		found_shadow_identif = TRUE

	/* HAAA! It doesn't work for some reason. It conflcits with the ubiquitous_rendering thing. ;_;
	// Same tile has done it before.......
	for (var/atom/movable/light/neighbour in get_turf(src)) // This light atom is rendered from point A to point B, so it's fine
		if ((shadow_image_identifier in neighbour.pre_rendered_shadows) && !(shadow_image_identifier in ubiquitous_shadow_renders))
			I.render_source = shadow_image_identifier
			found_shadow_identif = TRUE
	*/

	// Or not!
	if (!found_shadow_identif)
		// An explicit call to file() is easily 1000 times as expensive than this construct, so... yeah.
		// Setting icon explicitly allows us to use byond rsc instead of fetching the file everytime.
		// The downside is, of course, that you need to cover all the cases in your switch.
		var/icon/shadowicon = try_get_light_range_icon(block_1, block_2, light_range, num)
		I = image(shadowicon)
		//I.render_target = shadow_image_identifier
		pre_rendered_shadows += shadow_image_identifier

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
	// Front shadows have a small white component meant to display the reflection of the light on the wall.
	// This white component need to be layered under the rest of the shadow.
	// IMPROVEMENT: have the white and black components (in case more white components get added for bounced lights) be on two different sets of icons.
	// PROBLEM: too many overlays = difficult to group.
	switch(num)
		if (CORNER_SHADOW)
			I.layer = HIGHEST_LIGHTING_LAYER + temp_appearance_shadows.len
		if (FRONT_SHADOW)
			I.layer = ABOVE_LIGHTING_LAYER + temp_appearance_shadows.len

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

	//and add it to the lights overlays
	temp_appearance_shadows += I

// No main shadows for wall lighting.
/atom/movable/light/wall_lighting/cast_main_shadow(var/turf/target_turf, var/x_offset, var/y_offset)
	return

// No turf shaodws/wall lighting for the main source of light.
/atom/movable/light/proc/cast_turf_shadow(var/turf/target_turf, var/x_offset, var/y_offset)
	return

// While this proc is quite involuted, the highest it can do is :
// 8 loops in the first "for"
// 4 loops in the second "for"
/atom/movable/light/secondary_shadow/cast_turf_shadow(var/turf/target_turf, var/x_offset, var/y_offset, var/atom/movable/light/wall_lighting/parent)

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

		img.pixel_x = 4*PIXEL_MULTIPLIER + (x_offset * world.icon_size)
		img.pixel_y = 4*PIXEL_MULTIPLIER + (y_offset * world.icon_size)
		img.layer = ROID_TURF_LIGHT_LAYER + temp_appearance.len
		img.color = light_color
		temp_appearance += img

	var/image/I = new()
	I.render_source = "*white_turf_prerender"
	I.icon_state = "white"

	var/intensity = min(255,max(0,round(light_power*light_power_multiplier*25)))
	var/fadeout_distance = max(round((get_dist(parent, target_turf) - light_range/2)), 0)

	I.alpha =  round(intensity * 0.5**fadeout_distance) // dist = half light, 0.5**00 = 1 ; 1 tile more = 0.5 ; 2 tiles more = 0.25
	I.pixel_x = WORLD_ICON_SIZE/2 + (x_offset * world.icon_size)
	I.pixel_y = WORLD_ICON_SIZE/2 + (y_offset * world.icon_size)
	I.color = light_color
	I.layer = HIGHEST_LIGHTING_LAYER + temp_appearance.len
	temp_appearance_shadows += I

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
// -- Wrap it up, put all the overlay components in one place, then apply a colour.

/atom/movable/light/proc/update_appearance()
	if (light_post_processing)
		post_processing()
	else
		temp_appearance += temp_appearance_shadows
	overlays = temp_appearance
	temp_appearance = null

	update_color()

// We explicitly add new overlays to post_processing so we have to do this slightly modified wrappup
/atom/movable/light/secondary_shadow/update_appearance()
	if (light_post_processing)
		post_processing()
	else
		temp_appearance += temp_appearance_shadows
		overlays = temp_appearance

	final_appearance.overlays = final_appearance.temp_appearance
	overlays += final_appearance
	final_appearance = null

	update_color()

/atom/movable/light/proc/update_color()
	// Coloring!
	var/image/I = new
	I.icon = src.icon
	I.icon_state = "white"
	I.alpha = 255
	I.blend_mode = BLEND_MULTIPLY // acts a color map on top of us
	I.color = light_color
	I.layer = LIGHTING_COLOUR_LAYER
	overlays += I
	if (lighting_flags & LIGHT_BLOOM)
		filters += filter(type="bloom", size = 2, offset = 4, threshold = "#000000", alpha = alpha)

/atom/movable/light/wall_lighting/update_appearance()
	for (var/atom/movable/light/secondary_shadow/shadow_comp in shadow_component_atoms)
		shadow_comp.update_appearance()

/atom/movable/light/secondary_shadow/update_color()
	return

// -- Smoothing out shadows with a blur filter.
/atom/movable/light/proc/post_processing()
	if (light_post_processing == ALL_SHADOWS)
		var/image/shadow_overlay/image_result = new()
		for (var/image/image_component in temp_appearance_shadows)
			image_result.temp_appearance += image_component

		image_result.overlays = image_result.temp_appearance
		// Apply a filter. Don't do that if there's already a stacked light on the tile (avoid lag machines)
		if (!found_prerendered_white_light_glob)
			image_result.filters = filter(type = "blur", size = BLUR_SIZE)
		image_result.blend_mode = BLEND_INSET_OVERLAY
		temp_appearance += image_result
	else
		temp_appearance += temp_appearance_shadows

	if (light_range < 2)
		return

	// And then blacken out what's unvisible
	// -- eliminating the underglow

	for (var/turf/T in affected_shadow_walls)

		var/image/black_turf = new()
		black_turf.render_source = "*black_turf_prerender"
		black_turf.icon_state = "black"

		var/x_offset = T.x - x
		var/y_offset = T.y - y
		black_turf.pixel_x = (world.icon_size * light_range) + (x_offset * world.icon_size)
		black_turf.pixel_y = (world.icon_size * light_range) + (y_offset * world.icon_size)
		black_turf.layer = ANTI_GLOW_PASS_LAYER + temp_appearance.len
		black_turf.blend_mode = BLEND_INSET_OVERLAY
		temp_appearance += black_turf

// Smooth out shadows and then blacken out the wall glow
/atom/movable/light/secondary_shadow/post_processing()
	var/image/shadow_overlay/combined_shadow_walls = new()
	for (var/image/I in temp_appearance_shadows)
		combined_shadow_walls.temp_appearance += I

	combined_shadow_walls.overlays = combined_shadow_walls.temp_appearance
	if (!parent.found_prerendered_white_light_glob)
		combined_shadow_walls.filters = filter(type = "blur", size = BLUR_SIZE)

	temp_appearance_shadows = list()
	final_appearance = new()

	final_appearance.temp_appearance += combined_shadow_walls

	// -- eliminating the underglow
	// Due to the blur filter, some of the white pixels may extend below the turf they are supposed to be rendered on.
	// This fixes that by drawing a black turf on top of it.
	for (var/turf/T in affected_shadow_walls)
		for (var/dir in cardinal)

			var/turf/neighbour = get_step(T, dir)
			if (neighbour && !CHECK_OCCLUSION(neighbour))
				var/image/black_turf = new()

				black_turf.render_source = "*black_turf_prerender"

				var/x_offset = (neighbour.x - x)
				var/y_offset = (neighbour.y - y)
				black_turf.pixel_x = (WORLD_ICON_SIZE/2) + (x_offset * world.icon_size)
				black_turf.pixel_y = (WORLD_ICON_SIZE/2) + (y_offset * world.icon_size)
				black_turf.layer = ANTI_GLOW_PASS_LAYER
				final_appearance.temp_appearance += black_turf

// --------- Misc utilitary procs.

/atom/movable/light/proc/update_light_dir()
	if(light_type == LIGHT_DIRECTIONAL)
		follow_holder_dir()

/atom/movable/light/proc/CheckOcclusion(var/turf/T)
	if(!istype(T))
		return 0
	return T.check_blocks_light()

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

	overlays = list()
	light_color = (holder.light_color || light_color)
	follow_holder_dir()

	temp_appearance = list()
	if (holder.lighting_flags & NO_LUMINOSITY)
		luminosity = 3
	else
		luminosity = max(3, 2*light_range)

	light_range = 1

	alpha = min(255,max(0,round(light_power*light_power_multiplier*25)))
	light_color = (holder.light_color || light_color)

	for (var/mob/M in view(world.view, src))
		M.check_dark_vision()

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
	I.layer = LIGHTING_COLOUR_LAYER
	I.icon_state = "overlay[overlay_state]"
	I.dir = dir
	overlays += I

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
// -- Wall lighting atom

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

/atom/movable/light/wall_lighting/simulate_wall_illum()
	for (var/atom/movable/light/secondary_shadow/shadow_comp in shadow_component_atoms)
		shadow_comp.simulate_wall_illum()

/atom/movable/light/secondary_shadow/simulate_wall_illum()
	var/distance_to_wall_illum = get_wall_view()
	for (var/thing in view(min(world.view, distance_to_wall_illum), src))
		if (isturf(thing))
			var/turf/T = thing
			T.lumcount = -1
			affecting_turfs += T
			if (get_dist(T, get_turf(src)) <= distance_to_wall_illum && CHECK_OCCLUSION(T))
				var/intensity = min(255,max(0,round(light_power*light_power_multiplier*25)))
				var/fadeout_distance = max(round((get_dist(parent, thing) - light_range/2)), 0)
				var/x =  round(intensity * 0.5**fadeout_distance) // dist = half light, 0.5**00 = 1 ; 1 tile more = 0.5 ; 2 tiles more = 0.25
				var/obj/item/weapon/paper/P = new(T)
				P.autoignition_temperature = 1e9
				P.name = "[x]"

/turf/proc/check_sum_lighting()
	var/i = 0
	for (var/atom/movable/light/wall_lighting/S in range(src, 7))
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

#undef FULL_BRIGHT_WIDTH
#undef FADEOUT_STEP
#undef DIRECT_ILLUM_ANGLE

#undef NO_POST_PROCESSING
#undef WALL_SHADOWS_ONLY
#undef ALL_SHADOWS
