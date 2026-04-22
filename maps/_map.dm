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
	var/list/datum/zLevel/zLevels = list()
	var/list/datum/virtual_z/vLevels = list()
	var/list/datum/virtual_z/systemVLevels = list() // System vLevels (holodeck, transit levels, dungeons, etc) - numbered 101+
	var/zMainStation = 1
	var/zCentcomm = 2
	var/zTCommSat = 3
	var/zDerelict = 4
	var/zAsteroid = 5
	var/zDeepSpace = 6

	var/zAdditionalStationZlevel = 0 // 0 because surely nothing will ever go to Z 0, right? why not null? because nullspace

	var/skip_hobo_shack = FALSE // if true, skips hobo shack generation. set to TRUE if you want to map your own custom one for the map.

	//Holomap offsets
	var/list/holomap_offset_x = list()
	var/list/holomap_offset_y = list()

	//List for traitor items which are not in the map
	var/list/unavailable_items

	//nanoui stuff
	var/map_dir = ""
	//buildmode reset
	var/file_dir = ""

	//Fuck the preprocessor
	var/dorf = 0
	var/linked_to_centcomm = 1
	var/shuttle_call_label = "Call Shuttle"
	var/shuttle_cancel_label = "Cancel Shuttle"

	//Disable holominimaps on generation, map-wide. If you're just testing things out, change config.txt instead.
	var/disable_holominimap_generation = 0

	//If 1, only spawn vaults that are exclusive to this map (other vaults aren't spawned). For more info, see code/modules/randomMaps/vault_definitions.dm
	var/only_spawn_map_exclusive_vaults = 0

	var/list/enabled_jobs = list() //Jobs that require enabling that are enabled on this map
	var/list/disabled_jobs = list() //Jobs that are disabled on this map

	var/list/event_blacklist = list(/datum/event/blizzard, /datum/event/omega_blizzard)
	var/list/event_whitelist = list()

	var/datum/shuttle/ship_shuttle = null //Reference to "the ship" for map-specific features (events, etc). Set by map-specific init code.

	//Map elements that should be loaded together with this map. Stuff like the holodeck areas, etc.
	var/list/load_map_elements = list()
	var/list/load_custom_fixedvaults = list() //don't use this
	var/center_x = 226
	var/center_y = 254

	var/snow_theme = FALSE
	var/can_enlarge = TRUE //can map elements expand this map? turn off for surface maps
	var/has_engines = FALSE // Is the map a space ship with big engines?
	var/broken_lights = TRUE //broken lights roundstart
	var/can_have_robots = TRUE
	var/planet_size = 0 // If set, overrides planet allocation size for this map

	var/list/daynight_z_lvls = list() //Z-levels that participate in the day/night cycle

//Used for events; override as-needed.
/datum/map/proc/map_specific_event_checks(var/datum/event/E)
	return 1

/datum/map/New()
	. = ..()
	src.loadZLevels(src.zLevels)

/datum/map/proc/map_ruleset(var/datum/dynamic_ruleset/DR)
	return TRUE //If false, fails Ready()

/datum/map/proc/ruleset_multiplier(var/datum/dynamic_ruleset/DR)
	return 1

/datum/map/proc/ignore_enemy_requirement(var/datum/dynamic_ruleset/DR)
	return 0

/datum/map/proc/loadZLevels(list/levelPaths)
	for(var/i = 1 to levelPaths.len)
		var/path = levelPaths[i]
		addZLevel(new path, i)

/datum/map/proc/addZLevel(datum/zLevel/level, z_to_use = 0, make_base_turf = FALSE, fast_base_turf = FALSE)
	if(!istype(level))
		warning("ERROR: addZLevel received [level ? "a bad level of type [ispath(level) ? "[level]" : "[level.type]" ]" : "no level at all!"]")
		return
	if(!level.base_turf)
		level.base_turf = /turf/space
	if(z_to_use > zLevels.len)
		zLevels.len = z_to_use
	zLevels[z_to_use] = level
	level.z = z_to_use
	if(!istype(level.base_turf,/turf/space) && make_base_turf)
		level.reset_base_turf(/turf/space,fast_base_turf)

