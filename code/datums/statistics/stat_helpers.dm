// the main file for statistics is statcollection.dm, look there first

// functions related to handling/collecting data, and not writing data specifically
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
	for(var/ID in tech_list)
		var/datum/tech/T = tech_list[ID]
		if(T.goal_level==0) // Ignore illegal tech, etc
			continue
		var/datum/tech/KT = server.files.GetKTechByID(ID)
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
	if(M.iscorpse) return 0 // only ever 1 if they are a corpse landmark spawned mob
	if(ticker.current_state != GAME_STATE_PLAYING) return 0 // We don't care about pre-round or post-round deaths. 3 is TICKERSTATE_PLAYING which is undefined I guess
	if(!istype(M, /mob/living) || istype(M, /mob/living/carbon/human/manifested)) return 0

	var/datum/stat/death_stat/d = new
	d.time_of_death = M.timeofdeath

	var/turf/spot = get_turf(M)
	d.death_x = spot.x
	d.death_y = spot.y
	d.death_z = spot.z

	d.mob_typepath = M.type
	d.mind_name = M.name
	d.from_suicide = M.suiciding

	d.damage["BRUTE"] = M.bruteloss
	d.damage["FIRE"]  = M.fireloss
	d.damage["TOXIN"] = M.toxloss
	d.damage["OXY"]   = M.oxyloss
	d.damage["CLONE"] = M.cloneloss
	d.damage["BRAIN"] = M.brainloss

	if(M.mind)
		if(M.mind.assigned_role && M.mind.assigned_role != "")
			d.assigned_role = M.mind.assigned_role
		// if(M.mind.special_role && M.mind.special_role != "")
		// 	d.special_role = M.mind.special_role
		if(M.mind.key)
			d.key = ckey(M.mind.key) // To prevent newlines in keys
		if(M.mind.name)
			d.mind_name = M.mind.name
	deaths.Add(d)

/datum/stat_collector/proc/add_survivor_stat(var/mob/living/M)
	if(!istype(M, /mob/living)) return 0

	var/datum/stat/survivor/s = new
	s.mob_typepath = M.type
	s.mind_name = M.name

	var/turf/spot = get_turf(M)
	s.loc_x = spot.x
	s.loc_y = spot.y
	s.loc_z = spot.z

	s.damage["BRUTE"] = M.bruteloss
	s.damage["FIRE"]  = M.fireloss
	s.damage["TOXIN"] = M.toxloss
	s.damage["OXY"]   = M.oxyloss
	s.damage["CLONE"] = M.cloneloss
	s.damage["BRAIN"] = M.brainloss

	if(istype(M, /mob/living/silicon/robot))
		borgs_at_round_end++
	// how the scoreboard checked for escape-ness:
	// if(istype(T.loc, /area/shuttle/escape/centcom) || istype(T.loc, /area/shuttle/escape_pod1/centcom) || istype(T.loc, /area/shuttle/escape_pod2/centcom) || istype(T.loc, /area/shuttle/escape_pod3/centcom) || istype(T.loc, /area/shuttle/escape_pod5/centcom))
	// luckily this works for us:
	if(M.z == map.zCentcomm)
		s.escaped = TRUE // not all survivors escape, and not all rounds end with the shuttle

	if(M.mind)
		if(M.mind.assigned_role && M.mind.assigned_role != "")
			s.assigned_role = M.mind.assigned_role
			if(M.mind.assigned_role in command_positions)
				heads_at_round_end++
		if(M.mind.special_role && M.mind.special_role != "")
			s.special_role = M.mind.special_role
		if(M.mind.key)
			s.key = ckey(M.mind.key) // To prevent newlines in keys
		if(M.mind.name)
			s.mind_name = STRIP_NEWLINE(M.mind.name)
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
		var/datum/stat/uplink_purchase_stat/PUR = new
		if(istype(bundle, /datum/uplink_item/badass/random))
			PUR.itemtype = resulting_item.type
		else
			PUR.itemtype = bundle.item
		PUR.bundle = bundle.type
		PUR.purchaser_key = ckey(user.mind.key)
		PUR.purchaser_name = STRIP_NEWLINE(user.mind.name)
		PUR.purchaser_is_traitor = was_traitor
		uplink_purchases.Add(PUR)

/datum/stat_collector/proc/add_role(var/datum/role/R)
	R.stat_datum.generate_statistics(R)
	roles.Add(R.stat_datum)

/datum/stat_collector/proc/add_faction(var/datum/faction/F)
	F.stat_datum.generate_statistics(F)
	factions.Add(F.stat_datum)

/datum/stat_collector/proc/do_post_round_checks()
	// grab some variables
	round_start_time = time2text(round_start_time, STAT_TIMESTAMP_FORMAT)
	round_end_time   = time2text(world.realtime,   STAT_TIMESTAMP_FORMAT)
	map_name = map.nameLong
	nuked = ticker.station_was_nuked
	tech_total = get_research_score()
	station_name = station_name()

	// check for survivors
	for(var/datum/mind/M in ticker.minds)
		// add_objectives(M)
		manifest_entries.Add(new /datum/stat_collector(M))
		if(istype(M.current, /mob/living) && !M.current.isDead())
			add_survivor_stat(M.current)


/proc/stats_server_alert_new_file()
	world.Export("http://stats.ss13.moe/alert_new_file")

#undef STAT_TIMESTAMP_FORMAT
