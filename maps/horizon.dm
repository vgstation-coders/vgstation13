#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- NRV Horizon
//**************************************************************

/datum/map/active
	nameShort = "NRVH"
	nameLong = "NRV Horizon"
	map_dir = "horizon"
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

	event_blacklist = list(/datum/event/carp_migration,/datum/event/rogue_drone,/datum/event/immovable_rod,
						/datum/event/meteor_wave,/datum/event/meteor_shower,/datum/event/thing_storm/meaty_gore,/datum/event/thing_storm/blob_shower,
						,/datum/event/thing_storm/fireworks)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck/holodeck_3x3
	)
	has_engines = TRUE

	holomap_offset_x = list(0,0,0,86,0,0,0,)
	holomap_offset_y = list(0,0,0,94,0,0,0,)

	center_x = 253
	center_y = 142

	default_tagger_locations = list(
		null,
		null,
		null,
		DISP_ENGINEERING,
		null,
		DISP_ATMOSPHERICS,
		DISP_SECURITY,
		null,
		DISP_MEDBAY,
		null,
		null,
		DISP_RESEARCH,
		null,
		DISP_ROBOTICS,
		null,
		null,
		null,
		null,
		DISP_BAR,
		DISP_KITCHEN,
		DISP_HYDROPONICS,
		null,
		DISP_GENETICS,
		null,
		null,
		null
	)

/datum/map/active/New()
	.=..()

	research_shuttle.name = "Asteroid Shuttle" //There is only one shuttle on packedstation - the asteroid shuttle
	research_shuttle.req_access = list() //It's shared by miners and researchers, so remove access requirements
	salvage_shuttle.can_rotate = 1

////////////////////////////////////////////////////////////////
#include "horizon.dmm"
#endif
