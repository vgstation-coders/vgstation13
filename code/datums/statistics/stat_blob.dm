// Because why bloat the main file when I can do this?
/datum/stat_blob/

/datum/stat_blob/proc/doPostRoundChecks()

/datum/stat_blob/proc/writeStats(file)

/datum/stat_blob/cult
	var/runes_written = 0
	var/runes_fumbled = 0
	var/runes_nulled = 0
	var/tomes_created = 0
	var/converted = 0
	var/narsie_summoned = 0
	var/narsie_corpses_fed = 0
	var/surviving_cultists = 0
	var/deconverted = 0

/datum/stat_blob/cult/doPostRoundChecks()
	for(var/datum/mind/M in ticker.minds)
		if(M.active && istype(M.current, /mob/living/carbon) && M.special_role == "Cultist")
			surviving_cultists++

/datum/stat_blob/cult/writeStats(file)
	file << "CULTSTATS|[runes_written]|[runes_fumbled]|[runes_nulled]|[converted]|[tomes_created]|[narsie_summoned]|[narsie_corpses_fed]|[surviving_cultists]|[deconverted]"

/datum/stat_blob/xeno/
	var/eggs_laid = 0
	var/faces_hugged = 0 //this actually should only count people impregnated, I just like the name
	var/proper_head_protection = 0 //whenever a facehugger fails to impregnate someone

/datum/stat_blob/xeno/writeStats(file)
	file << "XENOSTATS|[eggs_laid]|[faces_hugged]|[proper_head_protection]"

/datum/stat_blob/blobmode
	var/blob_wins = 0
	var/spawned_blob_players = 0
	var/spores_spawned = 0
	var/res_generated = 0 // Note this does not take into consideration points that were wasted for going over the maximum possible points

/datum/stat_blob/blobmode/writeStats(file)
	file << "BLOBSTATS|[blob_wins]|[spawned_blob_players]|[spores_spawned]|[res_generated]"

/datum/stat_blob/malf
	var/malf_wins = 0
	var/list/bought_modules = list()
	var/borgs_at_roundend = 0
	var/did_shunt = 0

/datum/stat_blob/malf/doPostRoundChecks()
	for(var/mob/living/silicon/robot/R in player_list)
		if(!R.isUnconscious())
			borgs_at_roundend++ //TODO check lawset

/datum/stat_blob/malf/writeStats(file)
	file << "MALFSTATS|[malf_wins]|[did_shunt]|[borgs_at_roundend]"
	if(bought_modules.len)
		var/modulestring = "MALFMODULES"
		for(var/module in bought_modules)
			modulestring += "|[module]"
		file << modulestring

/datum/stat_blob/revsquad
	var/revsquad_won = 0
	var/list/revsquad_items = list()
	var/headcount = 0

/datum/stat_blob/revsquad/doPostRoundChecks()
	var/list/heads = ticker.mode.get_all_heads()
	headcount = heads.len

/datum/stat_blob/revsquad/writeStats(file)
	file << "REVSQUADSTATS|[revsquad_won]|[headcount]"
	if(revsquad_items.len)
		var/itemsline = "REVSQUADITEMS"
		for(var/i in revsquad_items)
			itemsline += "|[i]"
		file << itemsline
