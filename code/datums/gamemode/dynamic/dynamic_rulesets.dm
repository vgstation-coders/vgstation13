/datum/dynamic_ruleset
	var/name = ""//For admin logging, and round end scoreboard.
	var/persistent = 0//if set to 1, the rule won't be discarded after being executed, and /gamemode/dynamic will call process() every MC tick
	var/repeatable = 0//if set to 1, dynamic mode will be able to draft this ruleset again later on. (doesn't apply for roundstart rules)
	var/midround = 1//if set to 1, is a midround rule
	var/list/candidates = list()//list of players that are being drafted for this rule
	var/list/assigned = list()//list of players that were selected for this rule
	var/datum/role/role_category = /datum/role/traitor //rule will only accept candidates with "Yes" or "Always" in the preferences for this role
	var/list/protected_from_jobs = list() // if set, and config.protect_roles_from_antagonist = 0, then the rule will have a much lower chance than usual to pick those roles.
	var/list/restricted_from_jobs = list()//if set, rule will deny candidates from those jobs
	var/list/exclusive_to_jobs = list()//if set, rule will only accept candidates from those jobs
	var/list/job_priority = list() //May be used by progressive_job_search for prioritizing some jobs for a role. Order matters.
	var/list/enemy_jobs = list()//if required_enemies is set, there needs to be a certain amount of players doing those jobs (among the players who won't be drafted) for the rule to be drafted
	var/list/required_pop = list(10,10,0,0,0,0,0,0,0,0)//this is the amount of population required for the ruleset to fire (per threat level in slices of 0-9, 10-11, etc..). if enemy_jobs was set, those players count double
	var/required_enemies = list(0,0,0,0,0,0,0,0,0,0)		//If set, the ruleset requires this many enemy jobs to be filled in order to fire (per threat level in slices of 0-9, 10-19, etc..)
	var/required_candidates = 0//the rule needs this many candidates (post-trimming) to be executed (example: Cult need 4 players at round start)
	var/weight = 5//1 -> 9, probability for this rule to be picked against other rules
	var/list/weekday_rule_boost = list()
	var/list/timeslot_rule_boost = list()
	var/cost = 0//threat cost for this rule.
	var/logo = ""//any state from /icons/logos.dmi
	var/calledBy //who dunnit, for round end scoreboard

	var/flags = 0

	var/stillborn = FALSE//executed when the round was already about to end

	//for midround polling
	var/list/applicants = list()
	var/searching = 0

	var/list/requirements = list(40,30,20,10,10,10,10,10,10,10)
	//requirements are the threat level requirements per pop range. The ranges are as follow:
	//0-4, 5-9, 10-14, 15-19, 20-24, 25-29, 30-34, 35-39, 40-44, 45+
	//so with the above default values, The rule will never get drafted below 10 threat level (aka: "peaceful extended"), and it requires a higher threat level at lower pops.
	//for reminder: the threat level is rolled at roundstart and tends to hover around 50 https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=499381388
	var/high_population_requirement = 10
	//an alternative, static requirement used instead when "high_population_override" is set to 1 in the config
	//which it should be when even low pop rounds have over 30 players and high pop rounds have 90+.

	var/datum/gamemode/dynamic/mode = null

	var/role_category_override = null // If a role is to be considered another for the purpose of bannig.

	var/weight_category = null	//Allows multiple rulesets to share the same dynamic weight (like Wizard and CWC, or a Roundstart Ruleset with its Midround/Latejoin variants)

/datum/dynamic_ruleset/New()
	..()
	if (config.protect_roles_from_antagonist)
		restricted_from_jobs += protected_from_jobs
	if (istype(ticker.mode, /datum/gamemode/dynamic))
		mode = ticker.mode
	else
		message_admins("A dynamic ruleset was created but server isn't on Dynamic Mode!")
		qdel(src)

/datum/dynamic_ruleset/roundstart//One or more of those drafted at roundstart
	midround = FALSE

