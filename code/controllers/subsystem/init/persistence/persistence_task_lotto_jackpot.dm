
//Lotto

/datum/persistence_task/lotto_jackpot
	execute = TRUE
	name = "Lotto jackpot"
	file_path = "data/persistence/lotto_jackpot.json"

/datum/persistence_task/lotto_jackpot/on_init()
	data = read_file()
	if(length(data))
		station_jackpot = max(1000000,min(200000000, data["station_jackpot"])) //1 - 200 mil

/datum/persistence_task/lotto_jackpot/on_shutdown()
	write_file(list("station_jackpot" = max(1000000,station_jackpot)))
