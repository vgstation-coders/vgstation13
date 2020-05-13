/datum/trade
	var/list/items = list()
	var/list/reagents = list()
	var/reward = 0
	var/display = list()
	var/id

/datum/trade/proc/check(var/obj/structure/closet/crate/C)
	var/have_items = 1
	var/have_reagents = 1
	if(items)
		have_items = check_items(C)
	if(reagents)
		have_reagents = check_reagents(C)
	return (have_items && have_reagents)

/datum/trade/proc/check_items(var/obj/structure/closet/crate/C)
	var/list/needs = items.Copy()

	for(var/obj/O in C.contents)
		for(var/type in needs)
			if(istype(O, type))
				needs[type] -= 1

	for(var/type in needs)
		if(needs[type] > 0)
			return 0

	return 1

/datum/trade/proc/check_reagents(var/obj/structure/closet/crate/C)
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
