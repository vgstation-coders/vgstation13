var/global/list/matching_type_list_cache = list()

/proc/matching_type_list(object, parent_type = /atom)
	//Key string for the cache
	var/key = "[object]:[parent_type]"
	//Get cached list's copy if it exists
	var/list/cache = matching_type_list_cache[key]
	if(cache)
		return cache.Copy()

	var/list/matches = list()
	//The string is null or "" - no need for calculations
	if(!object || !length(object))
		return typesof(parent_type)

	if(text_ends_with(object, ".")) //Path ends with a dot - DO NOT include subtypes
		object = copytext(object, 1, length(object)) //Remove the dot

		for(var/path in typesof(parent_type))
			if(text_ends_with("[path]", object))
				matches += path
	else //Include subtypes
		for(var/path in typesof(/atom))
			if(findtext("[path]", object))
				matches += path

	matching_type_list_cache[key] = matches.Copy()

	return matches

var/global/list/get_vars_from_type_cache = list()

/proc/get_vars_from_type(T)
	if(ispath(T, /atom) && !ispath(T, /atom/movable))
		//It's impossible to spawn a turf or an area without a location
		//Attempting to proceed will result in a runtime error
		return null

	var/list/cache = get_vars_from_type_cache[T]
	if(cache)
		return cache.Copy()

	var/list/variable_list = list()

	var/datum/temp_datum = new T(null)

	for(var/variable in temp_datum.vars)
		variable_list.Add(variable)
	variable_list = sortList(variable_list) //Sort the variable list alphabetically
	get_vars_from_type_cache[T] = variable_list

	qdel(temp_datum)

	return variable_list

var/global/list/existing_typesof_cache = list()

//existing_typesof functions like typesof, with some differences
//1) it only works with pathes derived from /atom
//2) the returned list contains NO items without an icon state or an icon
//
//Intended to be used, for example, when you want to spawn a random monster or an item.
//picking a type from typesof(/mob/living/simple_animal/hostile) can output an abstract type like /mob/living/simple_animal/hostile/asteroid,
//resulting in an invisible monster.

//Values are cached, so when doing existing_typesof(/atom), all paths derived from /atom will only be checked on the first call
//All calls afterwards will return a copy of a list from the cache

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
