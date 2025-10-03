/**
 * # Mapping Subsystem
 *
 * Handles map generation, including vaults, away missions, and procedural generation.
 *
 * This subsystem is responsible for:
 * * Initializing away missions at round start
 * * Generating fixed and random vaults/structures in space
 * * Creating asteroid secrets and hobo shacks
 * * Managing procedurally generated planets and biomes
 * * Allocating sectors for planets in z-levels
 * * Handling planet-specific map generation and climate systems
 */

var/datum/subsystem/mapping/SSmapping

/datum/subsystem/mapping
	name       = "Map"
	init_order = SS_INIT_MAP
	flags      = SS_NO_FIRE

	/// All possible biomes in assoc list as type || instance
	var/list/biomes = list()
	/// All possible planet types available for generation
	var/list/planet_types = list(
		/datum/planet_type/beach,
		/datum/planet_type/desert,
		/datum/planet_type/grass,
		/datum/planet_type/lava,
		/datum/planet_type/snow,
		/datum/planet_type/xeno
	)
	/// All spawned planets
	var/list/planets = list()
	/// All sector allocations for planets
	var/list/allocations = list()

/datum/subsystem/mapping/New()
	NEW_SS_GLOBAL(SSmapping)


/datum/subsystem/mapping/Initialize(timeofday)
	if (config.enable_roundstart_away_missions)
		log_startup_progress("Attempting to generate an away mission...")
		createRandomZlevel()

	var/watch
	if (!config.skip_fixedvault_generation)
		watch = start_watch()
		log_startup_progress("Placing fixed space structures...")
		generate_fixedvaults()
		log_startup_progress("Finished placing fixed structures in [stop_watch(watch)]s.")
	else
		log_startup_progress("Not generating fixed vaults - SKIP_VAULT_GENERATION found in config/config.txt")

	if (!config.skip_vault_generation)
		watch = start_watch()
		log_startup_progress("Placing random space structures...")
		generate_vaults()
		generate_asteroid_secrets()
		make_mining_asteroid_secrets() // loops 3 times
		log_startup_progress("Finished placing structures in [stop_watch(watch)]s.")
	else
		log_startup_progress("Not generating vaults - SKIP_VAULT_GENERATION found in config/config.txt")

	//hobo shack generation, one shack will spawn, 1/3 chance of two shacks
	if(!map.skip_hobo_shack)
		generate_hoboshack()
		if (prob(33))
			generate_hoboshack()

	watch = start_watch()
	for(var/datum/zLevel/z in map.zLevels)
		var/watch_prim = start_watch()
		z.post_mapload()
		log_debug("Finished with zLevel [z.z] in [stop_watch(watch_prim)]s.", FALSE)
	log_debug("Finished calling post on zLevels in [stop_watch(watch)]s.", FALSE)

	watch = start_watch()
	map.map_specific_init()
	log_debug("Finished map-specific inits in [stop_watch(watch)]s.", FALSE)

	spawn_map_pickspawners() //this is down here so that it calls after allll the vaults etc are done spawning - if in the future some pickspawners don't fire, it's because this needs moving

	watch = start_watch()
	initialize_biomes()
	create_procgen_level()
	log_startup_progress("Finished initializing procgen in [stop_watch(watch)]s.")

	..()

/proc/generate_planet(mob/user)
	if(!user)
		return
	if(!check_rights(R_ADMIN))
		return

	var/list/planet_types = list()
	for(var/planet_path in subtypesof(/datum/planet_type))
		planet_types += planet_path

	var/chosen_planet_type = input(user, "Select a planet type to generate:", "Planet Generation") as null|anything in planet_types
	if(!chosen_planet_type)
		return

	var/list/ruin_types = list()
	for(var/ruin_path in subtypesof(/datum/map_element/mining_surprise))
		ruin_types += ruin_path

	var/chosen_ruin_type = input(user, "Select a ruin to place on the planet (random if no selection):", "Vault Selection") as null|anything in ruin_types
	if(!chosen_ruin_type)
		chosen_ruin_type = pick(ruin_types)

	SSmapping.spawn_planet(chosen_planet_type, chosen_ruin_type)

