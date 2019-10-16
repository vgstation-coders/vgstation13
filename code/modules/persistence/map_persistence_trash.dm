/datum/map_persistence_type/trash
	name = SS_TRASH
	tracked_types = list(/obj/item/trash)
	filth = TRUE

/datum/map_persistence_type/trash/canTrack(var/obj/item/trash/T)
	if(!T.persistence_type)
		return FALSE
	return ..()

/datum/map_persistence_type/trash/create(var/turf/T, var/list/L)
	var/type = text2path(L["type"])
	var/atom/created = new type(T, L["age"], L["icon_state"], L["color"], L["dir"], L["pixel_x"], L["pixel_y"])
	created.post_mapsave2atom(L)
	return created