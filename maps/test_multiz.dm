
//**************************************************************
// Map Datum -- Teststation
//**************************************************************

/datum/zLevel/surface
	name = "planet surface"
	movementJammed = 1
	base_turf = /turf/simulated/floor/plating/snow

/datum/zLevel/subterranean
	name = "subterranean"
	movementJammed = 1
	base_turf = /turf/unsimulated/floor/asteroid/air

/datum/zLevel/upper
	name = "above ground level"
	movementJammed = 1
	base_turf = /turf/simulated/open

/datum/zLevel/sky
	name = "sky"
	movementJammed = 1
	base_turf = /turf/simulated/open

/datum/map/active
	nameShort = "test_multiz"
	nameLong = "Multi-Floor Test Station"
	map_dir = "teststation_multiz"
	tDomeX = 100
	tDomeY = 100
	tDomeZ = 1
	multiz = TRUE
	zLevels = list(
		/datum/zLevel/centcomm,
		/datum/zLevel/subterranean,
		/datum/zLevel/surface,
		/datum/zlevel/upper,
		/datum/zLevel/sky
		)

////////////////////////////////////////////////////////////////
#include "test_multiz.dmm"
