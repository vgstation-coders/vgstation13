
/datum/persistence_task/round_end_data
	execute = TRUE
	name = "Round end information"
	file_path = "data/persistence/round_end_info.json"

/datum/persistence_task/round_end_data/on_init()
	var/to_read = read_file()
	if(!to_read)
		log_debug("[name] task found an empty file on [file_path]")
		return
	last_round_end_info = to_read["round_info"]
	for (var/client/C in clients)
		winset(C, "rpane.round_end", "is-visible=false")
		winset(C, "rpane.last_round_end", "is-visible=true")

/datum/persistence_task/round_end_data/on_shutdown()
	if (round_end_info)
		data["round_info"] = round_end_info
	write_file(data)
