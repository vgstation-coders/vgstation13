/* Sood's Statistics Collection Project
	For the web side of this project, go to
	https://github.com/gbasood/vgstation-statistics-viewer

	What this part of the code does is take a bunch of data stored as datums and
	exports it to a JSON file so the statistics viewer can read it.

	The function that handles the JSONification is datum2json, which live in json_helpers.dm

	File structure:
		documentation/: Contains Markdown documentation for the code in this directory.
		statcollection.dm: Data definitions for non-gamemode related data that we collect, as well as core statistics logic.
		stat_helpers.dm: Contains procs which help with processing game data into statistics data for export.
		json_helpers.dm: Contains the logic that outputs all our data to valid JSON, since BYOND's built-in JSON methods do not output valid JSON.


	If you feel that there is some data that aught to be collected, feel free to make a PR to change
	this code. Be aware, however, that if the web server is not updated to handle new data formats,
	it will not properly use this information, or may cause the data to be discarded as invalid.
	In short, please ensure the web server is updated before merging changes to these files.

	When making additions, changes or removals to any of the data that is exported here, please change
	STAT_OUTPUT_VERSION. This allows me to easily handle new versions of data on the web server side.

*/

// To ensure that if output file syntax is changed, we will still be able to process
// new and old files
// please increment this version whenever making changes
#define STAT_OUTPUT_VERSION "1.3"
#define STAT_OUTPUT_DIR "data/statfiles/"

/datum/stat_collector
	var/const/data_revision = STAT_OUTPUT_VERSION
	// UNUSED
	// var/enabled = 1
	var/list/datum/stat/death_stat/deaths = list()
	var/list/datum/stat/explosion_stat/explosions = list()
	var/list/survivors = list()
	var/list/uplink_purchases = list()
	var/list/badass_bundles = list()
	var/list/antag_objectives = list()
	var/list/manifest_entries = list()
	var/list/datum/stat/role/roles = list()
	var/list/datum/stat/faction/factions = list()

	// Blood spilled in c.liters
	var/blood_spilled = 0
	var/crates_ordered = 0
	var/artifacts_discovered = 0
	var/narsie_corpses_fed = 0
	var/crew_score = 0
	var/nuked = FALSE
	var/borgs_at_round_end = 0
	var/heads_at_round_end = 0


	// GAMEMODE-SPECIFIC STATS START HERE
	var/datum/stat/dynamic_mode/dynamic_stats = null

	// THESE MUST BE SET IN POSTROUNDCHECKS OR SOMEWHERE ELSE BEFORE THAT IS CALLED
	var/round_start_time = null
	var/round_end_time = null
	var/map_name = null
	var/tech_total = 0
	var/station_name = null

/datum/stat
	// Hello. Nothing to see here.

/datum/stat/death_stat
	var/mob_typepath = null
	var/death_x = 0
	var/death_y = 0
	var/death_z = 0
	var/time_of_death = 0
	var/special_role = null
	var/assigned_role = null
	var/key = null
	var/mind_name = null
	var/from_suicide = 0
	var/list/damage = list(
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
	var/mind_name = null
	var/escaped = FALSE
	var/list/damage = list(
		"BRUTE" = 0,
		"FIRE" = 0,
		"TOXIN" = 0,
		"OXY" = 0,
		"CLONE" = 0,
		"BRAIN" = 0)
	var/loc_x = 0
	var/loc_y = 0
	var/loc_z = 0

/datum/stat/antag_objective
	var/mind_name = null
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

/datum/stat/manifest_entry
	var/key = null
	var/name = null
	var/assignment = null

// redo using mind list instead so we can get non-human players in its output
/datum/stat/manifest_entry/New(/var/mob/living/carbon/human/M)
	key = ckey(M.mind.key)
	name = STRIP_NEWLINE(M.mind.name)
	assignment = STRIP_NEWLINE(M.mind.assigned_job)

/datum/stat_collector/proc/get_valid_file(var/extension = "json")
	var/filename_date = time2text(round_start_time, "YYYY-MM-DD")
	var/uniquefilename = time2text(round_start_time, "hhmmss")
	// Iterate until we have an unused file.
	while(fexists(file(("[STAT_OUTPUT_DIR]statistics-[filename_date].[uniquefilename].[extension]"))))
		uniquefilename = "[uniquefilename].dupe"
	return file("[STAT_OUTPUT_DIR]statistics-[filename_date].[uniquefilename].[extension]")


/datum/stat_collector/proc/Process()
	var/statfile = get_valid_file("json")

	if (istype(ticker.mode, /datum/gamemode/dynamic))
		var/datum/gamemode/dynamic/mode = ticker.mode
		dynamic_stats = mode.dynamic_stats

	do_post_round_checks()

	to_chat(world, "Writing statistics to file")
	var/start_time = world.realtime
	var/jsonout = datum2json(src)
	statfile << jsonout
	world.log << "Statistics written to file in [(start_time - world.realtime)/10] seconds."

	stats_server_alert_new_file()
	spawn(10 SECONDS)
		to_chat(world, "<span class='info center'>Statistics for this round available at http://stats.ss13.moe/match/latest</span>")
