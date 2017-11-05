//unused now

/datum/stat_collector/proc/Process_csv()
	var/statfile = get_valid_file("txt")

	to_chat(world, "Writing statistics to file")

	var/start_time = world.realtime
	Write_Header_CSV(statfile)
	statfile << "TECH_TOTAL|[get_research_score()]"
	statfile << "BLOOD_SPILLED|[blood_spilled]"
	statfile << "CRATES_ORDERED|[crates_ordered]"
	statfile << "ARTIFACTS_DISCOVERED|[artifacts_discovered]"
	statfile << "CREWSCORE|[crewscore]"
	statfile << "ESCAPEES|[escapees]"
	statfile << "NUKED|[nuked]"

	for(var/datum/stat/death_stat/D in death_stats)
		statfile << STRIP_NEWLINE("MOB_DEATH|[D.mob_typepath]|[D.special_role]|[num2text(D.time_of_death, 30)]|[D.last_attacked_by]|[D.death_x]|[D.death_y]|[D.death_z]|[D.key]|[D.realname]")
	for(var/datum/stat/explosion_stat/E in explosion_stats)
		statfile << "EXPLOSION|[E.epicenter_x]|[E.epicenter_y]|[E.epicenter_z]|[E.devastation_range]|[E.heavy_impact_range]|[E.light_impact_range]|[E.max_range]"
	for(var/datum/stat/uplink_purchase_stat/U in uplink_purchases)
		statfile << STRIP_NEWLINE("UPLINK_ITEM|[U.purchaser_key]|[U.purchaser_name]|[U.purchaser_is_traitor]|[U.bundle]|[U.itemtype]")
	for(var/datum/stat/uplink_badass_bundle_stat/B in badass_bundles)
		var/o 	= 	STRIP_NEWLINE("BADASS_BUNDLE|[B.purchaser_key]|[B.purchaser_name]|[B.purchaser_is_traitor]")
		for(var/S in B.contains)
			o += "|[S]"
		statfile << "[o]"

	cult.doPostRoundChecks()
	cult.writeStats(statfile)

	xeno.doPostRoundChecks()
	xeno.writeStats(statfile)

	blobblob.doPostRoundChecks()
	blobblob.writeStats(statfile)

	malf.doPostRoundChecks()
	malf.writeStats(statfile)

	revsquad.doPostRoundChecks()
	revsquad.writeStats(statfile)

	antagCheckCSV(statfile)
	writePopulationStatsCSV(statfile)

	Write_Footer_CSV(statfile)
	world.log << "Statistics written to file in [(start_time - world.realtime)/10] seconds." // I think that's right?


// This guy writes the first line(s) of the stat file! Woo!
/datum/stat_collector/proc/Write_Header_CSV(statfile)
	var/start_timestamp = time2text(round_start_time, "YYYY.MM.DD.hh.mm.ss")
	var/end_timestamp = time2text(world.realtime, "YYYY.MM.DD.hh.mm.ss")
	statfile << "STATLOG_START|[STAT_OUTPUT_VERSION]|[map.nameLong]|[start_timestamp]|[end_timestamp]"
	statfile << "MASTERMODE|[master_mode]" // sekrit, or whatever else was decided as the 'actual' mode on round start.
	if(istype(ticker.mode, /datum/game_mode/mixed))
		var/datum/game_mode/mixed/mixy = ticker.mode
		var/T = "GAMEMODE"
		for(var/datum/game_mode/GM in mixy.modes)
			T += "|[GM.name]"
		statfile << T
	else
		statfile << "GAMEMODE|[ticker.mode.name]"

/datum/stat_collector/proc/Write_Footer_CSV(statfile)
	statfile << "WRITE_COMPLETE" // because I'd like to know if a write was interrupted and therefore invalid

/datum/stat_collector/proc/writePopulationStatsCSV(statfile)
	for(var/datum/stat/population_stat/PS in population_polls)
		statfile << "POPCOUNT|[PS.time]|[PS.popcount]"

/datum/stat_collector/proc/antagCheckCSV(statfile)
	for(var/datum/mind/Mind in ticker.minds)
		for(var/datum/objective/objective in Mind.objectives)
			if(objective.explanation_text == "Free Objective")
				statfile << STRIP_NEWLINE("ANTAG_OBJ|[Mind.name]|[Mind.key]|[Mind.special_role]|FREE_OBJ")
			else if (objective.target)
				statfile << STRIP_NEWLINE("ANTAG_OBJ|[Mind.name]|[Mind.key]|[Mind.special_role]|[objective.type]|[objective.target]|[objective.target.assigned_role]|[objective.target.name]|[objective.check_completion()]|[objective.explanation_text]")
			else
				statfile << STRIP_NEWLINE("ANTAG_OBJ|[Mind.name]|[Mind.key]|[Mind.special_role]|[objective.type]|[objective.check_completion()]|[objective.explanation_text]")
