
//**************************************************************
// Map Datum -- Thumbstation
//**************************************************************

/datum/map/active
	nameShort = "thumb"
	nameLong = "Thumbstation"
	map_dir = "thumbstation"
	tDomeX = 128
	tDomeY = 58
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
#include "maps/thumbstation.dmm"
#include "maps/thumbstation/removed.dm"
#include "maps/thumbstation/misc.dm"