
//**************************************************************
// Map Datum -- Defficiency
//**************************************************************

/datum/map/active
	nameShort = "deff"
	nameLong = "Defficiency"
	map_dir = "defficiency"
	tDomeX = 127
	tDomeY = 67
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
			name = "spaceEmpty" ;
			},
		)

////////////////////////////////////////////////////////////////
#include "defficiency/areas.dm" // Areas

#include "defficiency.dmm"
