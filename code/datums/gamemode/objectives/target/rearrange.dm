/datum/objective/target/locate/rearrange
	name = "rearrange object"
	var/area/destination
	obj_min = 1
	obj_max = 1

/datum/objective/target/locate/rearrange/format_explanation()
	var/explanation = "Move "
	if(objects_to_locate.len)
		if(objects_to_locate.len > 1)
			for(var/i in objects_to_locate)
				if(i != objects_to_locate[objects_to_locate.len])
					explanation += "\an [i], "
				else
					explanation += "& \an [i]."
		else
			explanation += "\an [objects_to_locate[1]]."
		explanation += "to [destination.name]"
	else
		explanation = "Item moved."
	return explanation

/datum/objective/target/locate/rearrange/find_target()
	destination = pick(the_station_areas - /area/solar)
	..()
	return TRUE

/datum/objective/target/locate/rearrange/check(var/list/objects)
	for(var/A in objects_to_locate)
		if(is_type_in_list(objects_to_locate[A], objects))
			var/atom/thing = objects_to_locate[A]
			if(istype(thing.loc, destination)
				to_chat(owner.current, "[initial(thing.name)] moved.")
				objects_to_locate.Remove(A)
	explanation_text = format_explanation()
	IsFulfilled()