/datum/map/proc/linkVLevel(datum/zLevel/level)
	var/datum/virtual_z/new_vz = new(level, world.maxx, world.maxy, 1, 1, skip_turf_setup = FALSE)
	new_vz.id = level.z
	new_vz.name = level.name
	if(level.z == zCentcomm)
		new_vz.level_type = VZ_PROTECTED
	else if(level.planetside)
		new_vz.level_type = VZ_PLANET
	if(level.z in daynight_z_lvls)
		daynight_v_lvls += new_vz
	new_vz.gps_allowed = level.z != zCentcomm
	new_vz.teleJammed = level.teleJammed ? VZ_TELEPORTATION_FORBIDDEN : VZ_TELEPORTATION_ALLOWED
	new_vz.bluespace_jammed = level.bluespace_jammed
	new_vz.movementJammed = level.movementJammed
	new_vz.movementChance = level.movementChance
	new_vz.transitionLoops = level.transitionLoops
	if(level.transition_crosswrap_z && level.transition_crosswrap_z.len == 4)
		new_vz.transition_crosswrap_v = level.transition_crosswrap_z.Copy()
	new_vz.update_settings()
	vLevels |= new_vz
	return new_vz

/datum/map/proc/addVLevel(var/size_x = ALLOCATION_SMALL, var/size_y = null, var/skip_turf_setup = FALSE, var/fill_turf_type = null, var/system = FALSE)
	if(!size_y)
		size_y = size_x
	var/found_x = 0
	var/found_y = 0

	var/spacing = VIRTUAL_Z_SPACING

	// Check existing dynamic zLevels for available space using 2D bin packing
	var/datum/zLevel/z_to_use = null
	for(var/datum/zLevel/check_z in zLevels)
		if(istype(check_z, /datum/zLevel/dynamic))
			var/list/placement = SSmapping.try_place_vz(check_z, size_x, size_y, spacing)
			if(placement)
				z_to_use = check_z
				found_x = placement["x"]
				found_y = placement["y"]
				break

	// Create a new dynamic zLevel if no suitable one was found
	if(!z_to_use)
		z_to_use = new /datum/zLevel/dynamic()
		// Skip turf initialization during z-level creation to avoid lag
		skip_turf_init = TRUE
		world.maxz++
		skip_turf_init = FALSE
		z_to_use.z = world.maxz
		map.zLevels += z_to_use
		found_x = 1
		found_y = 1

	if(fill_turf_type)
		skip_turf_setup = FALSE

	// Create the new virtual_z
	var/datum/virtual_z/new_vz = new(z_to_use, size_x, size_y, found_x, found_y, skip_turf_setup, system)

	if(fill_turf_type)
		for(var/turf/T in new_vz.get_turfs())
			T.ChangeTurf(fill_turf_type)

	return new_vz

/datum/map/proc/addTransitVLevel(datum/shuttle/shuttle, var/system = FALSE)
	var/buffer = world.view
	var/list/dims = shuttle.get_size()
	var/shuttle_width = dims[1]
	var/shuttle_height = dims[2]
	var/datum/virtual_z/new_vz = addVLevel(shuttle_width + 2*buffer, shuttle_height + 2*buffer, system = system)
	new_vz.name = "[shuttle.name] - transit area"
	new_vz.level_type = VZ_TRANSIT
	new_vz.linked_shuttle = shuttle
	for(var/turf/T in new_vz.get_turfs(FALSE))
		var/turf/space/transit/t_turf = T.ChangeTurf(/turf/space/transit,0,0,1,0)
		t_turf.v = new_vz
		t_turf.pushdirection = shuttle.dir
		t_turf.update_icon()
		CHECK_TICK
	return new_vz

