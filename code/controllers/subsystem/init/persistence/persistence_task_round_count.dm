
// -- Round count
/datum/persistence_task/round_count
	execute = TRUE
	name = "Round count"
	file_path = "data/persistence/round_counts_per_year.json"

// We just get the data from the file.
/datum/persistence_task/round_count/on_init()
	data = read_file()

// We bump the round round and write it to file.
/datum/persistence_task/round_count/on_shutdown()
	var/itsthecurrentyear = time2text(world.realtime,"YY")
	if(!(itsthecurrentyear in data))
		data[itsthecurrentyear] = "0"
	data[itsthecurrentyear] = num2text(text2num(data[itsthecurrentyear]) + 1)
	write_file(data)