/**
 * Creates a grid of 25 99x99 sectors for procedural generation
 *
 * Adds a new z-level and creates a grid structure with border turfs
 * separating each sector. Each sector can hold a different planet.
 */
/datum/subsystem/mapping/proc/create_procgen_level()
	world.maxz += 1
	map.addZLevel(new /datum/zLevel/away, world.maxz, TRUE, TRUE)
	for(var/x = 1,  x < world.maxx, x++)
		for(var/y = 1, y < world.maxy, y++)
			if(!(x % SECTOR_SIZE) || !(y % SECTOR_SIZE))
				var/turf/T = locate(x,y,world.maxz)
				T.ChangeTurf(/turf/unsimulated/border)

/**
 * Initialize all biomes
 *
 * Creates instances of all biome subtypes and stores them in an associative list
 * as type || instance for quick lookup during map generation.
 */
/datum/subsystem/mapping/proc/initialize_biomes()
	for(var/biome_path in subtypesof(/datum/biome))
		var/datum/biome/biome_instance = new biome_path()
		biomes[biome_path] += biome_instance

/**
 * Spawns a new planet with optional ruin
 *
 * Creates a new planet in the procgen z-level, generates terrain using the planet's
 * map generator, places an optional ruin, populates the terrain with features,
 * initializes day/night cycle and weather systems.
 *
 * Arguments:
 * * planet_datum - The planet type path or instance to spawn
 * * ruin_type - Optional ruin type to place on the planet
 *
 * Returns:
 * * The z-level number where the planet was spawned
 */
/datum/subsystem/mapping/proc/spawn_planet(datum/planet_type/planet_datum, ruin_type)
	var/datum/planet_type/newplanet = new planet_datum
	var/datum/planetGenerator/mapgen = new newplanet.mapgen
	planets += newplanet

	var/datum/map_element/mining_surprise/used_ruin = ispath(ruin_type) ? (new ruin_type) : ruin_type
	var/datum/allocation/A = assign_allocation(newplanet, world.maxz)

	// Generate base terrain
	mapgen.generate_turfs(A.turfs)

	// Place optional ruin before populating terrain
	var/list/ruin_turfs = list()
	var/list/ruin_templates = list()
	if(used_ruin)
		var/placement_result = place_ruin_in_allocation(used_ruin, A)
		if(placement_result)
			var/list/result_data = placement_result
			ruin_turfs[used_ruin.name] = result_data["turf"]
			ruin_templates[used_ruin.name] = used_ruin

	// Populate turfs AFTER generating the ruin to prevent:
	// * Features from spawning inside the ruin
	// * The ruin from being spaced when it spawns in
	mapgen.populate_turfs(turfs_from_sector(A.sector, world.maxz))

	// Initialize day/night cycle for this planet
	newplanet.build_daynight_turflist()

	// Set a random time of day for the new planet
	var/list/possible_times = list(TOD_MORNING, TOD_SUNRISE, TOD_DAYTIME, TOD_AFTERNOON, TOD_SUNSET, TOD_NIGHTTIME)
	newplanet.current_timeOfDay = pick(possible_times)

	// Set next_firetime based on the randomly chosen time to match natural cycle durations
	switch(newplanet.current_timeOfDay)
		if(TOD_MORNING) newplanet.next_firetime = world.time + 5 MINUTES
		if(TOD_SUNRISE) newplanet.next_firetime = world.time + 3 MINUTES
		if(TOD_DAYTIME) newplanet.next_firetime = world.time + 14 MINUTES
		if(TOD_AFTERNOON) newplanet.next_firetime = world.time + 15 MINUTES
		if(TOD_SUNSET) newplanet.next_firetime = world.time + 3 MINUTES
		if(TOD_NIGHTTIME) newplanet.next_firetime = world.time + 36 MINUTES

	// Apply initial lighting to the planet (immediate = TRUE for instant visibility)
	SSDayNight.update_planet_lighting(newplanet, immediate = TRUE)

	if(newplanet.climate_type)
		newplanet.climate = SSweather.set_climate(newplanet.climate_type, world.maxz, A)
		register_weather_turfs(newplanet.climate, mapgen, A)
		SSweather.fire()

	message_admins("Planet '[newplanet.planet_name]' generated successfully at z-level [world.maxz]")
	return world.maxz

