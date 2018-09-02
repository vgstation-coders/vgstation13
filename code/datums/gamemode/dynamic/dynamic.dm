/datum/gamemode/dynamic
	name = "Dynamic Mode"
	var/threat_level = 0//rolled at the beginning of the round.
	var/threat = 0//set at the beginning of the round. Spent by the mode to "purchase" rules.
	var/list/roundstart_rules = list()
	var/list/second_rule_req = list(100,100,100,80,60,40,20,0,0,0)//requirements for extra round start rules
	var/list/third_rule_req = list(100,100,100,100,100,70,50,30,10,0)
	var/roundstart_pop_ready = 0
	var/list/candidates = list()
	var/list/current_rules = list()
	var/list/executed_rules = list()

/datum/gamemode/dynamic/can_start()
	threat_level = rand(1,100)*0.6 + rand(1,100)*0.4//https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=499381388
	threat = threat_level
	message_admins("Dynamic Mode initialized with a Threat Level of... <font size='8'>[threat_level]</font>!")
	return 1

/datum/gamemode/dynamic/Setup()
	for (var/rule in subtypesof(/datum/dynamic_ruleset/roundstart))
		roundstart_rules += new rule()
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
	roundstart()
	return 1

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
	var/datum/dynamic_ruleset/roundstart/extra_rule = pickweight(drafted_rules)

	if (extra_rule)
		message_admins("Picking a ruleset...<font size='3'>[extra_rule.name]</font>!")

		if (extra_rule.persistent)
			current_rules += extra_rule
		roundstart_rules -= extra_rule
		drafted_rules -= extra_rule

		threat -= extra_rule.cost
		if (extra_rule.execute())//this should never fail since ready() returned 1
			executed_rules += extra_rule
			for(var/mob/M in extra_rule.assigned)
				candidates -= M
				for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
					rule.candidates -= M//removing the assigned players from the candidates for the other rules
					if (!rule.ready())
						drafted_rules -= rule//and removing rules from those that are no longer elligible
			return 1
		else
			message_admins("....except not because whoever coded that ruleset forgot some cases in ready() apparently! execute() returned 0.")
	return 0
