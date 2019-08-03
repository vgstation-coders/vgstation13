//Returns a list of types derived from [parent_type], that contain the substring [partial_name]
//If the substring ends with a dot, only functions that END with the substring are returned
var/global/list/get_matching_types_cache = list()
/proc/get_matching_types(partial_name, parent_type = /atom)
	//Key string for the cache
	var/key = "[partial_name]:[parent_type]"
	//Get cached list's copy if it exists
	var/list/cache = get_matching_types_cache[key]
	if(cache)
		return cache.Copy()

	var/list/matches = list()
	//The string is null or "" - no need for calculations
	if(!partial_name || !length(partial_name))
		return typesof(parent_type)

	if(text_ends_with(partial_name, ".")) //Path ends with a dot - DO NOT include subtypes
		partial_name = copytext(partial_name, 1, length(partial_name)) //Remove the dot

		for(var/path in typesof(parent_type))
			if(text_ends_with("[path]", partial_name))
				matches += path
	else //Include subtypes
		for(var/path in typesof(parent_type))
			if(findtext("[path]", partial_name))
				matches += path

	//Cache the result
	get_matching_types_cache[key] = matches.Copy()

	return matches

//Returns a list of variables of an object of type [object_type].
//Because it's impossible to access variables of a type, this proc creates a temporary datum, grabs its variables and deletes it, caching the result in a global list
//object_type CAN'T be a type of a turf (/turf) or an area (/area), because these datums can't be created in nullspace
var/global/list/get_vars_from_type_cache = list()
/proc/get_vars_from_type(object_type)
	if(ispath(object_type, /atom) && !ispath(object_type, /atom/movable))
		//Attempting to proceed will result in a runtime error
		return null

	var/list/cache = get_vars_from_type_cache[object_type]
	if(cache)
		return cache.Copy()

	var/list/variable_list = list()

	//Create a temporary datum in nullspace to access the variables
	var/datum/temp_datum = new object_type(null)

	for(var/variable in temp_datum.vars)
		variable_list.Add(variable)

	//Sort the variable list alphabetically
	variable_list = sortList(variable_list)
	//Cache the result
	get_vars_from_type_cache[object_type] = variable_list

	qdel(temp_datum)

	return variable_list

//existing_typesof functions like typesof, with some differences
//1) it only works with pathes derived from /atom
//2) the returned list contains NO items without an icon state or an icon
//
//Intended to be used, for example, when you want to spawn a random monster or an item.
//picking a type from typesof(/mob/living/simple_animal/hostile) can output an abstract type like /mob/living/simple_animal/hostile/asteroid,
//resulting in an invisible monster.

//Values are cached, so when doing existing_typesof(/atom), all paths derived from /atom will only be checked on the first call
//All calls with the same path afterwards will return a copy of a list from the cache
var/global/list/existing_typesof_cache = list()
/proc/existing_typesof(var/path)
	if(!ispath(path, /atom))
		return typesof(path)

	if(existing_typesof_cache[path])
		var/list/L = existing_typesof_cache[path]
		return L.Copy()

	var/list/L = typesof(path)

	for(var/checked_type in L) //Go through all types
		var/atom/A = checked_type

		if(!initial(A.icon) || !initial(A.icon_state)) //No icon or icon_state -> into the trash it goes
			L.Remove(checked_type)
			continue

		var/list/IS = icon_states(initial(A.icon))
		if(!(initial(A.icon_state) in IS)) //If icon_state is set, but doesn't exist in the icon -> hello trash can my old friend
			L.Remove(checked_type)
			continue

	existing_typesof_cache[path] = L.Copy()

	return L

//existing_typesof does not like lists, so...
/proc/existing_typesof_list(var/list/L)
	if(!islist(L))
		return

	var/list/existing_types = list()

	for(var/types in L)
		existing_types += existing_typesof(types)

	return existing_types
