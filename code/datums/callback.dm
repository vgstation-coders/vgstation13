/callback
	var/datum/thing_to_call
	var/proc_to_call
	var/list/arguments

/callback/New(datum/thing_to_call, proc_to_call, ...)
	src.thing_to_call = thing_to_call
	src.proc_to_call = proc_to_call
	if(length(args) > 2)
		arguments = args.Copy(3)

/callback/proc/invoke(...)
	if(!thing_to_call)
		return

	var/list/calling_arguments = arguments
	if(length(args))
		if(length(arguments))
			calling_arguments = calling_arguments + args  //not += so that it creates a new list so the arguments list stays clean
		else
			calling_arguments = args

	if(thing_to_call == GLOBAL_PROC)
		return call(proc_to_call)(arglist(calling_arguments))
	return call(thing_to_call, proc_to_call)(arglist(calling_arguments))

/callback/proc/invoke_async(...)
	set waitfor = FALSE
	invoke(arglist(args))

