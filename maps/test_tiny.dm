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
	zLevels = list(/datum/zLevel/station)
	enabled_jobs = list(/datum/job/trader)
	zCentcomm = 1
	lights_always_ok = TRUE

/datum/subsystem/supply_shuttle
	movetime = 5 SECONDS

////////////////////////////////////////////////////////////////
#include "test_tiny.dmm"
#endif
