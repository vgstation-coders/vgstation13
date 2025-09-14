// Subsystem for things such as vaults, away mission init, and procgen.

var/datum/subsystem/mapping/SSmapping


/datum/subsystem/mapping
	name       = "Map"
	init_order = SS_INIT_MAP
	flags      = SS_NO_FIRE

	///All possible biomes in assoc list as type || instance
	var/list/biomes = list()
	//All possible planet types
	var/list/planet_types = list(
		/datum/planet_type/beach,
		/datum/planet_type/desert,
		/datum/planet_type/grass,
		/datum/planet_type/lava,
		/datum/planet_type/snow,
		/datum/planet_type/xeno
	)
	//All spawned planetoids
	var/list/planets = list()
	//All allocations
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

	SSmapping.spawn_planetoid(chosen_planet_type, chosen_ruin_type)

//Creates a grid of 25 99x99 squares for procedural generation
/datum/subsystem/mapping/proc/create_procgen_level()
	world.maxz += 1
	map.addZLevel(new /datum/zLevel/away, world.maxz, TRUE, TRUE)
	for(var/x = 1,  x < 500, x++)
		for(var/y = 1, y < 500, y++)
			if(!(x % 100) || !(y % 100))
				var/turf/T = locate(x,y,world.maxz)
				T.ChangeTurf(/turf/unsimulated/border)

///Initialize all biomes, assoc as type || instance
/datum/subsystem/mapping/proc/initialize_biomes()
	for(var/biome_path in subtypesof(/datum/biome))
		var/datum/biome/biome_instance = new biome_path()
		biomes[biome_path] += biome_instance

/datum/subsystem/mapping/proc/spawn_planetoid(datum/planet_type/planet_datum, ruin_type)
	var/datum/planet_type/newplanet = new planet_datum
	var/datum/planetGenerator/mapgen = new newplanet.mapgen
	planets += newplanet

	var/datum/map_element/mining_surprise/used_ruin = ispath(ruin_type) ? (new ruin_type) : ruin_type
	message_admins("Generating turfs")
	var/datum/allocation/A = assign_allocation(newplanet, world.maxz)
	mapgen.generate_turfs(A.turfs)
	var/list/ruin_turfs = list()
	var/list/ruin_templates = list()
	if(used_ruin)
		var/placement_result = place_ruin_in_allocation(used_ruin, A)
		if(placement_result)
			var/list/result_data = placement_result
			ruin_turfs[used_ruin.name] = result_data["turf"]
			ruin_templates[used_ruin.name] = used_ruin

	// fill in the turfs, AFTER generating the ruin. this prevents them from generating within the ruin
	// and ALSO prevents the ruin from being spaced when it spawns in
	// WITHOUT needing to fill the reservation with a bunch of dummy turfs
	mapgen.setup_loot_tables(planet_datum)
	message_admins("Populating turfs")
	mapgen.populate_turfs(turfs_from_sector(A.sector, world.maxz))
	message_admins("Finished populating turfs")
	message_admins("Starting day/night cycle")
	SSDayNight.get_turflist()
	SSDayNight.process_lighting()
	message_admins("Starting weather controller")
	SSweather.resume()
	return world.maxz

//// BEGIN LLM-SLOP I MUST REVIEW AND FIX LATER ////
//Post-processes ruin turfs to match the planet environment
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

	var/turfs_processed = 0
	var/floor_replacements = 0
	var/mineral_replacements = 0

	// Process all turfs in the spawned objects
	for(var/atom/A in spawned_objects)
		if(isturf(A))
			var/turf/T = A

			// Replace floor turfs with planet's default baseturf
			if(istype(T, /turf/unsimulated/floor/asteroid))
				if(default_baseturf)
					T.ChangeTurf(default_baseturf)
					floor_replacements++

			// Replace mineral turfs with planet's mineral type
			else if(istype(T, /turf/unsimulated/mineral))
				T.ChangeTurf(mineral_replacement)
				mineral_replacements++

			turfs_processed++

	if(turfs_processed > 0)
		message_admins("Post-processed [turfs_processed] turfs in ruin [ruin.name]: [floor_replacements] floors → [default_baseturf], [mineral_replacements] minerals → [mineral_replacement]")

