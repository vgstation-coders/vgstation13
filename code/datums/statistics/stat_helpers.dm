// functions related to handling/collecting data, and not writing data specifically
#define STRIP_NEWLINE(S) replacetextEx(S, "\n", null)

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

/datum/stat_collector/proc/add_explosion_stat(turf/epicenter, const/dev_range, const/hi_range, const/li_range, mx_range)
	var/datum/stat/explosion_stat/e = new
	e.epicenter_x = epicenter.x
	e.epicenter_y = epicenter.y
	e.epicenter_z = epicenter.z
	e.devastation_range = dev_range
	e.heavy_impact_range = hi_range
	e.light_impact_range = li_range
	e.max_range = mx_range
	stat_collection.explosions += e

/datum/stat_collector/proc/add_death_stat(var/mob/living/M)
	if(istype(M, /mob/living)) return 0
	if(ticker.current_state != 3)
		return 0 // We don't care about pre-round or post-round deaths. 3 is GAME_STATE_PLAYING which is undefined I guess
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
		if(M.mind.special_role && M.mind.special_role != "")
			d.special_role = M.mind.special_role
		if(M.mind.key)
			d.key = ckey(M.mind.key) // To prevent newlines in keys
		if(M.mind.name)
			d.realname = M.mind.name
	stat_collection.deaths += d

/datum/stat_collector/proc/add_survivor_stat(var/mob/living/M)
	if(istype(M, /mob/living)) return 0

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
		stat_collection.borgs_at_roundend++

	if(M.mind)
		if(M.mind.assigned_role && M.mind.assigned_role != "")
			s.assigned_role = M.mind.assigned_role
			if(M.mind.assigned_role in command_positions)
				stat_collection.heads_at_roundend++
		if(M.mind.special_role && M.mind.special_role != "")
			s.special_role = M.mind.special_role
		if(M.mind.key)
			s.key = ckey(M.mind.key) // To prevent newlines in keys
		if(M.mind.name)
			s.realname = M.mind.name
	stat_collection.survivors += s

/datum/stat_collector/proc/uplink_purchase(var/datum/uplink_item/bundle, var/obj/resulting_item, var/mob/user )
	var/was_traitor = 1
	if(user.mind && user.mind.special_role != "traitor")
		was_traitor = 0

	if(istype(bundle, /datum/uplink_item/badass/bundle))
		var/datum/stat/uplink_badass_bundle_stat/BAD = new
		var/obj/item/weapon/storage/box/B = resulting_item
		for(var/obj/O in B.contents)
			BAD.contains += O.type
		BAD.purchaser_key = ckey(user.mind.key)
		BAD.purchaser_name = STRIP_NEWLINE(user.mind.name)
		BAD.purchaser_is_traitor = was_traitor
		badass_bundles += BAD
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
		uplink_purchases += UP

/datum/stat/population_stat/New(pop as num)
	time = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	popcount = pop

/datum/stat_collector/proc/doPostRoundChecks()
	for(var/datum/mind/M in ticker.minds)
		if(M.active && istype(M.current, /mob/living) && !M.current.isDead())
			add_survivor_stat(M.current)
			if(M.special_role == "Cultist")
				stat_collection.cult_surviving_cultists++

/proc/stats_server_alert_new_file()
	world.Export("http://stats.ss13.moe/alert_new_file")

// Global stuff
/proc/population_poll()
	var/playercount = 0
	for(var/mob/M in player_list)
		if(M.client)
			playercount += 1
	stat_collection.population_polls += (new /datum/stat/population_stat(playercount))

/proc/population_poll_loop()
	while(1)
		population_poll()
		sleep(5 MINUTES) // we're called inside a spawn() so we'll be fine