/datum/dynamic_ruleset/roundstart/delayed/ // Executed with a 30 seconds delay
	var/delay = 30 SECONDS
	var/required_type = /mob/living/carbon/human // No ghosts, new players or silicons allowed.
	var/assigned_ckeys = list()

/datum/dynamic_ruleset/latejoin//Can be drafted when a player joins the server

/datum/dynamic_ruleset/proc/acceptable()
	//by default, a rule is acceptable if it satisfies the threat level/population requirements.
	//If your rule has extra checks, such as counting security officers, do that in ready() instead
	if (!map.map_ruleset(src))
		message_admins("Dynamic Mode: Skipping [name] due to map blacklist.")
		log_admin("Dynamic Mode: Skipping [name] due to map blacklist")
		return 0

	var/threat = !midround ? mode.threat : mode.midround_threat
	if(threat < cost)
		message_admins("Dynamic Mode: Skipping [name] due to not meeting threat cost.")
		log_admin("Dynamic Mode: Skipping [name] due to not meeting threat cost.")
		return 0

	var/threat_level = !midround ? mode.threat_level : mode.midround_threat_level
	if (player_list.len >= mode.high_pop_limit)
		return (threat_level >= high_population_requirement)
	else
		var/population = !midround ? mode.roundstart_pop_ready : mode.living_players.len
		var/indice_pop = min(10,round(population/5)+1)
		return (threat_level >= requirements[indice_pop])

// -- Choosing the candidate(s) for a rule which is otherwise guarenteed to be executed.
// This generic proc works for a solo candidate.
// returns: 0 or 1 depending on success. (failure meaning something runtimed mid-code.)
/datum/dynamic_ruleset/proc/choose_candidates()
	if (candidates.len <= 0)
		return FALSE
	var/mob/M = pick(candidates)
	if (istype(M))
		assigned += M
		candidates -= M
	return (assigned.len > 0)

/datum/dynamic_ruleset/proc/latespawn_interaction(var/mob/living/newPlayer)//persistent rulesets will attempt to hire latejoiners when applicable
	return FALSE

/datum/dynamic_ruleset/proc/execute()
	//write here your rule execution code, everything about faction/role spawning/populating.
	return 1

/datum/dynamic_ruleset/proc/ready(var/forced = 0)	//Here you can perform any additional checks you want. (such as checking the map, the amount of certain jobs, etc)
	if (admin_disable_rulesets && !forced)
		message_admins("Dynamic Mode: [name] was prevented from firing because rulesets are disabled.")
		log_admin("Dynamic Mode: [name] was prevented from firing because rulesets are disabled.")
		return FALSE
	if (required_candidates > candidates.len)		//IMPORTANT: If ready() returns 1, that means execute() should never fail!
		log_admin("Cannot accept [name] ruleset, lack of eligible players.")
		message_admins("Cannot accept [name] ruleset, lack of eligible players.")
		return FALSE
	return TRUE

// Returns TRUE if there is enough pop to execute this ruleset
/datum/dynamic_ruleset/proc/check_enemy_jobs(var/dead_dont_count = FALSE, var/midround = FALSE)
	var/enemies_count = 0
	if (dead_dont_count)
		for (var/mob/M in mode.living_players)
			if (M.stat == DEAD)
				continue//dead players cannot count as opponents
			if (M.mind && M.mind.assigned_role && (M.mind.assigned_role in enemy_jobs) && (!(M in candidates) || (M.mind.assigned_role in restricted_from_jobs)))
				enemies_count++//checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it
	else
		for (var/mob/M in mode.candidates)
			if (M.mind && M.mind.assigned_role && (M.mind.assigned_role in enemy_jobs) && (!(M in candidates) || (M.mind.assigned_role in restricted_from_jobs)))
				enemies_count++//checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it

	var/pop_and_enemies
	if (ticker && ticker.current_state == GAME_STATE_PLAYING)
		pop_and_enemies += mode.living_players.len
	else
		pop_and_enemies += mode.roundstart_pop_ready

	pop_and_enemies += enemies_count // Enemies count twice

	var/threat = 0
	if(midround)
		threat = mode.midround_threat_level != 100 ? round(mode.midround_threat_level/10)+1 : 10
	else
		threat = mode.threat_level != 100 ? round(mode.threat_level/10)+1 : 10
	if (enemies_count < required_enemies[threat] && !map.ignore_enemy_requirement(src))
		message_admins("Dynamic Mode: There are not enough enemy jobs ready for [name]. ([enemies_count] out of [required_enemies[threat]])")
		log_admin("Dynamic Mode: There are not enough enemy jobs ready for [name]. ([enemies_count] out of [required_enemies[threat]])")
		return FALSE
	if (pop_and_enemies >= required_pop[threat])
		return TRUE
	if (!dead_dont_count)//roundstart check only
		message_admins("Dynamic Mode: Despite [name] having enough candidates, there are not enough enemy jobs and pop ready ([enemies_count] and [mode.roundstart_pop_ready] out of [required_pop[threat]])")
		log_admin("Dynamic Mode: Despite [name] having enough candidates, there are not enough enemy jobs and pop ready ([enemies_count] and [mode.roundstart_pop_ready] out of [required_pop[threat]])")
	return FALSE