//Places a ruin within an allocation's sector boundaries
//Returns a list with placement data on success, or null on failure
/datum/subsystem/mapping/proc/place_ruin_in_allocation(datum/map_element/ruin, datum/allocation/allocation)
	if(!ruin || !allocation)
		return null

	// Initialize the dimensions of the map element before using them
	ruin.assign_dimensions()

	// Calculate sector boundaries for proper placement within allocation
	var/sector_x = allocation.sector[1]
	var/sector_y = allocation.sector[2]
	var/sector_x_min = 1 + (sector_x - 1) * 100
	var/sector_x_max = sector_x * 100 - 1
	var/sector_y_min = 1 + (sector_y - 1) * 100
	var/sector_y_max = sector_y * 100 - 1

	// Calculate safe placement bounds within the sector, with padding
	var/padding = 5
	var/safe_x_min = sector_x_min + padding
	var/safe_x_max = sector_x_max - ruin.width - padding
	var/safe_y_min = sector_y_min + padding
	var/safe_y_max = sector_y_max - ruin.height - padding

	// Ensure we have valid placement area
	if(safe_x_max < safe_x_min || safe_y_max < safe_y_min)
		message_admins("Warning: Ruin [ruin.name] ([ruin.width]x[ruin.height]) too large for sector [sector_x],[sector_y] - skipping ruin placement")
		return null

	// Find random placement location within safe bounds
	var/turf/ruin_turf = locate(
		rand(safe_x_min, safe_x_max),
		rand(safe_y_min, safe_y_max),
		allocation.z
	)

	message_admins("Generating ruin [ruin.name] at [ruin_turf.x], [ruin_turf.y] in sector [sector_x],[sector_y] (z[allocation.z])")

	// Note: load() adds +1 to x and y coordinates, so we subtract 1 to place at exact location
	var/load_result = ruin.load(ruin_turf.x - 1, ruin_turf.y - 1, allocation.z, 0, TRUE, TRUE)

	if(load_result)
		message_admins("Successfully loaded ruin [ruin.name] - [length(load_result)] objects spawned")

		// Post-processing: Replace turfs to match planet environment
		post_process_ruin_turfs(ruin, allocation, load_result)

		return list("turf" = ruin_turf, "objects" = load_result)
	else
		message_admins("Failed to load ruin [ruin.name] at [ruin_turf.x], [ruin_turf.y]")
		return null
//// END LLM-SLOP I MUST REVIEW AND FIX LATER ////

//Assigns a planetoid to a region
/datum/subsystem/mapping/proc/assign_allocation(var/datum/planet_type/planet_type, z_id)
	var/datum/allocation/A = new
	var/sector_count = allocations.len + 1
	A.sector = list((sector_count - 1) % 5 + 1, ceil(sector_count / 5))
	message_admins("Assigning planetoid to sector x:[A.sector[1]] y:[A.sector[2]] in z-level [z_id]")
	A.ptype = planet_type
	A.z = z_id
	A.turfs = turfs_from_sector(A.sector, z_id)
	allocations += A
	planet_type.allocation = A
	return A

//Gets turfs given sector
/datum/subsystem/mapping/proc/turfs_from_sector(var/list/sector, var/z_in)
	var/sector_x = sector[1]
	var/sector_y = sector[2]
	var/x_min = 1 + (sector_x - 1) * 100
	var/x_max = sector_x * 100 - 1
	var/y_min = 1 + (sector_y - 1) * 100
	var/y_max = sector_y * 100 - 1
	return block(locate(x_min, y_min, z_in), locate(x_max, y_max, z_in))

//Get turfs from planet
/datum/subsystem/mapping/proc/turfs_from_planet(var/datum/planet_type/planet)
	if(!planet || !planet.allocation)
		return list()
	var/datum/allocation/A = planet.allocation
	return A.turfs

//Get allocation from coords or turf
/datum/subsystem/mapping/proc/get_allocation(var/x = 0, var/y = 0, var/z = 7, var/turf/T = null)
	if(T)
		x = T.x
		y = T.y
		z = T.z
	var/sector = list(ceil(x / 100), ceil(y / 100))
	for(var/datum/allocation/A in allocations)
		if(A.sector == sector && A.z == z)
			return A

//Gets a landing zone for a given planetoid
/datum/subsystem/mapping/proc/get_landing_zone(var/datum/allocation/alloc,var/list/size)
	if (!alloc || !size || size.len != 2)
		return null
	var/x_dim = size[1]
	var/y_dim = size[2]
	var/list/turf/search_turfs = turfs_from_sector(alloc.sector, alloc.z)

	// Get sector boundaries to calculate relative positions
	var/sector_x = alloc.sector[1]
	var/sector_y = alloc.sector[2]
	var/x_min = 1 + (sector_x - 1) * 100
	var/y_min = 1 + (sector_y - 1) * 100

	// Create matrix with relative coordinates
	var/datum/turf_matrix[100][100]
	for (var/turf/T in search_turfs)
		var/rel_x = T.x - x_min + 1
		var/rel_y = T.y - y_min + 1
		turf_matrix[rel_x][rel_y] = T

	// Define safe zone boundaries (11 tiles from edge, accounting for shuttle size)
	var/edge_buffer = 11
	var/safe_x_min = edge_buffer + 1
	var/safe_x_max = 100 - edge_buffer - x_dim
	var/safe_y_min = edge_buffer + 1
	var/safe_y_max = 100 - edge_buffer - y_dim

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
				if(check_x > 100 || check_y > 100) // Out of sector bounds
					found = FALSE
					continue
				var/turf/target = turf_matrix[check_x][check_y]
				if (!target || !istype(target,T.type))
					found = FALSE

		if (found)
			return T  // Return top-left turf of matching rectangle

	return null

// Get or create a landing zone for a specific shuttle on a planet
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

//Contains the ID of the allocation, its turfs, and the planety type. To be replaced with vlevels in the future.
/datum/allocation
	var/list/sector = list(1,1) //x,y
	var/z = 7
	var/datum/planet_type/ptype
	var/list/turf/turfs = list()
	// Track shuttle landing zones
	var/list/shuttle_landing_zones = list() // Associated list: shuttle_type -> docking_port
