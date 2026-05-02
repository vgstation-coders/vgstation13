//Shoal Reserves
/datum/persistence_task/shoalreserve
	execute = TRUE
	name = "Shoal Reserve"
	file_path = "data/persistence/shoalreserve.json"

/datum/persistence_task/shoalreserve/on_init()
	shoal_reserves = read_file() || 0

/datum/persistence_task/shoalreserve/on_shutdown()
	write_file(trader_account.money)