/**
 * Registers open turfs from a planet with its climate for weather overlays
 *
 * Iterates through all turfs in the allocation and registers those matching
 * the biome's open_turf_types with the climate system.
 * Arguments:
 * * climate - The climate datum to register turfs with
 * * mapgen - The planet generator containing biome information
 * * allocation - The allocation containing the planet's turfs
 */
/datum/subsystem/mapping/proc/register_weather_turfs(var/datum/climate/climate, var/datum/planetGenerator/mapgen, var/datum/allocation/allocation)
	if(!climate || !mapgen || !allocation)
		return

	if(!mapgen.biome_table)
		return

	// Collect all unique open turf types from all biomes in the biome table
	var/list/all_open_turf_types = list()
	for(var/temp_key in mapgen.biome_table)
		var/list/humidity_list = mapgen.biome_table[temp_key]
		for(var/humidity_key in humidity_list)
			var/biome_type = humidity_list[humidity_key]
			var/datum/biome/biome = new biome_type
			if(biome.open_turf_types)
				for(var/turf_type in biome.open_turf_types)
					all_open_turf_types[turf_type] = TRUE
			qdel(biome)

	if(!all_open_turf_types.len)
		return

	// Register all turfs in the allocation that match any open turf type from any biome
	for(var/turf/T in allocation.turfs)
		for(var/turf_type in all_open_turf_types)
			if(istype(T, turf_type))
				climate.register_weather_turf(T)
				break

/**
 * Post-processes ruin turfs to match the planet environment
 *
 * After a ruin is placed on a planet, this proc replaces generic asteroid floors
 * and mineral walls with planet-appropriate turf types to ensure visual consistency.
 *
 * Arguments:
 * * ruin - The map element/ruin that was placed
 * * allocation - The sector allocation containing planet information
 * * spawned_objects - List of all objects spawned by the ruin template
 */
/datum/subsystem/mapping/proc/post_process_ruin_turfs(datum/map_element/ruin, datum/allocation/allocation, list/spawned_objects)
	if(!ruin || !allocation || !allocation.ptype)
		return

	var/datum/planet_type/planet = allocation.ptype
	var/default_baseturf = planet.default_baseturf

	// Get the first closed turf type from the planet generator
	var/datum/planetGenerator/mapgen = new planet.mapgen
	var/mineral_replacement = null

	// Find the first closed turf type from any biome in the cave_biome_table
	if(mapgen.cave_biome_table && mapgen.cave_biome_table.len)
		for(var/temp_key in mapgen.cave_biome_table)
			var/list/humidity_list = mapgen.cave_biome_table[temp_key]
			for(var/humidity_key in humidity_list)
				var/biome_type = humidity_list[humidity_key]
				var/datum/biome/cave_biome = SSmapping.biomes[biome_type]
				if(cave_biome && istype(cave_biome, /datum/biome/cave))
					var/datum/biome/cave/cave_biome_casted = cave_biome
					if(cave_biome_casted.closed_turf_types && cave_biome_casted.closed_turf_types.len)
						// Get the first closed turf type (highest weighted)
						mineral_replacement = cave_biome_casted.closed_turf_types[1]
						break
			if(mineral_replacement)
				break

	// Fallback to a default mineral type if none found
	if(!mineral_replacement)
		mineral_replacement = /turf/unsimulated/mineral/random

	// Process all turfs in the spawned objects
	for(var/atom/A in spawned_objects)
		if(isturf(A))
			var/turf/T = A

			// Replace floor turfs with planet's default baseturf
			if(istype(T, /turf/unsimulated/floor/asteroid))
				if(default_baseturf)
					T.ChangeTurf(default_baseturf)

			// Replace mineral turfs with planet's mineral type
			else if(istype(T, /turf/unsimulated/mineral))
				T.ChangeTurf(mineral_replacement)

