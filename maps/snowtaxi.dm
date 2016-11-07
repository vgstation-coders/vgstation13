//**************************************************************
// Map Datum -- Snow Taxistation
//**************************************************************

/datum/map/active
	nameShort = "snaxi"
	nameLong = "Taxi Station"
	map_dir = "snowtaxi"
	tDomeX = 127
	tDomeY = 67
	tDomeZ = 2
	zAsteroid = 6
	zDeepSpace = 5
	base_turf = /turf/snow
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
	enabled_jobs = list(/datum/job/trader)
	radial_generate = RADIAL_GENERATE_SNOW_MAP

/datum/map/active/New()
	.=..()

	research_shuttle.name = "Asteroid Shuttle" //There is only one shuttle on taxi - the asteroid shuttle
	research_shuttle.req_access = list() //It's shared by miners and researchers, so remove access requirements

////////////////////////////////////////////////////////////////
#include "snowtaxi.dmm"
