var/datum/subsystem/persistence_tasks/SSpersistence_tasks

/datum/subsystem/persistence_tasks
	name       = "Persistence - Tasks"
	init_order = SS_INIT_PERSISTENCE_MISC
	flags      = SS_NO_FIRE
	var/list/tasks = list()

/datum/subsystem/persistence_tasks/New()
	NEW_SS_GLOBAL(SSpersistence_tasks)

/datum/subsystem/persistence_tasks/Recover()
	tasks = SSpersistence_tasks.tasks
	..()

/datum/subsystem/persistence_tasks/Initialize(timeofday)
	for (var/task_type in subtypesof(/datum/persistence_task))
		var/datum/persistence_task/task = task_type
		if (!initial(task.execute)) // Deprecated or wip persistence task
			continue
		task = new task_type()
		task.on_init()
		tasks["[task.type]"] = task
	..()

/datum/subsystem/persistence_tasks/Shutdown()
	for (var/task_type in tasks)
		var/datum/persistence_task/task = tasks[task_type]
		task.on_shutdown()
	..()

/datum/subsystem/persistence_tasks/proc/read_data(var/path)
	var/datum/persistence_task/task_to_read = tasks["[path]"]
	if (!task_to_read)
		return null
	return task_to_read.data



// *** PERISTENCE TASKS ***

// -- Abstract

/datum/persistence_task
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