/**
 * Places a ruin within an allocation's sector boundaries
 *
 * Finds a safe random location within the sector for the ruin, loads the ruin template,
 * and post-processes the turfs to match the planet environment.
 *
 * Arguments:
 * * ruin - The map element/ruin to place
 * * allocation - The sector allocation to place the ruin in
 *
 * Returns:
 * * A list containing "turf" (placement location) and "objects" (spawned objects) on success, or null on failure
 */
/datum/subsystem/mapping/proc/place_ruin_in_allocation(datum/map_element/ruin, datum/allocation/allocation)
	if(!ruin || !allocation)
		return null

	// Initialize the dimensions of the map element before using them
	ruin.assign_dimensions()

	// Calculate sector boundaries for proper placement within allocation
	var/list/bounds = get_sector_bounds(allocation.sector)

	// Calculate safe placement bounds within the sector, with padding
	var/safe_x_min = bounds["x_min"] + RUIN_PLACEMENT_PADDING
	var/safe_x_max = bounds["x_max"] - ruin.width - RUIN_PLACEMENT_PADDING
	var/safe_y_min = bounds["y_min"] + RUIN_PLACEMENT_PADDING
	var/safe_y_max = bounds["y_max"] - ruin.height - RUIN_PLACEMENT_PADDING

	// Ensure we have valid placement area
	if(safe_x_max < safe_x_min || safe_y_max < safe_y_min)
		CRASH("Warning: Ruin [ruin.name] ([ruin.width]x[ruin.height]) too large for sector [allocation.sector[1]],[allocation.sector[2]] - skipping ruin placement")

	// Find random placement location within safe bounds
	var/turf/ruin_turf = locate(
		rand(safe_x_min, safe_x_max),
		rand(safe_y_min, safe_y_max),
		allocation.z
	)

	// Note: load() adds +1 to x and y coordinates, so we subtract 1 to place at exact location
	var/load_result = ruin.load(ruin_turf.x - 1, ruin_turf.y - 1, allocation.z, 0, TRUE, TRUE)

	if(load_result)
		post_process_ruin_turfs(ruin, allocation, load_result)
		return list("turf" = ruin_turf, "objects" = load_result)
	else
		CRASH("Failed to load ruin [ruin.name] at [ruin_turf.x], [ruin_turf.y]")

/**
 * Assigns a planet to a sector
 *
 * Allocates a sector in the procgen grid for a planet, calculates the sector coordinates,
 * and retrieves all turfs within that sector.
 *
 * Arguments:
 * * planet_type - The planet type to assign to the sector
 * * z_id - The z-level ID where the sector exists
 *
 * Returns:
 * * The newly created allocation datum
 */
/datum/subsystem/mapping/proc/assign_allocation(var/datum/planet_type/planet_type, z_id)
	var/datum/allocation/A = new
	var/sector_count = allocations.len + 1
	A.sector = list((sector_count - 1) % 5 + 1, ceil(sector_count / 5))
	A.ptype = planet_type
	A.z = z_id
	A.turfs = turfs_from_sector(A.sector, z_id)
	allocations += A
	planet_type.allocation = A
	return A

/**
 * Calculates the coordinate bounds for a sector
 *
 * Helper function to avoid duplicating sector bound calculation logic.
 *
 * Arguments:
 * * sector - List containing [x, y] sector coordinates
 *
 * Returns:
 * * An associative list with keys: "x_min", "x_max", "y_min", "y_max"
 */
/datum/subsystem/mapping/proc/get_sector_bounds(var/list/sector)
	var/sector_x = sector[1]
	var/sector_y = sector[2]
	return list(
		"x_min" = 1 + (sector_x - 1) * SECTOR_SIZE,
		"x_max" = sector_x * SECTOR_SIZE - 1,
		"y_min" = 1 + (sector_y - 1) * SECTOR_SIZE,
		"y_max" = sector_y * SECTOR_SIZE - 1
	)

