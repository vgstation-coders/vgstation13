var/global/datum/shuttle/mining/mining_shuttle

/datum/shuttle/mining
	name = "mining shuttle"
	can_link_to_computer = LINK_FREE
	req_access = list(access_mining)
	linked_area = /area/shuttle/mining/station

/datum/shuttle/mining/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/mining/station)
	add_dock(/obj/docking_port/destination/mining/outpost)
	mining_shuttle = src

/obj/machinery/computer/shuttle_control/mining //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	shuttle = /datum/shuttle/mining

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/mining/station
	areaname = "mining dock"
	shuttle_type = /datum/shuttle/mining

/obj/docking_port/destination/mining/outpost
	areaname = "mining outpost"
