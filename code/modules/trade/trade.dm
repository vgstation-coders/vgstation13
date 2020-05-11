/datum/trade
	var/list/items
	var/list/reagents
	var/reward

/datum/trade/proc/check_items(var/obj/structure/closet/crate/C)
	var/list/needs = items.Copy()

	for(var/obj/O in C.contents)
		for(var/type in needs)
			if(istype(O, type))
				needs -= type

	if(needs.len > 0)
		return 0

	return 1

/datum/trade/check_reagents(var/obj/structure/closet/crate/C)
	var/list/needs = reagents.Copy()

	for (var/obj/item/weapon/reagent_containers/I in get_contents_in_object(C, /obj/item/weapon/reagent_containers))
		var/datum/reagents/R = I.reagents
		for(var/reagent_type in needs)
			var/reagent_amount = R.get_reagent_amount()
			needs[reagent_type] = max(0, needs[reagent_type] - reagent_amount)

	for(var/reagent_type in needs)
		if(needs[reagent_type] > 0)
			return 0

	return 1
