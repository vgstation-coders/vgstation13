#ifndef MAP_OVERRIDE

/datum/map/active
	nameShort = "olympics"
	nameLong = "Olympics Station"
	map_dir = "olympics"
	tDomeX = 128
	tDomeY = 58
	tDomeZ = 2
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
	)
	enabled_jobs = list()

	load_map_elements = list(/datum/map_element/dungeon/holodeck/olympics)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 250
	center_y = 250

////////////////////////////////////////////////////////////////
#include "olympics.dmm"
#include "olympics_z2.dmm"
#endif
