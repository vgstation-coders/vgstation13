#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Junglestation
//**************************************************************

/datum/map/active
	nameShort = "Jungle"
	nameLong = "Jungle Station"
	map_dir = "junglestation"
	
	zMainStation = 1
	zAdditionalStationZlevel = 2
	zCentcomm = 3
	zAsteroid = 4
	zDerelict = 5
	
	zDeepSpace = -1
	zTCommSat = -1
	
	zLevels = list(
		/datum/zLevel/junglesurface,
		/datum/zLevel/jungleunderground,
		/datum/zLevel/centcomm,
		/datum/zLevel/mining,
		/datum/zLevel/space{
			name = "derelict" ;
			},
		)
	enabled_jobs = list(/datum/job/trader)
	event_blacklist = list(/datum/event/radiation_storm,/datum/event/carp_migration,/datum/event/rogue_drone,/datum/event/immovable_rod,
						/datum/event/meteor_wave,/datum/event/meteor_shower,/datum/event/thing_storm/meaty_gore,/datum/event/thing_storm/blob_shower,
						/datum/event/thing_storm/blob_storm,/datum/event/thing_storm/fireworks)
	load_map_elements = list(
	)

	skip_hobo_shack=TRUE
	can_enlarge=FALSE

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 182
	center_y = 163

/datum/map/active/New()
	world.name = "NT Colony Gamma-8"
	station_name="NT Colony Gamma-8"

/****************************
**	Day and Night Lighting **
**	See: daynightcycle.dm  **
****************************/
/datum/subsystem/daynightcycle/jungle
	flags = SS_FIRE_IN_LOBBY


////////////////////////////////////////////////////////////////
#include "junglestation.dmm"
#endif
