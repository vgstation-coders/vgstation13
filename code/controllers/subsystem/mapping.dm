var/datum/subsystem/mapping/SSMapping

/datum/subsystem/mapping
	name          = "Mapping"
	init_order    = SS_INIT_MAPPING
	display_order = SS_DISPLAY_MAPPING
	priority      = SS_PRIORITY_MAPPING
	wait          = SS_WAIT_MAPPING
	flags 		  = SS_NO_FIRE
	var/list/currentrun
	// var/datum/procedural_generator/PG

/datum/subsystem/mapping/New()
	NEW_SS_GLOBAL(SSMapping)

/datum/subsystem/mapping/Initialize()
	// var/datum/procedural_generator/genpath = pick(typesof(/datum/procedural_generator) - /datum/procedural_generator)
	// PG = new genpath
	generate_roundstart_away_missions()
	generate_roundstart_vaults()
	load_default_zlevels()
	load_procgen_zlevel()
	spawn_map_pickspawners() //this is down here so that it calls after allll the vaults etc are done spawning - if in the future some pickspawners don't fire, it's because this needs moving
	..()

// /datum/subsystem/mapping/stat_entry()
// 	..("P:[PG.turfs_remaining]")

// /datum/subsystem/mapping/fire(resumed = FALSE)
// 	if(!resumed)
// 		currentrun = block(locate(1,PG.current_row,PG.procgen_z),locate(PG.map_size,PG.current_row+(PG.rows_per_tick-1),PG.procgen_z))

// 	while(currentrun.len)
// 		var/turf/T = currentrun[currentrun.len]
// 		currentrun.len--

// 		if(!T || T.gcDestroyed)
// 			continue

// 		PG.process(T)

// 		if(MC_TICK_CHECK)
// 			return

// 	PG.current_row += PG.rows_per_tick

/////////////////////////////////////////////////////////////////////////////////////////////////
// INIT PROCS ---------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////////////////
/datum/subsystem/mapping/proc/generate_roundstart_away_missions()
	if (config.enable_roundstart_away_missions)
		log_startup_progress("Attempting to generate an away mission...")
		createRandomZlevel()

/datum/subsystem/mapping/proc/generate_roundstart_vaults()
	if (!config.skip_vault_generation)
		var/watch = start_watch()
		log_startup_progress("Placing random space structures...")
		generate_vaults()
		generate_asteroid_secrets()
		make_mining_asteroid_secrets() // loops 3 times
		log_startup_progress("  Finished placing structures in [stop_watch(watch)]s.")
	else
		log_startup_progress("Not generating vaults - SKIP_VAULT_GENERATION found in config/config.txt")

	//hobo shack generation, one shack will spawn, 1/3 chance of two shacks
	generate_hoboshack()
	if (rand(1,3) == 3)
		generate_hoboshack()

/datum/subsystem/mapping/proc/load_default_zlevels()
	var/watch_prim = start_watch()
	for(var/datum/zLevel/z in map.zLevels)
		var/watch = start_watch()
		z.post_mapload()
		log_debug("Finished with zLevel [z.z] in [stop_watch(watch)]s.", FALSE)
	log_debug("Finished calling post on zLevels in [stop_watch(watch_prim)]s.", FALSE)

	var/watch = start_watch()
	map.map_specific_init()
	log_debug("Finished map-specific inits in [stop_watch(watch)]s.", FALSE)

/datum/subsystem/mapping/proc/load_procgen_zlevel()
	world.maxz += 1
	map.addZLevel(new /datum/zLevel/procgen,world.maxz,TRUE,TRUE)
	var/newz = map.zLevels.len
	log_debug("Z-level [newz] reserved for procedural generation.")
	configure_virtual_zlevels(newz)


/////////////////////////////////////////////////////////////////////////////////////////////////
// VIRTUAL Z LEVELS =--------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////////////////
/turf/unsimulated/wall/edge
	name = "edge"
	desc = null
	icon = 'icons/turf/space.dmi'
	icon_state = "black"
	layer = TURF_LAYER
	plane = TURF_PLANE
	mouse_opacity = 0
	explosion_block = 50

/datum/subsystem/mapping/proc/configure_virtual_zlevels(var/z_id) //Splits a single z-level into 5 sub-maps (1 250x250, 2 200x200, 2 100x100)
	var/list/cornerx1 = list(
		"x1" = 251,
		"x2" = 301,
		"x3" = 0,
		"x4" = 101,
		"x5" = 0
	)
	var/list/cornerx2 = list(
		"x1" = 299,
		"x2" = 500,
		"x3" = 299,
		"x4" = 149,
		"x5" = 299
	)
	var/list/cornery1 = list(
		"y1" = 500,
		"y2" = 299,
		"y3" = 249,
		"y4" = 150,
		"y5" = 49
	)
	var/list/cornery2 = list(
		"y1" = 0,
		"y2" = 201,
		"y3" = 151,
		"y4" = 51,
		"y5" = 0
	)
	for(var/i = 1, i <= cornerx1.len, i++)
		for(var/turf/T in block(locate(cornerx1["x[i]"],cornery1["y[i]"],z_id),locate(cornerx2["x[i]"],cornery2["y[i]"],z_id)))
			T.ChangeTurf(/turf/unsimulated/wall/edge)
		addVLevel("Procedurally-Generated Planet Zone [i]", i, map.zLevels[world.maxz], round(cornerx1["x[i]"],10),round(cornerx2["x[i]"],10), round(cornery1["y[i]"],10), round(cornery2["y[i]"],world.maxz))

	log_startup_progress("Created [vLevels.len] virtual z-levels at z-level [z_id].")
