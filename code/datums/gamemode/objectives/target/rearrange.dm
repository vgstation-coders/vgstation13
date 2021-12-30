/datum/objective/target/locate/rearrange
	name = "rearrange object"
	var/area/destination
	obj_min = 1
	obj_max = 1

/datum/objective/target/locate/rearrange/format_explanation()
	if(objects_to_locate.len)
		return "Move [counted_english_list(objects_to_locate)] to [destination.name]."
	else
		return "No items to move."

/datum/objective/target/locate/rearrange/find_target()
	destination = pick(the_station_areas - /area/solar)
	..()
	return TRUE

/datum/objective/target/locate/rearrange/check(var/list/objects)
	for(var/atom/A in objects_to_locate)
		if(locate(A) in objects)
			if(istype(get_area(A), destination)
				objects_to_locate.Remove(A)
	if(!objects_to_locate.len)
		to_chat(owner.current, "<span class='notice'>All items moved to [destination.name].</span>")
	IsFulfilled()
