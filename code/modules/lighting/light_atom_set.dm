// Destroys and removes a light
/atom/proc/kill_light()
	if(light_obj)
		qdel(light_obj)
		light_obj = null
	if (wall_lighting_obj)
		qdel(wall_lighting_obj)
		wall_lighting_obj = null
	if (moody_light_obj)
		qdel(moody_light_obj)
		moody_light_obj = null

// Updates all appropriate lighting values and then applies all changed values
// to the objects light_obj overlay atom.
/atom/proc/set_light(var/l_range, var/l_power, var/l_color, var/l_type, var/fadeout)

	if(!loc)
		if(light_obj)
			qdel(light_obj)
			qdel(wall_lighting_obj)
			qdel(moody_light_obj)
			light_obj = null
			wall_lighting_obj = null
			moody_light_obj = null
		return

	light_value_inits(l_range, l_power, l_color, l_type)

	// Apply data and update light casting/bleed masking.
	var/update_cast
	if(!light_obj)
		update_cast = 1
		light_obj = new(newholder = src)

	light_atom_update(light_obj, update_cast)

	// Apply data and update light casting/bleed masking.
	var/update_cast_shadow
	if(!wall_lighting_obj)
		update_cast_shadow = 1
		wall_lighting_obj = new(newholder = src)

	light_atom_update(wall_lighting_obj, update_cast_shadow)

	// Rare enough that we can probably get away with calling animate().
	if(fadeout)
		animate(light_obj, alpha = 0, time = fadeout)
		animate(wall_lighting_obj, alpha = 0, time = fadeout)

/atom/proc/light_value_inits(var/l_range, var/l_power, var/l_color, var/l_type)
	// Update or retrieve our variable data.
	if(isnull(l_range))
		l_range = light_range
	else
		light_range = l_range
	if(isnull(l_power))
		l_power = light_power
	else
		light_power = l_power
	if(isnull(l_color))
		l_color = light_color
	else
		light_color = l_color
	if(isnull(l_type))
		l_type = light_type
	else
		light_type = l_type

/atom/proc/light_atom_update(var/atom/movable/light/target, var/update_cast)

	if(target.light_power != light_power)
		update_cast = 1
		target.light_power = light_power

	if(target.light_type != light_type)
		update_cast = 1
		target.light_type = light_type

	if(!target.alpha)
		update_cast = 1

	if(update_cast)
		target.follow_holder()

/atom/movable/light/set_light(var/l_range, var/l_power, var/l_color, var/l_type, var/fadeout)
	return

// -- A lightweight version of the proc for cosmetic light overlays only.
// They are not added to the subsystem and must be properly updated by their parent atoms.
/atom/proc/set_moody_light(var/l_range, var/l_power, var/l_color, var/l_type, var/fadeout)
	if (moody_light_obj?.type != moody_light_type)
		qdel(moody_light_obj)
		moody_light_obj = null
	if (!moody_light_obj)
		moody_light_obj = new moody_light_type(newholder = src)
	light_value_inits(l_range, l_power, l_color, l_type)
	light_atom_update(moody_light_obj, 1)
	moody_light_obj.cast_light()
