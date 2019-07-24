/obj/machinery/power/solar/panel/fake/New(loc) //This most likely shouldn't exist, but sure
	..(loc)
	var/datum/net_node/power/node = getNode(/datum/net_node/power)
	node.set_active(FALSE)


/obj/machinery/power/solar/panel/fake/process()
	return PROCESS_KILL
