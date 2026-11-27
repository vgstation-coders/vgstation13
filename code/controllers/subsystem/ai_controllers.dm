// Ticks AI controllers (and their behavior trees).
// This is the vg subsystem adapter for the WIP tgstation behavior tree port;
// see code/datums/ai/README.md.

var/datum/subsystem/ai_controllers/SSai_controllers

/datum/subsystem/ai_controllers
	name = "AI Controllers"
	wait = SS_WAIT_BOTS
	flags = SS_NO_INIT | SS_KEEP_TIMING
	priority = SS_PRIORITY_MOB

	var/list/currentrun
	/// Controllers grouped by AI_STATUS_* so status changes only touch two lists.
	var/list/ai_controllers_by_status = list(
		AI_STATUS_ON = list(),
		AI_STATUS_ON_LOW = list(),
		AI_STATUS_OFF = list(),
	)

/datum/subsystem/ai_controllers/New()
	NEW_SS_GLOBAL(SSai_controllers)

/datum/subsystem/ai_controllers/stat_entry(msg)
	if(msg)
		return ..()
	..("AI:[ai_controllers_by_status[AI_STATUS_ON].len]+[ai_controllers_by_status[AI_STATUS_ON_LOW].len]")

/datum/subsystem/ai_controllers/fire(resumed = FALSE)
	if(!resumed)
		currentrun = ai_controllers_by_status[AI_STATUS_ON] + ai_controllers_by_status[AI_STATUS_ON_LOW]

	var/seconds_per_tick = wait / 10
	while(currentrun.len)
		var/datum/ai_controller/controller = currentrun[currentrun.len]
		currentrun.len--

		if(!controller || controller.gcDestroyed)
			continue

		controller.SelectBehaviors(seconds_per_tick)

		if(MC_TICK_CHECK)
			return
