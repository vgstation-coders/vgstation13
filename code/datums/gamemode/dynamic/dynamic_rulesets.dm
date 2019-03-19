/datum/dynamic_ruleset
	var/name = ""//For admin logging, and round end scoreboard
	var/persistent = 0//if set to 1, the rule won't be discarded after being executed, and /gamemode/dynamic will call process() every MC tick
	var/repeatable = 0//if set to 1, dynamic mode will be able to draft this ruleset again later on. (doesn't apply for roundstart rules)
	var/list/candidates = list()//list of players that are being drafted for this rule
	var/list/assigned = list()//list of players that were selected for this rule
	var/datum/role/role_category = /datum/role/traitor //rule will only accept candidates with "Yes" or "Always" in the preferences for this role
	var/list/protected_from_jobs = list() // if set, and config.protect_roles_from_antagonist = 0, then the rule will have a much lower chance than usual to pick those roles.
	var/list/restricted_from_jobs = list()//if set, rule will deny candidates from those jobs
	var/list/exclusive_to_jobs = list()//if set, rule will only accept candidates from those jobs
	var/list/job_priority = list() //May be used by progressive_job_search for prioritizing some jobs for a role. Order matters.
	var/list/enemy_jobs = list()//if set, there needs to be a certain amount of players doing those jobs (among the players who won't be drafted) for the rule to be drafted
	var/required_enemies = list(1,1,0,0,0,0,0,0,0,0)//if enemy_jobs was set, this is the amount of enemy job workers needed per threat_level range (0-10,10-20,etc)
	var/required_candidates = 0//the rule needs this many candidates (post-trimming) to be executed (example: Cult need 4 players at round start)
	var/weight = 5//1 -> 9, probability for this rule to be picked against other rules
	var/cost = 0//threat cost for this rule.
	var/logo = ""//any state from /icons/logos.dmi

	//for midround polling
	var/list/applicants = list()
	var/searching = 0

	var/list/requirements = list(40,30,20,10,10,10,10,10,10,10)
	//requirements are the threat level requirements per pop range. The ranges are as follow:
	//0-4, 5-9, 10-14, 15-19, 20-24, 25-29, 30-34, 35-39, 40-54, 45+
	//so with the above default values, The rule will never get drafted below 10 threat level (aka: "peaceful extended"), and it requires a higher threat level at lower pops.
	//for reminder: the threat level is rolled at roundstart and tends to hover around 50 https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=499381388

	var/datum/gamemode/dynamic/mode = null

	var/role_category_override = null // If a role is to be considered another for the purpose of bannig.

/datum/dynamic_ruleset/New()
	..()
	if (config.protect_roles_from_antagonist)
		restricted_from_jobs += protected_from_jobs
	if (istype(ticker.mode, /datum/gamemode/dynamic))
		mode = ticker.mode
	else
		//message_admins("A dynamic ruleset was created but server isn't on Dynamic Mode!")
		qdel(src)

/datum/dynamic_ruleset/roundstart//One or more of those drafted at roundstart

/datum/dynamic_ruleset/roundstart/delayed/ // Executed with a 30 seconds delay
	var/delay = 30 SECONDS
	var/required_type = /mob/living/carbon/human // No ghosts, new players or silicons allowed.

/datum/dynamic_ruleset/latejoin//Can be drafted when a player joins the server


/datum/dynamic_ruleset/proc/acceptable(var/population=0,var/threat=0)
	//by default, a rule is acceptable if it satisfies the threat level/population requirements.
	//If your rule has extra checks, such as counting security officers, do that in ready() instead
	var/indice_pop = min(10,round(population/5)+1)
	return (threat >= requirements[indice_pop])

/datum/dynamic_ruleset/proc/process()
	//write here your rule execution code, everything about faction/role spawning/populating.
	return

/datum/dynamic_ruleset/proc/execute()
	//write here your rule execution code, everything about faction/role spawning/populating.
	return 1

/datum/dynamic_ruleset/proc/ready(var/forced = 0)	//Here you can perform any additional checks you want. (such as checking the map, the amount of certain jobs, etc)
	if (required_candidates > candidates.len)		//IMPORTANT: If ready() returns 1, that means execute() should never fail!
		return 0
	if (!map.map_ruleset(src))
		return 0
	return 1

/datum/dynamic_ruleset/proc/get_weight()
	if(repeatable && weight > 1)
		for(var/datum/dynamic_ruleset/DR in mode.executed_rules)
			if(istype(DR,src.type))
				weight = max(weight-2,1)
	message_admins("[name] had [weight] weight (-[initial(weight) - weight]).")
	return weight

/datum/dynamic_ruleset/proc/trim_candidates()
	return


