/datum/unit_test/dynamic
	var/datum/gamemode/dynamic/dynamic_mode
	var/datum/dynamic_ruleset
	var/ruletype = /datum/dynamic_ruleset/roundstart/traitor

/datum/unit_test/dynamic/start()
	ticker.mode = new /datum/gamemode/dynamic
	dynamic_mode = ticker.mode
	dynamic_ruleset = new ruletype
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
		N.mind = new("fgsfds")
		if(i <= 3)
			N.ready = 1
		player_list += N
	..()
	assert_eq(player_list.len, 5)
	assert_eq(dynamic_mode.roundstart_pop_ready, 3)
