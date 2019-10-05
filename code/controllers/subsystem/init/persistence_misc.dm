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
		tasks[task.type] = task
	..()

/datum/subsystem/persistence_misc/Shutdown()
	for (var/datum/persistence_task/task in tasks)
		task.on_shutdown()
	..()

/datum/subsystem/persistence_misc/proc/read_data(var/path)
	var/datum/persistence_task/task_to_read = tasks[path]
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
	if (!locate(/datum/dynamic_ruleset/midround/from_ghosts/faction_based/hesit) in dynamic_mode.executed_rules)
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