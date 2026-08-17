
//Ape-related

/datum/persistence_task/ape_mode
	execute = TRUE
	name = "Ape mode"
	file_path = "data/persistence/ape_mode.json"

/datum/persistence_task/ape_mode/on_init()
	data = read_file()
	if(length(data))
		ape_mode = data["ape_mode"]

/datum/persistence_task/ape_mode/on_shutdown()
	write_file(list("ape_mode" = ape_mode))
