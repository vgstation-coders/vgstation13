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

#define STAGE_TERRAIN 1
#define STAGE_RUIN 2
#define STAGE_POPULATION 3
#define STAGE_WEATHER 4

/// Cell size for spatial bucketing of mobs
#define SPATIAL_BUCKET_SIZE 15

/// Minimum space turfs between any point of the shuttle and the vlevel's transition zone in encounters.
/// Must exceed TRANSITIONEDGE so the shuttle (and any crew walking near it) cannot overlap the
/// outer band that would teleport them to another z-level.
#define ENCOUNTER_EDGE_BUFFER (TRANSITIONEDGE + 7)

/// Fixed encounter zone size (must be large enough for shuttle + vaults)
#define ENCOUNTER_ZONE_SIZE 145

var/datum/subsystem/mapping/SSmapping
var/skip_turf_init = FALSE //NEVER change this var for anything other than incrementing world.maxz it breaks EVERYTHING!!

/datum/subsystem/mapping
	name       = "Mapping"
	init_order = SS_INIT_MAP
	flags      = SS_BACKGROUND | SS_FIRE_IN_LOBBY
	priority   = SS_PRIORITY_MAPPING
	wait       = 0.5 SECONDS

	/// All possible biomes in assoc list as type || instance
	var/list/biomes = list()
	/// All possible planet types available for generation
	var/list/planet_types = list(
		/datum/planet_type/beach,
		/datum/planet_type/desert,
		/datum/planet_type/grass,
		/datum/planet_type/jungle,
		/datum/planet_type/lava,
		/datum/planet_type/snow,
		/datum/planet_type/urban,
		/datum/planet_type/xeno
	)
	/// All spawned planets
	var/list/planets = list()
	/// All spawned encounters
	var/list/encounters = list()
	/// Whether a planet scanner is currently scanning
	var/scanning = FALSE
	/// Whether a planet is currently being generated
	var/generating = FALSE
	/// The planet currently being generated
	var/datum/planet_type/current_planet
	/// The virtual_z for the current planet
	var/datum/virtual_z/current_virtual_z
	/// Is scanning disabled globally
	var/scanning_disabled = FALSE
	/// World time when scanning can be toggled again
	var/last_lockdown_time = 0
	var/lockdown_duration = 15 MINUTES

	// Queue-based processing variables
	/// Start time for generation tracking
	var/generation_start_time = 0
	/// Current processing stage: STAGE_TERRAIN, STAGE_RUIN, STAGE_POPULATION, or STAGE_WEATHER
	var/current_stage = null
	/// Queue of turfs for terrain generation
	var/list/terrain_queue = list()
	/// Queue of turfs for population
	var/list/population_queue = list()
	/// Current position in the active queue
	var/queue_index = 1
	/// The mapgen instance for the current planet
	var/datum/planetGenerator/current_mapgen
	/// Features created during population
	var/list/created_features = list()
	/// Mobs created during population
	var/list/created_mobs = list()
	// Fast-processing lists
	var/list/feature_buckets = list() // Spatial buckets for features - key is "cellX_cellY", value is list of features in that cell
	var/list/mob_buckets = list() // Spatial buckets for mobs - key is "cellX_cellY", value is list of mobs in that cell
	var/turfs_per_tick = 300 // Base turfs processed per tick (adjusted dynamically)
	var/turfs_processed = 0 // Turfs processed in the current tick
	var/max_turfs_per_tick = 2000 // Maximum turfs to process per tick
	var/min_turfs_per_tick = 100 // Minimum turfs to process per tick
	var/list/ruins_by_type = list()

	var/list/queued_planets = list() // List of planets waiting to be processed

/datum/subsystem/mapping/New()
	NEW_SS_GLOBAL(SSmapping)
	ruins_by_type["[RUIN_TYPE_GENERIC]"] = list()
	ruins_by_type["[RUIN_TYPE_SNOW]"] = list()
	ruins_by_type["[RUIN_TYPE_JUNGLE]"] = list()
	ruins_by_type["[RUIN_TYPE_TROPICAL]"] = list()
	ruins_by_type["[RUIN_TYPE_LAVA]"] = list()
	ruins_by_type["[RUIN_TYPE_URBAN]"] = list()
	ruins_by_type["[RUIN_TYPE_XENO]"] = list()
	ruins_by_type["[RUIN_TYPE_WET]"] = list()

	var/list/ruins = subtypesof(/datum/map_element/ruin) - typesof(/datum/map_element/ruin/story)
	for(var/R in ruins)
		var/datum/map_element/ruin/ME = new R()
		for(var/type_flag in ruins_by_type)
			var/numeric_flag = text2num(type_flag)
			if(ME.ruin_type & numeric_flag)
				ruins_by_type[type_flag] += R
		qdel(ME)

