var/global/datum/shuttle/security/security_shuttle

/datum/shuttle/security
	name = "security shuttle"
	can_link_to_computer = LINK_FREE
	req_access = list(access_security)
	linked_area = /area/shuttle/security

/datum/shuttle/security/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/security/station)
	add_dock(/obj/docking_port/destination/security/outpost)
	security_shuttle = src

/obj/machinery/computer/shuttle_control/security //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	shuttle = /datum/shuttle/security

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/security/station
	areaname = "security dock"
	shuttle_type = /datum/shuttle/security

/obj/docking_port/destination/security/outpost
	areaname = "security outpost"
