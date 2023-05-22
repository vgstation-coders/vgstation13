#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Lamprey Station
//**************************************************************

/datum/map/active
	nameShort = "lamprey"
	nameLong = "Lamprey Station"
	map_dir = "lampreystation"
	zDerelict = 3
	zAsteroid = 4
	zTCommSat = 5
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
		/datum/zLevel/space{
			name = "derelict" ;
			},
		/datum/zLevel/mining,
		)
	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 226
	center_y = 254

	disable_holominimap_generation = 1 // else the server gets fucking kneecapped. TODO SOMEDAY: fix minimap generation alongside, it's dirty code

/datum/job/bartender/New()
	..()
	total_positions = 9
	spawn_positions = 9

/datum/job/botanist/New()
	..()
	total_positions = 4
	spawn_positions = 4

/datum/job/cargo_tech/New()
	..()
	total_positions = 5
	spawn_positions = 5

/datum/job/chief_engineer/New()
	..()
	spawn_positions = 2

/datum/job/cmo/New()
	..()
	spawn_positions = 1

/datum/job/hos/New()
	..()
	spawn_positions = 1

/datum/job/lawyer/New()
	..()
	total_positions = 3
	spawn_positions = 3

/datum/job/janitor/New()
	..()
	total_positions = 3
	spawn_positions = 3

/datum/job/officer/New()
	..()
	spawn_positions = 11

////////////////////////////////////////////////////////////////
#include "LampreyStation.dmm"
#endif