/datum/map/proc/addMapElementVLevel(var/datum/map_element/ME, var/rotation = 0, var/fill_turf = null, var/buffer_size = 5, var/system = FALSE)
	var/ortho = rotation && !(rotation % 180) // Flip width and height if rotated 90 or 270 degrees
	var/w_to_use = ortho? ME.height : ME.width
	var/h_to_use = ortho? ME.width : ME.height
	var/datum/virtual_z/new_vz = src.addVLevel(w_to_use + buffer_size * 2, h_to_use + buffer_size * 2, fill_turf_type = fill_turf, system = system)
	var/prefix = "Map Element: "
	if(istype(ME, /datum/map_element/away_mission))
		prefix = "Away Mission: "
	new_vz.name = "[prefix][ME.name]"
	new_vz.level_type = VZ_PROTECTED
	new_vz.gps_allowed = FALSE
	new_vz.teleJammed = VZ_TELEPORTATION_FORBIDDEN
	new_vz.bluespace_jammed = TRUE
	new_vz.movementJammed = TRUE
	new_vz.set_status(FALSE)
	return new_vz

// Returns the vLevel with the given ID
/datum/map/proc/getVLevel(var/vlevel_id)
	if(!vlevel_id)
		return null
	if(vlevel_id > SYSTEM_VLEVEL_OFFSET)
		var/system_index = vlevel_id - SYSTEM_VLEVEL_OFFSET
		if(system_index >= 1 && system_index <= systemVLevels.len)
			return systemVLevels[system_index]
		return null
	else if(vlevel_id >= 1 && vlevel_id <= vLevels.len)
		return vLevels[vlevel_id]
	return null

// Returns all vLevels (both system and regular) as a flat list
/datum/map/proc/getAllVLevels()
	return systemVLevels + vLevels

var/global/list/accessable_v_levels = list(
	"Default" = list()
)

/datum/map/proc/map_specific_init()

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
	var/z_above //The linked zLevel Z above, for multiZ
	var/z_below //Same, with below
	var/list/transition_crosswrap_z=null // list(z_north,z_south,z_east,z_west). when you hit the edge, instead of drifting to a random zlevel or looping on the current one, teleports you to the corresponding edge on the z-level in the list.
	var/planetside=FALSE //if the z-level is supposed to represent being on a planet, surface or underground.

	var/list/virtual_z_levels = list() //list of virtual z-levels that use this z-level as their base

/datum/zLevel/proc/post_mapload()
	return

/datum/zLevel/proc/reset_base_turf(old_type, fast_base_turf = FALSE)
	for(var/turf/T in block(locate(1,1,z),locate(world.maxx,world.maxy,z)))
		if(istype(T,old_type))
			if(fast_base_turf)
				new base_turf(T)
			else
				T.set_area(base_area)
				T.ChangeTurf(base_turf)

/datum/zLevel/proc/blur_holomap(var/area/aera, var/turf/truf)
	return FALSE

/datum/zLevel/proc/is_box_free(low_x, low_y, high_x, high_y)
	for(var/datum/virtual_z/vlevel in virtual_z_levels)
		if(low_x <= vlevel.x_max && vlevel.x_min <= high_x && low_y <= vlevel.y_max && vlevel.y_min <= high_y)
			return FALSE
	return TRUE

// Returns the minimum Y position that would have at least 'spacing' turfs of separation from all existing vlevels
// Returns 0 if no adjustment needed
/datum/zLevel/proc/get_min_valid_y(low_x, high_x, low_y, spacing)
	var/min_y = 0
	for(var/datum/virtual_z/vlevel in virtual_z_levels)
		// Check if we overlap in X (meaning we need Y separation)
		if(low_x <= vlevel.x_max && vlevel.x_min <= high_x)
			// Calculate minimum Y to have 'spacing' turfs of gap from this vlevel
			var/required_y = vlevel.y_max + spacing + 1
			if(required_y > low_y && required_y > min_y)
				min_y = required_y
	return min_y

