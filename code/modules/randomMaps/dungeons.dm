//DUNGEONS
//Map elements that can be loaded into the game with a single proc, without specifying coordinates or any arguments at all.
//They're loaded to unique virtual z-levels, sized accordingly

var/list/existing_dungeons = list()

/datum/map_element/dungeon
	//If TRUE, don't load any duplicates (subtypes are fine)
	//Note: When trying to load a duplicate, load_dungeon() will return a reference to the "original" dungeon datum, instead of a list of its objects
	var/unique = 0

//Load a map element into its own virtual z-level
//You can pass a map element object, or a map element path (like /datum/map_element/meme)

//Returns list of loaded objects. If trying to load a duplicate dungeon (and it's forbidden), returns a reference to the "original" dungeon instead

/proc/load_dungeon(dungeon_type, var/rotate = 0, var/hidden = FALSE, var/teleporters = TRUE)
	var/datum/map_element/ME
	if(ispath(dungeon_type, /datum/map_element))
		ME = new dungeon_type
	else if(istype(dungeon_type, /datum/map_element))
		ME = dungeon_type
	else
		return 0

	var/datum/map_element/dungeon/D = ME
	if(istype(D) && D.unique)
		//Check if this exact dungeon already exists
		for(var/datum/map_element/dungeon/dungeon in existing_dungeons)
			if(dungeon.type == ME.type)
				return dungeon

	if(!ME.width) //If the map element doesn't have its width/height calculated yet, do it now and add the map element to the dungeon list
		ME.assign_dimensions()
	existing_dungeons.Add(ME) //Add it now, to prevent issues occuring when two dungeons are loaded at once

	var/datum/virtual_z/used_vz = map.addMapElementVLevel(ME, rotation = rotate, buffer_size = 0, system = hidden)

	var/result = ME.load(used_vz.x_min - 1, used_vz.y_min - 1, used_vz.parent_z.z, rotate)

	if(teleporters)
		for(var/turf/T in block_borders(locate(used_vz.x_min, used_vz.y_min,used_vz.parent_z.z), locate(used_vz.x_max, used_vz.y_max, used_vz.parent_z.z)))
			new /obj/effect/step_trigger/teleporter/random/shuttle_transit(T)

	return result
