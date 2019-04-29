
/datum/stat/dynamic_mode
	//population curbs, updated every minutes
	var/list/pop_levels = list()

	var/starting_threat_level = 0
	var/list/threat = list()

	var/list/roundstart_rulesets = list()
	var/roundstart_pop = 0

	var/list/successful_injections = list()//midround/latejoin rulesets should appear here

/datum/stat/dynamic_mode/proc/update_population(var/datum/gamemode/dynamic/mode)
	var/datum/stat/pop_level/new_pop_level = new
	new_pop_level.time = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	for(var/mob/M in player_list)
		if(M.client)
			new_pop_level.total_server_pop += 1
	new_pop_level.living_players = mode.living_players.len
	new_pop_level.living_antags = mode.living_antags.len
	new_pop_level.dead_players = mode.dead_players.len
	new_pop_level.observers = mode.list_observers.len
	pop_levels.Add(new_pop_level)

/datum/stat/dynamic_mode/proc/successful_injection(var/datum/dynamic_ruleset/ruleset)
	var/datum/stat/successful_injection/new_injection = new
	new_injection.time = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	new_injection.name = ruleset.name
	successful_injections.Add(new_injection)

/datum/stat/dynamic_mode/proc/measure_threat(var/new_threat)
	var/datum/stat/threat_measure/new_threat_mesure = new
	new_threat_mesure.time = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	new_threat_mesure.threat = new_threat
	threat.Add(new_threat_mesure)

/datum/stat/pop_level
	var/time = ""
	var/total_server_pop = 0
	var/living_players = 0
	var/living_antags = 0
	var/dead_players = 0
	var/observers = 0

/datum/stat/successful_injection
	var/time = ""
	var/name = ""

/datum/stat/threat_measure
	var/time = ""
	var/threat = 0