/**
 * Gets all turfs within a sector
 *
 * Calculates the bounds of a sector in the procgen grid and returns all turfs within it.
 *
 * Arguments:
 * * sector - List containing [x, y] sector coordinates
 * * z_in - The z-level to get turfs from
 *
 * Returns:
 * * A list of all turfs in the sector
 */
/datum/subsystem/mapping/proc/turfs_from_sector(var/list/sector, var/z_in)
	var/list/bounds = get_sector_bounds(sector)
	return block(locate(bounds["x_min"], bounds["y_min"], z_in), locate(bounds["x_max"], bounds["y_max"], z_in))

/**
 * Gets all turfs from a planet's allocation
 *
 * Arguments:
 * * planet - The planet type to get turfs from
 *
 * Returns:
 * * A list of all turfs in the planet's allocated sector, or an empty list if no allocation
 */
/datum/subsystem/mapping/proc/turfs_from_planet(var/datum/planet_type/planet)
	if(!planet || !planet.allocation)
		return list()
	var/datum/allocation/A = planet.allocation
	return A.turfs

/**
 * Gets the allocation at given coordinates or turf
 *
 * Looks up which sector allocation contains the specified coordinates.
 *
 * Arguments:
 * * x - X coordinate (optional if trf provided)
 * * y - Y coordinate (optional if trf provided)
 * * z - Z level (defaults to 7, optional if trf provided)
 * * trf - Turf to look up allocation for (takes priority over x/y/z)
 *
 * Returns:
 * * The allocation datum for the sector, or null if none found
 */
/datum/subsystem/mapping/proc/get_allocation(var/x = 0, var/y = 0, var/z = 7, var/turf/trf = null)
	if(trf)
		x = trf.x
		y = trf.y
		z = trf.z
	var/sector_x = ceil(x / SECTOR_SIZE)
	var/sector_y = ceil(y / SECTOR_SIZE)
	for(var/datum/allocation/A in allocations)
		if(A.sector[1] == sector_x && A.sector[2] == sector_y && A.z == z)
			return A

/**
 * Finds a suitable landing zone for a shuttle on a planet
 *
 * Searches the planet's sector for a flat area large enough to accommodate
 * the specified dimensions, staying at least 11 tiles from sector edges.
 * Returns a random valid location to provide variety.
 *
 * Arguments:
 * * alloc - The planet allocation to search within
 * * size - List containing [width, height] of the landing area needed
 *
 * Returns:
 * * The top-left turf of a suitable landing zone, or null if no valid location found
 */
