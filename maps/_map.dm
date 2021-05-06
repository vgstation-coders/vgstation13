#define ZLEVEL_BASE_CHANCE			10  //Not a strict chance, but a relative one
#define ZLEVEL_STATION_MODIFIER		0.5 //multiplier on the chance
#define ZLEVEL_SPACE_MODIFIER		1.5

//**************************************************************
//
// Map Datums
// --------------
// Each map can have its own datum now. This means no more
// hardcoded bullshit. Same for each Z-level.
//
// Should be mostly self-explanatory. Define /datum/map/active
// in your map file. See current maps for examples.
//
// Base Turf
// --------------
// Because the times are changing, even space being space
// is now considered hardcoding. So now you can have
// grass or asteroid under the station
//
//**************************************************************

/datum/map

	var/nameShort = ""
	var/nameLong = ""
	var/list/zLevels = list()
	var/zMainStation = 1
	var/zCentcomm = 2
	var/zTCommSat = 3
	var/zDerelict = 4
	var/zAsteroid = 5
	var/zDeepSpace = 6

	//Center of thunderdome admin room
	var/tDomeX = 0
	var/tDomeY = 0
	var/tDomeZ = 0

	//Holomap offsets
	var/list/holomap_offset_x = list()
	var/list/holomap_offset_y = list()

	//List for traitor items which are not in the map
	var/list/unavailable_items

	//nanoui stuff
	var/map_dir = ""

	//Fuck the preprocessor
	var/dorf = 0
	var/linked_to_centcomm = 1

	//Disable holominimaps on generation, map-wide. If you're just testing things out, change config.txt instead.
	var/disable_holominimap_generation = 0

	//If 1, only spawn vaults that are exclusive to this map (other vaults aren't spawned). For more info, see code/modules/randomMaps/vault_definitions.dm
	var/only_spawn_map_exclusive_vaults = 0

	// List of package tagger locations. Due to legacy shitcode you can only append or replace ones with null, or you'll break stuff.
	var/list/default_tagger_locations = list(
		DISP_DISPOSALS,
		DISP_CARGO_BAY,
		DISP_QM_OFFICE,
		DISP_ENGINEERING,
		DISP_CE_OFFICE,
		DISP_ATMOSPHERICS,
		DISP_SECURITY,
		DISP_HOS_OFFICE,
		DISP_MEDBAY,
		DISP_CMO_OFFICE,
		DISP_CHEMISTRY,
		DISP_RESEARCH,
		DISP_RD_OFFICE,
		DISP_ROBOTICS,
		DISP_HOP_OFFICE,
		DISP_LIBRARY,
		DISP_CHAPEL,
		DISP_THEATRE,
		DISP_BAR,
		DISP_KITCHEN,
		DISP_HYDROPONICS,
		DISP_JANITOR_CLOSET,
		DISP_GENETICS,
		DISP_TELECOMMS,
		DISP_MECHANICS,
		DISP_TELESCIENCE
	)

	var/list/enabled_jobs = list() //Jobs that require enabling that are enabled on this map
	var/list/disabled_jobs = list() //Jobs that are disabled on this map

	var/list/event_blacklist = list(/datum/event/blizzard, /datum/event/omega_blizzard)
	var/list/event_whitelist = list()

	//Map elements that should be loaded together with this map. Stuff like the holodeck areas, etc.
	var/list/load_map_elements = list()
	var/center_x = 226
	var/center_y = 254

	var/snow_theme = FALSE
	var/can_enlarge = TRUE //can map elements expand this map? turn off for surface maps
	var/datum/climate/climate = null //use for weather cycle
	var/has_engines = FALSE // Is the map a space ship with big engines?

	var/lights_always_ok = FALSE //should all lights be on and working at roundstart

	var/list/holodeck_rooms = list(
		"Basketball Court",
		"Beach",
		"Boxing Court",
		"Checkers Court",
		"Chess Board",
		"Desert",
		"Dining Hall",
		"Empty Court",
		"Firing Range",
		"Gym",
		"Laser Tag Arena",
		"Maze",
		"Meeting Hall",
		"Panic Bunker",
		"Picnic Area",
		"Snow Field",
		"Theatre",
		"Thunderdome Court",
		"Wild Ride",
		"Zoo"
	)
	var/list/emagged_holodeck_rooms = list(
		"Begin Atmospheric Burn Simulation" = "Ensure the holodeck is empty before testing.",
		"Begin Wildlife Simulation" = "Ensure the holodeck is empty before testing.",
		"Club Catnip" = "Ensure the holodeck is empty before testing.",
		"Combat Arena" = "Safety protocols disabled - weapons are not for recreation.",
		"Medieval Tournament" = "Safety protocols disabled - weapons are not for recreation.",
	)

