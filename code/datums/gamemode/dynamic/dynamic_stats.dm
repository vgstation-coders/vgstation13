
/datum/stat/dynamic_mode
	//population curbs, updated every minutes
	var/list/pop_levels = list()

	var/starting_threat_level = 0
	var/list/threat = list()

	var/list/roundstart_rulesets = list()
	var/roundstart_pop = 0

	var/list/successful_injections = list()//midround/latejoin rulesets should appear here

/datum/stat/dynamic_mode/proc/update_population(var/datum/gamemode/dynamic/mode)
	var/time = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/total_pop = 0
	for(var/mob/M in player_list)
		if(M.client)
			total_pop += 1
	pop_levels[time] = list(total_pop,mode.living_players.len,mode.living_antags.len,mode.dead_players.len,mode.list_observers.len)
