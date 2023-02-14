/datum/unit_test/dynamic
	var/datum/gamemode/dynamic/dynamic_mode
	var/datum/dynamic_ruleset/ruleset
	var/ruletype

/datum/unit_test/dynamic/start()
	ticker.mode = new /datum/gamemode/dynamic
	dynamic_mode = ticker.mode
	if(ruletype)
		ruleset = new ruletype
	dynamic_mode.can_start()
	assert_eq(dynamic_mode.can_start(), 1)
	if(dynamic_mode)
		assert_eq(dynamic_mode.Setup(), 1)
	ASSERT(dynamic_mode.roundstart_rules.len)
	ASSERT(dynamic_mode.midround_rules.len)
	ASSERT(dynamic_mode.latejoin_rules.len)

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
	// no need to check roundstart rules in the dead check, not used there
	var/list/rules2check = dead_dont_count ? dynamic_mode.latejoin_rules + dynamic_mode.midround_rules : dynamic_mode.roundstart_rules + dynamic_mode.latejoin_rules + dynamic_mode.midround_rules
	for(var/n in 1 to 10)
		dynamic_mode.threat_level = (n-1)*10
		for(var/datum/dynamic_ruleset/DR in rules2check)
			QDEL_LIST_CUT(dynamic_mode.living_players)
			QDEL_LIST_CUT(dynamic_mode.candidates)
			var/mob/M
			var/enemies_count = 0
			for(var/j in 1 to max(DR.required_pop[n],DR.required_enemies[n]))
				M = new()
				M.mind = new("fgsfds[n]")
				if(j <= DR.required_enemies[n])
					M.mind.assigned_role = pick(DR.enemy_jobs)
					enemies_count++
				if(DR.midround)
					dynamic_mode.living_players += M
					if(dead_dont_count)
						M.stat = DEAD
				else
					dynamic_mode.candidates += M
			dynamic_mode.roundstart_pop_ready = dynamic_mode.candidates.len
			ASSERT(ticker)
			var/old_game_state = ticker.current_state
			if(!DR.midround) // make roundstart act like it for the proc
				ticker.current_state = GAME_STATE_SETTING_UP
			var/result = DR.check_enemy_jobs(DR.midround,FALSE)
			var/tocheck = !(dead_dont_count && DR.midround && DR.required_enemies[n]) // only if there is actual enemy jobs here
			ticker.current_state = old_game_state // and back again
			if(result != tocheck)
				fail("[__FILE__]:[__LINE__]: enemy job test failed. expected [tocheck], got [result] on rule [DR.name] with a threat of [dynamic_mode.threat_level] with [enemies_count] out of [DR.required_enemies[n]] enemies[!DR.midround ? " and [!DR.midround ? dynamic_mode.roundstart_pop_ready : dynamic_mode.living_players.len] out of [DR.required_pop[n]] candidates" : ""]")

/datum/unit_test/dynamic/enemy_jobs/dead_dont_count
	dead_dont_count = TRUE

/datum/unit_test/dynamic/can_spend/start()
	..()
	var/list/rules2check = dynamic_mode.roundstart_rules + dynamic_mode.latejoin_rules + dynamic_mode.midround_rules
	for(var/i in 1 to 10)
		dynamic_mode.threat_level = (i-1)*10
		dynamic_mode.midround_threat_level = dynamic_mode.threat_level
		for(var/datum/dynamic_ruleset/DR in rules2check)
			if(DR.cost < dynamic_mode.threat_level)
				continue
			var/pop2check
			for(var/j in 1 to 10)
				dynamic_mode.living_players.Cut()
				pop2check = (j-1)*5
				for(var/k in 1 to pop2check)
					dynamic_mode.living_players.Add(list("fgsfds" = null))
				dynamic_mode.roundstart_pop_ready = pop2check
				if(dynamic_mode.threat_level >= DR.requirements[j])
					if(!DR.acceptable())
						fail("[__FILE__]:[__LINE__]: threat spending acceptability test failed. expected 1, got 0 on rule [DR.name] with [pop2check] players and [!DR.midround ? dynamic_mode.threat_level : dynamic_mode.midround_threat_level] threat out of [DR.requirements[j]]")
				else if(DR.acceptable())
					fail("[__FILE__]:[__LINE__]: threat spending acceptability test failed. expected 0, got 1 on rule [DR.name] with [pop2check] players and [!DR.midround ? dynamic_mode.threat_level : dynamic_mode.midround_threat_level] threat out of [DR.requirements[j]]")
