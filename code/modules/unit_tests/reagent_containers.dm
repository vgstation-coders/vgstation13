/datum/unit_test/reagent_containers/start()
	var/obj/item/weapon/reagent_containers/RC
	for(var/type in subtypesof(/obj/item/weapon/reagent_containers))
		RC = type
		if(isnull(initial(RC.reagents_to_add)))
			continue
		RC = new type
		if(RC.reagents)
			for(var/entry in reagents_to_add)
				var/volume
				if(islist(reagents_to_add[entry]) && ("volume" in reagents_to_add[entry]))
					var/volume = reagents_to_add[entry]["volume"]
				else
					var/volume = reagents_to_add[entry]
				if(!RC.reagents.has_reagent(entry, reagents_to_add[entry]))
					fail("Reagent ID [entry] from reagents_to_add not found in at least [info[entry]] units in atom [RC]]")
		qdel(RC)
