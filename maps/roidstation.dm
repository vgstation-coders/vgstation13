#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Roidstation
//**************************************************************

/datum/map/active
	nameShort = "roid"
	nameLong = "Asteroid Station"
	map_dir = "roidstation"
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
			name = "spacePirateShip" ;
			},
		)
	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 177
	center_y = 193

/datum/map/active/map_ruleset(var/datum/dynamic_ruleset/DR)
	if(ispath(DR.role_category,/datum/role/changeling)) // From parent
		return FALSE
	if(ispath(DR.role_category,/datum/role/blob_overmind))
		return FALSE
	return TRUE

////////////////////////////////////////////////////////////////
#include "roidstation/areas.dm"
#include "roidstation.dmm"
#endif