/datum/subsystem/mapping/stat_entry(msg)
	if(!generating)
		return ..("Idle")

	var/stage_name
	var/progress = 0
	switch(current_stage)
		if(STAGE_TERRAIN)
			stage_name = "Terrain"
			if(terrain_queue.len > 0)
				progress = round((queue_index / terrain_queue.len) * 100, 1)
		if(STAGE_RUIN)
			stage_name = "Ruin"
			progress = "[initial(current_planet.ruin_budget) - current_planet.ruin_budget]/[initial(current_planet.ruin_budget)]"
		if(STAGE_POPULATION)
			stage_name = "Population"
			if(population_queue.len > 0)
				progress = round((queue_index / population_queue.len) * 100, 1)
		if(STAGE_WEATHER)
			stage_name = "Weather"
			progress = 100

	return ..("[stage_name] [progress]% | Tp:[turfs_processed]")

/datum/subsystem/mapping/Initialize(timeofday)
	var/watch

	if (config.enable_roundstart_away_missions)
		log_startup_progress("Attempting to generate an away mission...")
		createRandomZlevel()

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
		if(!istype(z, /datum/zLevel/dynamic))
			map.linkVLevel(z)
		log_debug("Finished with zLevel [z.z] in [stop_watch(watch_prim)]s.", FALSE)
	log_debug("Finished calling post on zLevels in [stop_watch(watch)]s.", FALSE)

	//load all roundstart dungeons
	for(var/T in map.load_map_elements)
		load_dungeon(T, 0, TRUE)

	for(var/T in map.load_custom_fixedvaults)
		load_dungeon(T, 0, FALSE, FALSE)

	watch = start_watch()
	for(var/datum/virtual_z/vz in map.getAllVLevels())
		vz.initialize_turfs()
	SSDayNight.get_turflist() //vlevels are ready now
	log_startup_progress("Initialized virtual z-levels in [stop_watch(watch)]s.")

	watch = start_watch()
	map.map_specific_init()
	log_debug("Finished map-specific inits in [stop_watch(watch)]s.", FALSE)

	spawn_map_pickspawners() //this is down here so that it calls after allll the vaults etc are done spawning - if in the future some pickspawners don't fire, it's because this needs moving

	watch = start_watch()
	initialize_biomes()
	log_startup_progress("Finished initializing procgen in [stop_watch(watch)]s.")

	..()

