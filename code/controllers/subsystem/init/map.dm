// Subsystem for things such as vaults and away mission init.

var/datum/subsystem/map/SSmap

/**
List of players by z level
	list(1 = list(mind1, mind2, mind3...)
		2 = list())

fleshed out in map init
populated during player spawning.

**/
var/list/players_by_z_level = list()



proc/handle_z_level_transition(var/datum/mind/M, var/from_z, var/to_z)
	if(players_by_z_level.len && from_z && to_z && M) //If it's initialized
		for(var/i = 1 to players_by_z_level.len) //Find them in the list currently
			if(islist(players_by_z_level[i]))
				var/list/L = players_by_z_level[i]
				if(i != to_z && L.Find(M)) //They are in this list, and shouldn't be
					L.Remove(M)
				if(i == to_z && !L.Find(M)) //They aren't in this list and should be
					L.Add(M)

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

	if(config.disable_zlevel_processing_if_no_players)
		log_startup_progress("disable zlevel processing if no players enabled. Initializing list.")
		for(var/datum/zLevel/Z in map.zLevels)
			players_by_z_level.Add(Z.z)
			players_by_z_level[Z.z] = list()
		log_startup_progress("List initialized. number of zLevels [players_by_z_level.len].")
	..()