// VIRTUAL Z-LEVELS
// A virtual z-level is a "fake" z-level that exists within a true z-level.
// It allows us to partition a large z-level into smaller sections for
// generating planets, away missions, and shuttle transit zones without
// needing to create actual new z-levels in the game world.

/datum/virtual_z
	var/name = "Virtual Z-Level"
	var/id = 0
	var/size_x = ALLOCATION_SMALL
	var/size_y = ALLOCATION_SMALL
	var/datum/zLevel/parent_z
	var/active = TRUE
	var/level_type = VZ_DEFAULT

	var/list/area/areas = list()
	var/list/shuttle_landing_zones = list()
	var/datum/shuttle/linked_shuttle = null // If this virtual z-level is a transit area, the shuttle it's linked to

	var/placed_ruin = null
	var/list/placed_ruins = list()

	var/turf/base_turf = /turf/space
	var/base_area = null

	var/datum/planet_type/planet = null

	var/obj/machinery/telecomms/relay/planetary/comms_relay = null

	// Absolute coordinate bounds within the parent z-level
	var/x_min = 0
	var/x_max = 0
	var/y_min = 0
	var/y_max = 0

	// Daynight cycle support
	var/current_timeOfDay = TOD_DAYTIME
	var/current_light_power = 1
	var/next_firetime = 0
	var/list/daynight_turfs = list()
	var/weather_mod = 1 // Weather light modifier

	// Parameters
	var/gps_allowed = FALSE // Whether regular GPS functions in this vlevel
	var/teleJammed = VZ_TELEPORTATION_FORBIDDEN //Prevents teleportation into/out of the vlevel
	var/bluespace_jammed = FALSE
	var/movementJammed = TRUE //Prevents you from accessing the vlevel by drifting
	var/movementChance = 10 //Inhereted from parent z (for now)
	var/transition_channel = "Default" //The "galaxy" the vlevel is in; can only drift between vlevels in the same channel
	var/transitionLoops = FALSE //if true, transition sends you back to the same v-level
	var/list/transition_crosswrap_v=null // list(z_north,z_south,z_east,z_west). when you hit the edge, instead of drifting to a random zlevel or looping on the current one, teleports you to the corresponding edge on the z-level in the list.

/datum/virtual_z/New(var/datum/zLevel/z, var/input_size_x, var/input_size_y, var/input_x = 0, var/input_y = 0, var/skip_turf_setup = FALSE, var/system = FALSE)
	. = ..()
	if(!z)
		CRASH("Tried creating a virtual zLevel without a parent zLevel!")
	if(!SSmapping)
		CRASH("Tried creating a virtual zLevel before SSmapping was ready!")
	parent_z = z
	size_x = input_size_x
	size_y = input_size_y
	x_min = input_x
	y_min = input_y
	x_max = x_min + size_x - 1
	y_max = y_min + size_y - 1
	active = FALSE
	setup(skip_turf_setup, system)

/datum/virtual_z/proc/setup(var/skip_turf_setup = FALSE, var/system = FALSE)
	parent_z.virtual_z_levels |= src
	// System vLevels (centcomm dungeons) are stored in map.systemVLevels, not map.vLevels
	// Their IDs are 100 * parent_z + # of system vLevels on the parent z
	if(system)
		map.systemVLevels += src
		var/count = 0
		for(var/datum/virtual_z/VZ in map.systemVLevels)
			if(VZ.parent_z == parent_z)
				count++
		id = count + SYSTEM_VLEVEL_OFFSET * parent_z.z
		WORLD_X_OFFSET += list("[id]" = 0)
		WORLD_Y_OFFSET += list("[id]" = 0)
	else
		map.vLevels += src
		id = map.vLevels.len
		var/variance_x = floor(size_x/10)
		var/variance_y = floor(size_y/10)
		WORLD_X_OFFSET += list("[id]" = rand(-variance_x,variance_x))
		WORLD_Y_OFFSET += list("[id]" = rand(-variance_y,variance_y))

	if(!skip_turf_setup)
		initialize_turfs()
	if(size_x != ALLOCATION_FULL && size_y != ALLOCATION_FULL)
		spawn(0)
			make_borders()

	// Base vLevels (IDs 1-6) should always start active
	if(id <= 6)
		active = TRUE

/proc/list_world_offsets()
	var/listlen = WORLD_X_OFFSET.len
	message_admins("len: [listlen]")
	var/i = 1
	while(i <= listlen)
		message_admins("vz.id: [i], x offset: [WORLD_X_OFFSET[i]], y offset: [WORLD_Y_OFFSET[i]] ")
		i++

