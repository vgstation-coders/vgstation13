#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Boxstation
//**************************************************************

/datum/map/active
	nameShort = "snaxi"
	nameLong = "Snow Station"
	map_dir = "snaxistation"
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

	event_blacklist = list(/datum/event/radiation_storm)
	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 226
	center_y = 254

	snow_theme = 1

/datum/zLevel/station
    base_turf = /turf/unsimulated/floor/snow

/datum/map/active/map_ruleset(var/datum/dynamic_ruleset/DR)
	if(ispath(DR.role_category,/datum/role/blob_overmind))
		return FALSE
	if(ispath(DR.role_category,/datum/role/changeling))
		return TRUE

	return TRUE

////////////////////////////////////////////////////////////////
#include "snaxi.dmm"
#endif