/datum/dynamic_ruleset/proc/get_weight()
	var/result = weight
	result *= map.ruleset_multiplier(src)
	result *= weight_time_day()

	for(var/datum/dynamic_ruleset/DR in mode.executed_rules)
		if(DR.role_category == src.role_category) // If the same type of antag is already in this round, reduce the odds
			result *= 0.5
			break

	result = previous_rounds_odds_reduction(result)

	if (weight_category in mode.ruleset_category_weights)
		result *= mode.ruleset_category_weights[weight_category]

	if (mode.highlander_rulesets_favoured && (flags & HIGHLANDER_RULESET))
		result *= ADDITIONAL_RULESET_WEIGHT
	message_admins("[name] had [result] weight (-[initial(weight) - result]).")
	return result

/datum/dynamic_ruleset/proc/previous_rounds_odds_reduction(var/result)
	for (var/previous_round in mode.previously_executed_rules)
		for(var/previous_ruleset in mode.previously_executed_rules[previous_round])
			var/datum/dynamic_ruleset/DR = previous_ruleset
			if(initial(DR.role_category) == src.role_category)
				switch (previous_round)
					if ("one_round_ago")
						result *= 0.4
					if ("two_rounds_ago")
						result *= 0.7
					if ("three_rounds_ago")
						result *= 0.9
	return result

//Return a multiplicative weight. 1 for nothing special.
/datum/dynamic_ruleset/proc/weight_time_day()
	var/weigh = 1
	if(time2text(world.timeofday, "DDD") in weekday_rule_boost)
		weigh *= 2
		for(var/i = 1 to requirements.len)
			if ((i < requirements.len) && (requirements[i+1] == 90))//let's not actually reduce the requirement on low pop.
				continue
			requirements[i] = clamp(requirements[i] - 20,10,90)
		for(var/i = 1 to required_pop.len)
			required_pop[i] = clamp(required_pop[i] - 5,0,100)
	if(getTimeslot() in timeslot_rule_boost)
		weigh *= 2
	return weigh

/datum/dynamic_ruleset/proc/trim_candidates()
	return


