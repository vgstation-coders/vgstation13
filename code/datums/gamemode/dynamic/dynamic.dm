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
	roundstart()
	return (executed_rules.len > 0)

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

	var/datum/dynamic_ruleset/roundstart/chosen_rule = pickweight(drafted_rules)

	message_admins("[i] rulesets qualify for the current pop and threat level, including [drafted_rules.len] with elligible candidates.")
	message_admins("The first ruleset of the round is...[chosen_rule.name]")

	if (chosen_rule.persistent)
		current_rules += chosen_rule
	if (!chosen_rule.repeatable)
		roundstart_rules -= chosen_rule

	threat -= chosen_rule.cost
	if (chosen_rule.execute())
		executed_rules += chosen_rule
