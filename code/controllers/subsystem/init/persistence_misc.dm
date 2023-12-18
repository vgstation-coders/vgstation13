var/datum/subsystem/persistence_misc/SSpersistence_misc

/datum/subsystem/persistence_misc
	name       = "Persistence - Misc"
	init_order = SS_INIT_PERSISTENCE_MISC
	flags      = SS_NO_FIRE

	var/list/tasks = list()

/datum/subsystem/persistence_misc/New()
	NEW_SS_GLOBAL(SSpersistence_misc)

/datum/subsystem/persistence_misc/Recover()
	tasks = SSpersistence_misc.tasks
	..()

/datum/subsystem/persistence_misc/Initialize(timeofday)
	for (var/task_type in subtypesof(/datum/persistence_task))
		var/datum/persistence_task/task = task_type
		if (!initial(task.execute)) // Deprecated or wip persistence task
			continue
		task = new task_type()
		task.on_init()
		tasks["[task.type]"] = task
	..()

/datum/subsystem/persistence_misc/Shutdown()
	for (var/task_type in tasks)
		var/datum/persistence_task/task = tasks[task_type]
		task.on_shutdown()
	..()

/datum/subsystem/persistence_misc/proc/read_data(var/path)
	var/datum/persistence_task/task_to_read = tasks["[path]"]
	if (!task_to_read)
		return null
	return task_to_read.data

// *** PERISTENCE TASKS ***

// -- Abstract

/datum/persistence_task/
	var/execute = FALSE // -- Do we execute this task or not ?
	var/name = "Abstract persistence task"

	var/file_path = "" // -- Where do we read/write our peristance data ?
	var/list/data = list() // -- The data we save to file.

// -- Proc to be called when the game starts.
/datum/persistence_task/proc/on_init()

// -- Proc to be called when the game shutdowns.
/datum/persistence_task/proc/on_shutdown()

// -- FILE WRITING/DELETION HELPERS --

/* Get the data in the persistance file. */
/datum/persistence_task/proc/read_file()
	if(fexists(file_path))
		return json_decode(file2text(file_path))

/* Write some data into our file. */
/datum/persistence_task/proc/write_file(var/to_write)
	var/writing = file(file_path)
	fdel(writing)
	writing << json_encode(to_write)

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

// This task has a unit test on code/modules/unit_tests/highscores.dm
/datum/persistence_task/highscores
	execute = TRUE
	name = "Money highscores"
	file_path = "data/persistence/money_highscores.json"

/datum/persistence_task/highscores/on_init()
	var/to_read = read_file()
	if(!to_read)
		log_debug("[name] task found an empty file on [file_path]")
		return
	for(var/list/L in to_read)
		var/datum/record/money/record = new(L["ckey"], L["role"], L["cash"], L["shift_duration"], L["date"])
		data += record

/datum/persistence_task/highscores/on_shutdown()
	var/list/L = list()
	for(var/datum/record/money/record in data)
		L += list(record.vars)
	write_file(L)

/datum/persistence_task/highscores/proc/insert_records(list/records)
	data += records
	cmp_field = "cash"
	sortTim(data, /proc/cmp_list_by_element_desc)
	if (data.len > 5)
		data.Cut(6) // we only store the top 5
	for(var/datum/record/money/record in data)
		if(record in records)
			if(data[1] == record)
				announce_new_highest_record(record)
			else
				announce_new_record(record)

/datum/persistence_task/highscores/proc/announce_new_highest_record(var/datum/record/money/record)
	var/name = "Richest escape ever"
	var/desc = "You broke the record of the richest escape! $[record.cash] chips accumulated."
	give_award(record.ckey, /obj/item/weapon/reagent_containers/food/drinks/golden_cup, name, desc)

/datum/persistence_task/highscores/proc/announce_new_record(var/datum/record/money/record)
	var/name = "Good rich escape"
	var/desc = "You made it to the top 5! You accumulated $[record.cash]."
	give_award(record.ckey, /obj/item/clothing/accessory/medal/gold, name, desc, FALSE)

/datum/persistence_task/highscores/proc/clear_records()
	data = list()
	fdel(file(file_path))

/datum/persistence_task/highscores/trader
	execute = TRUE
	name = "Trader shoal highscores"
	file_path = "data/persistence/trader_highscores.json"

/datum/persistence_task/highscores/trader/announce_new_highest_record(var/datum/record/money/record)
	var/name = "Richest shoal haul ever"
	var/desc = "You broke the record of the richest shoal haul! $[record.cash] chips accumulated."
	give_award(record.ckey, /obj/item/weapon/reagent_containers/food/drinks/golden_cup, name, desc)