/datum/map/New()
	. = ..()

	src.loadZLevels(src.zLevels)

	//The spawn below is needed
	spawn()
		for(var/T in load_map_elements)
			load_dungeon(T)

/datum/map/proc/map_ruleset(var/datum/dynamic_ruleset/DR)
	if(ispath(DR.role_category,/datum/role/changeling))
		return FALSE

	return TRUE //If false, fails Ready()

/datum/map/proc/ruleset_multiplier(var/datum/dynamic_ruleset/DR)
	return 1

/datum/map/proc/ignore_enemy_requirement(var/datum/dynamic_ruleset/DR)
	return 0

/datum/map/proc/loadZLevels(list/levelPaths)


	for(var/i = 1 to levelPaths.len)
		var/path = levelPaths[i]
		addZLevel(new path, i)

/datum/map/proc/addZLevel(datum/zLevel/level, z_to_use = 0)


	if(!istype(level))
		warning("ERROR: addZLevel received [level ? "a bad level of type [ispath(level) ? "[level]" : "[level.type]" ]" : "no level at all!"]")
		return
	if(!level.base_turf)
		level.base_turf = /turf/space
	if(z_to_use > zLevels.len)
		zLevels.len = z_to_use
	zLevels[z_to_use] = level
	if(!level.movementJammed)
		accessable_z_levels += list("[z_to_use]" = level.movementChance)

	level.z = z_to_use

var/global/list/accessable_z_levels = list()

/datum/map/proc/map_specific_init()

//Set map-specific conditions here
/datum/map/proc/map_specific_conditions(var/condition)
	return 1

//For any map-specific UI, like AI jumps
/datum/map/proc/special_ui(var/obj/abstract/screen/S, mob/user)
	return FALSE

//This list contains the z-level numbers which can be accessed via space travel and the percentile chances to get there.
//Generated by the map datum on roundstart - and added to during the round
//This comment is a memorial to balance bickering from a long-gone TGstation - Errorage and Urist

/datum/map/proc/give_AI_jumps(var/list/L)
	var/obj/abstract/screen/using
	using = new /obj/abstract/screen
	using.name = "AI Core"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "ai_core"
	using.screen_loc = ui_ai_core
	L += using
	return L

/datum/map/proc/generate_mapvaults()
	return FALSE

/datum/map/proc/map_equip(var/mob/living/carbon/human/H)
	return

////////////////////////////////////////////////////////////////

/datum/zLevel

	var/name = ""
	var/teleJammed = 0
	var/movementJammed = 0 //Prevents you from accessing the zlevel by drifting
	var/transitionLoops = FALSE //if true, transition sends you back to the same Z-level (see turfs/turf.dm)
	var/bluespace_jammed = 0
	var/movementChance = ZLEVEL_BASE_CHANCE
	var/base_turf //Our base turf, what shows under the station when destroyed. Defaults to space because it's fukken Space Station 13
	var/base_area = null //default base area type, what blueprints erase into; if null, space; be careful with parent areas because locate() could find a child!
	var/z //Number of the z-level (the z coordinate)

/datum/zLevel/proc/post_mapload()
	return

////////////////////////////////

/datum/zLevel/station

	name = "station"
	movementChance = ZLEVEL_BASE_CHANCE * ZLEVEL_STATION_MODIFIER


/datum/zLevel/centcomm

	name = "centcomm"
	teleJammed = 1
	movementJammed = 1
	bluespace_jammed = 1

/datum/zLevel/space

	name = "space"
	movementChance = ZLEVEL_BASE_CHANCE * ZLEVEL_SPACE_MODIFIER

/datum/zLevel/mining

	name = "mining"

//for snowmap
/datum/zLevel/snowsurface
	name = "snowy surface"
	base_turf = /turf/unsimulated/floor/snow
	base_area = /area/surface/snow
	movementJammed = TRUE
	transitionLoops = TRUE

//for Horizon
/datum/zLevel/hyperspace
	name = "hyperspace"
	base_turf = /turf/space/transit/horizon //NRV Horizon flies ever onward.  Replace this with faketransit if the change to the horizon turf goes through or crew will get chucked around like little dolls.
	movementJammed = TRUE

//Currently experimental, contains nothing worthy of interest
/datum/zLevel/desert

	name = "desert"
	teleJammed = 1
	movementJammed = 1
	base_turf = /turf/unsimulated/beach/sand



