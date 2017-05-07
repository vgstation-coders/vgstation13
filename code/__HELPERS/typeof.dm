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
