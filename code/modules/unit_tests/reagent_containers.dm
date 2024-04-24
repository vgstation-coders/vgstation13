/datum/unit_test/reagent_containers/start()
	var/obj/item/weapon/reagent_containers/RC
	for(var/type in subtypesof(/obj/item/weapon/reagent_containers))
		RC = type
		if(isnull(initial(RC.reagents_to_add)))
			continue
		RC = new type
		if(RC.reagents)
			for(var/datum/reagent/R in RC.reagents)
				if(!(reagents_to_add == R.id || (R.id in reagents_to_add)))
					fail("Reagent ID [id] is not in the reagents_to_add list on [RC]")
