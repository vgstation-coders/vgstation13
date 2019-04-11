/datum/objective/target/locate
	name = "locate objects"
	var/list/objects_to_locate = list() //Formatted as String(name) = Path

/datum/objective/target/locate/IsFulfilled()
	.=..()
	if(objects_to_locate.len)
		return FALSE
	return TRUE

/datum/objective/target/locate/random/find_target()
	var/list/potential_objects = list("rubber duck" = /obj/item/weapon/bikehorn/rubberducky,
			"hand teleporter" = /obj/item/weapon/hand_tele,
			"captains laser pistol" = /obj/item/weapon/gun/energy/laser/captain,
			"nuclear authentication disk" = /obj/item/weapon/disk/nuclear,
			"bucket" = /obj/item/weapon/reagent_containers/glass/bucket,
			)
	potential_objects = shuffle(potential_objects)
	for(var/i = 0 to rand(3,potential_objects.len-1))
		var/pick = pick(potential_objects)
		objects_to_locate.Add(pick)
		potential_objects.Remove(pick)
	explanation_text = format_explanation()
	return TRUE

/datum/objective/target/locate/format_explanation()
	var/explanation = "Locate "
	if(objects_to_locate.len)
		if(objects_to_locate.len > 1)
			for(var/i in objects_to_locate)
				if(objects_to_locate[i] != objects_to_locate[objects_to_locate.len])
					explanation += "a [objects_to_locate[i]], "
				else
					explanation += "& a [objects_to_locate[i]]."
		else
			explanation += "a [objects_to_locate[1]]."
	else
		explanation = "All items located."
	return explanation

/datum/objective/target/locate/proc/check(var/list/objects)
	for(var/A in objects_to_locate)
		if(is_type_in_list(objects_to_locate[A], objects))
			var/atom/thing = A
			to_chat(owner.current, "[initial(thing.name)] located.")
			objects_to_locate.Remove(A)
	explanation_text = format_explanation()
	IsFulfilled()