// Ticks AI controllers (and their behavior trees).
// This is the vg subsystem adapter for the WIP tgstation behavior tree port;
// see code/datums/ai/README.md.
//
// There are two subsystems: SSai_controllers for AI_STATUS_ON (full rate) and
// SSai_controllers_low for AI_STATUS_ON_LOW (half rate). Controllers move
// between them through set_ai_status().

var/datum/subsystem/ai_controllers/SSai_controllers
var/datum/subsystem/ai_controllers/low/SSai_controllers_low
/// Controllers created before the subsystems exist (the map loads first); the
/// subsystems adopt them by status when they start.
var/list/ai_controllers_pending = list()

/datum/subsystem/ai_controllers
	name = "AI Controllers"
	wait = SS_WAIT_BOTS
	flags = SS_NO_INIT | SS_KEEP_TIMING
	priority = SS_PRIORITY_MOB

	/// Controllers being processed this fire; kept across a paused fire.
	var/list/currentrun
	/// Controllers currently in AI_STATUS_ON.
	var/list/ai_controllers = list()

/datum/subsystem/ai_controllers/New()
	NEW_SS_GLOBAL(SSai_controllers)
	for(var/datum/ai_controller/controller in ai_controllers_pending.Copy())
		if(controller.ai_status != AI_STATUS_ON)
			continue
		ai_controllers += controller
		ai_controllers_pending -= controller

/datum/subsystem/ai_controllers/stat_entry(msg)
	if(msg)
		return ..()
	..("AI:[ai_controllers.len]")

/datum/subsystem/ai_controllers/fire(resumed = FALSE)
	if(!resumed)
		currentrun = ai_controllers.Copy()
	tick_ai_controllers(currentrun, wait / 10)

/// Shared tick loop; mutates currentrun so a paused fire can resume in place.
/datum/subsystem/ai_controllers/proc/tick_ai_controllers(list/currentrun, seconds_per_tick)
	while(currentrun.len)
		var/datum/ai_controller/controller = currentrun[currentrun.len]
		currentrun.len--

		if(!controller || controller.gcDestroyed || controller.ai_status == AI_STATUS_OFF)
			continue

		controller.SelectBehaviors(seconds_per_tick)

		if(MC_TICK_CHECK)
			return

/datum/subsystem/ai_controllers/low
	name = "AI Controllers (low)"
	wait = SS_WAIT_BOTS * 2

/datum/subsystem/ai_controllers/low/New()
	NEW_SS_GLOBAL(SSai_controllers_low)
	for(var/datum/ai_controller/controller in ai_controllers_pending.Copy())
		if(controller.ai_status != AI_STATUS_ON_LOW)
			continue
		ai_controllers += controller
		ai_controllers_pending -= controller
