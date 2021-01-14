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
		/datum/zLevel/space{
			name = "spacePirateShip" ;
			},
		/datum/zLevel/mining,
		)
	enabled_jobs = list(/datum/job/trader)

	event_blacklist = list(/datum/event/radiation_storm,/datum/event/carp_migration,/datum/event/rogue_drone,/datum/event/immovable_rod,
						/datum/event/meteor_wave,/datum/event/meteor_shower,/datum/event/thing_storm/meaty_gore,/datum/event/thing_storm/blob_shower,
						/datum/event/thing_storm/blob_storm,/datum/event/thing_storm/fireworks)
	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	holomap_offset_x = list(96,0,0,96,0,0,0,)
	holomap_offset_y = list(96,0,0,96,0,0,0,)

	center_x = 150
	center_y = 150

	snow_theme = TRUE
	can_enlarge = FALSE

/****************************
**	Day and Night Lighting **
**	See: daynightcycle.dm  **
****************************/
/datum/subsystem/daynightcycle
	flags = SS_FIRE_IN_LOBBY
	daynight_z_lvl = STATION_Z

/datum/map/active/New()
	. = ..()

	research_shuttle.name = "Southern Station Shuttle"
	research_shuttle.req_access = list()
	mining_shuttle.name = "Northwest Station Shuttle"
	mining_shuttle.req_access = list()
	security_shuttle.name = "Northeast Station Shuttle"
	security_shuttle.req_access = list()

/datum/map/active/special_ui(var/obj/abstract/screen/S, mob/user)
	if(!user)
		return FALSE
	switch(S.name)
		if("Jump Northwest / View Core")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.view_core()
				return TRUE
		if("Jump South")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				var/area/A = locate(/area/hallway/secondary/exit)
				AI.jump_to_area(A)
				return TRUE
		if("Jump Northeast")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				var/area/A = locate(/area/wreck/engineering) //This is the area used for Snaxi Northeast Bridge
				AI.jump_to_area(A)
				return TRUE
	return FALSE

#define ui_jump_2 "SOUTH+1:[6*PIXEL_MULTIPLIER],WEST:0"
#define ui_jump_3 "SOUTH+1:[6*PIXEL_MULTIPLIER],WEST:[32*PIXEL_MULTIPLIER]"
/datum/map/active/give_AI_jumps(var/list/L)
	//do not call parent, we have our own AI core button
	var/obj/abstract/screen/using
	//Jump to Core/Northwest
	using = new /obj/abstract/screen
	using.name = "Jump Northwest / View Core"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "northwest"
	using.screen_loc = ui_jump_2
	L += using

	//Jump to Northeast
	using = new /obj/abstract/screen
	using.name = "Jump Northeast"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "northeast"
	using.screen_loc = ui_jump_3
	L += using

	//Jump to South
	using = new /obj/abstract/screen
	using.name = "Jump South"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "south"
	using.screen_loc = ui_ai_core //confusing, but this one is on bottom so it views better
	L += using

	return L

// Making nodes every 5*5 tiles in a 100*100 radius
// This makes (100*100)/(10*10) = 100 nodes

/datum/map/active/map_specific_init()
	climate = new /datum/climate/arctic()

	for (var/x = center_x; x <= center_x + center_x/3; x = x + 10)
		for (var/y = center_y; y <= center_y + center_y/3; y = y + 10)
			gaussian_geyser(x, y)
			CHECK_TICK
		for (var/y = center_y; y >= center_y - center_y/3; y = y - 10)
			gaussian_geyser(x, y)
			CHECK_TICK
	for (var/x = center_x; x >= center_x - center_x/3; x = x - 10)
		for (var/y = center_y; y <= center_y + center_y/3; y = y + 10)
			gaussian_geyser(x, y)
			CHECK_TICK
		for (var/y = center_y; y >= center_y - center_y/3; y = y - 10)
			gaussian_geyser(x, y)
			CHECK_TICK

/proc/gaussian_geyser(var/x, var/y)
	if (prob(30))
		return
	var/dx = round(16*GaussRand(1))
	var/dy = round(16*GaussRand(1))
	var/turf/T = locate(x + dx, y + dy, 1)
	if (!istype(T,/turf/unsimulated/floor/snow/))
		return
	if (istype(T, /turf/unsimulated/floor/snow/asphalt))
		return
	if (locate(/obj/structure/snow_flora/tree/pine) in T)
		return
	if (locate(/obj/glacier) in T)
		return
	var/area/A = get_area(T)
	A.make_geyser(T)

/datum/map/active/map_ruleset(var/datum/dynamic_ruleset/DR)
	if(ispath(DR.role_category,/datum/role/blob_overmind))
		return FALSE
	if(ispath(DR.role_category,/datum/role/changeling))
		return FALSE

	return TRUE

////////////////////////////////////////////////////////////////
#include "snaxi.dmm"
#endif
