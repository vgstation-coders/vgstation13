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
		/datum/planet_type/desert,
		/datum/planet_type/beach,
		/datum/planet_type/lava,
		/datum/planet_type/snow,
		/datum/planet_type/xeno
	)
	//All spawned planetoids
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
		if (rand(1,3) == 3)
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

/proc/generate_planet()//debug
	return SSmapping.spawn_planetoid(pick(SSmapping.planet_types), /datum/map_element/mining_surprise/crashed_tradeship)

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
	var/datum/planetGenerator/mapgen = new planet_datum.mapgen
	var/datum/map_element/mining_surprise/used_ruin = ispath(ruin_type) ? (new ruin_type) : ruin_type
	message_admins("Generating turfs")
	var/datum/allocation/A = assign_allocation(planet_datum, map.zLevels.len)
	mapgen.generate_turfs(A.turfs)
	var/list/ruin_turfs = list()
	var/list/ruin_templates = list()
	if(used_ruin)
		var/turf/ruin_turf = locate(
			rand(
				11,
				100-used_ruin.width-6 - 11
			),
			100-used_ruin.height-6 - 11,
			world.maxz
		)
		message_admins("Generating ruin at [ruin_turf.x], [ruin_turf.y], [world.maxz]")
		used_ruin.load(ruin_turf.x, ruin_turf.y, world.maxz, 0, TRUE, TRUE, 1, world.maxx-11, 11, world.maxy-11, 11, world.maxz-11)
		ruin_turfs[used_ruin.name] = ruin_turf
		ruin_templates[used_ruin.name] = used_ruin

	// fill in the turfs, AFTER generating the ruin. this prevents them from generating within the ruin
	// and ALSO prevents the ruin from being spaced when it spawns in
	// WITHOUT needing to fill the reservation with a bunch of dummy turfs
	message_admins("Populating turfs")
	mapgen.populate_turfs(turfs_from_sector(A.sector, map.zLevels.len))
	message_admins("Finished populating turfs")
	message_admins("Starting day/night cycle")
	SSDayNight.get_turflist()
	SSDayNight.process_lighting()

	return world.maxz

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
	var/datum/turf_matrix[99][99]
	for (var/turf/T in search_turfs)
		turf_matrix[T.x][T.y] = T
	for (var/turf/T in search_turfs)
		var/start_x = T.x
		var/start_y = T.y
		if(iswall(T) || istype(T, /turf/unsimulated/mineral))
			continue
		var/found = TRUE

		for (var/dx = 0; dx < x_dim && found; dx++)
			for (var/dy = 0; dy < y_dim && found; dy++)
				var/turf/target = turf_matrix[start_x + dx][start_y + dy]
				if (!istype(target,T.type))
					found = FALSE

		if (found)
			message_admins("Found a landing zone at [T.x], [T.y] for allocation [alloc.sector] in z-level [alloc.z]")
			return T  // Return top-left turf of matching rectangle

	return null

//Contains the ID of the allocation, its turfs, and the planety type. To be replaced with vlevels in the future.
/datum/allocation
	var/list/sector = list(1,1) //x,y
	var/z = 7
	var/datum/planet_type/ptype
	var/list/turf/turfs = list()