/datum/subsystem/mapping/fire(resumed = FALSE)
	if(!generating)
		if(queued_planets.len)
			var/next_planet = pick_n_take(queued_planets)
			if(!ispath(next_planet, /datum/planet_type) && !istype(next_planet, /datum/planet_type))
				return
			spawn_planet(next_planet, FALSE, map.planet_size)
		else
			return

	var/tick_start = world.tick_usage
	turfs_processed = 0
	var/target_turfs = turfs_per_tick

	switch(current_stage)
		if(STAGE_TERRAIN)
			while(queue_index <= terrain_queue.len && turfs_processed < target_turfs)
				var/turf/T = terrain_queue[queue_index]
				if(T)
					current_mapgen.generate_turf(T)
					T.planet = current_planet
				queue_index++
				turfs_processed++

			if(queue_index > terrain_queue.len)
				current_stage = STAGE_RUIN
				queue_index = 1
			else
				throttle(tick_start, turfs_processed)
				return

		if(STAGE_RUIN)
			if(!current_mapgen.spawned_story_ruin)
				current_virtual_z.place_story_ruins()
				current_mapgen.spawned_story_ruin = TRUE
			if(current_planet.ruin_budget <= 0)
				current_stage = STAGE_POPULATION
				queue_index = 1
				created_features = list()
				created_mobs = list()
				feature_buckets = list()
				mob_buckets = list()
				turfs_processed = 0
			else
				if(!current_mapgen.weighted_ruin_list.len)
					var/list/ruins = get_ruin_list(whitelist = current_planet.ruin_whitelist, blacklist = current_planet.ruin_blacklist)
					current_mapgen.weighted_ruin_list = weighted_ruin_list(ruins, current_planet.preferred_ruin_type)
				var/datum/map_element/ruin/used_ruin = pick(current_mapgen.weighted_ruin_list)
				for(var/ruin_entry in current_mapgen.weighted_ruin_list)
					if(ruin_entry == used_ruin)
						current_mapgen.weighted_ruin_list.Remove(ruin_entry)
				current_virtual_z.place_ruin(used_ruin)
				current_planet.ruin_budget -= used_ruin.cost

		if(STAGE_POPULATION)
			// Create climate before processing turfs so weather registration works
			if(!current_planet.climate && current_planet.climate_type)
				current_planet.climate = SSweather.set_climate(current_planet.climate_type, current_virtual_z, random_start = TRUE)

			while(queue_index <= population_queue.len && turfs_processed < target_turfs)
				var/turf/T = population_queue[queue_index]
				if(T)
					// Populate with flora, features, mobs, loot
					current_mapgen.populate_turf(T, created_features, created_mobs, current_mapgen.planet_loot, current_planet.mob_faction)

					// Inline finalization (eliminates a full extra pass over all turfs)
					T.v = current_virtual_z
					T.turf_flags &= ~DEFER_EDGING
					if(T.edge_flags & EDGE_CARDINAL)
						T.update_edges()

					// Close up any remaining space turfs
					if(istype(T, /turf/space) && current_planet.default_baseturf)
						T.ChangeTurf(current_planet.default_baseturf)

					var/area/planet/A = T.loc
					if(istype(A) && A.is_open_surface)
						if(current_planet.climate)
							current_planet.climate.register_weather_turf(T)
						// Build daynight turf list (sample every other tile)
						if(!(T.x & 1) && !(T.y & 1))
							current_virtual_z.daynight_turfs += T

				queue_index++
				turfs_processed++

				if(TICK_CHECK)
					throttle(tick_start, turfs_processed)
					return

			if(queue_index > population_queue.len)
				// Run post-processing (gas vents etc.) before moving to weather
				if(current_mapgen)
					current_mapgen.post_process(current_virtual_z)
				current_stage = STAGE_WEATHER
				queue_index = 1
			else
				throttle(tick_start, turfs_processed)
				return

		if(STAGE_WEATHER)
			if(current_planet.climate)
				SSweather.fire()

			var/list/possible_times = list(TOD_MORNING, TOD_SUNRISE, TOD_DAYTIME, TOD_AFTERNOON, TOD_SUNSET, TOD_NIGHTTIME)
			current_virtual_z.current_timeOfDay = pick(possible_times)

			switch(current_virtual_z.current_timeOfDay)
				if(TOD_MORNING) current_virtual_z.next_firetime = world.time + 5 MINUTES
				if(TOD_SUNRISE) current_virtual_z.next_firetime = world.time + 3 MINUTES
				if(TOD_DAYTIME) current_virtual_z.next_firetime = world.time + 14 MINUTES
				if(TOD_AFTERNOON) current_virtual_z.next_firetime = world.time + 15 MINUTES
				if(TOD_SUNSET) current_virtual_z.next_firetime = world.time + 3 MINUTES
				if(TOD_NIGHTTIME) current_virtual_z.next_firetime = world.time + 36 MINUTES

			daynight_v_lvls |= current_virtual_z
			current_virtual_z.level_type = VZ_PLANET
			current_virtual_z.update_settings()
			SSDayNight.flags = 0
			SSDayNight.update_lighting(current_virtual_z, immediate = TRUE)

			var/total_time = (world.timeofday - generation_start_time) / 10
			message_admins("Planet '[current_planet.planet_name]' generated successfully at v-level [current_virtual_z.id] in [total_time]s")

			generating = FALSE
			current_planet = null
			current_virtual_z = null
			current_stage = null
			current_mapgen = null
			terrain_queue = list()
			population_queue = list()
			queue_index = 1
			created_features = null
			created_mobs = null
			feature_buckets = list()
			mob_buckets = list()

	// Adjust processing rate based on performance
	if(turfs_processed > 0)
		throttle(tick_start, turfs_processed)


