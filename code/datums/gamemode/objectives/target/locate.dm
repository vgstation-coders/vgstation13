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

var/list/potential_locate_objects = list(/obj/item/weapon/bikehorn/rubberducky,
	/obj/item/weapon/hand_tele,
	/obj/item/weapon/gun/energy/laser/captain,
	/obj/item/weapon/aiModule/freeform/core,
	/obj/item/weapon/gun/lawgiver,
	/obj/machinery/computer/aiupload/longrange,
	/obj/item/clothing/gloves/yellow,
	/obj/item/weapon/reagent_containers/hypospray,
	/obj/item/weapon/disk/nuclear,
	/obj/item/weapon/reagent_containers/glass/bucket,
)

/datum/objective/target/locate/find_target()
	var/list/potential_objects = shuffle(potential_locate_objects)
	var/min = object_min - 1
	var/max = (object_max >= object_min) ? object_max : (potential_objects.len-1)
	for(var/i = 0 to rand(min,max))
		var/type = pick(potential_objects)
		objects_to_locate.Add(type)
		potential_objects.Remove(type)
	explanation_text = format_explanation()
	return TRUE

/datum/objective/target/locate/format_explanation()
	if(objects_to_locate.len)
		return "Locate [counted_english_list(objects_to_locate)] using your chronocapture device."
	return "No items to locate."

/datum/objective/target/locate/proc/check(var/list/objects)
	for(var/atom/A in objects)
		// Have to do it this way to prevent list cache being made and including redundant subtypes, and also to check supertypes
		for(var/type in objects_to_locate)
			if(istype(A,type))
				to_chat(owner.current, "<span class='notice'>[capitalize(initial(A.name))] located.</span>")
				objects_to_locate.Remove(A.type)
				if(objects_to_locate.len)
					to_chat(owner.current, "<span class='notice'>Remaining items to locate: [capitalize(counted_english_list(objects_to_locate))].</span>")
				else
					to_chat(owner.current, "<span class='notice'>All items located!</span>")
	IsFulfilled()