/datum/persistence_task/highscores/trader/announce_new_record(var/datum/record/money/record)
	var/name = "Good rich shoal haul"
	var/desc = "You made it to the top 5! You accumulated $[record.cash]."
	give_award(record.ckey, /obj/item/clothing/accessory/medal/gold, name, desc, FALSE)

//stores map votes for code/modules/html_interface/voting/voting.dm
/datum/persistence_task/vote
	execute = TRUE
	name = "Persistent votes"
	file_path = "data/persistence/votes.json"

/datum/persistence_task/vote/on_init()
	var/list/to_read = read_file()
	if(!to_read)
		log_debug("[name] task found an empty file on [file_path]")
		return
	for(var/i = 1; i <= to_read.len; i++)
		data[to_read[i]] = to_read[to_read[i]]

/datum/persistence_task/vote/on_shutdown()
	write_file(data)

/datum/persistence_task/vote/proc/insert_counts(var/list/tally)
	sortTim(tally, /proc/cmp_numeric_dsc,1)
	//reset the winner
	data[tally[1]] = 0
	for(var/i = 2; i <= tally.len; i++)
		data[tally[i]] = tally[tally[i]]

/datum/persistence_task/vote/proc/clear_counts()
	data = list()
	fdel(file(file_path))

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

//Research Archive
/datum/persistence_task/researcharchive
	execute = TRUE
	name = "Research Archive"
	file_path = "data/persistence/researcharchive.json"

/datum/persistence_task/researcharchive/on_init()
	if(!research_archive_datum)
		research_archive_datum = new /datum/research()
	var/list/techs = read_file()
	log_debug("DEBUG ARCHIVE: [json_encode(techs)]")
	var/skip_reporting = TRUE
	for(var/obj/machinery/computer/rdconsole/C in machines)
		for(var/element in techs)
			var/datum/tech/T = C.files.known_tech[element]
			if(!T)
				message_admins("DEBUG ARCHIVE: Aborted [element], [C.files.known_tech[element]] failed.")
				continue
			T.level = text2num(techs[element])
			if(skip_reporting && (T.level>1))
				skip_reporting = FALSE //If any level was increased, we want to report

	if(!skip_reporting)
		for(var/obj/machinery/computer/rdconsole/S in machines)
			var/obj/item/weapon/paper/P = new (S.loc)
			P.info = "Your station has benefitted from the research archive project."
			P.update_icon()

/datum/persistence_task/researcharchive/on_shutdown()
	var/list/to_archive = list()
	for(var/datum/tech/T in get_list_of_elements(research_archive_datum.known_tech))
		if(T.id in list("syndicate", "Nanotrasen", "anomaly"))
			continue
		to_archive[T.id] = T.level
	write_file(to_archive)

// Traitor item of the day
/datum/persistence_task/traitor_item_of_the_day
	execute = TRUE
	name = "Traitor Item of the day"
	file_path = "data/persistence/traitordiscount.json"
	var/list/item_list = list()

/datum/persistence_task/traitor_item_of_the_day/on_init()
	data = read_file()
	if (data)
		var/DD = data["date"]
		var/DD_now = text2num(time2text(world.timeofday, "DD:MM:YYYY")) // get the current day
		if (DD != DD_now)
			data["date"] = DD_now
			message_admins("This is a new day, so there are new discounted traitor items.")
			pick_items()
		else
			item_list = json2list(data["list"])
	else
		data = list()
		message_admins("File not found, writing a file for new traitor items.")
		data["date"] = time2text(world.timeofday, "DD:MM:YYYY")
		pick_items()

/datum/persistence_task/traitor_item_of_the_day/proc/pick_items()
	// Make sure to clear it.
	item_list = list()

	var/list/static/forbidden_items = list(
		/datum/uplink_item/badass/bundle,
		/datum/uplink_item/badass/experimental_gear,
		/datum/uplink_item/implants/uplink,
	)

	var/list/traitor_items = subtypesof(/datum/uplink_item)
	var/list/possible_picks = list()
	for (var/thing in traitor_items)
		var/datum/uplink_item/u_item = thing
		if (thing in forbidden_items)
			continue
		if (initial(u_item.item))
			possible_picks += thing

	for (var/i = 1 to 3)
		var/picked = pick(possible_picks)
		possible_picks -= picked
		item_list += picked

	for (var/x in item_list)
		world.log << "Traitor discount item: [x]"

	data["list"] = list2json(item_list)

/datum/persistence_task/traitor_item_of_the_day/on_shutdown()
	write_file(data)
