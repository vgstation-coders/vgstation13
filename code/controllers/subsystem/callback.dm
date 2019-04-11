var/datum/subsystem/callback/SScallback

#define CALLBACK(a,b,c,d,e,f,g,h) callbacks.Add(new /datum/callback{caller = a, called = b, time_to_wait = h*SScallback.wait, function_to_be_called = c, function_to_tell_caller = e, args_called = d, args_call_success = f, args_call_fail = g})

var/list/callbacks = list()

/datum/subsystem/callback
	name			= "callback"
	display_order	= SS_DISPLAY_CALLBACK
	priority 		= SS_PRIORITY_CALLBACK
	wait			= SS_WAIT_CALLBACK
	flags			= SS_NO_INIT
	var/list/currentrun

/datum/subsystem/callback/New()
	NEW_SS_GLOBAL(SScallback)

/datum/subsystem/callback/stat_entry()
	..("P:[callbacks.len]")

/datum/subsystem/callback/fire(var/resumed = FALSE)
	if(!resumed)
		currentrun = global.callbacks.Copy()

	while(currentrun.len)
		var/datum/callback/C = currentrun[currentrun.len]
		currentrun.len--

		if(!C || !C.caller || !C.called || !C.function_to_be_called || !C.function_to_tell_caller)
			qdel(C)

		C.attempt_callback()
		if (MC_TICK_CHECK)
			return

/datum/callback
	var/datum/caller //Thing that is waiting on the response
	var/datum/called //Thing that is to make the response
	var/function_to_be_called //The function that is to be called by the response
	var/list/args_called = list() //Arguments to be passed to the
	var/function_to_tell_caller
	var/list/args_call_success = list()
	var/list/args_call_fail = list()
	var/time_to_wait = 0 //In however may ticks it takes for callback to function

/datum/callback/Destroy()
	caller = null
	called = null
	args_called.Cut()
	args_call_success.Cut()
	args_call_fail.Cut()
	callbacks.Remove(src)

/datum/callback/proc/attempt_callback()
	if(time_to_wait <= 0)
		var/result = call(called,function_to_be_called)(args_called)
		if(result)
			call(caller,function_to_tell_caller)(args_call_success)
		else
			call(caller,function_to_tell_caller)(args_call_fail)
		qdel(src)
	else
		time_to_wait--