// Returns the minimum X position that would have at least 'spacing' turfs of separation from all existing vlevels
// Returns 0 if no adjustment needed
/datum/zLevel/proc/get_min_valid_x(low_y, high_y, low_x, spacing)
	var/min_x = 0
	for(var/datum/virtual_z/vlevel in virtual_z_levels)
		// Check if we overlap in Y (meaning we need X separation)
		if(low_y <= vlevel.y_max && vlevel.y_min <= high_y)
			// Calculate minimum X to have 'spacing' turfs of gap from this vlevel
			var/required_x = vlevel.x_max + spacing + 1
			if(required_x > low_x && required_x > min_x)
				min_x = required_x
	return min_x

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

/datum/zLevel/krakenroid
	name = "krakenroid"

/datum/zLevel/krakenroid/blur_holomap(var/area/aera, var/turf/truf)
	if (istype(aera, /area/mine/explored) && !istype(truf, /turf/unsimulated/floor/airless))
		if (prob(80)) //blurring the shape of Snaxi's Kraken asteroid so it's a bit more subtle.
			return TRUE
	return FALSE

//for snowmap
/datum/zLevel/snowsurface
	name = "snowy surface"
	base_turf = /turf/unsimulated/floor/snow
	base_area = /area/surface/snow
	movementJammed = TRUE
	transitionLoops = TRUE
	planetside = TRUE

//for junglestation
/datum/zLevel/junglesurface
	name = "jungle surface"
	base_turf = /turf/unsimulated/floor/planetary/dirt/jungle
	base_area = /area/surface/jungle/landing //hacky workaround.
	planetside = TRUE

/datum/zLevel/jungleunderground
	name = "jungle underground"
	base_turf = /turf/unsimulated/floor/planetary/cave/jungle
	base_area = /area/surface/jungle/underground
	planetside = TRUE

/datum/zLevel/junglesurface/mining
	name = "Jungle Fallen Meteor"

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

/datum/zLevel/snowmine //not used on snaxi
	name = "belowMine"
	base_turf = /turf/unsimulated/floor/asteroid/cave/permafrost
	base_area = /area/mine/explored
	movementJammed = TRUE
	transitionLoops = TRUE
	movementChance = ZLEVEL_BASE_CHANCE * ZLEVEL_SPACE_MODIFIER

/datum/zLevel/snow //not used on snaxi
	name = "snow"
	base_turf = /turf/unsimulated/floor/snow
	base_area = /area/surface/snow
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

/datum/zLevel/dynamic
	name = "dynamic zLevel"
	movementJammed = TRUE
	transitionLoops = FALSE

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

/proc/get_base_turf(var/input_v_or_z)
	if(istype(input_v_or_z, /datum/virtual_z))
		var/datum/virtual_z/vz = input_v_or_z
		return vz.base_turf
	else if(isnum(input_v_or_z))
		var/datum/zLevel/L = map.zLevels[input_v_or_z]
		return L.base_turf
	else
		return /turf/space

//Area that blueprints should erase to
/proc/get_base_area(var/z)
	var/datum/zLevel/L = map.zLevels[z]
	if(L.base_area)
		return locate(L.base_area) //this is a type
	else
		return get_space_area()

/proc/change_base_turf(var/choice,var/new_base_path,var/update_old_base = 0)
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
		var/new_base_text = input("Filter to a turf type.","Turf Type") as text
		var/new_base_path = filter_typelist_input("Please select a turf path (cancel to reset to /turf/space).","Turf Path",get_matching_types(new_base_text,/turf))
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

/proc/increment_z()
	var/target_z = world.maxz + 1
	skip_turf_init = TRUE
	spawn(0)
		world.maxz++
	UNTIL(world.maxz == target_z)
	skip_turf_init = FALSE