/datum/dynamic_ruleset/proc/send_applications(var/list/possible_volunteers = list())
	if (possible_volunteers.len <= 0)//this shouldn't happen, as ready() should return 0 if there is not a single valid candidate
		message_admins("Possible volunteers was 0. This shouldn't appear, because of ready(), unless you forced it!")
		return
	message_admins("DYNAMIC MODE: Polling [possible_volunteers.len] players to apply for the [name] ruleset.")
	log_admin("DYNAMIC MODE: Polling [possible_volunteers.len] players to apply for the [name] ruleset.")

	searching = 1
	var/icon/logo_icon = icon('icons/logos.dmi', logo)
	for(var/mob/M in possible_volunteers)
		var/banned_factor = (jobban_isbanned(M, role_category) || isantagbanned(M) || (role_category_override && jobban_isbanned(M, role_category_override)))
		if(!M.client || banned_factor || M.client.is_afk())
			continue

		to_chat(M, "[logo ? "[bicon(logo_icon)]" : ""]<span class='recruit'>The mode is looking for volunteers to become [initial(role_category.id)]. (<a href='?src=\ref[src];signup=\ref[M]'>Apply now!</a>)</span>[logo ? "[bicon(logo_icon)]" : ""]")

	spawn(1 MINUTES)
		searching = 0
		for(var/mob/M in possible_volunteers)
			if(!M.client || jobban_isbanned(M, role_category) || M.client.is_afk())
				continue
			to_chat(M, "[logo ? "[bicon(logo_icon)]" : ""]<span class='recruit'>Applications for [initial(role_category.id)] are now closed.</span>[logo ? "[bicon(logo_icon)]" : ""]")
		if(!applicants || applicants.len <= 0)
			log_admin("DYNAMIC MODE: [name] received no applications.")
			message_admins("DYNAMIC MODE: [name] received no applications.")
			mode.refund_threat(cost)
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

//////////////////////////////////////////////
//                                          //
//           ROUNDSTART RULESETS            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////Remember that roundstart objectives are automatically forged by /datum/gamemode/proc/PostSetup()

/datum/dynamic_ruleset/roundstart/trim_candidates()
	var/role_id = initial(role_category.id)
	var/role_pref = initial(role_category.required_pref)
	for(var/mob/new_player/P in candidates)
		if (!P.client || !P.mind || !P.mind.assigned_role)//are they connected?
			candidates.Remove(P)
			continue
		if (!P.client.desires_role(role_pref) || jobban_isbanned(P, role_id) || isantagbanned(P) || (role_category_override && jobban_isbanned(P, role_category_override)))//are they willing and not antag-banned?
			candidates.Remove(P)
			continue
		if (P.mind.assigned_role in protected_from_jobs)
			var/probability = initial(role_category.protected_traitor_prob)
			if (prob(probability))
				candidates.Remove(P)
			continue
		if (P.mind.assigned_role in restricted_from_jobs)//does their job allow for it?
			candidates.Remove(P)
			continue
		if ((exclusive_to_jobs.len > 0) && !(P.mind.assigned_role in exclusive_to_jobs))//is the rule exclusive to their job?
			candidates.Remove(P)
			continue

/datum/dynamic_ruleset/roundstart/delayed/trim_candidates()
	if (ticker && ticker.current_state <  GAME_STATE_PLAYING)
		return ..() // If the game didn't start, we'll use the parent's method to see if we have enough people desiring the role & what not.
	var/role_id = initial(role_category.id) 
	for (var/mob/P in candidates)
		if (!istype(P, required_type))
			candidates.Remove(P) // Can be a new_player, etc.
			continue
		if (!P.client || !P.mind || !P.mind.assigned_role)//are they connected?
			candidates.Remove(P)
			continue
		if (!P.client.desires_role(role_id) || jobban_isbanned(P, role_id) || isantagbanned(P) || (role_category_override && jobban_isbanned(P, role_category_override)))//are they willing and not antag-banned?
			candidates.Remove(P)
			continue
		if (P.mind.assigned_role in protected_from_jobs)
			var/probability = initial(role_category.protected_traitor_prob)
			if (prob(probability))
				candidates.Remove(P)
			continue
		if (P.mind.assigned_role in restricted_from_jobs)//does their job allow for it?
			candidates.Remove(P)
			continue
		if ((exclusive_to_jobs.len > 0) && !(P.mind.assigned_role in exclusive_to_jobs))//is the rule exclusive to their job?
			candidates.Remove(P)
			continue

/datum/dynamic_ruleset/roundstart/ready(var/forced = 0)
	if (!forced)
		var/job_check = 0
		if (enemy_jobs.len > 0)
			for (var/mob/M in mode.candidates)
				if (M.mind && M.mind.assigned_role && (M.mind.assigned_role in enemy_jobs) && (!(M in candidates) || (M.mind.assigned_role in restricted_from_jobs)))
					job_check++//checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it

		var/threat = round(mode.threat_level/10)
		if (job_check < required_enemies[threat])
			return 0
	return ..()
