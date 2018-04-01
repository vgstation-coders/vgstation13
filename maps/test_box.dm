
//**************************************************************
// Map Datum -- Teststation
//**************************************************************

/datum/map/active
	nameShort = "test_box"
	nameLong = "Test Station"
	map_dir = "teststation_box"
	tDomeX = 8
	tDomeY = 8
	tDomeZ = 1
	zLevels = list(
		/datum/zLevel/station,
		)


	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

////////////////////////////////////////////////////////////////
#include "test_box.dmm"
