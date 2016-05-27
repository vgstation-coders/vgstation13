//**************************************************************
// Map Datum -- Snowbase
//**************************************************************

/datum/map/active
	nameShort = "snowbase"
	nameLong = "Snow Station"
	map_dir = "snowbase"
	tDomeX = 127
	tDomeY = 67
	tDomeZ = 2
	zAsteroid = 6
	zDeepSpace = 5
	zLevels = list(
		/datum/zLevel/snow{
			name = "station" ;
			},
		/datum/zLevel/centcomm,
		/datum/zLevel/snow{
			name = "OldOutpost" ;
			},
		/datum/zLevel/snow{
			name = "derelict" ;
			},
		/datum/zLevel/snow{
			name = "PirateShip" ;
			},
		/datum/zLevel/snow{
			name = "mining" ;
			}
		)
	enabled_jobs = list(/datum/job/trader)

/datum/map/active/New()
	.=..()

	research_shuttle.name = "Asteroid Shuttle" //Due to budget cuts, only one shuttle
	research_shuttle.req_access = list() //It's shared by miners and researchers, so remove access requirements

////////////////////////////////////////////////////////////////
#include "snowbase.dmm"
