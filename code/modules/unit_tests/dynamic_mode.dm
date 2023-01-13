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
	var/dead_dont_count = FALSE

/datum/unit_test/dynamic/enemy_jobs/start()
	..()
	for(var/i in 1 to 10)
		dynamic_mode.threat_level = (i-1)*10
		var/list/rules2check = dynamic_mode.roundstart_rules + dynamic_mode.latejoin_rules + dynamic_mode.midround_rules
		for(var/datum/dynamic_ruleset/DR in rules2check)
			for(var/mob/oldM1 in dynamic_mode.living_players)
				qdel(oldM1)
			for(var/mob/oldM2 in dynamic_mode.candidates)
				qdel(oldM2)
			dynamic_mode.living_players.Cut()
			dynamic_mode.candidates.Cut()
			var/mob/M
			var/enemies_count = 0
			for(var/j in 1 to max(DR.required_pop[i],DR.required_enemies[i]))
				M = new()
				M.mind = new("fgsfds[i]")
				if(j <= DR.required_enemies[i])
					M.mind.assigned_role = pick(DR.enemy_jobs)
					enemies_count++
				if(dead_dont_count)
					dynamic_mode.living_players += M
					M.stat = DEAD
				else
					dynamic_mode.candidates += M
			dynamic_mode.roundstart_pop_ready = max(dynamic_mode.candidates.len,dynamic_mode.living_players.len)
			var/result = DR.check_enemy_jobs(dead_dont_count,FALSE,!dead_dont_count)
			var/tocheck = dead_dont_count && DR.required_enemies[i]
			if(result == tocheck)
				fail("[__FILE__]:[__LINE__]: enemy job test failed. expected [!tocheck], got [result] with [enemies_count] out of [DR.required_enemies[i]] enemies[!dead_dont_count ? " and [dynamic_mode.roundstart_pop_ready] out of [DR.required_pop[i]] candidates" : ""]")

/datum/unit_test/dynamic/enemy_jobs/dead_dont_count
	dead_dont_count = TRUE
