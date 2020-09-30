/datum/unit_test/reagent_ids/start()
	var/list/id_to_reagents = list()
	for(var/john in subtypesof(/datum/reagent))
		var/datum/reagent/reagent_path = john
		var/id = initial(reagent_path.id)
		if(id == EXPLICITLY_INVALID_REAGENT_ID)
			// If the id is invalid and the parent of the type also has an
			// invalid id, we assume this is a mistake.
			// This currently only works for one level of inheritance.
			// If you need more nested types with invalid IDs,
			// figure out how to change this test. :^)
			var/datum/reagent/parent_type = type2parent(reagent_path)
			if(ispath(parent_type, /datum/reagent) && initial(parent_type.id) == EXPLICITLY_INVALID_REAGENT_ID)
				fail("[reagent_path] does not specify an ID")
			continue
		if(id_to_reagents[id])
			id_to_reagents[id] += reagent_path
		else
			id_to_reagents[id] = list(reagent_path)

	for(var/id in id_to_reagents)
		var/list/reagents = id_to_reagents[id]
		if(reagents.len != 1)
			fail("Reagent ID [id] is used by more than one type: [json_encode(reagents)]")
