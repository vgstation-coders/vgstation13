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
		/datum/zLevel/hyperspace,
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

	event_blacklist = list(/datum/event/carp_migration,/datum/event/rogue_drone,/datum/event/immovable_rod,
						/datum/event/meteor_wave,/datum/event/meteor_shower,/datum/event/thing_storm/meaty_gore,/datum/event/thing_storm/blob_shower,
						/datum/event/thing_storm/blob_storm,/datum/event/thing_storm/fireworks)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck/holodeck_3x3
	)
	has_engines = TRUE

	holomap_offset_x = list(0,0,0,86,0,0,0,)
	holomap_offset_y = list(85,0,0,94,0,0,0,)

	center_x = 253
	center_y = 142

/datum/map/active/New()
	.=..()

	research_shuttle.name = "Asteroid Shuttle" //There is only one shuttle on packedstation - the asteroid shuttle
	research_shuttle.req_access = list() //It's shared by miners and researchers, so remove access requirements

////////////////////////////////////////////////////////////////
#include "nrvhorizon.dmm"

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