// Adjusts the turfs_per_tick based on current tick usage
// Increases rate if we're using less than 50% of tick, decreases if using more than 80%
/datum/subsystem/mapping/proc/throttle(tick_start, turfs_processed)
	var/tick_used = world.tick_usage - tick_start

	// Scale up when performing well
	if(tick_used < 20 && turfs_per_tick < max_turfs_per_tick)
		turfs_per_tick = min(turfs_per_tick + 200, max_turfs_per_tick)
	else if(tick_used < 40 && turfs_per_tick < max_turfs_per_tick)
		turfs_per_tick = min(turfs_per_tick + 100, max_turfs_per_tick)
	else if(tick_used < 60 && turfs_per_tick < max_turfs_per_tick)
		turfs_per_tick = min(turfs_per_tick + 50, max_turfs_per_tick)
	// Scale back when approaching limits
	else if(tick_used > 85 && turfs_per_tick > min_turfs_per_tick)
		turfs_per_tick = max(turfs_per_tick - 150, min_turfs_per_tick)
	else if(tick_used > 75 && turfs_per_tick > min_turfs_per_tick)
		turfs_per_tick = max(turfs_per_tick - 75, min_turfs_per_tick)

/datum/subsystem/mapping/proc/get_bucket_key(x, y)
	return "[round(x / SPATIAL_BUCKET_SIZE)]_[round(y / SPATIAL_BUCKET_SIZE)]"

/datum/subsystem/mapping/proc/add_feature_to_bucket(atom/feature)
	if(!feature)
		return
	var/key = get_bucket_key(feature.x, feature.y)
	if(!feature_buckets[key])
		feature_buckets[key] = list()
	feature_buckets[key] += feature
	created_features += feature

/datum/subsystem/mapping/proc/add_mob_to_bucket(atom/spawned_mob)
	if(!spawned_mob)
		return
	var/key = get_bucket_key(spawned_mob.x, spawned_mob.y)
	if(!mob_buckets[key])
		mob_buckets[key] = list()
	mob_buckets[key] += spawned_mob
	created_mobs += spawned_mob

/datum/subsystem/mapping/proc/can_spawn_feature_at(x, y, feature_type, distance = 7)
	var/cell_x = round(x / SPATIAL_BUCKET_SIZE)
	var/cell_y = round(y / SPATIAL_BUCKET_SIZE)

	for(var/dx = -1 to 1)
		for(var/dy = -1 to 1)
			var/key = "[cell_x + dx]_[cell_y + dy]"
			var/list/bucket = feature_buckets[key]
			if(!bucket)
				continue
			for(var/atom/other_feature in bucket)
				if(istype(other_feature, feature_type))
					var/dist = max(abs(x - other_feature.x), abs(y - other_feature.y)) // chessboard distance
					if(dist <= distance)
						return FALSE
	return TRUE

/datum/subsystem/mapping/proc/can_spawn_mob_at(x, y, mob_type, hostile_distance = 12, spawner_distance = 2)
	var/cell_x = round(x / SPATIAL_BUCKET_SIZE)
	var/cell_y = round(y / SPATIAL_BUCKET_SIZE)

	var/is_hostile = ispath(mob_type, /mob/living/simple_animal/hostile)
	var/is_spawner = ispath(mob_type, /obj/abstract/map/spawner/mobs)

	for(var/dx = -1 to 1)
		for(var/dy = -1 to 1)
			var/key = "[cell_x + dx]_[cell_y + dy]"
			var/list/bucket = mob_buckets[key]
			if(!bucket)
				continue
			for(var/thing in bucket)
				if(!ishostile(thing) && !istype(thing, /obj/abstract/map/spawner/mobs))
					continue

				var/atom/A = thing
				var/dist = max(abs(x - A.x), abs(y - A.y)) // chessboard distance

				if(dist <= hostile_distance && (ishostile(thing) || is_hostile))
					return FALSE

				if(dist <= spawner_distance && (istype(thing, /obj/abstract/map/spawner/mobs) || is_spawner))
					return FALSE
	return TRUE

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

	var/list/size_options = list(
		"Small (92x92) (~1min)" = ALLOCATION_SMALL,
		"Quadrant (245x245) (~5min)" = ALLOCATION_QUADRANT,
		"Full (500x500) (~1hr)" = ALLOCATION_FULL,
		"Custom" = 0
	)
	var/chosen_size = input(user, "Select planet size:", "Planet Size") as null|anything in size_options
	if(!chosen_size)
		return
	var/allocation_size = size_options[chosen_size]
	if(!allocation_size)
		allocation_size = input(user, "Enter planet dimension (creates a square NxN planet, min 50, max 500):", "Custom Planet Size", ALLOCATION_SMALL) as null|num
		if(!allocation_size)
			return
		allocation_size = clamp(round(allocation_size), 50, 500)

	var/hide_from_scanner = alert(user, "Should this planet be hidden from the Deep Space Scanner?", "Scanner Visibility", "No", "Yes") == "Yes"

	SSmapping.spawn_planet(chosen_planet_type, hide_from_scanner, allocation_size)

