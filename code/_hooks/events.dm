/**
 * /vg/ Events System
 *
 * Intended to replace the hook system.
 * Eventually. :V
 */

// Buggy bullshit requires shitty workarounds
#define INVOKE_EVENT(event,args) if(istype(event)) event.Invoke(args)

/**
 * Event dispatcher
 */
/event
	var/list/handlers=list() // List of [\ref, Function]
	var/atom/holder

/event/New(owner)
	. = ..()
	holder = owner

/event/Destroy()
	. = ..()
	holder = null
	
/event/proc/Add(var/objectRef,var/procName)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/event/proc/Add() called tick#: [world.time]")
	var/key="\ref[objectRef]:[procName]"
	handlers[key]=list("o"=objectRef,"p"=procName)
	return key

/event/proc/Remove(var/key)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/event/proc/Remove() called tick#: [world.time]")
	return handlers.Remove(key)

/event/proc/Invoke(var/list/args)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/event/proc/Invoke() called tick#: [world.time]")
	if(handlers.len==0)
		return
	for(var/key in handlers)
		var/list/handler=handlers[key]
		if(!handler)
			continue

		var/objRef = handler["o"]
		var/procName = handler["p"]

		if(objRef == null)
			handlers.Remove(handler)
			continue
		args["event"] = src
		call(objRef,procName)(args)