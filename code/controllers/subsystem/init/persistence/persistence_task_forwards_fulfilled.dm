
/datum/persistence_task/forwards_fulfilled
	execute = TRUE
	name = "Cargo forwards fulfilled"
	file_path = "data/persistence/fulfilled_cargo_forwards.json"

/datum/persistence_task/forwards_fulfilled/on_init()
	data = read_file()
	if ("fulfilled_forwards" in data)
		var/list/previous_forwards_formatted = data["fulfilled_forwards"]
		for(var/list/formatted_vars in previous_forwards_formatted)
			var/ourtype = null
			if(formatted_vars["type"])
				ourtype = text2path(formatted_vars["type"])
			var/ourname = null
			if(formatted_vars["sender"])
				ourname = formatted_vars["sender"]
			var/ourstation = null
			if(formatted_vars["station"])
				ourstation = formatted_vars["station"]
			var/oursubtype = null
			if(formatted_vars["subtype"])
				oursubtype = text2path(formatted_vars["subtype"])
			if(ispath(ourtype,/datum/cargo_forwarding))
				SSsupply_shuttle.previous_forwards += new ourtype(ourname, ourstation, oursubtype, TRUE)

/datum/persistence_task/forwards_fulfilled/on_shutdown()
	var/list/all_forwards = SSsupply_shuttle.previous_forwards.Copy() + SSsupply_shuttle.fulfilled_forwards.Copy()
	var/list/all_forwards_formatted = list()
	for(var/datum/cargo_forwarding/forward in all_forwards)
		all_forwards_formatted += list(list("type" = forward.type, "sender" = forward.origin_sender_name, "station" = forward.origin_station_name, "subtype" = forward.initialised_type))
	write_file(list("fulfilled_forwards" = all_forwards_formatted))
