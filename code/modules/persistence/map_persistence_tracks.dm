/datum/map_persistence_type/tracks
	name = SS_TRACKS
	tracked_types = list(/obj/effect/decal/cleanable/blood/tracks)
	filth = TRUE

/datum/map_persistence_type/tracks/canTrack(var/obj/effect/decal/cleanable/blood/tracks/T)
	if(!T.persistence_type)
		return FALSE
	return ..()

/datum/map_persistence_type/tracks/create(var/turf/T, var/list/L)
	var/type = text2path(L["type"])
	var/atom/created = new type(T, L["age"], L["icon_state"], L["color"], L["dir"], L["pixel_x"], L["pixel_y"], L["basecolor"], L["steps_to_remake"])
	created.post_mapsave2atom(L)
	return created