/datum/virtual_z/proc/initialize_turfs()
	var/list/turf/turfs = get_turfs()
	for(var/turf/T in turfs)
		if(!T)
			continue
		T.v = src
		var/area/A = get_area(T)
		if(!A || isspace(A))
			continue
		areas |= A
		A.v = src

/datum/virtual_z/proc/update_settings()
	if(!movementJammed)
		accessable_v_levels[transition_channel] += list("[id]" = movementChance)
	switch(teleJammed)
		if(VZ_TELEPORTATION_FORBIDDEN)
			for(var/area/A in areas)
				A.jammed = 2 //SUPER_JAMMED
		if(VZ_TELEPORTATION_EXPENSIVE)
			for(var/area/A in areas)
				A.jammed = 1 //JAMMED
		if(VZ_TELEPORTATION_ALLOWED)
			for(var/area/A in areas)
				A.jammed = 0

/datum/virtual_z/proc/get_turfs()
	var/effective_x_max = min(x_max, world.maxx)
	var/effective_y_max = min(y_max, world.maxy)
	var/turf/corner1 = locate(x_min, y_min, parent_z.z)
	var/turf/corner2 = locate(effective_x_max, effective_y_max, parent_z.z)
	return block(corner1, corner2)

/datum/virtual_z/proc/get_mobs()
	return mobs_in_vlevel(src, FALSE, mob_list)

/datum/virtual_z/proc/get_players()
	return mobs_in_vlevel(src, TRUE, mob_list)

/datum/virtual_z/proc/get_living_players()
	var/list/mob/players = get_players()
	var/list/mob/living/living_players = list()
	for(var/mob/M in players)
		if(istype(M, /mob/living))
			var/mob/living/L = M
			living_players |= L
	return living_players

/////////////////////////////////////
///////// SUBSYSTEM PAUSING /////////
/////////////////////////////////////
/datum/virtual_z/proc/set_status(var/active_state)
	if(id <= 6) // Don't pause system vLevels (station, centcomm, etc - IDs 101+)
		return

	active = active_state
	var/list/mob/mobs = get_mobs()
	for(var/mob/living/L in mobs)
		if(istype(L))
			L.paused = !active_state

/datum/virtual_z/proc/mob_entered(var/mob/living/M)
	if(!M || !istype(M))
		return

	if(M.client)
		set_status(TRUE)

/datum/virtual_z/proc/mob_exited(var/mob/living/M)
	if(!M || !istype(M))
		return

	if(M.client)
		var/list/mob/living/players = get_living_players()
		if(!players.len)
			set_status(FALSE)

//////////////////////////////////////
/////// COORDINATE TRANSLATION ///////
//////////////////////////////////////
//Get virtual x from true x
/datum/virtual_z/proc/vx(var/atom/A = null, var/coord = null)
	if(A)
		var/turf/T = get_turf(A)
		if(T)
			coord = T.x
	if(!coord)
		return null
	return coord - x_min + 1

//Get virtual y from true y
/datum/virtual_z/proc/vy(var/atom/A = null, var/coord = null)
	if(A)
		var/turf/T = get_turf(A)
		if(T)
			coord = T.y
	if(!coord)
		return null
	return coord - y_min + 1

//Get virtual z from true z
/datum/virtual_z/proc/vz(var/atom/A)
	return id

//Get true x from virtual x
/datum/virtual_z/proc/x(var/coord)
	return coord + x_min - 1

//Get true y from virtual y
/datum/virtual_z/proc/y(var/coord)
	return coord + y_min - 1

//Get true z from virtual z
/datum/virtual_z/proc/z()
	return parent_z.z

