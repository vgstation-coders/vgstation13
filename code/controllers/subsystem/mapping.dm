// Subsystem for things such as vaults, away mission init, and procgen.

var/datum/subsystem/mapping/SSmapping


/datum/subsystem/mapping
	name       = "Map"
	init_order = SS_INIT_MAP
	flags      = SS_NO_FIRE

	///All possible biomes in assoc list as type || instance
	var/list/biomes = list()

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
	log_startup_progress("Finished initializing biomes in [stop_watch(watch)]s.")

	..()

/proc/generate_planet()//debug
	return SSmapping.spawn_planetoid(/datum/planet_type/lava, /datum/map_element/mining_surprise/crashed_tradeship)

///Initialize all biomes, assoc as type || instance
/datum/subsystem/mapping/proc/initialize_biomes()
	for(var/biome_path in subtypesof(/datum/biome))
		var/datum/biome/biome_instance = new biome_path()
		biomes[biome_path] += biome_instance

/datum/subsystem/mapping/proc/spawn_planetoid(datum/planet_type/planet_datum, ruin_type)
	var/datum/planetGenerator/mapgen = new planet_datum.mapgen
	var/datum/map_element/mining_surprise/used_ruin = ispath(ruin_type) ? (new ruin_type) : ruin_type
	message_admins("Generating turfs")
	world.maxz += 1
	map.addZLevel(new /datum/zLevel/away, world.maxz, TRUE, TRUE)
	mapgen.generate_turfs(map.zLevels.len)

	//DEBUG needs less hardcoding
	for(var/x = 1,  x < 102, x++)
		var/turf/T = locate(x,101,world.maxz)
		T.ChangeTurf(/turf/unsimulated/border)
	for(var/y = 1, y < 102, y++)
		var/turf/T = locate(101,y,world.maxz)
		T.ChangeTurf(/turf/unsimulated/border)


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
	mapgen.populate_turfs()

	return world.maxz