// Tries to place a new virtual zLevel of given size within the specified zLevel
/datum/subsystem/mapping/proc/try_place_vz(var/datum/zLevel/check_z, var/size_x, var/size_y, var/spacing)
	var/target_x = 1
	var/target_y = 1

	if(size_x > world.maxx || size_y > world.maxy)
		CRASH("Tried to find virtual level allocation that cannot possibly fit in a physical level.")

	while(TRUE)
		var/upper_target_x = target_x + size_x
		var/upper_target_y = target_y + size_y

		var/out_of_bounds = FALSE
		if((target_x < 1 || upper_target_x > world.maxx) || (target_y < 1 || upper_target_y > world.maxy))
			out_of_bounds = TRUE

		if(!out_of_bounds && check_z.is_box_free(target_x, target_y, upper_target_x, upper_target_y))
			// Found non-overlapping position, now ensure minimum spacing
			var/min_y = check_z.get_min_valid_y(target_x, upper_target_x, target_y, spacing)
			var/min_x = check_z.get_min_valid_x(target_y, upper_target_y, target_x, spacing)

			if(min_y > target_y)
				target_y = min_y
				continue
			if(min_x > target_x)
				target_x = min_x
				continue

			return list("x" = target_x, "y" = target_y) // Found valid spot with proper spacing

		if(upper_target_x > world.maxx) // If we can't increment x, then the search is over
			break

		var/increments_y = TRUE
		if(upper_target_y > world.maxy)
			target_y = 1
			increments_y = FALSE
		if(increments_y)
			target_y += spacing
		else
			target_x += spacing

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

/datum/subsystem/mapping/proc/queue_planets(var/count = 1)
	var/list/available_planets = SSmapping.planet_types.Copy()
	for(var/i = 1 to count)
		queued_planets += pick(available_planets)

/**
 * Spawns a new planet asynchronously with optional ruin
 *
 * Generates a planet in chunks across multiple ticks to prevent server lag.
 * The generation process includes terrain generation, ruin placement, population,
 * weather registration, and day/night cycle initialization.
 *
 * The generation is handled by the subsystem's fire() proc through a queue-based system.
 *
 * Arguments:
 * * planet_datum - The planet type path or instance to spawn
 * * hide_from_scanner - Optional boolean to hide the planet from the Deep Space Scanner
 *
 * Returns:
 * * TRUE if generation started successfully, FALSE if already generating
 */
