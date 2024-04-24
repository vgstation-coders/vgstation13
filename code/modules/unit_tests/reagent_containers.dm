/datum/unit_test/reagent_containers/start()
	var/obj/item/weapon/reagent_containers/RC
	for(var/type in subtypesof(/obj/item/weapon/reagent_containers))
		RC = type
		if(isnull(initial(RC.reagents_to_add)))
			continue
		RC = new type
		if(RC.reagents)
			var/list/info = list()
			for(var/datum/reagent/R in RC.reagents)
				info += list(R.id = R.volume)
			for(var/entry in info)
				if(!RC.reagents.has_reagent(entry, info[entry]))
					fail("Reagent ID [entry] from reagents_to_add not found in at least [info[entry]] units in atom [RC]]")
		qdel(RC)
