
//**************************************************************
// Map Datum -- Ancientstation
//**************************************************************

/datum/map/active
	nameShort = "box"
	nameLong = "Ancient Station"
	map_dir = "ancientstation"
	tDomeX = 128
	tDomeY = 69
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
#include "ancientstation/areas.dm" // Areas
#include "ancientstation/turfs.dm" // Areas
#include "ancientstation.dmm"
