/atom
	var/atom/movable/light/light_obj
	var/atom/movable/light/wall_lighting/wall_lighting_obj
	var/atom/movable/light/moody_light_obj
	var/light_type = LIGHT_SOFT
	var/light_power = 1
	var/light_range = 1
	var/light_color = "#F4FFFA"

// Used to change hard BYOND opacity; this means a lot of updates are needed.
/atom/proc/set_opacity(var/newopacity)
	opacity = newopacity ? 1 : 0
	var/turf/T = get_turf(src)
	if(istype(T))
		T.blocks_light = -1
		for(var/atom/movable/light/L in range(world.view, T)) //view(world.view, dview_mob))
			if (world.tick_usage < TICK_LIMIT_RUNNING && ticker.current_state > GAME_STATE_PREGAME)
				lighting_update_lights |= L
			else
				L.cast_light()

/atom/proc/copy_light(var/atom/other)
	light_range = other.light_range
	light_power = other.light_power
	light_color = other.light_color
	set_light()

/atom/proc/update_all_lights()
	if(light_obj && !light_obj.gcDestroyed)
		light_obj.follow_holder()
	if (wall_lighting_obj && !wall_lighting_obj.gcDestroyed)
		wall_lighting_obj.follow_holder()

/atom/movable/change_dir()
	. = ..()
	update_contained_lights()

/atom/movable/Move(atom/NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	var/old_loc = loc
	. = ..()
	update_contained_lights(old_loc)

/atom/movable/forceMove(atom/NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0, from_tp = 0)
	var/old_loc = loc
	. = ..()
	update_contained_lights(old_loc)

/atom/proc/update_contained_lights(var/old_loc, var/list/specific_contents)
	if(!specific_contents)
		specific_contents = contents
	for(var/thing in (specific_contents + src))
		var/atom/A = thing
		if(A && !A.gcDestroyed)
			if (ismob(old_loc)) // BUGFIX: otherwise the flare does a weird animation when coming out of the backpack.
				spawn(1)
					A.update_all_lights()
			else
				A.update_all_lights()

/atom/movable/light/update_contained_lights(var/list/specific_contents)
	return

/atom/var/has_white_turf_lighting = 0

/area/proc/set_white_turf_lighting(bool)
	has_white_turf_lighting = bool
	update_white_turf_lighting()

/area/proc/update_white_turf_lighting()
	if(has_white_turf_lighting)
		var/image/I = image(icon = 'icons/mob/screen1.dmi', icon_state = "white")
		I.plane = relative_plane(LIGHTING_PLANE)
		I.blend_mode = BLEND_ADD
		overlays += I
		luminosity = 1
	else
		overlays.Cut()
