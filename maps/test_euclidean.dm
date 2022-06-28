
//**************************************************************
// Map Datum -- Teststation
//**************************************************************

/datum/zLevel/first
	name = "first floor"
	movementJammed = 1
	z_above = 4
	z_below = 2

/datum/zLevel/ground
	name = "ground floor"
	movementJammed = 1
	z_above = 3
	z_below = 5

/datum/zLevel/second
	name = "second floor"
	movementJammed = 1
	z_above = 5
	z_below = 3

/datum/zLevel/third
	name = "third floor"
	movementJammed = 1
	z_above = 2
	z_below = 4

/datum/map/active
	nameShort = "test_euclidean"
	nameLong = "Euclidean Test Station"
	map_dir = "teststation_euclidean"
	tDomeX = 50
	tDomeY = 50
	tDomeZ = 1
	zLevels = list(
		/datum/zLevel/centcomm,
		/datum/zLevel/ground,
		/datum/zLevel/first,
		/datum/zLevel/second,
		/datum/zLevel/third
		)

////////////////////////////////////////////////////////////////
#include "test_euclidean.dmm"
