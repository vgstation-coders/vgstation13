/datum/objective/target/locate
	name = "locate objects"
	var/list/objects_to_locate()

/datum/objective/target/locate/IsFulfilled()
	.=..()
	if(objects_to_locate.len)
		return FALSE
	return TRUE

/datum/objective/targetlocate/random/get_targets()
	for(var/i = 0 to rand(3,6))
		objects_to_locate.Add(pick(
			/obj/item/weapon/bikehorn/rubberducky))

/datum/objective/target/locate/proc/check(var/list/objects)
	for(var/atom/A in objects)
		if(is_type_in_list(A, objects_to_locate))
			objects_to_locate.Remove(A.type)

	IsFulfilled()