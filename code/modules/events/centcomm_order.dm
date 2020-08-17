//Refer to game/centcomm_orders.dm

/datum/event/centcomm_order

/datum/event/centcomm_order/can_start()
	return 25

/datum/event/centcomm_order/start()
	create_random_order()