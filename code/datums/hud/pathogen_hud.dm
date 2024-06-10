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
	if(M.get_item_by_slot(slot_glasses))
		var/obj/item/clothing/glasses/MS = M.get_item_by_slot(slot_glasses) //State: 0:off, 1:purple overlay + virus scan, 2:no overlay + virus scan
		if((MS.multiple_states == 1) || (!initial(MS.multiple_states)))
			M.overlay_fullscreen("science", /obj/abstract/screen/fullscreen/science)
		else
			M.clear_fullscreen("science",0)

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
