var/datum/subsystem/timer/SStimer

var/PriorityQueue/timers = new /PriorityQueue(/proc/cmp_timer)
var/list/timers_by_id = list()
var/timer_id = 1

/datum/subsystem/timer
	name          = "Timer"
	display_order = SS_DISPLAY_TIMER
	priority      = SS_PRIORITY_TIMER
	flags         = SS_TICKER | SS_NO_INIT
	wait = 1

/datum/subsystem/timer/New()
	NEW_SS_GLOBAL(SStimer)

/datum/subsystem/timer/stat_entry()
	..("T:[timers.L.len]")

/datum/subsystem/timer/fire(resumed = FALSE)
	for(var/entry in timers.L)
		var/datum/timer/timer = entry
		if(timer.when > world.time)
			return
		timer.callback.invoke_async()
		qdel(timer)

/proc/add_timer(callback/callback, wait)
	var/when = world.time + wait
	var/id = timer_id++

	var/datum/timer/new_timer = new
	new_timer.callback = callback
	new_timer.when = when
	new_timer.id = id

	var/datum/thing_to_call = callback.thing_to_call
	if(thing_to_call != GLOBAL_PROC)
		if(!thing_to_call.active_timers)
			thing_to_call.active_timers = list()
		thing_to_call.active_timers += new_timer
	timers.Enqueue(new_timer)

	var/id_str = "[id]"
	timers_by_id += id_str
	timers_by_id[id_str] = new_timer

	return id_str

/proc/del_timer(id)
	qdel(timers_by_id[id])

/datum/timer
	var/callback/callback
	var/when
	var/id

/datum/timer/Destroy()
	var/datum/thing_to_call = callback.thing_to_call
	// Optimization or waste of time?
	// If a datum has many timers it may be beneficial to check whether thing_to_call.gcDestroyed has been set,
	// indicating there's no need to remove this timer from its active_timers list, as the list will be nulled right afterwards.
	if(thing_to_call != GLOBAL_PROC && !thing_to_call.gcDestroyed)
		thing_to_call.active_timers -= src
		if(!thing_to_call.active_timers.len)
			thing_to_call.active_timers = null

	timers.L -= src
	timers_by_id -= "[id]"
	..()
