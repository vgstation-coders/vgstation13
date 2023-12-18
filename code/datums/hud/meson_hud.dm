//Mesons HUD
var/list/meson_wearers = list()
var/list/meson_images = list()

/datum/visioneffect/meson
	name = "mesons hud"
	vision_flags = SEE_TURFS
	see_invisible = SEE_INVISIBLE_MINIMUM
	eyeprot = -1
	my_dark_plane_alpha_override = "mesons"
	my_dark_plane_alpha_override_value = 255

/datum/visioneffect/meson/on_apply(var/mob/M)
	..()
	if(!M.client)
		return
	meson_wearers += M
	M.client.images += meson_images
	M.seedarkness = FALSE
	M.update_darkness()
	M.handle_regular_hud_updates()
//	M.update_perception()

/datum/visioneffect/meson/on_remove(var/mob/M)
	..()
	if(!M.client)
		return
	meson_wearers -= M
	M.client.images -= meson_images
	if(M.dark_plane)
		M.dark_plane.alphas -= "mesons"
	M.seedarkness = TRUE
	M.update_darkness()
	M.handle_regular_hud_updates()
//	M.update_perception()

/atom/movable
	var/image/meson_image
	var/is_on_mesons = FALSE

/atom/movable/New()
	..()
	if(is_on_mesons)
		update_meson_image()

/atom/movable/Destroy()
	if(meson_image)
		for (var/mob/L in meson_wearers)
			if (L.client)
				L.client.images -= meson_image
		meson_images -= meson_image
	..()

/atom/movable/proc/update_meson_image()
	for (var/mob/L in meson_wearers)
		if (L.client)
			L.client.images -= meson_image
	meson_images -= meson_image
	if(is_on_mesons)
		meson_image = image(icon,loc,icon_state,layer,dir)
		meson_image.plane = relative_plane_to_plane(plane, loc.plane)
		meson_images += meson_image
		for (var/mob/L in meson_wearers)
			if (L.client)
				L.client.images |= meson_image
