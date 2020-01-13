/datum/map_persistence_type/gibs
	name = SS_GIBS
	tracked_types = list(/obj/effect/decal/cleanable/blood/gibs)
	filth = TRUE

/datum/map_persistence_type/gibs/canTrack(var/obj/effect/decal/cleanable/blood/gibs/G)
	if(!G.persistence_type)
		return FALSE
	return ..()

/datum/map_persistence_type/gibs/create(var/turf/T, var/list/L)
	var/type = text2path(L["type"])
	var/atom/created = new type(T, L["age"], L["icon_state"], L["color"], L["dir"], L["pixel_x"], L["pixel_y"], L["basecolor"], L["fleshcolor"])
	created.post_mapsave2atom(L)
	return created