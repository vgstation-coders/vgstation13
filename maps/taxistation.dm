//Defining taxi shuttles here as they are only featured in this map

#define TAXI_A_STARTING_AREA /area/shuttle/taxi_a/engineering_cargo_station
#define TAXI_B_STARTING_AREA /area/shuttle/taxi_b/engineering_cargo_station

var/global/datum/shuttle/taxi/a/taxi_a = new(starting_area = TAXI_A_STARTING_AREA)

var/global/datum/shuttle/taxi/b/taxi_b = new(starting_area = TAXI_B_STARTING_AREA)

//**************************************************************
// Map Datum -- Taxistation
//**************************************************************

/datum/map/active
	nameShort = "taxi"
	nameLong = "Taxi Station"
	map_dir = "taxistation"
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
		/datum/zLevel/space{
			name = "spacePirateShip" ;
			},
		/datum/zLevel/mining,
		)

////////////////////////////////////////////////////////////////
#include "taxistation.dmm"
