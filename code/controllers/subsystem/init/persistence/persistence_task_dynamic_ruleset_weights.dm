
/datum/persistence_task/dynamic_ruleset_weights
	execute = TRUE
	name = "Dynamic ruleset weights"
	file_path = "data/persistence/dynamic_ruleset_weights.json"

/datum/persistence_task/dynamic_ruleset_weights/on_init()
	data = read_file()

/datum/persistence_task/dynamic_ruleset_weights/on_shutdown()
	var/datum/gamemode/dynamic/dynamic_mode = ticker.mode
	if (!istype(dynamic_mode))
		stack_trace("we shut down the persistence - Misc subsystem and ticker.mode is not Dynamic.")
		return

	data = list()

	for (var/category in dynamic_mode.ruleset_category_weights)
		data[category] = dynamic_mode.ruleset_category_weights[category]

	if (dynamic_mode.executed_rules.len <= 0)
		data["Extended"] = 0
	else
		for (var/datum/dynamic_ruleset/DR in dynamic_mode.executed_rules)
			data[DR.weight_category] = 0

	write_file(data)
