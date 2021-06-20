/atom
	var/atom/movable/light/light_obj
	var/atom/movable/light/shadow/shadow_obj
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
			L.cast_light()

/atom/proc/copy_light(var/atom/other)
	light_range = other.light_range
	light_power = other.light_power
	light_color = other.light_color
	set_light()

/atom/proc/update_all_lights()
	if(light_obj && !light_obj.gcDestroyed)
		light_obj.follow_holder()
	if (shadow_obj && !shadow_obj.gcDestroyed)
		shadow_obj.follow_holder()

/atom/movable/change_dir()
	. = ..()
	update_contained_lights()

/atom/movable/Move(atom/NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	. = ..()
	update_contained_lights()

/atom/movable/forceMove(atom/NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	. = ..()
	update_contained_lights()

/atom/proc/update_contained_lights(var/list/specific_contents)
	if(!specific_contents)
		specific_contents = contents
	for(var/thing in (specific_contents + src))
		var/atom/A = thing
		if(A && !A.gcDestroyed)
			A.update_all_lights()

/atom/var/dynamic_lighting = 0

/area/proc/set_dynamic_lighting(bool)
	dynamic_lighting = bool
	update_dynamic_lighting()

/area/proc/update_dynamic_lighting()
	if(dynamic_lighting)
		var/image/I = image(icon = 'icons/mob/screen1.dmi', icon_state = "white")
		I.plane = LIGHTING_PLANE_MASTER
		I.blend_mode = BLEND_ADD
		overlays += I
	else
		overlays.Cut()
