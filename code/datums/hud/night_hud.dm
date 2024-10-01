//Nightvision HUD

/datum/visioneffect/night
	name = "nightvision hud"
	see_invisible = 0
	see_in_dark = 8
	eyeprot = -1
	my_dark_plane_alpha_override = "night_vision"
	my_dark_plane_alpha_override_value = null

/datum/visioneffect/night/on_apply(var/mob/M)
	..()
	if(!M.client)
		return
	M.client.color = "#33FF33"
	if (M.master_plane)
		M.master_plane.blend_mode = BLEND_ADD
	M.update_perception()
	M.update_darkness()
	M.check_dark_vision()

/datum/visioneffect/night/process_update_perception(var/mob/M)
	..()
	if (M.master_plane)
		M.master_plane.blend_mode = BLEND_ADD

/datum/visioneffect/night/on_remove(var/mob/M)
	..()
	if(!M.client)
		return
	M.client.color = null
	if (M.master_plane)
		M.master_plane.blend_mode = BLEND_MULTIPLY
	M.update_perception()
	M.update_darkness()
	M.check_dark_vision()
