/datum/map_persistence_type/blood
	name = SS_BLOOD
	tracked_types = list(/obj/effect/decal/cleanable/blood)
	filth = TRUE

/datum/map_persistence_type/blood/canTrack(var/obj/effect/decal/cleanable/blood/B)
	if(!B.persistence_type)
		return FALSE
	return ..()

/datum/map_persistence_type/blood/create(var/turf/T, var/list/L)
	var/type = text2path(L["type"])
	var/atom/created = new type(T, L["age"], L["icon_state"], L["color"], L["dir"], L["pixel_x"], L["pixel_y"], L["basecolor"])
	created.post_mapsave2atom(L)
	return created