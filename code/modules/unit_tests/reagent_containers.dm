/datum/unit_test/reagent_containers/start()
	var/obj/item/weapon/reagent_containers/RC
	for(var/type in subtypesof(/obj/item/weapon/reagent_containers))
		RC = type
		if(isnull(initial(RC.reagents_to_add)))
			continue
		RC = new type
		if(!RC.gcDestroyed)
			check_container(RC)
			RC.refill()
			check_container(RC)
		qdel(RC)

/datum/unit_test/reagent_containers/proc/check_container(var/obj/item/weapon/reagent_containers/RC)
	if(RC.reagents)
		for(var/entry in RC.reagents_to_add)
			if(!chemical_reagents_list[entry])
				fail("Reagent ID [entry] is not a valid reagent.")
			var/volume
			if(islist(RC.reagents_to_add[entry]) && ("volume" in RC.reagents_to_add[entry]))
				volume = RC.reagents_to_add[entry]["volume"]
			else
				volume = RC.reagents_to_add[entry]
			if(!RC.reagents.has_reagent(entry, volume))
				fail("Reagent ID [entry] from reagents_to_add not found in at least [volume] units in atom [RC]]. (got [RC.reagents.get_reagent_amount(entry)] units instead)")
			if(islist(RC.reagents_to_add[entry]) && ("data" in RC.reagents_to_add[entry]))
				var/list/list1 = RC.reagents_to_add[entry]["data"]
				var/list/list2 = RC.reagents.get_data(entry)
				for(var/subentry in list1)
					if(islist(subentry1))
						continue // for now
					if(list1[subentry] != list2[subentry])
						fail("Reagent ID [entry] has mismatching data in atom [RC]. (expected [list1[subentry]] on [subentry], got [list2[subentry]])")
	else
		fail("[RC] could not create a reagents holder.")
