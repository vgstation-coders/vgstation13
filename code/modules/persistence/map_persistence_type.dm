/datum/map_persistence_type
	var/name
	var/filename
	var/list/tracking = list()
	var/list/tracked_types = list()
	var/max_per_turf = 5
	var/max_age = 5
	var/saving = TRUE

/datum/map_persistence_type/New()
	setFilename()

/datum/map_persistence_type/proc/setFilename()
	filename = "data/persistence/map/[map.nameShort]_[src.name]"

/datum/map_persistence_type/proc/readSavefile()
	if(!fexists(filename))
		return
	for(var/L in json_decode(file2text(filename)))
		var/turf/T = locate(L["x"], L["y"], L["z"])
		if(!isValidTurf(T))
			continue
		create(T, L)

//Note: We save all items. Even if they're in space etc. Next round will be in charge of seeing if they're valid. I don't expect any significant performance loss from this, but if so, this can be changed easily.
/datum/map_persistence_type/proc/writeSavefile()
	if(!saving)
		return
	var/list/finished_list = list()
	for(var/atom/A in tracking)
		if(A.getPersistenceAge() >= max_age) //This used to be in canTrack() but I moved it here in case an admin varedits an atom's age or something.
			continue
		finished_list += list(A.atom2mapsave()) //list of a list because BYOND eats one list
	var/writing = file(filename)
	fdel(writing)
	writing << json_encode(finished_list)

/datum/map_persistence_type/proc/isValidTurf(var/turf/T)
	if(!isturf(T))
		return FALSE
	var/area/A = get_area(T)
	if(!A || isspace(A) || A.flags & NO_PERSISTENCE)
		return FALSE
	//if(T.z != map.zMainStation && T.z != map.zAsteroid)
	//	return FALSE
	if(T.density) //no blood in walls thank you
		return FALSE
	if(max_per_turf > 0)
		var/clutter = 0
		for(var/atom/thing in T)
			if(is_type_in_list(thing, tracked_types))
				clutter++
				if(clutter >= max_per_turf)
					return FALSE
	return TRUE

/datum/map_persistence_type/proc/canTrack(atom/A)
	if(!is_type_in_list(A, tracked_types))
		return FALSE
	return TRUE

/datum/map_persistence_type/proc/track(atom/A)
	if(canTrack(A))
		tracking |= A

/datum/map_persistence_type/proc/forget(atom/A)
	tracking -= A

//The following is provided only as an example and really should be overwritten for any children.
/datum/map_persistence_type/proc/create(var/turf/T, var/list/L)
	var/type = text2path(L["type"])
	var/atom/created = new type(T)
	created.setPersistenceAge(text2num(L["age"]) + 1)
	created.post_mapsave2atom(L)
	return created

/datum/map_persistence_type/proc/toggleSavingThisRound()
	saving = !saving

/datum/map_persistence_type/proc/qdelAllTrackedItems()
	for(var/atom/A in tracking)
		qdel(A)
