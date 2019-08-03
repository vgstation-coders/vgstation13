/datum/map_persistence_type/cleanable
	name = SS_CLEANABLE
	tracked_types = list(/obj/effect/decal/cleanable)
	filth = TRUE

/datum/map_persistence_type/cleanable/canTrack(var/obj/effect/decal/cleanable/C)
	if(!C.persistence_type)
		return FALSE
	return ..()

/datum/map_persistence_type/cleanable/create(var/turf/T, var/list/L)
	var/type = text2path(L["type"])
	var/atom/created = new type(T, L["age"], L["icon_state"], L["color"], L["dir"], L["pixel_x"], L["pixel_y"])
	created.post_mapsave2atom(L)
	return created