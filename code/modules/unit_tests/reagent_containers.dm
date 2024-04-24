/datum/unit_test/reagent_containers/start()
	var/obj/item/weapon/reagent_containers/RC
	for(var/type in subtypesof(/obj/item/weapon/reagent_containers))
		RC = type
		if(isnull(initial(RC.reagents_to_add)))
			continue
		RC = new type
		if(RC.reagents)
			for(var/entry in RC.reagents_to_add)
				var/volume
				if(islist(RC.reagents_to_add[entry]) && ("volume" in RC.reagents_to_add[entry]))
					var/volume = RC.reagents_to_add[entry]["volume"]
				else
					var/volume = RC.reagents_to_add[entry]
				if(!RC.reagents.has_reagent(entry, RC.reagents_to_add[entry]))
					fail("Reagent ID [entry] from reagents_to_add not found in at least [info[entry]] units in atom [RC]]")
		qdel(RC)