/datum/subsystem/mapping/proc/spawn_planet(datum/planet_type/planet_datum, hide_from_scanner = FALSE, size_override = 0)
	if(generating)
		message_admins("Planet generation already in progress! Please wait for '[current_planet.planet_name]' to complete.")
		return FALSE

	// Initialize generation state
	generation_start_time = world.timeofday
	current_planet = new planet_datum
	var/alloc_size = size_override ? size_override : current_planet.allocation_size
	current_mapgen = new current_planet.mapgen(alloc_size)
	current_virtual_z = map.addVLevel(alloc_size, null, TRUE)
	current_virtual_z.teleJammed = VZ_TELEPORTATION_EXPENSIVE

	planets += current_planet
	current_virtual_z.planet = current_planet
	current_planet.v = current_virtual_z
	current_virtual_z.name = current_planet.planet_name

	if(hide_from_scanner)
		current_planet.hidden = TRUE

	// Baseturf
	if(current_planet.default_baseturf)
		current_mapgen.primary_area.base_turf_type = current_planet.default_baseturf
		current_mapgen.cave_area.base_turf_type = current_planet.default_baseturf

	// Set planet and v on the shared areas
	current_mapgen.primary_area.planet = current_planet
	current_mapgen.primary_area.v = current_virtual_z
	current_mapgen.cave_area.planet = current_planet
	current_mapgen.cave_area.v = current_virtual_z


	// Store coordinate offsets on the generator for biome grid lookups
	current_mapgen.x_offset = current_virtual_z.x_min
	current_mapgen.y_offset = current_virtual_z.y_min

	// Prepare terrain queue (population reuses the same list — no Copy() needed)
	terrain_queue = current_virtual_z.get_turfs()
	population_queue = terrain_queue
	current_stage = STAGE_TERRAIN
	queue_index = 1

	var/total_turfs = (current_virtual_z.x_max - current_virtual_z.x_min + 1) * (current_virtual_z.y_max - current_virtual_z.y_min + 1)
	message_admins("Started generating planet '[current_planet.planet_name]' at v-level [current_virtual_z.id]. [total_turfs] turfs to process.")

	generating = TRUE

	return TRUE

/**
 * Checks living mobs with clients are present on a given vLevel and pauses/unpauses it accordingly
 */
/datum/subsystem/mapping/proc/v_pause_check(var/mob/living/user, var/datum/virtual_z/to_v = null, var/datum/virtual_z/from_v = null)
	if(!istype(user) || !user.client || !(to_v && from_v))
		return
	if(isnum(to_v))
		to_v = map.getVLevel(to_v)
	if(isnum(from_v))
		from_v = map.getVLevel(from_v)
	if(to_v) // Unpause destination vLevel
		to_v.set_status(TRUE)
	if(from_v) // Check if any living mobs with clients remain on source vLevel
		var/has_living = FALSE
		for(var/mob/living/M in from_v.get_living_players())
			if(M.client)
				has_living = TRUE
				break
		from_v.set_status(has_living)

/**
 * Generates an encounter zone for the planet scanner.
 *
 * Creates a fixed [ENCOUNTER_ZONE_SIZE]x[ENCOUNTER_ZONE_SIZE] virtual z-level. If a shuttle is provided,
 * reserves a landing area for it (with [ENCOUNTER_EDGE_BUFFER]-turf buffer from the zone edge) and places
 * 1-3 vaults in the remaining space. Docking ports are created on demand via
 * [/datum/encounter/proc/get_shuttle_docking_port].
 *
 * Returns the encounter datum, or null on failure
 */