//////////////////////////////////
///////// MAP GENERATION /////////
//////////////////////////////////
/datum/virtual_z/proc/make_borders()
	var/z_level = z()
	var/list/sides = list(
		"North" = TRUE,
		"South" = TRUE,
		"East" = TRUE,
		"West" = TRUE
		)
	var/list/spacing = list(
		"North" = VIRTUAL_Z_SPACING,
		"South" = VIRTUAL_Z_SPACING,
		"East" = VIRTUAL_Z_SPACING,
		"West" = VIRTUAL_Z_SPACING
	)
	if(x_min <= VIRTUAL_Z_SPACING)
		if(x_min == 0)
			spacing["West"] = 0
			sides["West"] = FALSE
		else
			spacing["West"] = x_min
	if(y_min <= VIRTUAL_Z_SPACING)
		if(y_min == 0)
			spacing["North"] = 0
			sides["North"] = FALSE
		else
			spacing["North"] = y_min
	if(world.maxx - x_max <= VIRTUAL_Z_SPACING)
		if(world.maxx - x_max == 0)
			spacing["East"] = 0
			sides["East"] = FALSE
		else
			spacing["East"] = world.maxx - x_max
	if(world.maxy - y_max <= VIRTUAL_Z_SPACING)
		if(world.maxy - y_max == 0)
			spacing["South"] = 0
			sides["South"] = FALSE
		else
			spacing["South"] = world.maxy - y_max

	var/list/turf/border_turfs = list()

	var/outer_x_min = max(1, x_min - spacing["West"])
	var/outer_x_max = min(world.maxx, x_max + spacing["East"])
	var/outer_y_min = max(1, y_min - spacing["South"])
	var/outer_y_max = min(world.maxy, y_max + spacing["North"])

	var/list/turf/outer_block = block(locate(outer_x_min, outer_y_min, z_level), locate(outer_x_max, outer_y_max, z_level))
	var/list/turf/inner_block = block(locate(x_min, y_min, z_level), locate(x_max, y_max, z_level))

	border_turfs = outer_block - inner_block
	for(var/turf/T in border_turfs)
		T.ChangeTurf(/turf/unsimulated/border)

// Assigns all appropriate turfs on the vlevel to the provided climate system
/datum/virtual_z/proc/register_weather_turfs(var/datum/climate/climate)
	if(!climate)
		return

	var/list/turf/turfs = get_turfs()
	for(var/turf/T in turfs)
		var/area/A = get_area(T)
		if(isopensurface(A))
			climate.register_weather_turf(T)

// Replaces certain turfs in the ruin based on the planet's characteristics
/datum/virtual_z/proc/post_process_ruin_turfs(datum/map_element/ruin/ruin_to_use, list/spawned_objects)
	if(!ruin_to_use || !planet)
		return

	var/datum/planet_type/P = planet
	var/default_baseturf = P.default_baseturf

	var/datum/planetGenerator/mapgen = new P.mapgen
	var/mineral_replacement = null

	// Get mineral replacement type from cave biome table if available
	if(mapgen.cave_biome_table && mapgen.cave_biome_table.len)
		for(var/temp_key in mapgen.cave_biome_table)
			var/list/humidity_list = mapgen.cave_biome_table[temp_key]
			for(var/humidity_key in humidity_list)
				var/biome_type = humidity_list[humidity_key]
				var/datum/biome/cave_biome = SSmapping.biomes[biome_type]
				if(cave_biome && istype(cave_biome, /datum/biome/cave))
					var/datum/biome/cave/cave_biome_casted = cave_biome
					if(cave_biome_casted.closed_turf_types && cave_biome_casted.closed_turf_types.len)
						mineral_replacement = cave_biome_casted.closed_turf_types[1]
						break
			if(mineral_replacement)
				break

	// Fallback to a default mineral type if none found
	if(!mineral_replacement)
		mineral_replacement = /turf/unsimulated/mineral/random

	// Process all turfs in the spawned objects
	for(var/area/A in spawned_objects)
		if(istype(A) && !isspace(A))
			A.v = src
			areas |= A  // Add ruin areas to the virtual_z's areas list for proper get_turfs() lookups
			if(A?.base_turf_type != default_baseturf)
				A.base_turf_type = default_baseturf
	for(var/atom/AA in spawned_objects)
		if(isturf(AA))
			var/turf/T = AA
			T.v = src
			if(istype(T, /turf/unsimulated/floor/asteroid))
				if(default_baseturf)
					T.ChangeTurf(default_baseturf)
			else if(istype(T, /turf/unsimulated/mineral))
				T.ChangeTurf(mineral_replacement)
		else if(isobj(AA))
			var/obj/O = AA
			O.post_ruin_load()

