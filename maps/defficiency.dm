#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Defficiency
//**************************************************************

/datum/map/active
	nameShort = "deff"
	nameLong = "Defficiency"
	map_dir = "defficiency"
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
		/datum/zLevel/space{
			name = "spaceOldSat" ;
			},
		/datum/zLevel/space{
			name = "derelict" ;
			},
		/datum/zLevel/mining,
		/datum/zLevel/space{
			name = "spaceEmpty" ;
			},
		)

	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	center_x = 231
	center_y = 249

//The central shuttle leads to both outposts
/datum/map/active/New()
	. = ..()

	mining_shuttle.name = "Asteroid Shuttle" //There is only one shuttle on defficiency now - the asteroid shuttle
	mining_shuttle.req_access = list() //It's shared by miners and researchers, so remove access requirements

/obj/docking_port/destination/mining/station
	areaname = "main station dock"

/obj/docking_port/destination/mining/outpost
	areaname = "mining outpost"

/datum/shuttle/mining/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/mining/station)
	add_dock(/obj/docking_port/destination/mining/outpost)
	add_dock(/obj/docking_port/destination/research/outpost)

//All security airlocks have randomized wires
//Disabled from the game
// /obj/machinery/door/airlock/glass_security/New()
// 	.=..()
// 	wires = new /datum/wires/airlock/secure(src)

// /obj/machinery/door/airlock/security/New()
// 	.=..()
// 	wires = new /datum/wires/airlock/secure(src)

////////////////////////////////////////////////////////////////

#include "defficiency/areas.dm" // Areas

#include "defficiency/jobs.dm"

#include "defficiency.dmm"
#endif
