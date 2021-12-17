#define LIGHT_CPU_THRESHOLD 80
#define TURF_SHADOW_FRACTION 0.75

/atom/movable/light
	name = ""
	mouse_opacity = 0
	plane = LIGHTING_PLANE
	anchored = 1

	layer = 1
	//layer 1 = base plane layer
	//layer 2 = base shadow templates
	//layer 3 = wall lighting overlays
	//layer 4 = light falloff overlay

	appearance_flags = KEEP_TOGETHER
	icon = null
	invisibility = INVISIBILITY_LIGHTING
	pixel_x = -WORLD_ICON_SIZE/2
	pixel_y = -WORLD_ICON_SIZE/2
	glide_size = WORLD_ICON_SIZE
	blend_mode = BLEND_ADD
	animate_movement = NO_STEPS

	alpha = 180

	var/current_power = 1
	var/base_light_color_state = "white"
	var/atom/movable/holder
	var/point_angle
	var/list/affecting_turfs = list()
	var/list/affected_shadow_walls = list()
	var/list/temp_appearance
	var/list/temp_appearance_shadows

	var/light_swallowed = 0

	var/list/pre_rendered_shadows = list()

/atom/movable/light/shadow
	base_light_color_state = "black"
	appearance_flags = KEEP_TOGETHER | TILE_BOUND
	animate_movement = NO_STEPS

/atom/movable/light/New(..., var/atom/newholder)
	holder = newholder
	if(istype(holder, /atom))
		var/atom/A = holder
		light_range = A.light_range
		light_color = A.light_color || rgb(255, 255, 255)
		light_power = A.light_power
		light_type	= A.light_type
		color = light_color
	..()

/atom/movable/light/Destroy()
	transform = null
	appearance = null
	overlays = null
	temp_appearance = null

	if(holder)
		if(holder.light_obj == src)
			holder.light_obj = null
		if (holder.shadow_obj == src)
			holder.shadow_obj = null
		holder = null
	for(var/thing in affecting_turfs)
		var/turf/T = thing
		T.lumcount = -1
	affecting_turfs.Cut()
	. = ..()

/atom/movable/light/initialize()
	..()
	if(holder)
		follow_holder()

// Applies power value to size (via Scale()) and updates the current rotation (via Turn())
// angle for directional lights. This is only ever called before cast_light() so affected turfs
// are updated elsewhere.
/atom/movable/light/proc/update_transform(var/newrange)
	if(!isnull(newrange) && current_power != newrange)
		current_power = newrange

// Orients the light to the holder's (or the holder's holder) current dir.
// Also updates rotation for directional lights when appropriate.
/atom/movable/light/proc/follow_holder_dir()
	if(holder.loc.loc && ismob(holder.loc))
		set_dir(holder.loc.dir)
	else
		set_dir(holder.dir)

// Moves the light overlay to the holder's turf and updates bleeding values accordingly.
/atom/movable/light/proc/follow_holder()
	if(lighting_update_lights)
		if(holder && holder.loc)
			follow_holder_dir()

			if(isturf(holder))
				forceMove(holder, glide_size_override = 8) // Default glide.
			else if(holder.loc.loc && ismob(holder.loc))
				var/mob/M = holder.loc
				forceMove(holder.loc.loc, glide_size_override = M.glide_size) // Glide size from our mob.
			else
				forceMove(holder.loc, glide_size_override = 8) // Hopefully whatever we're gliding with has smooth movement.

			if (world.cpu < LIGHT_CPU_THRESHOLD || !ticker || ticker.current_state < GAME_STATE_SETTING_UP)
				cast_light() // We don't use the subsystem queue for this since it's too slow to prevent shadows not being updated quickly enough
			else
				lighting_update_lights |= src

	else
		init_lights |= src

/atom/movable/light/proc/set_dir(new_dir)
	if(dir != new_dir)
		dir = new_dir

	if(light_type == LIGHT_DIRECTIONAL)
		switch(dir)
			if(NORTH)
				pixel_x = -(world.icon_size * light_range) + world.icon_size / 2
				pixel_y = 0
			if(SOUTH)
				pixel_x = -(world.icon_size * light_range) + world.icon_size / 2
				pixel_y = -(world.icon_size * light_range) - world.icon_size * light_range + world.icon_size
			if(EAST)
				pixel_x = 0
				pixel_y = -(world.icon_size * light_range) + world.icon_size / 2
			if(WEST)
				pixel_x = -(world.icon_size * light_range) - (world.icon_size * light_range) + world.icon_size
				pixel_y = -(world.icon_size * light_range) + (world.icon_size / 2)

/atom/movable/light/proc/light_off()
	alpha = 0

/atom/movable/light/proc/get_wall_view()
	return light_range

/atom/movable/light/shadow/get_wall_view()
	return round(TURF_SHADOW_FRACTION*light_range)

// -- Does a basic cheap raycast from the light to the turf.
// Return true if it can see it.
/atom/movable/light/proc/can_see_turf(var/turf/T)
	var/vector/V = atoms2vector(src, T)
	var/list/vector/steps = vector_to_steps(V)
	var/turf/current_turf = get_turf(src)
	. = TRUE
	for (var/vector/step in steps)
		current_turf = current_turf.get_translated_turf(step)
		if (CHECK_OCCLUSION(current_turf))
			. = FALSE
			return

/image/shadow_overlay
	appearance_flags = KEEP_TOGETHER
	var/list/temp_appearance = list()

#undef LIGHT_CPU_THRESHOLD
#undef TURF_SHADOW_FRACTION
