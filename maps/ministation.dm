
//**************************************************************
// Map Datum -- Ministation
//**************************************************************

/datum/map/active
	nameShort = "Mini"
	nameLong = "Mini Station"
	map_dir = "ministation"
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
	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

/datum/map/active/New()
	.=..()

	research_shuttle.name = "Asteroid Shuttle" //There is only one shuttle on taxi - the asteroid shuttle
	research_shuttle.req_access = list() //It's shared by miners and researchers, so remove access requirements

////////////////////////////////////////////////////////////////
#include "ministation.dmm"

#if !defined(MAP_OVERRIDE_FILES)
	#define MAP_OVERRIDE_FILES
	#include "ministation\misc.dm"
	#include "ministation\telecomms.dm"
	#include "ministation\uplink_item.dm"
	#include "ministation\job\jobs.dm"
	#include "ministation\job\removed.dm"

//#elif !defined(MAP_OVERRIDE)
	//#warn a map has already been included, ignoring ministation.
