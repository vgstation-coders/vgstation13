// Subsystem for things such as vaults and away mission init.

var/datum/subsystem/map/SSmap


/datum/subsystem/map
	name       = "Map"
	init_order = SS_INIT_MAP
	flags      = SS_NO_FIRE


/datum/subsystem/map/New()
	NEW_SS_GLOBAL(SSmap)


/datum/subsystem/map/Initialize(timeofday)
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

	..()
