var/global/datum/shuttle/mining/mining_shuttle = new

/datum/shuttle/mining
	can_link_to_computer = LINK_FREE

/datum/shuttle/mining/New()
	.=..()
	setup_everything(starting_area = /area/shuttle/mining/station, \
		all_areas=list(/area/shuttle/mining/station, /area/shuttle/mining/outpost), \
		name = "mining shuttle")

/obj/machinery/computer/shuttle_control/mining/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(mining_shuttle)
	.=..()
