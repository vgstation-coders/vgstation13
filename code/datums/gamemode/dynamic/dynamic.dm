var/list/forced_roundstart_ruleset = list()

/datum/gamemode/dynamic
	name = "Dynamic Mode"
	var/threat_level = 0//rolled at the beginning of the round.
	var/threat = 0//set at the beginning of the round. Spent by the mode to "purchase" rules.
	var/list/roundstart_rules = list()
	var/list/latejoin_rules = list()
	var/list/midround_rules = list()
	var/list/second_rule_req = list(0,0,0,80,60,40,20,0,0,0)//requirements for extra round start rules
	//var/list/second_rule_req = list(100,100,100,80,60,40,20,0,0,0)//requirements for extra round start rules
	var/list/third_rule_req = list(100,100,100,100,100,70,50,30,10,0)
	var/roundstart_pop_ready = 0
	var/list/candidates = list()
	var/list/current_rules = list()
	var/list/executed_rules = list()

	var/list/living_players = list()
	var/list/living_antags = list()
	var/list/dead_players = list()
	var/list/list_observers = list()

	var/latejoin_injection_cooldown = 0
	var/midround_injection_cooldown = 0

	var/datum/dynamic_ruleset/latejoin/forced_latejoin_rule = null

/datum/gamemode/dynamic/can_start()
	threat_level = rand(1,100)*0.6 + rand(1,100)*0.4//https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=499381388
	threat = threat_level
	message_admins("Dynamic Mode initialized with a Threat Level of... <font size='8'>[threat_level]</font>!")
	return 1

/datum/gamemode/dynamic/Setup()
	for (var/rule in subtypesof(/datum/dynamic_ruleset/roundstart))
		roundstart_rules += new rule()
	for (var/rule in subtypesof(/datum/dynamic_ruleset/latejoin))
		latejoin_rules += new rule()
	for (var/rule in subtypesof(/datum/dynamic_ruleset/midround))
		midround_rules += new rule()
	for(var/mob/new_player/player in player_list)
		if(player.ready && player.mind)
			roundstart_pop_ready++
			candidates.Add(player)
	message_admins("Listing [roundstart_rules.len] round start rulesets, and [candidates.len] players ready.")
	if (candidates.len <= 0)
		message_admins("Not a single player readied-up. The round will begin without any roles assigned.")
		return 1
	if (roundstart_rules.len <= 0)
		message_admins("There are no roundstart rules within the code, what the fuck? The round will begin without any roles assigned.")
		return 1
	if (forced_roundstart_ruleset.len > 0)
		rigged_roundstart()
	else
		roundstart()
	return 1

/datum/gamemode/dynamic/proc/rigged_roundstart()
	message_admins("[forced_roundstart_ruleset.len] rulesets being forced. Will now attempt to draft players for them.")
	for (var/datum/dynamic_ruleset/roundstart/rule in forced_roundstart_ruleset)
		rule.mode = src
		rule.candidates = candidates.Copy()
		rule.trim_candidates()
		if (rule.ready())
			picking_roundstart_rule(list(rule))

/datum/gamemode/dynamic/proc/roundstart()
	var/list/drafted_rules = list()
	var/i = 0
	for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
		if (rule.acceptable(roundstart_pop_ready,threat_level) && threat >= rule.cost)	//if we got the population and threat required
			i++																			//we check whether we've got elligible players
			rule.candidates = candidates.Copy()
			rule.trim_candidates()
			if (rule.ready())
				drafted_rules[rule] = rule.weight

	var/indice_pop = min(10,round(roundstart_pop_ready/5)+1)
	message_admins("[i] rulesets qualify for the current pop and threat level, including [drafted_rules.len] with elligible candidates.")
	if (drafted_rules.len > 0 && picking_roundstart_rule(drafted_rules))
		if (threat >= second_rule_req[indice_pop])//we've got enough population and threat for a second rulestart rule
			message_admins("The current pop and threat level allow for a second round start ruleset, there remains [candidates.len] elligible candidates and [drafted_rules.len] elligible rulesets")
			if (drafted_rules.len > 0 && picking_roundstart_rule(drafted_rules))
				if (threat >= third_rule_req[indice_pop])//we've got enough population and threat for a third rulestart rule
					message_admins("The current pop and threat level allow for a third round start ruleset, there remains [candidates.len] elligible candidates and [drafted_rules.len] elligible rulesets")
					if (!drafted_rules.len > 0 || !picking_roundstart_rule(drafted_rules))
						message_admins("The mode failed to pick a third ruleset.")
			else
				message_admins("The mode failed to pick a second ruleset.")
	else
		message_admins("The mode failed to pick a first ruleset. The round will begin without any roles assigned.")
		return 0
	return 1

