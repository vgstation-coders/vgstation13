/datum/unit_test/dynamic
	var/datum/gamemode/dynamic/dynamic_mode
	var/datum/dynamic_ruleset/ruleset
	var/ruletype = /datum/dynamic_ruleset/roundstart/traitor

/datum/unit_test/dynamic/start()
	ticker.mode = new /datum/gamemode/dynamic
	dynamic_mode = ticker.mode
	ruleset = new ruletype
	dynamic_mode.can_start()
	assert_eq(dynamic_mode.can_start(), 1)
	if(dynamic_mode)
		assert_eq(dynamic_mode.Setup(), 1)
	ASSERT(dynamic_mode.roundstart_rules.len)

/datum/unit_test/dynamic/noplayers/start()
	..()
	assert_eq(dynamic_mode.roundstart_pop_ready, 0)

/datum/unit_test/dynamic/players/start()
	var/mob/new_player/N
	for(var/i in 1 to 5)
		N = new()
		N.mind = new("fgsfds[i]")
		if(i <= 3)
			N.ready = 1
		player_list += N
	..()
	assert_eq(player_list.len, 5)
	assert_eq(dynamic_mode.roundstart_pop_ready, 3)

/datum/unit_test/dynamic/enemy_jobs
	var/midround = FALSE
	var/dead_dont_count = FALSE

/datum/unit_test/dynamic/enemy_jobs/start()
	..()
	dynamic_mode.threat_level = 50
	dynamic_mode.midround_threat_level = 50
	var/mob/M
	for(var/i in 1 to 5)
		M = new()
		M.mind = new("fgsfds[i]")
		if(dead_dont_count)
			dynamic_mode.living_players += M
			if(i > 3)
				M.stat = DEAD
		else
			dynamic_mode.candidates += M
	assert_eq(ruleset.check_enemy_jobs(dead_dont_count,midround), TRUE)