/datum/subsystem/mapping/proc/get_landing_zone(var/datum/allocation/alloc,var/list/size)
	if (!alloc || !size || size.len != 2)
		return null
	var/x_dim = size[1]
	var/y_dim = size[2]
	var/list/turf/search_turfs = turfs_from_sector(alloc.sector, alloc.z)

	// Get sector boundaries to calculate relative positions
	var/list/bounds = get_sector_bounds(alloc.sector)
	var/x_min = bounds["x_min"]
	var/y_min = bounds["y_min"]

	// Create matrix with relative coordinates
	var/datum/turf_matrix[SECTOR_SIZE][SECTOR_SIZE]
	for (var/turf/T in search_turfs)
		var/rel_x = T.x - x_min + 1
		var/rel_y = T.y - y_min + 1
		turf_matrix[rel_x][rel_y] = T

	// Define safe zone boundaries (accounting for edge buffer and shuttle size)
	var/safe_x_min = LANDING_ZONE_EDGE_BUFFER + 1
	var/safe_x_max = SECTOR_SIZE - LANDING_ZONE_EDGE_BUFFER - x_dim
	var/safe_y_min = LANDING_ZONE_EDGE_BUFFER + 1
	var/safe_y_max = SECTOR_SIZE - LANDING_ZONE_EDGE_BUFFER - y_dim

	if(safe_x_max < safe_x_min || safe_y_max < safe_y_min)
		return null // Not enough space for safe landing

	// Create randomized search list within safe boundaries
	var/list/search_positions = list()
	for(var/rel_x = safe_x_min; rel_x <= safe_x_max; rel_x++)
		for(var/rel_y = safe_y_min; rel_y <= safe_y_max; rel_y++)
			var/turf/T = turf_matrix[rel_x][rel_y]
			if(T && !iswall(T) && !istype(T, /turf/unsimulated/mineral))
				search_positions += T

	// Shuffle the search positions for randomization
	if(!search_positions.len)
		return null

	search_positions = shuffle(search_positions)

	// Search through randomized positions
	for(var/turf/T in search_positions)
		var/rel_x = T.x - x_min + 1
		var/rel_y = T.y - y_min + 1
		var/found = TRUE

		for (var/dx = 0; dx < x_dim && found; dx++)
			for (var/dy = 0; dy < y_dim && found; dy++)
				var/check_x = rel_x + dx
				var/check_y = rel_y + dy
				if(check_x > SECTOR_SIZE || check_y > SECTOR_SIZE) // Out of sector bounds
					found = FALSE
					continue
				var/turf/target = turf_matrix[check_x][check_y]
				if (!target || !istype(target,T.type))
					found = FALSE

		if (found)
			return T  // Return top-left turf of matching rectangle

	return null

/**
 * Gets or creates a persistent landing zone for a specific shuttle on a planet
 *
 * Checks if the shuttle type already has a registered landing zone on this planet.
 * If not, finds a new landing zone and creates a docking port for it.
 * This ensures shuttles return to the same location on repeated landings.
 *
 * Arguments:
 * * alloc - The planet allocation to create a landing zone in
 * * shuttle - The shuttle that needs a landing zone
 * * size - List containing [width, height] for the landing area
 *
 * Returns:
 * * The docking port for the landing zone, or null if no suitable location found
 */
/datum/subsystem/mapping/proc/get_shuttle_landing_zone(var/datum/allocation/alloc, var/datum/shuttle/shuttle, var/list/size)
	if(!alloc || !shuttle || !size)
		return null

	// Check if this shuttle already has a landing zone on this planet
	if(alloc.shuttle_landing_zones[shuttle.type])
		var/obj/docking_port/existing_port = alloc.shuttle_landing_zones[shuttle.type]
		if(existing_port && existing_port.loc) // Make sure it still exists
			return existing_port
		else
			// Clean up dead reference
			alloc.shuttle_landing_zones -= shuttle.type

	// Find a new landing zone
	var/turf/landing_zone = get_landing_zone(alloc, size)
	if(!landing_zone)
		return null

	// Create and register the landing zone
	var/obj/docking_port/destination/planet_surface/surface_port = new(landing_zone)
	surface_port.dir = NORTH
	surface_port.areaname = "[alloc.ptype.planet_name] surface"

	// Set the base turf type for proper surface restoration when shuttles depart
	if(alloc.ptype && alloc.ptype.default_baseturf)
		surface_port.base_turf_type = alloc.ptype.default_baseturf

	// Remember this landing zone for this shuttle type
	alloc.shuttle_landing_zones[shuttle.type] = surface_port

	return surface_port

/**
 * # Allocation Datum
 *
 * Represents a sector allocation for a planet in the procedural generation grid.
 *
 * Contains information about which sector a planet occupies, what turfs are in that sector,
 * and which planet type is assigned to it. Also tracks shuttle landing zones for persistent
 * shuttle landings on the planet.
 *
 * NOTE: To be replaced with vlevels in the future.
 */
/datum/allocation
	/// Sector coordinates as [x, y] in the procgen grid
	var/list/sector = list(1,1)
	var/z = 7
	var/datum/planet_type/ptype
	var/list/turf/turfs = list()
	/// Tracks persistent shuttle landing zones - associative list: shuttle_type -> docking_port
	var/list/shuttle_landing_zones = list()