/datum/gamemode/dynamic/proc/picking_roundstart_rule(var/list/drafted_rules = list())
	var/datum/dynamic_ruleset/roundstart/starting_rule = pickweight(drafted_rules)

	if (starting_rule)
		message_admins("Picking a ruleset...<font size='3'>[starting_rule.name]</font>!")
		log_admin("Picking a ruleset...[starting_rule.name]!")

		roundstart_rules -= starting_rule
		drafted_rules -= starting_rule

		threat = max(0,threat-starting_rule.cost)
		if (starting_rule.execute())//this should never fail since ready() returned 1
			executed_rules += starting_rule
			if (starting_rule.persistent)
				current_rules += starting_rule
			for(var/mob/M in starting_rule.assigned)
				candidates -= M
				for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
					rule.candidates -= M//removing the assigned players from the candidates for the other rules
					if (!rule.ready())
						drafted_rules -= rule//and removing rules from those that are no longer elligible
			return 1
		else
			message_admins("....except not because whoever coded that ruleset forgot some cases in ready() apparently! execute() returned 0.")
	return 0

/datum/gamemode/dynamic/proc/picking_latejoin_rule(var/list/drafted_rules = list())
	var/datum/dynamic_ruleset/latejoin/latejoin_rule = pickweight(drafted_rules)
	if (latejoin_rule)
		if (!latejoin_rule.repeatable)
			latejoin_rules -= latejoin_rule
		threat = max(0,threat-latejoin_rule.cost)
		if (latejoin_rule.execute())//this should never fail since ready() returned 1
			var/mob/M = pick(latejoin_rule.assigned)
			message_admins("[key_name(M)] joined the station, and was selected by the <font size='3'>[latejoin_rule.name]</font> ruleset.")
			log_admin("[key_name(M)] joined the station, and was selected by the [latejoin_rule.name] ruleset.")
			executed_rules += latejoin_rule
			if (latejoin_rule.persistent)
				current_rules += latejoin_rule
			return 1
	return 0

/datum/gamemode/dynamic/proc/picking_midround_rule(var/list/drafted_rules = list())
	var/datum/dynamic_ruleset/midround/midround_rule = pickweight(drafted_rules)
	if (midround_rule)
		if (!midround_rule.repeatable)
			midround_rules -= midround_rule
		threat = max(0,threat-midround_rule.cost)
		if (midround_rule.execute())//this should never fail since ready() returned 1
			message_admins("Injecting some threats...<font size='3'>[midround_rule.name]</font>!")
			log_admin("Injecting some threats...[midround_rule.name]!")
			executed_rules += midround_rule
			if (midround_rule.persistent)
				current_rules += midround_rule
			return 1
	return 0

/datum/gamemode/dynamic/proc/picking_specific_rule(var/ruletype,var/forced=0)//an experimental proc to allow admins to call rules on the fly or have rules call other rules
	var/datum/dynamic_ruleset/midround/new_rule = new ruletype()//you should only use it to call midround rules though.
	update_playercounts()
	var/list/current_players = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
	current_players[CURRENT_LIVING_PLAYERS] = living_players.Copy()
	current_players[CURRENT_LIVING_ANTAGS] = living_antags.Copy()
	current_players[CURRENT_DEAD_PLAYERS] = dead_players.Copy()
	current_players[CURRENT_OBSERVERS] = list_observers.Copy()
	if (new_rule && (forced || (new_rule.acceptable(living_players.len,threat_level) && new_rule.cost <= threat)))
		new_rule.candidates = current_players.Copy()
		new_rule.trim_candidates()
		if (new_rule.ready())
			threat -= new_rule.cost
			if (new_rule.execute())//this should never fail since ready() returned 1
				message_admins("Making a call to a specific ruleset...<font size='3'>[new_rule.name]</font>!")
				log_admin("Making a call to a specific ruleset...[new_rule.name]!")
				executed_rules += new_rule
				if (new_rule.persistent)
					current_rules += new_rule
				return 1
	return 0