/datum/zLevel/snow //not used on snaxi
	name = "snow"
	base_turf = /turf/unsimulated/floor/snow
	movementChance = ZLEVEL_BASE_CHANCE * ZLEVEL_SPACE_MODIFIER

/datum/zLevel/snow/post_mapload()
	var/lake_density = rand(2,8)
	for(var/i = 0 to lake_density)
		var/turf/T = locate(rand(1, world.maxx),rand(1, world.maxy), z)
		if(!istype(T, base_turf))
			continue
		var/generator = pick(typesof(/obj/structure/radial_gen/cellular_automata/ice))
		new generator(T)

	var/tree_density = rand(25,45)
	for(var/i = 0 to tree_density)
		var/turf/T = locate(rand(1,world.maxx),rand(1, world.maxy), z)
		if(!istype(T, base_turf))
			continue
		var/generator = pick(typesof(/obj/structure/radial_gen/movable/snow_nature/snow_forest) + typesof(/obj/structure/radial_gen/movable/snow_nature/snow_grass))
		new generator(T)

// Debug ///////////////////////////////////////////////////////

/*
/mob/verb/getCurMapData()
	to_chat(src, "\nCurrent map data:")
	to_chat(src, "* Short name: [map.nameShort]")
	to_chat(src, "* Long name: [map.nameLong]")
	to_chat(src, "* [map.zLevels.len] Z-levels: [map.zLevels]")
	for(var/datum/zLevel/level in map.zLevels)
		to_chat(src, "  * [level.name], Telejammed : [level.teleJammed], Movejammed : [level.movementJammed]")
	to_chat(src, "* Main station Z: [map.zMainStation]")
	to_chat(src, "* Centcomm Z: [map.zCentcomm]")
	to_chat(src, "* Thunderdome coords: ([map.tDomeX],[map.tDomeY],[map.tDomeZ])")
	to_chat(src, "* Space movement chances: [accessable_z_levels]")
	for(var/z in accessable_z_levels)
		to_chat(src, "  * [z] has chance [accessable_z_levels[z]]")
	return
*/

// Base Turf //////////////////////////////////////////////////

//Returns the lowest turf available on a given Z-level, defaults to space.

proc/get_base_turf(var/z)


	var/datum/zLevel/L = map.zLevels[z]
	return L.base_turf

//Area that blueprints should erase to
proc/get_base_area(var/z)
	var/datum/zLevel/L = map.zLevels[z]
	if(L.base_area)
		return locate(L.base_area) //this is a type
	else
		return get_space_area()

proc/change_base_turf(var/choice,var/new_base_path,var/update_old_base = 0)
	var/datum/zLevel/L = map.zLevels[choice]
	if(update_old_base)
		var/previous_base_turf = L.base_turf
		for(var/turf/T in world)
			CHECK_TICK
			if(T.type == previous_base_turf && T.z == choice)
				T.ChangeTurf(new_base_path)
	L.base_turf = new_base_path
	for(var/obj/docking_port/destination/D in all_docking_ports)
		if(D.z == choice)
			D.base_turf_type = new_base_path

/client/proc/set_base_turf()


	set category = "Debug"
	set name = "Set Base Turf"
	set desc = "Set the base turf for a z-level. Defaults to space, does not replace existing tiles."

	if(check_rights(R_DEBUG, 0))
		if(!holder)
			return
		var/choice = input("Which Z-level do you wish to set the base turf for?") as null|num
		if(!choice)
			return
		var/new_base_path = input("Please select a turf path (cancel to reset to /turf/space).") as null|anything in typesof(/turf)
		if(!new_base_path)
			new_base_path = /turf/space //Only hardcode in the whole thing, feel free to change this if somewhere in the distant future spess is deprecated
		var/update_old_base = alert(src, "Do you wish to update the old base? This will LAG.", "Update old turfs?", "Yes", "No")
		update_old_base = update_old_base == "No" ? 0 : 1
		if(update_old_base)
			message_admins("[key_name_admin(usr)] is replacing the old base turf on Z level [choice] with [get_base_turf(choice)]. This is likely to lag.")
			log_admin("[key_name_admin(usr)] has replaced the old base turf on Z level [choice] with [get_base_turf(choice)].")
		change_base_turf(choice,new_base_path,update_old_base)
		feedback_add_details("admin_verb", "BTC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		message_admins("[key_name_admin(usr)] has set the base turf for Z-level [choice] to [get_base_turf(choice)]. This will affect all destroyed turfs from now on.")
		log_admin("[key_name(usr)] has set the base turf for Z-level [choice] to [get_base_turf(choice)]. This will affect all destroyed turfs from now on.")
