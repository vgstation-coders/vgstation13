//Refer to game/centcomm_orders.dm

/datum/event/centcomm_order

/datum/event/centcomm_order/can_start()
	return 25

/datum/event/centcomm_order/start()
	//Who is it paying to
	var/choice
	var/department = pick("Cargo","Medical","Science","Civilian")
	switch(department)
		if("Cargo") //Minerals
			choice = pick(subtypesof(/datum/centcomm_order/department/cargo))
		if("Science") //Guns
			choice = pick(subtypesof(/datum/centcomm_order/department/science))
		if("Medical") //Stolen organs
			choice = pick(subtypesof(/datum/centcomm_order/department/medical))
		if("Civilian") //FOOD
			choice = pick(subtypesof(/datum/centcomm_order/department/civilian))
	SSsupply_shuttle.add_centcomm_order(new choice)