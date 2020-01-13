#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Snowfort Station
// Literally just box station (as of 16/12/2018), but with the base turf being snow
//**************************************************************

/datum/map/active
	nameShort = "snowfort"
	nameLong = "Snowfort Station"
	map_dir = "snowstation"
	tDomeX = 128
	tDomeY = 58
	tDomeZ = 2
	zLevels = list(
		/datum/zLevel/snow{
			name = "station"
			movementChance = ZLEVEL_BASE_CHANCE * ZLEVEL_STATION_MODIFIER
		},
		/datum/zLevel/centcomm,
		/datum/zLevel/snow{
			name = "CrashedSat" ;
			},
		/datum/zLevel/snow{
			name = "derelict" ;
			},
		/datum/zLevel/snow,
		/datum/zLevel/snow{
			name = "spacePirateShip" ;
			},
		)
	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 226
	center_y = 254
	only_spawn_map_exclusive_vaults = TRUE


////////////////////////////////////////////////////////////////
#include "tgstation-snow.dmm"
#endif
