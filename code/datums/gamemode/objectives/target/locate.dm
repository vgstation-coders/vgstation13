/datum/objective/target/locate
	name = "locate objects"
	var/list/objects_to_locate = list() //Formatted as String(name) = Path
	var/object_min = 3
	var/object_max = -1

/datum/objective/target/locate/IsFulfilled()
	.=..()
	if(objects_to_locate.len)
		return FALSE
	return TRUE

/datum/objective/target/locate/find_target()
	var/list/potential_objects = list(/obj/item/weapon/bikehorn/rubberducky,
			/obj/item/weapon/hand_tele,
			/obj/item/weapon/gun/energy/laser/captain,
			/obj/item/weapon/aiModule/freeform/core,
			/obj/item/weapon/gun/lawgiver,
			/obj/item/weapon/circuitboard/aiupload,
			/obj/item/clothing/gloves/yellow,
			/obj/item/weapon/reagent_containers/hypospray,
			/obj/item/weapon/disk/nuclear,
			/obj/item/weapon/reagent_containers/glass/bucket,
			)
	potential_objects = shuffle(potential_objects)
	var/min = object_min - 1
	var/max = (object_max >= object_min) ? object_max : (potential_objects.len-1)
	for(var/i = 0 to rand(min,max))
		var/pick = pick(potential_objects)
		objects_to_locate.Add(pick)
		objects_to_locate[pick] = potential_objects[pick]
		potential_objects.Remove(pick)
	explanation_text = format_explanation()
	return TRUE

/datum/objective/target/locate/format_explanation()
	var/explanation = "Locate "
	if(objects_to_locate.len)
		if(objects_to_locate.len > 1)
			for(var/obj/i in objects_to_locate)
				var/name = initial(i.name)
				if(i != objects_to_locate[objects_to_locate.len])
					explanation += "\an [name], "
				else
					explanation += "& \an [name]."
		else
			explanation += "\an [objects_to_locate[1]]."
	else
		explanation = "All items located."
	return explanation

/datum/objective/target/locate/proc/check(var/list/objects)
	for(var/A in objects_to_locate)
		if(is_type_in_list(objects_to_locate[A], objects))
			var/atom/thing = objects_to_locate[A]
			to_chat(owner.current, "[initial(thing.name)] located.")
			objects_to_locate.Remove(A)
	explanation_text = format_explanation()
	IsFulfilled()
