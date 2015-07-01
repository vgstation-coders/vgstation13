var/global/datum/shuttle/research/research_shuttle = new

/datum/shuttle/research
	can_link_to_computer = LINK_FREE

/datum/shuttle/research/New()
	.=..()
	setup_everything(starting_area = /area/shuttle/research/station, \
		all_areas=list(/area/shuttle/research/station, /area/shuttle/research/outpost), \
		name = "research shuttle", dir = EAST)

/obj/machinery/computer/shuttle_control/research/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(research_shuttle)
	.=..()