/datum/subsystem/mapping/proc/generate_scanner_encounter(datum/shuttle/shuttle = null)
	var/enc_size = ENCOUNTER_ZONE_SIZE

	var/datum/virtual_z/encounter_vz = map.addVLevel(enc_size, enc_size)
	if(!encounter_vz)
		return null
	encounter_vz.name = "Encounter Zone"
	encounter_vz.gps_allowed = TRUE
	encounter_vz.teleJammed = VZ_TELEPORTATION_ALLOWED
	encounter_vz.movementJammed = FALSE

	// Inherit the deep-space drift channel from the shuttle's parking vlevel so this
	// encounter can be reached by drifting like the rest of the deep-space group.
	if(shuttle)
		for(var/datum/virtual_z/parking_vz in map.vLevels)
			if(parking_vz.level_type == VZ_PARKING && parking_vz.linked_shuttle == shuttle)
				encounter_vz.transition_channel = parking_vz.transition_channel
				break

	// Calculate shuttle reservation if shuttle is provided
	var/list/shuttle_reservation = null // list(x_min, y_min, x_max, y_max) - exclusion zone for vaults
	if(shuttle?.linked_port && shuttle.linked_area)
		var/list/shuttle_dims = shuttle.get_size()
		if(shuttle_dims)
			var/shuttle_width = shuttle_dims[1]
			var/shuttle_height = shuttle_dims[2]

			// Pick a random position for the shuttle with ENCOUNTER_EDGE_BUFFER from each edge
			var/safe_bl_x_min = encounter_vz.x_min + ENCOUNTER_EDGE_BUFFER
			var/safe_bl_x_max = encounter_vz.x_max - shuttle_width - ENCOUNTER_EDGE_BUFFER + 1
			var/safe_bl_y_min = encounter_vz.y_min + ENCOUNTER_EDGE_BUFFER
			var/safe_bl_y_max = encounter_vz.y_max - shuttle_height - ENCOUNTER_EDGE_BUFFER + 1

			if(safe_bl_x_max >= safe_bl_x_min && safe_bl_y_max >= safe_bl_y_min)
				var/bl_x = rand(safe_bl_x_min, safe_bl_x_max)
				var/bl_y = rand(safe_bl_y_min, safe_bl_y_max)
				// Exclusion zone includes a 2-turf buffer around the shuttle
				shuttle_reservation = list(bl_x - 2, bl_y - 2, bl_x + shuttle_width + 1, bl_y + shuttle_height + 1)

	// Spawn 1-3 vaults outside the shuttle reservation
	var/vault_count = rand(1, 3)
	var/list/available_vaults = get_map_element_objects()
	var/list/placed_bounds = list()
	var/vaults_placed = 0

	if(available_vaults.len)
		for(var/i = 1 to vault_count)
			if(!available_vaults.len)
				break

			var/datum/map_element/vault/vault = pick(available_vaults)
			available_vaults -= vault

			vault.assign_dimensions()
			if(!vault.width || !vault.height)
				continue

			var/vault_x_min = encounter_vz.x_min + 1
			var/vault_x_max = encounter_vz.x_max - vault.width
			var/vault_y_min = encounter_vz.y_min + 1
			var/vault_y_max = encounter_vz.y_max - vault.height

			if(vault_x_max < vault_x_min || vault_y_max < vault_y_min)
				continue

			var/turf/vault_turf = null
			for(var/attempt = 1 to 30)
				var/try_x = rand(vault_x_min, vault_x_max)
				var/try_y = rand(vault_y_min, vault_y_max)
				var/v_x_max = try_x + vault.width - 1
				var/v_y_max = try_y + vault.height - 1

				// Must not overlap shuttle reservation
				if(shuttle_reservation)
					if(!(v_x_max < shuttle_reservation[1] || try_x > shuttle_reservation[3] || v_y_max < shuttle_reservation[2] || try_y > shuttle_reservation[4]))
						continue

				// Must not overlap previously placed vaults
				var/overlaps = FALSE
				for(var/list/bounds in placed_bounds)
					if(!(v_x_max < bounds[1] || try_x > bounds[3] || v_y_max < bounds[2] || try_y > bounds[4]))
						overlaps = TRUE
						break
				if(overlaps)
					continue

				vault_turf = locate(try_x, try_y, encounter_vz.z())
				break

			if(!vault_turf)
				continue

			var/vault_rotate = (!config.disable_vault_rotation && vault.can_rotate) ? pick(0, 90, 180, 270) : 0
			if(vault.load(vault_turf.x - 1, vault_turf.y - 1, encounter_vz.z(), vault_rotate, TRUE))
				placed_bounds += list(list(vault_turf.x, vault_turf.y, vault_turf.x + vault.width - 1, vault_turf.y + vault.height - 1))
				vaults_placed++

	encounter_vz.initialize_turfs()
	encounter_vz.update_settings()

	var/datum/encounter/enc = new()
	enc.v = encounter_vz
	enc.placed_bounds = placed_bounds
	enc.shuttle_reservation = shuttle_reservation
	encounters += enc

	message_admins("Generated encounter '[enc.encounter_name]' at v-level [encounter_vz.id] ([enc_size]x[enc_size]) with [vaults_placed] vault(s).")
	captain_announce("Deep space scanners have detected a new anomaly: [enc.encounter_name].")

	return enc

#undef STAGE_TERRAIN
#undef STAGE_RUIN
#undef STAGE_POPULATION
#undef STAGE_WEATHER
#undef SPATIAL_BUCKET_SIZE
#undef ENCOUNTER_EDGE_BUFFER
#undef ENCOUNTER_ZONE_SIZE