/datum/dynamic_ruleset/proc/send_applications(var/list/possible_volunteers = list())
	if (possible_volunteers.len <= 0)//this shouldn't happen, as ready() should return 0 if there is not a single valid candidate
		message_admins("Possible volunteers was 0. This shouldn't appear, because of ready(), unless you forced it!")
		return
	message_admins("DYNAMIC MODE: Polling [possible_volunteers.len] players to apply for the [name] ruleset.")
	log_admin("DYNAMIC MODE: Polling [possible_volunteers.len] players to apply for the [name] ruleset.")

	searching = 1
	var/role_id = initial(role_category.id)
	var/icon/logo_icon = icon('icons/logos.dmi', logo)
	for(var/mob/M in possible_volunteers)
		var/banned_factor = (jobban_isbanned(M, role_id) || isantagbanned(M) || (role_category_override && jobban_isbanned(M, role_category_override)))
		if(!M.client || banned_factor || M.client.is_afk())
			continue

		to_chat(M, "[logo ? "[bicon(logo_icon)]" : ""]<span class='recruit'>The mode is looking for volunteers to become [initial(role_category.id)]. (<a href='?src=\ref[src];signup=\ref[M]'>Apply now!</a>)</span>[logo ? "[bicon(logo_icon)]" : ""]")
		window_flash(M.client)

	spawn(1 MINUTES)
		searching = 0
		for(var/mob/M in possible_volunteers)
			if(!M.client || jobban_isbanned(M, role_category) || M.client.is_afk())
				continue
			to_chat(M, "[logo ? "[bicon(logo_icon)]" : ""]<span class='recruit'>Applications for [initial(role_category.id)] are now closed.</span>[logo ? "[bicon(logo_icon)]" : ""]")
		if(!applicants || applicants.len <= 0)
			log_admin("DYNAMIC MODE: [name] received no applications.")
			message_admins("DYNAMIC MODE: [name] received no applications.")
			mode.refund_midround_threat(cost)
			mode.threat_log += "[worldtime2text()]: Rule [name] refunded [cost] (no applications)"
			mode.executed_rules -= src
			return

		log_admin("DYNAMIC MODE: [applicants.len] players volunteered for [name].")
		message_admins("DYNAMIC MODE: [applicants.len] players volunteered for [name].")
		review_applications()

/datum/dynamic_ruleset/proc/review_applications()

/datum/dynamic_ruleset/Topic(var/href, var/list/href_list)
	if(href_list["signup"])
		var/mob/M = usr
		if(!M)
			return
		volunteer(M)

/datum/dynamic_ruleset/proc/volunteer(var/mob/M)
	if (!searching)
		return
	if(jobban_isbanned(M, role_category) || isantagbanned(M))
		to_chat(M, "<span class='danger'>Banned from [initial(role_category.id)].</span>")
		to_chat(M, "<span class='warning'>Your application has been discarded due to past conduct..</span>")
		return
	if(M in applicants)
		to_chat(M, "<span class='notice'>Removed from the [initial(role_category.id)] registration list.</span>")
		applicants -= M
		return
	else
		to_chat(M, "<span class='notice'>Added to the [initial(role_category.id)] registration list.</span>")
		applicants |= M
		return

/datum/dynamic_ruleset/proc/progressive_job_search()
	for(var/job in job_priority)
		for(var/mob/M in candidates)
			if(M.mind.assigned_role == job)
				assigned += M
				candidates -= M
				return M
	var/mob/M = pick(candidates)
	assigned += M
	candidates -= M
	return M

////////////////////////////////////////////////////////////////////////

/datum/forced_ruleset
	var/name = ""
	var/ruleType
	var/calledBy


//////////////////////////////////////////////
//                                          //
//           ROUNDSTART RULESETS            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////Remember that roundstart objectives are automatically forged by /datum/gamemode/proc/PostSetup()

