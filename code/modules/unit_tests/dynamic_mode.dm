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
	for(var/mob/M in player_list)
		qdel(M)

/datum/unit_test/dynamic/enemy_jobs
	var/dead_dont_count = FALSE

/datum/unit_test/dynamic/enemy_jobs/start()
	..()
	var/list/rules2check = dynamic_mode.roundstart_rules + dynamic_mode.latejoin_rules + dynamic_mode.midround_rules
	for(var/i in 1 to 10)
		dynamic_mode.threat_level = (i-1)*10
		for(var/datum/dynamic_ruleset/DR in rules2check)
			var/midround = !(istype(DR,/datum/dynamic_ruleset/roundstart) && !istype(DR,/datum/dynamic_ruleset/roundstart/delayed))
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
				if(midround)
					dynamic_mode.living_players += M
					if(dead_dont_count)
						M.stat = DEAD
				else
					dynamic_mode.candidates += M
			dynamic_mode.roundstart_pop_ready = dynamic_mode.candidates.len
			if(!ticker)
				fail("[__FILE__]:[__LINE__]: enemy job test failed, no ticker")
			var/old_game_state = ticker.current_state
			if(!midround) // make roundstart act like it for the proc
				ticker.current_state = GAME_STATE_SETTING_UP
			var/result = DR.check_enemy_jobs(midround,FALSE)
			var/tocheck = dead_dont_count && DR.required_enemies[i] // only if there is actual enemy jobs here
			ticker.current_state = old_game_state // and back again
			if(result == tocheck)
				fail("[__FILE__]:[__LINE__]: enemy job test failed. expected [!tocheck], got [result] on rule [DR.name] with a threat of [dynamic_mode.threat_level] with [enemies_count] out of [DR.required_enemies[i]] enemies[!midround ? " and [!midround ? dynamic_mode.roundstart_pop_ready : dynamic_mode.living_players.len] out of [DR.required_pop[i]] candidates" : ""]")

/datum/unit_test/dynamic/enemy_jobs/dead_dont_count
	dead_dont_count = TRUE
