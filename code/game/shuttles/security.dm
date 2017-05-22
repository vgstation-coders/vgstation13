var/global/datum/shuttle/security/security_shuttle = new(starting_area = /area/shuttle/security)

/datum/shuttle/security
	name = "security shuttle"
	can_link_to_computer = LINK_FREE
	req_access = list(access_security)

/datum/shuttle/security/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/security/station)
	add_dock(/obj/docking_port/destination/security/outpost)

/obj/machinery/computer/shuttle_control/security/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(security_shuttle)
	.=..()

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/security/station
	areaname = "security dock"

/obj/docking_port/destination/security/outpost
	areaname = "security outpost"