/datum/dynamic_ruleset/roundstart/trim_candidates()
	//-----------debug info---------------------------
	var/cand = candidates.len
	var/a = 0
	var/b = 0
	var/b1 = 0
	var/c = 0
	var/c1 = 0
	var/d = 0
	var/e = 0
	//------------------------------------------------
	var/role_id = initial(role_category.id)
	var/role_pref = initial(role_category.required_pref)
	for(var/mob/P in candidates)
		if (!P.client || !P.mind || !P.mind.assigned_role)//are they connected?
			candidates.Remove(P)
			a++
			continue
		if (!P.client.desires_role(role_pref))//are they willing?
			candidates.Remove(P)
			b++
			continue
		else if (jobban_isbanned(P, role_id) || isantagbanned(P) || (role_category_override && jobban_isbanned(P, role_category_override)))//are they not antag-banned?
			candidates.Remove(P)
			b1++//we only count banned ones if they actually wanted to play the role
			continue
		if ((restricted_from_jobs.len > 0) && (P.mind.assigned_role && (P.mind.assigned_role in restricted_from_jobs)) || (P.mind.role_alt_title && (P.mind.role_alt_title in restricted_from_jobs)))//does their job allow for it?
			candidates.Remove(P)
			d++
			continue
		if ((exclusive_to_jobs.len > 0) && P.mind.assigned_role && !(P.mind.assigned_role in exclusive_to_jobs))//is the rule exclusive to their job?
			candidates.Remove(P)
			e++
			continue
		if ((protected_from_jobs.len > 0) && (P.mind.assigned_role && (P.mind.assigned_role in protected_from_jobs)) || (P.mind.role_alt_title && (P.mind.role_alt_title in protected_from_jobs)))
			var/probability = initial(role_category.protected_traitor_prob)
			if (prob(probability))
				candidates.Remove(P)
				c1++
			c++
			continue
	message_admins("DYNAMIC MODE: [name] has [candidates.len] valid candidates out of [cand] players ([a ? "[a] disconnected, ":""][b ? "[b] didn't want the role, ":""][b1 ? "[b1] wanted the role but are banned from it, ":""][c1 ? "[c1] out of [c] were protected from the role, " : ""][d ? "[d] were restricted from the role, " : ""][e ? "[e] didn't pick the job necessary for the role" : ""])")
	log_admin("DYNAMIC MODE: [name] has [candidates.len] valid candidates out of [cand] players ([a ? "[a] disconnected, ":""][b ? "[b] didn't want the role, ":""][b1 ? "[b1] wanted the role but are banned from it, ":""][c1 ? "[c1] out of [c] were protected from the role, " : ""][d ? "[d] were restricted from the role, " : ""][e ? "[e] didn't pick the job necessary for the role" : ""])")

/datum/dynamic_ruleset/roundstart/delayed/trim_candidates()
	if (ticker && ticker.current_state <  GAME_STATE_PLAYING)
		return ..() // If the game didn't start, we'll use the parent's method to see if we have enough people desiring the role & what not.
	var/role_id = initial(role_category.id)
	for (var/mob/P in candidates)
		if (!istype(P, required_type))
			candidates.Remove(P) // Can be a new_player, etc.
			continue
		if (!P.client || !P.mind || !P.mind.assigned_role || P.mind.antag_roles.len)//are they connected? Are they an antag already?
			candidates.Remove(P)
			continue
		if (!P.client.desires_role(role_id) || jobban_isbanned(P, role_id) || isantagbanned(P) || (role_category_override && jobban_isbanned(P, role_category_override)))//are they willing and not antag-banned?
			candidates.Remove(P)
			continue
		if ((P.mind.assigned_role && (P.mind.assigned_role in protected_from_jobs)) || (P.mind.role_alt_title && (P.mind.role_alt_title in protected_from_jobs)))
			var/probability = initial(role_category.protected_traitor_prob)
			if (prob(probability))
				candidates.Remove(P)
			continue
		if ((P.mind.assigned_role && (P.mind.assigned_role in restricted_from_jobs)) || (P.mind.role_alt_title && (P.mind.role_alt_title in restricted_from_jobs)))//does their job allow for it?
			candidates.Remove(P)
			continue
		if ((exclusive_to_jobs.len > 0) && !(P.mind.assigned_role in exclusive_to_jobs))//is the rule exclusive to their job?
			candidates.Remove(P)
			continue

/datum/dynamic_ruleset/roundstart/ready(var/forced = 0)
	if (!forced)
		if(!check_enemy_jobs(FALSE))
			return 0
	return ..()

/datum/dynamic_ruleset/proc/latejoinprompt(var/mob/user)
	var/turf/oldloc = get_turf(user)
	user.forceMove(null)
	if(alert(user,"The gamemode is trying to select you for [src], do you want this?",,"Yes","No") == "Yes")
		return 1
	user.forceMove(oldloc)
	message_admins("[user.key] has opted out of [src].")
	return 0

/datum/dynamic_ruleset/proc/generate_ruleset_body(mob/applicant)
	var/mob/living/carbon/human/new_character = makeBody(applicant)
	new_character.dna.ResetSE()
	return new_character
