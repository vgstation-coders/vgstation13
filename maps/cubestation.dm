#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Cubestation
//**************************************************************

/datum/map/active
	nameShort = "cube"
	nameLong = "Cube Station"
	map_dir = "cubestation"
	file_dir = "cubestation"
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
			name = "spacePirateShip" ;
			},
		)
	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck,
	/datum/map_element/dungeon/mecha_graveyard
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 226
	center_y = 254

////////////////////////////////////////////////////////////////
#include "cubestation.dmm"
#endif
