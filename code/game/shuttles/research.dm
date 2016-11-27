var/global/datum/shuttle/research/research_shuttle = new(starting_area = /area/shuttle/research/station)

/datum/shuttle/research
	name = "research shuttle"
	can_link_to_computer = LINK_FREE
	req_access = list(access_science)

/datum/shuttle/research/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/research/station)
	add_dock(/obj/docking_port/destination/research/outpost)

/obj/machinery/computer/shuttle_control/research/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(research_shuttle)
	.=..()

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/research/station
	areaname = "main research department"

/obj/docking_port/destination/research/outpost
	areaname = "research outpost"
