/*

Moody lights are additive overlays displayed on the LIGHTING_PLANE that allow for discrete "fake" light sources that are much cheaper than actual lights
When enabled, moody lights also raise the luminosity of the atom they're associated with to 2, making them visible even far away in a pitch black room.

If your atom needs a single of those overlays, use update_moody_light()
If it needs to have multiple overlays that can toggled independently, use update_moody_light_index()

*/

//Single overlay moody light
/atom/proc/update_moody_light(var/moody_icon = 'icons/lighting/moody_lights.dmi', var/moody_state = "white", var/moody_alpha = 255, var/moody_color = "#ffffff", var/offX = 0, var/offY = 0, var/dir_override = 0)
	overlays -= moody_light
	var/area/here = get_area(src)
	if (here && here.dynamic_lighting)
		moody_light = image(moody_icon, src, moody_state, LIGHTING_LAYER, dir_override)
		moody_light.appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
		moody_light.plane = LIGHTING_PLANE
		moody_light.blend_mode = BLEND_ADD
		moody_light.alpha = moody_alpha
		moody_light.color = moody_color
		moody_light.pixel_x = offX
		moody_light.pixel_y = offY
		if (dir_override)
			moody_light.dir = dir_override
		overlays += moody_light
	luminosity = max(luminosity, 2)

/atom/proc/kill_moody_light()
	overlays -= moody_light
	luminosity = initial(luminosity)
	moody_light = null

//Multi-overlay moody lights. don't combine both procs on a single atom, use one or the other.
/atom/proc/update_moody_light_index(var/index, var/moody_icon = 'icons/lighting/moody_lights.dmi', var/moody_state = "white", var/moody_alpha = 255, var/moody_color = "#ffffff", var/offX = 0, var/offY = 0, var/image_override = null, var/dir_override = 0)
	if (!index)
		return
	if (isnull(moody_lights))
		moody_lights = list()
	if (index in moody_lights)
		overlays -= moody_lights[index]
	var/area/here = get_area(src)
	if (here && here.dynamic_lighting)
		if (image_override)
			moody_light = image_override
		else
			moody_light = image(moody_icon, src, moody_state, LIGHTING_LAYER, dir_override)
		moody_light.appearance_flags |= RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
		moody_light.plane = LIGHTING_PLANE
		moody_light.blend_mode = BLEND_ADD
		moody_light.alpha = moody_alpha
		moody_light.color = moody_color
		moody_light.pixel_x = offX
		moody_light.pixel_y = offY
		moody_lights[index] = moody_light
		overlays += moody_lights[index]
	luminosity = max(luminosity, 2)

/atom/proc/kill_moody_light_index(var/index)
	if (isnull(moody_lights))
		moody_lights = list()
	if (!index || !(index in moody_lights))
		return
	overlays -= moody_lights[index]
	moody_lights.Remove(index)
	if (moody_lights.len <= 0)
		luminosity = initial(luminosity)

/atom/proc/kill_moody_light_all()
	if (isnull(moody_lights))
		moody_lights = list()
	for (var/i in moody_lights)
		overlays -= moody_lights[i]
		moody_lights.Remove(i)
	luminosity = initial(luminosity)
