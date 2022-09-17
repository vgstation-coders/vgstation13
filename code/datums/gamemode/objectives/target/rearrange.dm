/datum/objective/target/locate/rearrange
	name = "rearrange object"
	var/area/destination
	var/list/objects_in_area = list()
	object_min = 1
	object_max = 1

/datum/objective/target/locate/rearrange/format_explanation()
	if(objects_to_locate.len)
		return "Move [counted_english_list(objects_to_locate)] to [initial(destination.name)]."
	else
		return "No items to move."

/datum/objective/target/locate/rearrange/find_target()
	destination = pick(the_station_areas - /area/solar)
	..()
	return TRUE

/datum/objective/target/locate/rearrange/check(var/list/objects)
	for(var/atom/A in objects_in_area) // First check, to make sure any objects that used to be in the area don't count as being in it anymore.
		if(!istype(get_area(A), destination))
			objects_in_area.Remove(A)
	for(var/atom/A in objects)
		// (Have to do it this way to prevent list cache being made and including redundant subtypes, and also to check supertypes)
		for(var/type in objects_to_locate)
			if(istype(A,type) && istype(get_area(A), destination) && !(locate(A) in objects_in_area)) // Second, to add anything new
				objects_in_area.Add(A)
		if(!(locate(A) in objects_in_area)) // Third, once this is all done, check all objects we need in the area, if one isn't there, break out, we aren't done.
			return
	objects_to_locate.Cut() // If done, wipe the list so IsFulfilled() works on super calls, we got everything.
	to_chat(owner.current, "<span class='notice'>All items moved to [initial(destination.name)].</span>")
	IsFulfilled()
