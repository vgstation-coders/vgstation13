#ifndef MAP_OVERRIDE

//**************************************************************
// Map Datum -- Waystation
//**************************************************************

/datum/map/active
	nameShort = "way"
	nameLong = "Waystation"
	map_dir = "waystation"
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
		/datum/zLevel/space{name = "spaceOldSat"},
		/datum/zLevel/space{name = "derelict"},
		/datum/zLevel/mining,
		/datum/zLevel/space{name = "spacePirateShip"},
		)
	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck/holodeck_3x3
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 221
	center_y = 241

#include "waystation.dmm"
#endif
