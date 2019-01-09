#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Teststation
//**************************************************************

/datum/map/active
	nameShort = "test_empty"
	nameLong = "Literally just space"
	map_dir = "teststation_empty"
	zLevels = list(
		/datum/zLevel/station,
		)

	load_map_elements = list()

////////////////////////////////////////////////////////////////
#include "test_empty.dmm"
#endif
