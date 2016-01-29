
//**************************************************************
// Map Datum -- Boxstation
//**************************************************************

/datum/map/active
	nameShort = "box"
	nameLong = "Box Station"
	map_dir = "boxstation"
	tDomeX = 250
	tDomeY = 99
	tDomeZ = 2
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
		/datum/zLevel/space{
			name = "spaceOldSat" ;
			},
		/datum/zLevel/space{
			name = "derelict" ;
			},
		/datum/zLevel/mining,
		/datum/zLevel/space{
			name = "spacePirateShip" ;
			},
		)

////////////////////////////////////////////////////////////////
#include "defficiency/pipes.dm" // Atmos layered pipes.
#include "tgstation.dmm"
