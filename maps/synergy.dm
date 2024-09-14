#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Synergy
//**************************************************************

/datum/map/active
	nameShort = "SNR"
	nameLong = "Synergy Station"
	map_dir = "synergy"
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
	/datum/map_element/dungeon/holodeck
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,-41,10,0,0,)

	center_x = 246
	center_y = 245

////////////////////////////////////////////////////////////////
#include "synergy.dmm"

#endif
