
// -- Vox raiders
/datum/persistence_task/vox_raiders
	execute = TRUE
	name = "Vox raiders best team"
	file_path = "data/persistence/vox_raiders_best_team.json"

/datum/persistence_task/vox_raiders/on_init()
	data = read_file()

/datum/persistence_task/vox_raiders/on_shutdown()
	var/datum/gamemode/dynamic/dynamic_mode = ticker.mode
	if (!istype(dynamic_mode))
		return // No dynamic mode = no raiders
	if (!locate(/datum/dynamic_ruleset/midround/from_ghosts/faction_based/heist) in dynamic_mode.executed_rules)
		return

	var/datum/faction/vox_shoal/raiders_of_the_day = find_active_faction_by_type(/datum/faction/vox_shoal)

	var/score = text2num(data["best_score"])

	if (score > raiders_of_the_day.total_points)
		return // They didn't beat the best

	else
		data["best_score"] = num2text(raiders_of_the_day.total_points)
		data["winning_team"] = raiders_of_the_day.generate_string()
		data["DD"] = time2text(world.realtime,"DD")
		data["MM"] = time2text(world.realtime,"MM")
		data["YY"] = time2text(world.realtime,"YY")
		write_file(data)