/datum/gamemode/dynamic/process()
	if (latejoin_injection_cooldown)
		latejoin_injection_cooldown--

	for (var/datum/dynamic_ruleset/rule in current_rules)
		rule.process()

	if (midround_injection_cooldown)
		midround_injection_cooldown--
	else
		//time to inject some threat into the round
		if(emergency_shuttle.departed)//unless the shuttle is gone
			return

		update_playercounts()

		if (injection_attempt())
			midround_injection_cooldown = rand(12000,21000)//20 to 35 minutes inbetween midround threat injections attempts
			var/list/drafted_rules = list()
			var/list/current_players = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
			current_players[CURRENT_LIVING_PLAYERS] = living_players.Copy()
			current_players[CURRENT_LIVING_ANTAGS] = living_antags.Copy()
			current_players[CURRENT_DEAD_PLAYERS] = dead_players.Copy()
			current_players[CURRENT_OBSERVERS] = list_observers.Copy()
			for (var/datum/dynamic_ruleset/latejoin/rule in midround_rules)
				if (rule.acceptable(living_players.len,threat_level) && threat >= rule.cost)
					rule.candidates = current_players.Copy()
					rule.trim_candidates()
					if (rule.ready())
						drafted_rules[rule] = rule.weight

			if (drafted_rules.len > 0)
				picking_latejoin_rule(drafted_rules)


/datum/gamemode/dynamic/proc/update_playercounts()
	living_players = list()
	living_antags = list()
	dead_players = list()
	list_observers = list()
	for (var/mob/M in player_list)
		if (!M.client)
			continue
		if (istype(M,/mob/new_player))
			continue
		if (M.stat != DEAD)
			living_players.Add(M)
			if (M.mind && (M.mind.antag_roles.len > 0))
				living_antags.Add(M)
		else
			if (istype(M,/mob/dead/observer))
				var/mob/dead/observer/O = M
				if (O.started_as_observer)//Observers
					list_observers.Add(M)
					continue
				if (O.mind && O.mind.current && O.mind.current.ajourn)//Cultists
					living_players.Add(M)//yes we're adding a ghost to "living_players", so make sure to properly check for type when testing midround rules
					continue
			dead_players.Add(M)//Players who actually died (and admins who ghosted, would be nice to avoid counting them somehow)

/datum/gamemode/dynamic/proc/injection_attempt()//will need to gather stats to refine those values later
	if (latejoin_injection_cooldown)
		return
	var/chance = 0
	var/max_pop_per_antag = max(5,15 - round(threat_level/10) - round(living_players.len/5))//https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=2053826290
	if (!living_antags.len)
		chance += 50//no antags at all? let's boost those odds!
	else
		var/current_pop_per_antag = living_players.len / living_antags.len
		if (current_pop_per_antag > max_pop_per_antag)
			chance += min(50, 25+10*(current_pop_per_antag-max_pop_per_antag))
		else
			chance += 25-10*(max_pop_per_antag-current_pop_per_antag)
	if (dead_players.len > living_players.len)
		chance -= 30//more than half the crew died? ew, let's calm down on antags
	if (threat > 70)
		chance += 20
	if (threat < 30)
		chance -= 20
	chance = round(max(0,chance))
	return (prob(chance))

/datum/gamemode/dynamic/latespawn(var/mob/living/newPlayer)
	if(emergency_shuttle.departed)//no more rules after the shuttle has left
		return

	update_playercounts()

	if (forced_latejoin_rule)
		forced_latejoin_rule.candidates = list(newPlayer)
		forced_latejoin_rule.trim_candidates()
		if (forced_latejoin_rule.ready())
			picking_latejoin_rule(list(forced_latejoin_rule))
		forced_latejoin_rule = null

	else if (injection_attempt())
		var/list/drafted_rules = list()
		for (var/datum/dynamic_ruleset/latejoin/rule in latejoin_rules)
			if (rule.acceptable(living_players.len,threat_level) && threat >= rule.cost)
				rule.candidates = list(newPlayer)
				rule.trim_candidates()
				if (rule.ready())
					drafted_rules[rule] = rule.weight

		if (drafted_rules.len > 0 && picking_latejoin_rule(drafted_rules))
			latejoin_injection_cooldown = rand(6600,10200)//11 to 17 minutes inbetween antag latejoiner rolls
