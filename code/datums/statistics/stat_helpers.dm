// functions related to handling/collecting data, and not writing data specifically
#define STRIP_NEWLINE(S) replacetextEx(S, "\n", null)
// so I can't get timestamp info so unfortunately I can't do anything like ISO standards
// at least I can keep the format consistent though
#define STAT_TIMESTAMP_FORMAT "YYYY-MM-DD hh:mm:ss"

/datum/stat_collector/proc/get_research_score()
	var/obj/machinery/r_n_d/server/server = null
	var/tech_level_total
	for(var/obj/machinery/r_n_d/server/serber in machines)
		if(serber.name == "Core R&D Server")
			server=serber
			break
	if(!server)
		return
	for(var/datum/tech/T in tech_list)
		if(T.goal_level==0) // Ignore illegal tech, etc
			continue
		var/datum/tech/KT  = locate(T.type, server.files.known_tech)
		tech_level_total += KT.level
	return tech_level_total

/datum/stat_collector/proc/add_explosion_stat(turf/epicenter, const/dev_range, const/hi_range, const/li_range)
	if(ticker.current_state != GAME_STATE_PLAYING) return

	var/datum/stat/explosion_stat/e = new
	e.epicenter_x = epicenter.x
	e.epicenter_y = epicenter.y
	e.epicenter_z = epicenter.z
	e.devastation_range = dev_range
	e.heavy_impact_range = hi_range
	e.light_impact_range = li_range
	explosions.Add(e)

/datum/stat_collector/proc/add_death_stat(var/mob/living/M)
	if(!istype(M, /mob/living)) return 0
	if(M.iscorpse) return 0 // only ever 1 if they are a corpse landmark spawned mob
	if(ticker.current_state != GAME_STATE_PLAYING)
		return 0 // We don't care about pre-round or post-round deaths. 3 is TICKERSTATE_PLAYING which is undefined I guess
	var/datum/stat/death_stat/d = new
	d.time_of_death = M.timeofdeath
	d.death_x = M.x
	d.death_y = M.y
	d.death_z = M.z
	d.mob_typepath = M.type
	d.realname = M.name

	d.damagevalues["BRUTE"] = M.bruteloss
	d.damagevalues["FIRE"]  = M.fireloss
	d.damagevalues["TOXIN"] = M.toxloss
	d.damagevalues["OXY"]   = M.oxyloss
	d.damagevalues["CLONE"] = M.cloneloss
	d.damagevalues["BRAIN"] = M.brainloss

	if(M.mind)
		if(M.mind.assigned_role && M.mind.assigned_role != "")
			d.assigned_role = M.mind.assigned_role
		// if(M.mind.special_role && M.mind.special_role != "")
		// 	d.special_role = M.mind.special_role
		if(M.mind.key)
			d.key = ckey(M.mind.key) // To prevent newlines in keys
		if(M.mind.name)
			d.realname = M.mind.name
	deaths.Add(d)

/datum/stat_collector/proc/add_survivor_stat(var/mob/living/M)
	if(!istype(M, /mob/living)) return 0

	var/datum/stat/survivor/s = new
	s.mob_typepath = M.type
	s.realname = M.name

	s.damagevalues["BRUTE"] = M.bruteloss
	s.damagevalues["FIRE"]  = M.fireloss
	s.damagevalues["TOXIN"] = M.toxloss
	s.damagevalues["OXY"]   = M.oxyloss
	s.damagevalues["CLONE"] = M.cloneloss
	s.damagevalues["BRAIN"] = M.brainloss

	if(istype(M, /mob/living/silicon/robot))
		borgs_at_roundend++
	// how the scoreboard checked for escape-ness:
	// if(istype(T.loc, /area/shuttle/escape/centcom) || istype(T.loc, /area/shuttle/escape_pod1/centcom) || istype(T.loc, /area/shuttle/escape_pod2/centcom) || istype(T.loc, /area/shuttle/escape_pod3/centcom) || istype(T.loc, /area/shuttle/escape_pod5/centcom))
	// luckily this works for us:
	if(M.z == map.zCentcomm)
		s.escaped = TRUE // not all survivors escape, and not all rounds end with the shuttle

	if(M.mind)
		if(M.mind.assigned_role && M.mind.assigned_role != "")
			s.assigned_role = M.mind.assigned_role
			if(M.mind.assigned_role in command_positions)
				heads_at_roundend++
		if(M.mind.special_role && M.mind.special_role != "")
			s.special_role = M.mind.special_role
		if(M.mind.key)
			s.key = ckey(M.mind.key) // To prevent newlines in keys
		if(M.mind.name)
			s.realname = M.mind.name
	survivors.Add(s)

