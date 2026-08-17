
// Hub Settings

/datum/persistence_task/hub_settings
	execute = TRUE
	name = "Hub Settings"
	file_path = "data/persistence/hub_settings.json"

/datum/persistence_task/hub_settings/on_init()
	data = read_file()
	if(length(data))
		byond_server_name = data["server_name"]
		byond_server_desc = data["server_desc"]
		byond_hub_playercount = data["hub_playercount"]
		byond_hub_open = data["byond_hub_open"]

/datum/persistence_task/hub_settings/on_shutdown()
	var/list/L = list(
		"server_name" = byond_server_name,
		"server_desc" = byond_server_desc,
		"hub_playercount" = byond_hub_playercount,
		"byond_hub_open" = byond_hub_open,
	)
	data = L
	write_file(data)
