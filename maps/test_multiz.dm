
//**************************************************************
// Map Datum -- Teststation
//**************************************************************

/datum/zLevel/surface
	name = "planet surface"
	movementJammed = 1
	base_turf = /turf/simulated/floor/plating/snow
	z_above = 4
	z_below = 2

/datum/zLevel/subterranean
	name = "subterranean"
	movementJammed = 1
	base_turf = /turf/unsimulated/floor/asteroid/air
	z_above = 3

/datum/zLevel/upper
	name = "above ground level"
	movementJammed = 1
	base_turf = /turf/simulated/open
	z_above = 5
	z_below = 3

/datum/zLevel/sky
	name = "sky"
	movementJammed = 1
	base_turf = /turf/simulated/open
	z_below = 4

/datum/map/active
	nameShort = "test_multiz"
	nameLong = "Multi-Floor Test Station"
	map_dir = "teststation_multiz"
	zLevels = list(
		/datum/zLevel/centcomm,
		/datum/zLevel/subterranean,
		/datum/zLevel/surface,
		/datum/zLevel/upper,
		/datum/zLevel/sky
		)

////////////////////////////////////////////////////////////////
#include "test_multiz.dmm"
