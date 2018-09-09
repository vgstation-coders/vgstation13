

/datum/dynamic_ruleset
	var/name = ""//For admin logging, and round end scoreboard
	var/persistent = 0//if set to 1, the rule won't be discarded after being executed, and /gamemode/dynamic will call process() every MC tick
	var/repeatable = 0//if set to 1, dynamic mode will be able to draft this ruleset again later on. (doesn't apply for roundstart rules)
	var/list/candidates = list()//list of players that are being drafted for this rule
	var/list/assigned = list()//list of players that were selected for this rule
	var/role_category = ROLE_TRAITOR//rule will only accept candidates with "Yes" or "Always" in the preferences for this role
	var/list/restricted_from_jobs = list()//if set, rule will deny candidates from those jobs
	var/list/exclusive_to_jobs = list()//if set, rule will only accept candidates from those jobs
	var/list/jobs_must_exist = list()//if set, there needs to be a certain amount of players doing those jobs (among the players who won't be drafted) for the rule to be drafted
	var/required_candidates = 0//the rule needs this many candidates (post-trimming) to be executed (example: Cult need 4 players at round start)
	var/weight = 5//1 -> 9, probability for this rule to be picked against other rules
	var/cost = 0//threat cost for this rule.

	var/list/requirements = list(40,30,20,10,10,10,10,10,10,10)
	//requirements are the threat level requirements per pop range. The ranges are as follow:
	//0-4, 5-9, 10-14, 15-19, 20-24, 25-29, 30-34, 35-39, 40-54, 45+
	//so with the above default values, The rule will never get drafted below 10 threat level (aka: "peaceful extended"), and it requires a higher threat level at lower pops.
	//for reminder: the threat level is rolled at roundstart and tends to hover around 50 https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=499381388

	var/datum/gamemode/dynamic/mode = null

/datum/dynamic_ruleset/New()
	..()
	if (istype(ticker.mode, /datum/gamemode/dynamic))
		mode = ticker.mode
	else
		message_admins("A dynamic ruleset was created but server isn't on Dynamic Mode!")
		qdel(src)

/datum/dynamic_ruleset/roundstart//One or more of those drafted at roundstart

/datum/dynamic_ruleset/latejoin//Can be drafted when a player joins the server

/datum/dynamic_ruleset/midround//Can be drafted once in a while during a round
	var/list/living_players = list()
	var/list/living_antags = list()
	var/list/dead_players = list()
	var/list/list_observers = list()

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

/datum/dynamic_ruleset/proc/ready()	//Here you can perform any additional checks you want. (such as checking the map, the amount of certain jobs, etc)
	if (required_candidates > candidates.len)	//IMPORTANT: If ready() returns 1, that means execute() should never fail!
		return 0
	return 1

/datum/dynamic_ruleset/proc/trim_candidates()
	return

//////////////////////////////////////////////
//                                          //
//           ROUNDSTART RULESETS            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/trim_candidates()
	for(var/mob/new_player/P in candidates)
		if (!P.client || !P.mind || !P.mind.assigned_role)//are they connected?
			candidates.Remove(P)
			continue
		if (!P.client.desires_role(role_category) || jobban_isbanned(P, role_category))//are they willing and not antag-banned?
			candidates.Remove(P)
			continue
		if (P.mind.assigned_role in restricted_from_jobs)//does their job allow for it?
			candidates.Remove(P)
			continue
		if ((exclusive_to_jobs.len > 0) && !(P.mind.assigned_role in exclusive_to_jobs))//is the rule exclusive to their job?
			candidates.Remove(P)
			continue

//////////////////////////////////////////////
//                                          //
//            LATEJOIN RULESETS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/trim_candidates()
	for(var/mob/new_player/P in candidates)
		if (!P.client || !P.mind || !P.mind.assigned_role)//are they connected?
			candidates.Remove(P)
			continue
		if (!P.client.desires_role(role_category) || jobban_isbanned(P, role_category))//are they willing and not antag-banned?
			candidates.Remove(P)
			continue
		if (P.mind.assigned_role in restricted_from_jobs)//does their job allow for it?
			candidates.Remove(P)
			continue
		if ((exclusive_to_jobs.len > 0) && !(P.mind.assigned_role in exclusive_to_jobs))//is the rule exclusive to their job?
			candidates.Remove(P)
			continue

//////////////////////////////////////////////
//                                          //
//            MIDROUND RULESETS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////


/datum/dynamic_ruleset/midround/trim_candidates()
	//unlike the previous two types, these rulesets are not meant for /mob/new_player
	//and since I want those rulesets to be as flexible as possible, I'm not gonna put much here,
	//but be sure to check dynamic_rulesets_debug.dm for an example.
	//
	//all you need to know is that here, the candidates list contains 4 lists itself, indexed with the following defines:
	//candidates = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
	//so for example you can get the list of all current dead players with var/list/dead_players = candidates[CURRENT_DEAD_PLAYERS]
	//make sure to properly typecheck the mobs in those lists, as the dead_players list could contain ghosts, or dead players still in their bodies.
	//we're still gonna trim the obvious (mobs without clients, jobbanned players, etc)
	living_players = trim_list(candidates[CURRENT_LIVING_PLAYERS])
	living_antags = trim_list(candidates[CURRENT_LIVING_ANTAGS])
	dead_players = trim_list(candidates[CURRENT_DEAD_PLAYERS])
	observers = trim_list(candidates[CURRENT_OBSERVERS])

/datum/dynamic_ruleset/midround/proc/trim_list(var/list/L = list())
	var/list/trimmed_list = L.Copy()
	for(var/mob/M in trimmed_list)
		if (!M.client)//are they connected?
			trimmed_list.Remove(M)
			continue
		if (!M.client.desires_role(role_category) || jobban_isbanned(M, role_category))//are they willing and not antag-banned?
			trimmed_list.Remove(M)
			continue
		if (M.mind.assigned_role in restricted_from_jobs)//does their job allow for it?
			trimmed_list.Remove(M)
			continue
		if ((exclusive_to_jobs.len > 0) && !(M.mind.assigned_role in exclusive_to_jobs))//is the rule exclusive to their job?
			trimmed_list.Remove(M)
			continue
	return trimmed_list

//You can then for example prompt dead players in execute() to join as strike teams or whatever
//Or autotator someone
