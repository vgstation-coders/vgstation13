#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- NRV Horizon
//**************************************************************

/datum/map/active
	nameShort = "NRVH"
	nameLong = "NRV Horizon"
	map_dir = "nrvhorizon"
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
	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

/datum/map/active/New()
	.=..()

	research_shuttle.name = "Asteroid Shuttle" //There is only one shuttle on packedstation - the asteroid shuttle
	research_shuttle.req_access = list() //It's shared by miners and researchers, so remove access requirements

////////////////////////////////////////////////////////////////
#include "NRVHorizon.dmm"
#include "NRVH\areas.dm"

#if !defined(MAP_OVERRIDE_FILES)
	#define MAP_OVERRIDE_FILES
	#include "packedstation\misc.dm"
	#include "packedstation\telecomms.dm"
	/* This is gonna stay just in case - Prometh
	#include "packedstation\uplink_item.dm"
	#include "packedstation\job\jobs.dm" //Job changes removed for now
	#include "packedstation\job\removed.dm"

#elif !defined(MAP_OVERRIDE)
	#warn a map has already been included, ignoring packedstation. */
#endif
#endif