/datum/virtual_z/proc/place_ruin(datum/map_element/ruin/ruin_to_use)
	if(!ruin_to_use)
		return null

	ruin_to_use.assign_dimensions()

	var/safe_x_min = x_min + RUIN_PLACEMENT_PADDING
	var/safe_x_max = x_max - ruin_to_use.width - RUIN_PLACEMENT_PADDING
	var/safe_y_min = y_min + RUIN_PLACEMENT_PADDING
	var/safe_y_max = y_max - ruin_to_use.height - RUIN_PLACEMENT_PADDING

	// Ensure we have valid placement area
	if(safe_x_max < safe_x_min || safe_y_max < safe_y_min)
		CRASH("Warning: Ruin [ruin_to_use.name] ([ruin_to_use.width]x[ruin_to_use.height]) too large for virtual Z with size: [size_x]x[size_y] - skipping ruin placement")
	// Try up to 20 times to find a valid placement location
	var/max_attempts = 20
	var/turf/ruin_turf = null

	var/ruin_separation = 10

	for(var/attempt = 1; attempt <= max_attempts; attempt++)
		var/turf/candidate_turf = locate(
			rand(safe_x_min, safe_x_max),
			rand(safe_y_min, safe_y_max),
			z()
		)

		// Check if any turfs in the ruin footprint have NO_RUINS flag
		var/valid_location = TRUE
		for(var/dx = 0; dx < ruin_to_use.width; dx++)
			for(var/dy = 0; dy < ruin_to_use.height; dy++)
				var/turf/check_turf = locate(candidate_turf.x + dx, candidate_turf.y + dy, z())
				if(check_turf && (check_turf.turf_flags & NO_RUINS))
					valid_location = FALSE
					break
			if(!valid_location)
				break

		// Check for minimum separation from other placed ruins
		if(valid_location)
			for(var/list/placed in placed_ruins)
				var/placed_x = placed[1]
				var/placed_y = placed[2]
				var/placed_w = placed[3]
				var/placed_h = placed[4]
				var/new_x_min = candidate_turf.x - ruin_separation
				var/new_x_max = candidate_turf.x + ruin_to_use.width + ruin_separation
				var/new_y_min = candidate_turf.y - ruin_separation
				var/new_y_max = candidate_turf.y + ruin_to_use.height + ruin_separation
				var/placed_x_max = placed_x + placed_w
				var/placed_y_max = placed_y + placed_h
				if(!(new_x_max < placed_x || new_x_min > placed_x_max || new_y_max < placed_y || new_y_min > placed_y_max))
					valid_location = FALSE
					break

		if(valid_location)
			ruin_turf = candidate_turf
			break
		else if(attempt == max_attempts)
			return null

	if(!ruin_turf)
		return null

	var/load_result = ruin_to_use.load(ruin_turf.x - 1, ruin_turf.y - 1, z(), 0, TRUE, TRUE)

	if(load_result)
		placed_ruins += list(list(ruin_turf.x, ruin_turf.y, ruin_to_use.width, ruin_to_use.height))
		post_process_ruin_turfs(ruin_to_use, load_result)
		return list("turf" = ruin_turf, "objects" = load_result)
	else
		CRASH("Failed to load ruin [ruin_to_use.name] at [ruin_turf.x], [ruin_turf.y]")

/datum/virtual_z/proc/place_story_ruins()
	var/list/story_ruin_types = subtypesof(/datum/map_element/ruin/story)

	var/ruin_type = pick(story_ruin_types)
	var/datum/map_element/ruin/story/story_ruin = new ruin_type()
	var/datum/story_theme/theme = get_compatible_story_theme(story_ruin.theme)

	var/max_age = 200
	var/story_year = game_year - rand(1, max_age)

	var/character_name = theme.generate_character_name()

	var/disease_type = null
	if(prob(STORY_DISEASE_CHANCE))
		var/list/allowed_disease_types = list(
			/datum/disease2/disease/virus,
			/datum/disease2/disease/bacteria,
			/datum/disease2/disease/prion,
			/datum/disease2/disease/fungus,
			/datum/disease2/disease/parasite
		)
		disease_type = pick(allowed_disease_types)
		var/datum/disease2/disease/temp_disease = new disease_type()
		theme.disease_log_entry = theme.get_disease_entry(temp_disease.form)
		qdel(temp_disease)

	story_ruin.assigned_theme = theme
	story_ruin.story_year = story_year

	placed_ruin = story_ruin

	var/list/result = place_ruin(story_ruin)
	if(!result)
		qdel(story_ruin)
		return

	var/list/spawned_objects = result["objects"]

	var/loot_type = pick(subtypesof(/datum/loot_table))
	if(loot_type)
		theme.stashed_loot_type = loot_type
		spawn_story_loot(spawned_objects, story_ruin, loot_type)

	for(var/atom/A in spawned_objects)
		if(istype(A, /obj/effect/landmark/story))
			var/obj/effect/landmark/story/landmark = A
			landmark.assigned_theme = theme
			landmark.story_year = story_year
			landmark.character_name = character_name
			landmark.disease_type = disease_type
			landmark.spawn_story_entity()
		else if(istype(A, /obj/machinery/old_database))
			var/obj/machinery/old_database/db = A
			db.assigned_theme = theme
			db.story_year = story_year
			db.character_name = character_name