/datum/stat_collector/proc/uplink_purchase(var/datum/uplink_item/bundle, var/obj/resulting_item, var/mob/user )
	var/was_traitor = TRUE
	if(ticker.current_state != GAME_STATE_PLAYING) return

	// if(user.mind && user.mind.special_role != "traitor")
	// 	was_traitor = FALSE

	if(istype(bundle, /datum/uplink_item/badass/bundle))
		var/datum/stat/uplink_badass_bundle_stat/BAD = new
		var/obj/item/weapon/storage/box/B = resulting_item
		for(var/obj/O in B.contents)
			BAD.contains.Add(O.type)
		BAD.purchaser_key = ckey(user.mind.key)
		BAD.purchaser_name = STRIP_NEWLINE(user.mind.name)
		BAD.purchaser_is_traitor = was_traitor
		badass_bundles.Add(BAD)
	else
		var/datum/stat/uplink_purchase_stat/UP = new
		if(istype(bundle, /datum/uplink_item/badass/random))
			UP.itemtype = resulting_item.type
		else
			UP.itemtype = bundle.item
		UP.bundle = bundle.type
		UP.purchaser_key = ckey(user.mind.key)
		UP.purchaser_name = STRIP_NEWLINE(user.mind.name)
		UP.purchaser_is_traitor = was_traitor
		uplink_purchases.Add(UP)

/datum/stat_collector/proc/add_objectives(var/datum/mind/M)
	// if(M.objectives.len)
	// 	for(var/datum/objective/O in M.objectives)
	// 		var/datum/stat/antag_objective/AO = new
	// 		AO.key = ckey(M.key)
	// 		AO.realname = STRIP_NEWLINE(M.name)
	// 		AO.special_role = M.special_role
	// 		AO.objective_type = O.type
	// 		AO.objective_desc = O.explanation_text
	// 		AO.objective_succeeded = O.check_completion()
	// 		if(O.target)
	// 			AO.target_name = STRIP_NEWLINE(O.target.name)
	// 			AO.target_role = O.target.assigned_role
    //
	// 		antag_objectives.Add(AO)


/datum/stat/population_stat/New(pop as num)
	if(ticker.current_state != GAME_STATE_PLAYING) return

	time = time2text(world.realtime, STAT_TIMESTAMP_FORMAT)
	popcount = pop

/datum/stat_collector/proc/doPostRoundChecks()
	round_start_time = time2text(round_start_time, STAT_TIMESTAMP_FORMAT)
	round_end_time   = time2text(world.realtime,   STAT_TIMESTAMP_FORMAT)
	mapname = map.nameLong
	mastermode = master_mode // this is stored as a string in game
	tickermode = ticker.mode.name
	nuked = ticker.mode.station_was_nuked
	tech_total = get_research_score()
	stationname = station_name()
	// if(istype(ticker.mode, /datum/game_mode/mixed))
	// 	var/datum/game_mode/mixed/mixy = ticker.mode
	// 	for(var/datum/game_mode/GM in mixy.modes)
	// 		mixed_gamemodes.Add(GM.name)

	for(var/datum/mind/M in ticker.minds)
		add_objectives(M)
		if(istype(M.current, /mob/living) && !M.current.isDead())
			add_survivor_stat(M.current)
			if(M.special_role == "Cultist")
				cult_surviving_cultists++

/proc/stats_server_alert_new_file()
	world.Export("http://stats.ss13.moe/alert_new_file")

// Global stuff
/proc/population_poll()
	var/playercount = 0
	for(var/mob/M in player_list)
		if(M.client)
			playercount++
	stat_collection.population_polls.Add(new /datum/stat/population_stat(playercount))

/proc/population_poll_loop()
	while(1)
		population_poll()
		sleep(5 MINUTES) // we're called inside a spawn() so we'll be fine

#undef STAT_TIMESTAMP_FORMAT
