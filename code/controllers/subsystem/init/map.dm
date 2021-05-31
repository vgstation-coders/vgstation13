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

	if (!config.skip_vault_generation)
		var/watch = start_watch()
		log_startup_progress("Placing random space structures...")
		generate_vaults()
		generate_asteroid_secrets()
		log_startup_progress("  Finished placing structures in [stop_watch(watch)]s.")
	else
		log_startup_progress("Not generating vaults - SKIP_VAULT_GENERATION found in config/config.txt")

	for(var/i = 0, i < max_secret_rooms, i++)
		make_mining_asteroid_secret()

	log_startup_progress("Calling post on zLevels, letting them know they can do zlevel specific stuff...")
	var/watch_prim = start_watch()
	for(var/datum/zLevel/z in map.zLevels)
		log_startup_progress("Generating zLevel [z.z].")
		var/watch = start_watch()
		z.post_mapload()
		log_startup_progress("Finished with zLevel [z.z] in [stop_watch(watch)]s.")
	log_startup_progress("Finished calling post on zLevels in [stop_watch(watch_prim)]s.")

	var/watch = start_watch()
	log_startup_progress("Starting map-specific inits...")
	map.map_specific_init()
	log_startup_progress("Finished map-specific inits in [stop_watch(watch)]s.")

	log_startup_progress("Creating pickspawners...")
	spawn_map_pickspawners() //this is down here so that it calls after allll the vaults etc are done spawning - if in the future some pickspawners don't fire, it's because this needs moving

	..()
