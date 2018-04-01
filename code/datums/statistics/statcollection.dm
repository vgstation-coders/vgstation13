/* THE GREAT BIG STATISTICS COLLECTION project
	The objective of all this shitcode is to collect important/interesting events in a round
	and write it to a really dumb text file, which will then be processed by an external server,
	whichi will generate a pretty, web-viewable version (if I get my shit together)
	by the public.

	Gamemode-specific stat collection is separated off into its own files because why not


	stat_collector is the nerve center, everything else is just there to store data until
	round end.
*/

// Important things to store stats on that aren't located here:
// ticker.mode, actual gamemode
// master_mode, i.e. secret, mixed

// To ensure that if output file syntax is changed, we will still be able to process
// new and old files
#define STAT_OUTPUT_VERSION "1.2"
#define STAT_OUTPUT_DIR "data/statfiles/"

var/list/datum_donotcopy = list("tag", "type", "parent_type", "vars", "gcDestroyed", "being_sent_to_past", "disposed")

// NOTE: datum2list and datum2json are pretty snowflakey and won't recurse properly in some cases
// specfically it checks for infinite recursion only one level down, so if you have:
// thing1
// 		thing2
//			thing3 referencing thing1
// you'll end up in an infinite loop
// don't use it for that that's bad
proc/datum2list(var/datum/D, var/list/do_not_copy=datum_donotcopy, parent_datum=null)
	var/list/L = list()
	for(var/I in D.vars)
		if(I in do_not_copy)
			continue
		L.Add(I)
		if(istype(D.vars[I], /list))
			var/list/item = D.vars[I]
			item = item.Copy() // so we get a copy of the list from vars instead

			var/iter = 0 // i'm running out of variables names
			// this next loop is gonna assume non-iterative
			for(var/X in item)
				iter++
				if(istype(X, /datum))
					if(X == parent_datum)
						item[iter] = "parentRecursionPrevention"
					else
						item[iter] = datum2list(X, do_not_copy, parent_datum)
			L[I] = item
		else
			L[I] = D.vars[I]
	return L

// converts a datum (including atoms!) to a JSON object
// do_not_copy is a list of vars to not include in the JSON output
proc/datum2json(var/datum/D, var/list/do_not_copy=datum_donotcopy)
	ASSERT(istype(D))

	var/list/L = datum2list(D, do_not_copy)
	for(var/I in L)
		if(istype(L[I], /datum))
			L[I] = datum2list(L[I], do_not_copy, D)
		else
			L[I] = L[I]
	return json_encode(L)

/datum/stat_collector
	var/const/data_revision = STAT_OUTPUT_VERSION
	// UNUSED
	// var/enabled = 1
	var/list/deaths = list()
	var/list/explosions = list()
	var/list/survivors = list()
	var/list/uplink_purchases = list()
	var/list/badass_bundles = list()
	var/list/antag_objectives = list()
	var/list/population_polls = list()
	// Blood spilled in c.liters
	var/blood_spilled = 0
	var/crates_ordered = 0
	var/artifacts_discovered = 0
	var/narsie_corpses_fed = 0
	var/crewscore = 0
	var/nuked = FALSE
	var/borgs_at_roundend = 0
	var/heads_at_roundend = 0


	// GAMEMODE-SPECIFIC STATS START HERE
	// cult stuff
	var/cult_runes_written = 0
	var/cult_runes_nulled = 0
	var/cult_runes_fumbled = 0
	var/cult_converted = 0
	var/cult_tomes_created = 0
	var/cult_narsie_summoned = FALSE
	var/cult_narsie_corpses_fed = 0
	var/cult_surviving_cultists = 0
	var/cult_deconverted = 0

	// xenos (yes they aren't a gamemode shut up)
	var/xeno_eggs_laid = 0
	var/xeno_faces_hugged = 0
	var/xeno_faces_protected = 0

	// blob
	var/blob_wins = FALSE
	var/blob_spawned_blob_players = 0
	var/blob_spores_spawned = 0
	var/blob_res_generated = 0

	// malf
	var/malf_won = FALSE
	var/malf_shunted = FALSE
	var/list/malf_modules = list() // TODO change the stats server model for this

	// revsquad
	var/revsquad_won = FALSE
	var/list/revsquad_items = list()


	// THESE MUST BE SET IN POSTROUNDCHECKS OR SOMEWHERE ELSE BEFORE THAT IS CALLED
	var/round_start_time = null
	var/round_end_time = null
	var/mapname = null
	var/mastermode = null
	var/tickermode = null
	var/list/mixed_gamemodes = list()
	var/tech_total = 0
	var/stationname = null

/datum/stat/population_stat
	var/time
	var/popcount = 0

/datum/stat/death_stat
	var/mob_typepath = null
	var/death_x = 0
	var/death_y = 0
	var/death_z = 0
	var/time_of_death = 0
	var/special_role = null
	var/assigned_role = null
	var/key = null
	var/realname = null
	var/list/damagevalues = list(
		"BRUTE" = 0,
		"FIRE" = 0,
		"TOXIN" = 0,
		"OXY" = 0,
		"CLONE" = 0,
		"BRAIN" = 0)

// this literally only exists because it's easier for me to serialize this way
/datum/stat/survivor
	var/mob_typepath = null
	var/special_role = null
	var/assigned_role = null
	var/key = null
	var/realname = null
	var/escaped = FALSE
	var/list/damagevalues = list(
		"BRUTE" = 0,
		"FIRE" = 0,
		"TOXIN" = 0,
		"OXY" = 0,
		"CLONE" = 0,
		"BRAIN" = 0)

/datum/stat/antag_objective
	var/realname = null
	var/key = null
	var/special_role = null
	var/objective_type = null
	var/objective_desc = null
	var/objective_succeeded = FALSE
	var/target_name = null
	var/target_role = null

/datum/stat/uplink_purchase_stat
	var/itemtype = null
	var/bundle = null
	var/purchaser_key = null
	var/purchaser_name = null
	var/purchaser_is_traitor = TRUE

/datum/stat/uplink_badass_bundle_stat
	var/list/contains = list()
	var/purchaser_key = null
	var/purchaser_name = null
	var/purchaser_is_traitor = TRUE

/datum/stat/explosion_stat
	var/epicenter_x = 0
	var/epicenter_y = 0
	var/epicenter_z = 0
	var/devastation_range = 0
	var/heavy_impact_range = 0
	var/light_impact_range = 0

/datum/stat_collector/proc/get_valid_file(var/extension = "json")
	var/filename_date = time2text(round_start_time, "YYYY-MM-DD")
	var/uniquefilename = time2text(round_start_time, "hhmmss")
	// Iterate until we have an unused file.
	while(fexists(file(("[STAT_OUTPUT_DIR]statistics-[filename_date].[uniquefilename].[extension]"))))
		uniquefilename = "[uniquefilename].dupe"
	return file("[STAT_OUTPUT_DIR]statistics-[filename_date].[uniquefilename].[extension]")

// new shiny JSON export
/datum/stat_collector/proc/Process()
	var/statfile = get_valid_file("json")
	doPostRoundChecks()

	to_chat(world, "Writing statistics to file")
	var/start_time = world.realtime

	var/jsonout = datum2json(src)
	statfile << jsonout
	world.log << "Statistics written to file in [(start_time - world.realtime)/10] seconds." // I think that's right?
	stats_server_alert_new_file()
	spawn(10 SECONDS)
		to_chat(world, "<span class='info center'>Statistics for this round available at http://stats.ss13.moe/match/latest</span>")

// TODO write all living mobs to DB