/datum/virtual_z/proc/spawn_story_loot(list/spawned_objects, datum/map_element/ruin/story/story_ruin, loot_type)
	if(!spawned_objects || !story_ruin || !loot_type)
		return

	var/list/ruin_turfs = list()
	for(var/atom/A in spawned_objects)
		ruin_turfs |= get_turf(A)

	var/list/valid_turfs = list()
	for(var/turf/T in ruin_turfs)
		if(!isfloor(T))
			continue

		var/has_structure = FALSE
		for(var/obj/O in T)
			if(istype(O,/obj/structure) || istype(O,/obj/machinery))
				has_structure = TRUE
				break
		if(has_structure)
			continue

		var/adj_wall = FALSE
		var/adj_door = FALSE
		for(var/turf/adj in orange(1, T))
			if(iswall(adj))
				adj_wall = TRUE
			for(var/obj/machinery/door/D in adj)
				adj_door = TRUE
				break
			if(adj_door)
				break

		if(!adj_wall || adj_door)
			continue

		valid_turfs += T

	if(!valid_turfs.len)
		return

	var/turf/chosen_turf = pick(valid_turfs)
	new /obj/abstract/loot_spawner/story(chosen_turf, loot_type, story_ruin.loot_containers)

/////////////////////////////////////
////////// SHUTTLE HELPERS //////////
/////////////////////////////////////
/datum/virtual_z/proc/get_shuttle_landing_zone(var/datum/shuttle/shuttle, var/list/size)
	if(!shuttle)
		return null

	// Check if this shuttle already has a landing zone on this planet
	if(shuttle_landing_zones[shuttle])
		var/datum/landing_zone/existing_lz = shuttle_landing_zones[shuttle]
		if(existing_lz?.docking_port?.loc)
			return existing_lz.docking_port
		else
			shuttle_landing_zones -= shuttle
			shuttle.unregister_event(/event/shuttle_arrived, src, nameof(src::on_shuttle_arrived()))
			shuttle.unregister_event(/event/shuttle_departed, src, nameof(src::on_shuttle_departed()))

	var/datum/landing_zone/new_lz = new(shuttle, planet)
	if(!new_lz || !new_lz.docking_port)
		return
	shuttle_landing_zones[shuttle] = new_lz

	shuttle.register_event(/event/shuttle_arrived, src, nameof(src::on_shuttle_arrived()))
	shuttle.register_event(/event/shuttle_departed, src, nameof(src::on_shuttle_departed()))

	return new_lz.docking_port

/datum/virtual_z/proc/spawn_lz_warnings(var/datum/shuttle/shuttle)
	if(!shuttle)
		return

	var/datum/landing_zone/lz = shuttle_landing_zones[shuttle]
	if(!lz)
		return

	lz.spawn_warnings()

/datum/virtual_z/proc/clear_lz_warnings(var/datum/shuttle/shuttle)
	if(!shuttle)
		return

	var/datum/landing_zone/lz = shuttle_landing_zones[shuttle]
	if(!lz)
		return

	lz.clear_warnings()

/datum/virtual_z/proc/reset_lz_turfs(var/datum/shuttle/shuttle)
	if(!shuttle)
		return

	var/datum/landing_zone/lz = shuttle_landing_zones[shuttle]
	if(!lz)
		return

	lz.reset_turfs()

// Called when shuttle arrives at a virtual_z
/datum/virtual_z/proc/on_shuttle_arrived(var/datum/virtual_z/vz, var/datum/shuttle/shuttle)
	if(vz != src)
		return
	if(!shuttle)
		return
	clear_lz_warnings(shuttle)

// Called when shuttle departs from a virtual_z
/datum/virtual_z/proc/on_shuttle_departed(var/datum/virtual_z/vz, var/datum/shuttle/shuttle)
	if(vz != src)
		return
	if(!shuttle)
		return
	reset_lz_turfs(shuttle)

/proc/vz_at_loc(var/x_co,var/y_co,var/z_co)
	var/datum/zLevel/true_z = map.zLevels[z_co]
	if(!true_z)
		return null
	for(var/datum/virtual_z/VZ in true_z.virtual_z_levels)
		if(x_co >= VZ.x_min && x_co <= VZ.x_max && y_co >= VZ.y_min && y_co <= VZ.y_max)
			return VZ
	return null
