#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Junglestation
//**************************************************************

/datum/map/active
	nameShort = "Jungle"
	nameLong = "Jungle Station"
	map_dir = "junglestation"
	zAsteroid = 4
	zMainStation = 1
	zCentcomm = 3
	zLevels = list(
		/datum/zLevel/junglesurface,
		/datum/zLevel/jungleunderground,
		/datum/zLevel/centcomm,
		/datum/zLevel/mining,
		/datum/zLevel/space{
			name = "derelict" ;
			},
		)
	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 182
	center_y = 163

/datum/map/active/New()
	world.name = "NT Colony Gamma-8"
	station_name="NT Colony Gamma-8"

/****************************
**	Day and Night Lighting **
**	See: daynightcycle.dm  **
****************************/
/datum/subsystem/daynightcycle/jungle
	flags = SS_FIRE_IN_LOBBY


////////////////////////////////////////////////////////////////
#include "junglestation.dmm"
#endif
