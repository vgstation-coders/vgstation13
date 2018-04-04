
//**************************************************************
// Map Datum -- Metaclub
//**************************************************************

/datum/map/active
	nameShort = "meta"
	nameLong = "Meta Club"
	map_dir = "metaclub"
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
			name = "spaceEmpty1" ;
			}
		)

	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

// Metaclub areas
/area/science/xenobiology/specimen_7
	name = "\improper Xenobiology Specimen Cage 7"
	icon_state = "xenocell7"

/datum/shuttle/trade/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/trade/start)
	add_dock(/obj/docking_port/destination/trade/station)
	add_dock(/obj/docking_port/destination/trade/extra)

/area/shuttle/trade/start
	requires_power = 1
////////////////////////////////////////////////////////////////
#include "metaclub.dmm"
