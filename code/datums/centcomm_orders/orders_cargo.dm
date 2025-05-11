
/datum/centcomm_order/per_unit/plasma//Centcom always wants plasma
	name = "Nanotrasen"
	worth = "1$ per sheet"
	silent = 1//so we don't hear the announcement at every round start
	requested = list(
		/obj/item/stack/sheet/mineral/plasma = INFINITY
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/plasma = VALUE_PLASMA * 2
	)

/datum/centcomm_order/per_unit/plasma/CheckShuttleObject(var/obj/O, var/in_crate)
	if(!in_crate)
		return 0
	if(!O)
		return 0
	if(istype(O, /obj/item/stack/sheet/mineral/plasma))
		var/obj/item/stack/sheet/mineral/plasma/P = O
		if(!(O.type in left_to_check))
			left_to_check[O.type] = 0
		left_to_check[O.type] += P.amount
		score.plasmashipped += P.amount
		qdel(O)
		return 1
	return 0


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//                                            MINING ORDERS                                                 //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//6 orders

/datum/centcomm_order/per_unit/department/cargo
	name = "Nanotrasen Industries Inc."
	acct_by_string = "Cargo"
	request_consoles_to_notify = list(
		"Cargo Bay",
		)

/datum/centcomm_order/per_unit/department/cargo/diamonds/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/diamond = rand (8,12)
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/diamond = VALUE_DIAMOND * 3
	)
	worth = "[VALUE_DIAMOND+3]$ per sheet"

/datum/centcomm_order/per_unit/department/cargo/uranium/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/uranium = rand (40,60)
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/uranium = VALUE_URANIUM * 3
	)
	worth = "[VALUE_URANIUM*3]$ per sheet"

/datum/centcomm_order/per_unit/department/cargo/gold/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/gold = rand (40,60)
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/gold = VALUE_GOLD * 3
	)
	worth = "[VALUE_GOLD*3]$ per sheet"

/datum/centcomm_order/per_unit/department/cargo/silver/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/silver = rand (40,60)
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/silver = VALUE_SILVER * 3
	)
	worth = "[VALUE_SILVER*3]$ per sheet"

/datum/centcomm_order/per_unit/department/cargo/phazon/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/phazon = rand (8,12)
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/phazon = VALUE_PHAZON * 3
	)
	worth = "[VALUE_PHAZON*3]$ per sheet"

/datum/centcomm_order/per_unit/department/cargo/clown/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/clown = rand (8,12)
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/clown = VALUE_CLOWN * 3
	)
	worth = "[VALUE_CLOWN*3]$ per sheet"
