#define MONKEY_DANGER_COUNT 4
#define ENDGAME_RATIO 0.5

/datum/faction/junglefever
	name = MADMONKEY
	ID = MADMONKEY
	logo_state = "monkey-logo"

	initroletype = /datum/role/madmonkey
	initial_role = MADMONKEY

	roletype = /datum/role/madmonkey
	late_role = MADMONKEY
	var/lastratio = 0

/datum/faction/junglefever/HandleRecruitedRole(var/datum/role/R)
	..()
	CheckQuarantine()

/datum/faction/junglefever/forgeObjectives()
	AppendObjective(/datum/objective/infect)

/datum/faction/junglefever/process()
	..()
	var/gameactivetime = world.time - ticker.gamestart_time*10 //gamestart_time is expressed in seconds, not deciseconds
	if(gameactivetime < 5 MINUTES)
		return
	var/alive = FALSE
	for(var/datum/role/R in members)
		var/mob/M = R.antag.current
		if(M && M.stat && isbadmonkey(M))
			alive = TRUE
	if(!alive && stage >= FACTION_ENDGAME)
		stage(FACTION_DEFEATED)

/datum/faction/junglefever/proc/CheckQuarantine()
	var/monkeys = 0
	var/humans = 0

	for(var/mob/M in player_list)
		if(!M.client)
			continue
		if(!iscarbon(M) || M.stat == DEAD)
			continue //include borers, silicons, the dead, etc.
		var/turf/T = get_turf(M)
		if(T.z != STATION_Z)
			continue
		if(isbadmonkey(M))
			monkeys++
		else
			humans++
	lastratio = monkeys/(monkeys+humans)

	if(stage < FACTION_ACTIVE && monkeys > MONKEY_DANGER_COUNT)
		stage(FACTION_ACTIVE)

	if(stage < FACTION_ENDGAME && lastratio >= ENDGAME_RATIO)
		stage(FACTION_ENDGAME)

	if(stage < FACTION_VICTORY && !humans)
		stage(FACTION_VICTORY)

/datum/faction/junglefever/stage(var/stage)
	..()
	switch(stage)
		if(FACTION_ACTIVE)
			command_alert(/datum/command_alert/jungle_fever)

		if(FACTION_ENDGAME)
			command_alert(/datum/command_alert/jungle_endgame)

		if(FACTION_DEFEATED)
			command_alert(/datum/command_alert/jungle_purified)

/datum/faction/junglefever/check_win()
	if(stage >= FACTION_VICTORY)
		to_chat(world, "<font size = 3><b>No Humans Left!</b></font><br/><font size = 2>The outbreak of Jungle Fever was not contained.</font>")
		return 1
	return 0