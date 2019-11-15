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
		/datum/zLevel/snowsurface,
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

	holomap_offset_x = list(96,0,0,96,0,0,0,)
	holomap_offset_y = list(96,0,0,96,0,0,0,)

	center_x = 150
	center_y = 150

	snow_theme = 1

/datum/map/active/New()
	.=..()
	
	research_shuttle.name = "Research and Mining Shuttle"
	research_shuttle.req_access = list() //It's shared by miners and researchers, so remove access requirements

// Making nodes every 5*5 tiles in a 100*100 radius
// This makes (100*100)/(10*10) = 100 nodes
/datum/map/active/map_specific_init()
	for (var/x = center_x; x <= center_x + center_x/3; x = x + 10)
		for (var/y = center_y; y <= center_y + center_y/3; y = y + 10)
			gaussian_geyer(x, y)
			CHECK_TICK
		for (var/y = center_y; y >= center_y - center_y/3; y = y - 10)
			gaussian_geyer(x, y)
			CHECK_TICK
	for (var/x = center_x; x >= center_x - center_x/3; x = x - 10)
		for (var/y = center_y; y <= center_y + center_y/3; y = y + 10)
			gaussian_geyer(x, y)
			CHECK_TICK
		for (var/y = center_y; y >= center_y - center_y/3; y = y - 10)
			gaussian_geyer(x, y)
			CHECK_TICK

/proc/gaussian_geyer(var/x, var/y)
	var/turf/T = locate(x, y, 1)
	if (!istype(T,/turf/unsimulated/floor/snow/))
		return
	if (locate(/obj/structure/snow_flora/tree/pine) in T)
		return
	if (istype(T, /turf/unsimulated/floor/snow/asphalt))
		return
	if (prob(30))
		return
	
	var/dx = round(16*GaussRand())
	var/dy = round(16*GaussRand())
	var/turf/T2 = locate(x + dx, y + dy, 1)
	if (!istype(T2,/turf/unsimulated/floor/snow/))
		return
	if (istype(T, /turf/unsimulated/floor/snow/asphalt))
		return
	if (locate(/obj/structure/snow_flora/tree/pine) in T)
		return
	switch (rand(100))
		if (0 to 60)
			new /obj/structure/geyser(T2)
		if (60 to 80)
			new /obj/structure/geyser/unstable(T2)
		else 
			new /obj/structure/geyser/vent(T2)

/datum/map/active/map_ruleset(var/datum/dynamic_ruleset/DR)
	if(ispath(DR.role_category,/datum/role/blob_overmind))
		return FALSE
	if(ispath(DR.role_category,/datum/role/changeling))
		return TRUE

	return TRUE

////////////////////////////////////////////////////////////////
#include "snaxi.dmm"
#endif
