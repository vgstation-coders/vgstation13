
/datum/persistence_task/latest_dynamic_rulesets
	execute = TRUE
	name = "Latest dynamic rulesets"
	file_path = "data/persistence/latest_dynamic_rulesets.json"

/datum/persistence_task/latest_dynamic_rulesets/on_init()
	data = read_file()

/datum/persistence_task/latest_dynamic_rulesets/on_shutdown()
	var/datum/gamemode/dynamic/dynamic_mode = ticker.mode
	if (!istype(dynamic_mode))
		stack_trace("we shut down the persistence - Misc subsystem and ticker.mode is not Dynamic.")
		return
	data = list(
		"one_round_ago" = list(),
		"two_rounds_ago" = dynamic_mode.previously_executed_rules["one_round_ago"],
		"three_rounds_ago" = dynamic_mode.previously_executed_rules["two_rounds_ago"]
	)
	for(var/datum/dynamic_ruleset/some_ruleset in dynamic_mode.executed_rules)
		if(some_ruleset.calledBy)//forced by an admin
			continue
		if(some_ruleset.stillborn)//executed near the end of the round
			continue
		data["one_round_ago"] |= "[some_ruleset.type]"
	write_file(data)
