/datum/shuttle/research
	name = "research shuttle"
	can_link_to_computer = LINK_FREE
	req_access = list(access_science)
	linked_area = /area/shuttle/research/station

/datum/shuttle/research/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/research/station)
	add_dock(/obj/docking_port/destination/research/outpost)
	outpost_shuttles |= src

/obj/machinery/computer/shuttle_control/research //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	shuttle = /datum/shuttle/research

//code/game/objects/structures/docking_port.dm
/obj/docking_port/destination/research/station
	areaname = "main research department"
	shuttle_type = /datum/shuttle/research

/obj/docking_port/destination/research/outpost
	areaname = "research outpost"
