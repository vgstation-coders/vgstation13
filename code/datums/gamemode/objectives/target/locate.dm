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
		var/type = pick(potential_objects)
		var/atom/pick = new type
		objects_to_locate.Add(pick)
		potential_objects.Remove(type)
	explanation_text = format_explanation()
	return TRUE

/datum/objective/target/locate/format_explanation()
	var/explanation = "Locate "
	if(objects_to_locate.len)
		explanation += "[counted_english_list(objects_to_locate)] using your chronocapture device."
	else
		explanation = "No items to locate."
	return explanation

/datum/objective/target/locate/proc/check(var/list/objects)
	for(var/atom/A in objects_to_locate)
		if(locate(A) in objects)
			to_chat(owner.current, "<span class='notice'>[capitalize(initial(A.name))] located.</span>")
			objects_to_locate.Remove(A)
			if(objects_to_locate.len)
				to_chat(owner.current, "<span class='notice'>Remaining items to locate: [capitalize(counted_english_list(objects_to_locate))].</span>")
			else
				to_chat(owner.current, "<span class='notice'>All items located!</span>")
	IsFulfilled()
