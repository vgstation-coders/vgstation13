#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Teststation
//**************************************************************

/datum/map/active
	nameShort = "test_tiny"
	nameLong = "Test Station"
	map_dir = "teststation_tiny"
	tDomeX = 100
	tDomeY = 100
	tDomeZ = 1
	zLevels = list(
		/datum/zLevel/station,
		)

	load_map_elements = list(/datum/map_element/dungeon/holodeck)

////////////////////////////////////////////////////////////////
#include "test_tiny.dmm"
#endif
