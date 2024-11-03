//Original Station Vision

/datum/visioneffect/material
	name = "material hud"
	var/list/image/showing = list()

/datum/visioneffect/material/on_apply(var/mob/M)
	..()
	if(!M.client)
		return
	process_hud(M)

/datum/visioneffect/material/process_hud(var/mob/M)
	..()
	if(!M.client)
		return
	M.client.images -= showing
	showing = get_images(get_turf(M), M.client.view)
	M.client.images += showing

/datum/visioneffect/material/on_remove(var/mob/M)
	..()
	if(!M.client)
		return
	M.client.images -= showing
	showing.Cut()

/datum/visioneffect/material/proc/get_images(var/turf/T, var/view)
	. = list()
	for (var/turf/TT in trange(view, T))
		if (TT.holomap_data)
			. += TT.holomap_data
