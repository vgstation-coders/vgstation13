#define SALVAGE_SHIP_MOVE_TIME 300
#define SALVAGE_SHIP_COOLDOWN 800

var/global/datum/shuttle/salvage/salvage_shuttle = new

/datum/shuttle/salvage/New()
	.=..()
	setup_everything(starting_area = /area/shuttle/salvage/start, \
		all_areas=list(/area/shuttle/salvage/start,
			/area/shuttle/salvage/arrivals,
			/area/shuttle/salvage/north,
			/area/shuttle/salvage/east,
			/area/shuttle/salvage/south,
			/area/shuttle/salvage/mining,
			/area/shuttle/salvage/trading_post,
			/area/shuttle/salvage/clown_asteroid,
			/area/shuttle/salvage/derelict,
			/area/shuttle/salvage/djstation,
			/area/shuttle/salvage/commssat,
			/area/shuttle/salvage/abandoned_ship), \
		name = "salvage shuttle", transit_area = /area/shuttle/salvage/transit, \
		dir = WEST, cooldown = 800, delay = 300)

/obj/machinery/computer/shuttle_control/salvage
	icon_state = "syndishuttle"

	req_access = list(access_salvage_captain)

	l_color = "#B40000"

/obj/machinery/computer/shuttle_control/salvage/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(salvage_shuttle)
	.=..()

#undef SALVAGE_SHIP_MOVE_TIME
#undef SALVAGE_SHIP_COOLDOWN
