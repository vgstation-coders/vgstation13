var/global/datum/shuttle/syndicate/syndicate_shuttle = new

/datum/shuttle/syndicate
	cant_leave_zlevel = list() //Nuke disk is allowed

/datum/shuttle/syndicate/New()
	.=..()
	setup_everything(starting_area = /area/syndicate_station/start, \
		all_areas=list(/area/syndicate_station/start,
			/area/syndicate_station/northwest,
			/area/syndicate_station/north,
			/area/syndicate_station/northeast,
			/area/syndicate_station/southwest,
			/area/syndicate_station/south,
			/area/syndicate_station/southeast,
			/area/syndicate_station/commssat,
			/area/syndicate_station/mining), \
		name = "syndicate shuttle", transit_area = /area/syndicate_station/transit, cooldown = 200, delay = 240)

/obj/machinery/computer/shuttle_control/syndicate
	icon_state = "syndishuttle"

	req_access = list(access_syndicate)

	l_color = "#B40000"

/obj/machinery/computer/shuttle_control/syndicate/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(syndicate_shuttle)
	.=..()

