/datum/objective/target/locate
	name = "locate objects"
	var/list/objects_to_locate = list()

/datum/objective/target/locate/IsFulfilled()
	.=..()
	if(objects_to_locate.len)
		return FALSE
	return TRUE

/datum/objective/target/locate/random/find_target()
	var/list/potential_objects = list(/obj/item/weapon/bikehorn/rubberducky,
			/obj/item/weapon/hand_tele,
			/obj/item/weapon/gun/energy/laser/captain,
			/obj/item/weapon/disk/nuclear,
			/obj/item/weapon/reagent_containers/glass/bucket,
			)
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
				var/obj/item/I = i
				if(objects_to_locate[i] != objects_to_locate[objects_to_locate.len-1])
					explanation += "a [initial(I.name)], "
				else
					explanation += "& a [initial(I.name)]."
		else
			var/obj/item/I = objects_to_locate[1]
			explanation += " a [initial(I.name)]."
	else
		explanation = "All items located."
	return explanation

/datum/objective/target/locate/proc/check(var/list/objects)
	for(var/A in objects_to_locate)
		if(is_type_in_list(A, objects))
			var/atom/thing = A
			to_chat(owner.current, "[initial(thing.name)] located.")
			objects_to_locate.Remove(A)
	explanation_text = format_explanation()
	IsFulfilled()