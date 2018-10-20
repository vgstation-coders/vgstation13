#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Defficiency
//**************************************************************

/datum/map/active
	nameShort = "deff"
	nameLong = "Defficiency"
	map_dir = "defficiency"
	tDomeX = 128
	tDomeY = 58
	tDomeZ = 2
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

	default_tagger_locations = list(
		DISP_DISPOSALS,
		DISP_CARGO_BAY,
		DISP_QM_OFFICE,
		DISP_ENGINEERING,
		DISP_CE_OFFICE,
		DISP_ATMOSPHERICS,
		DISP_SECURITY,
		DISP_HOS_OFFICE,
		DISP_MEDBAY,
		DISP_CMO_OFFICE,
		DISP_CHEMISTRY,
		DISP_RESEARCH,
		DISP_RD_OFFICE,
		DISP_ROBOTICS,
		DISP_HOP_OFFICE,
		DISP_LIBRARY,
		DISP_CHAPEL,
		DISP_THEATRE,
		DISP_BAR,
		DISP_KITCHEN,
		DISP_HYDROPONICS,
		DISP_JANITOR_CLOSET,
		DISP_GENETICS,
		null,
		DISP_MECHANICS,
		null
	)
	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

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
/obj/machinery/door/airlock/glass_security/New()
	.=..()
	wires = new /datum/wires/airlock/secure(src)

/obj/machinery/door/airlock/security/New()
	.=..()
	wires = new /datum/wires/airlock/secure(src)

////////////////////////////////////////////////////////////////

#include "defficiency/areas.dm" // Areas

#include "defficiency/jobs.dm"

#include "defficiency.dmm"
#endif
