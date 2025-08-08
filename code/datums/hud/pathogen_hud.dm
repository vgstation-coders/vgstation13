//Disease Vision!

var/list/science_goggles_wearers = list()

/datum/visioneffect/pathogen
	name = "pathogen hud"

/datum/visioneffect/pathogen/on_apply(var/mob/M)
	..()
	if(!M.client)
		return
	science_goggles_wearers.Add(M)
	for (var/obj/item/I in infected_items)
		if (I.pathogen)
			M.client.images |= I.pathogen
	for (var/mob/living/L in infected_contact_mobs)
		if (L.pathogen)
			M.client.images |= L.pathogen
	for (var/obj/effect/pathogen_cloud/C in pathogen_clouds)
		if (C.pathogen)
			M.client.images |= C.pathogen
	for (var/obj/effect/decal/cleanable/C in infected_cleanables)
		if (C.pathogen)
			M.client.images |= C.pathogen

/datum/visioneffect/pathogen/process_hud(var/mob/M)
	..()
	M.overlay_fullscreen("science", /obj/abstract/screen/fullscreen/science)

/datum/visioneffect/pathogen/on_remove(var/mob/M)
	..()
	if(!M.client)
		return
	science_goggles_wearers.Remove(M)
	for (var/obj/item/I in infected_items)
		M.client.images -= I.pathogen
	for (var/mob/living/L in infected_contact_mobs)
		M.client.images -= L.pathogen
	for (var/obj/effect/pathogen_cloud/C in pathogen_clouds)
		M.client.images -= C.pathogen
	for (var/obj/effect/decal/cleanable/C in infected_cleanables)
		M.client.images -= C.pathogen
	M.clear_fullscreen("science",0)
