/datum/unit_test/reagent_containers/start()
	var/obj/item/weapon/reagent_containers/RC
	for(var/type in subtypesof(/obj/item/weapon/reagent_containers))
		RC = type
		if(isnull(initial(RC.reagents_to_add)))
			continue
		RC = new type
		if(RC.reagents)
			for(var/entry in RC.reagents_to_add)
				if(!chemical_reagents_list[entry])
					fail("Reagent ID [entry] is not a valid reagent.")
				var/volume
				if(islist(RC.reagents_to_add[entry]) && ("volume" in RC.reagents_to_add[entry]))
					volume = RC.reagents_to_add[entry]["volume"]
				else
					volume = RC.reagents_to_add[entry]
				if(!RC.reagents.has_reagent(entry, RC.reagents_to_add[entry]))
					fail("Reagent ID [entry] from reagents_to_add not found in at least [RC.reagents_to_add[entry]] units in atom [RC]]. (got [RC.reagents.get_reagent_amount(entry)] units instead)")
		qdel(RC)
