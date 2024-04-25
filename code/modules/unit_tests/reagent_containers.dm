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
		var/list/to_add = RC.reagents_to_add
		if(!islist(RC.reagents_to_add))
			to_add = list(RC.reagents_to_add)
		var/total_volume = 0
		for(var/entry in to_add)
			if(!chemical_reagents_list[entry])
				fail("Reagent ID [entry] is not a valid reagent.")
			var/volume
			if(islist(to_add[entry]) && ("volume" in to_add[entry]))
				volume = to_add[entry]["volume"]
			else if(isnum(to_add[entry]))
				volume = to_add[entry]
			else
				volume = (RC.volume/to_add.len)
			total_volume += volume
			if(!RC.reagents.has_reagent(entry, volume))
				fail("Reagent ID [entry] from reagents_to_add not found in at least [volume] units in atom [RC]]. (got [RC.reagents.get_reagent_amount(entry)] units instead)")
			if(islist(to_add[entry]) && ("data" in to_add[entry]))
				var/list/list1 = to_add[entry]["data"]
				var/list/list2 = RC.reagents.get_data(entry)
				for(var/subentry in list1)
					if(islist(list1[subentry]))
						continue // for now
					if(list1[subentry] != list2[subentry])
						fail("Reagent ID [entry] has mismatching data in atom [RC]. (expected [list1[subentry]] on [subentry], got [list2[subentry]])")
			if(total_volume > RC.volume)
				fail("Reagents being added on [RC] exceeds volume capacity of [RC.volume] (got [total_volume] in total)")
	else
		fail("[RC] could not create a reagents holder.")
