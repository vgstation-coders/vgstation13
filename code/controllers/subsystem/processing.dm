var/datum/subsystem/processing/SSprocessing

/datum/subsystem/processing
	name          = "Processing"
	display_order = SS_DISPLAY_PROCESSING
	priority      = SS_PRIORITY_PROCESSING
	wait          = 1 SECONDS
	flags         = SS_BACKGROUND | SS_POST_FIRE_TIMING | SS_NO_INIT
	var/stat_tag = "P"
	var/list/processing = list()
	var/list/currentrun = list()

/datum/subsystem/processing/New()
	NEW_SS_GLOBAL(SSprocessing)

/datum/subsystem/processing/stat_entry()
	..("[stat_tag]:[processing.len]")


/datum/subsystem/processing/fire(resumed = FALSE)
	if (!resumed)
		currentrun = processing.Copy()

	var/list/current_run = currentrun

	while (current_run.len)
		var/atom/thing = current_run[current_run.len]
		current_run.len--
		if(!thing || thing.gcDestroyed || thing.process(wait) == PROCESS_KILL)
			processing -= thing
		if (MC_TICK_CHECK)
			return

/datum/var/isprocessing = FALSE
/datum/proc/process()
	set waitfor = 0
	STOP_PROCESSING(SSobj, src)
	return 0