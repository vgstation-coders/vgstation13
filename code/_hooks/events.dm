/**
 * /vg/ Events System
 *
 * Intended to replace the hook system.
 * Eventually. :V
 */

// Buggy bullshit requires shitty workarounds
/proc/INVOKE_EVENT(event/event,args)
	if(istype(event))
		. = event.Invoke(args)

/**
 * Event dispatcher
 */
/event
	var/list/handlers=list() // List of [\ref, Function]
	var/atom/holder

/event/New(loc, owner)
	..()
	holder = owner

/event/Destroy()
	holder = null
	handlers = null

/event/proc/Add(var/objectRef,var/procName)
	var/key="\ref[objectRef]:[procName]"
	handlers[key]=list(EVENT_OBJECT_INDEX=objectRef,EVENT_PROC_INDEX=procName)
	return key

/event/proc/Remove(var/key)
	return handlers.Remove(key)

/event/proc/Invoke(var/list/args)
	if(handlers.len==0)
		return
	for(var/key in handlers)
		var/list/handler=handlers[key]
		if(!handler)
			continue

		var/objRef = handler[EVENT_OBJECT_INDEX]
		var/procName = handler[EVENT_PROC_INDEX]

		if(objRef == null)
			handlers.Remove(handler)
			continue
		args["event"] = src
		if(call(objRef,procName)(args, holder)) //An intercept value so whatever code section knows we mean business
			. = 1


/**
* This is used to hold arguments fed to events so they can be read afterwards.
*
* var/event_args/subtype/myargs = new (ass=blast, usa=1)
* INVOKE_EVENT(myevent, myargs)
* if(myargs.usa)...
*/
/event_args
	// Common stuff
	var/cancel = FALSE // Used to cancel some action afterwards

/**
 * Used in player spawning things. (new_player.dm)
 */
/event_args/player_spawn
	var/mob/new_player/new_player = null
	var/mob/living/character = null
	var/rank = ""
	var/late = FALSE

/event_args/player_spawn/New(var/mob/new_player/new_player=null, var/mob/living/character=null, var/rank="", var/late=FALSE)
	src.new_player=new_player
	src.character=character
	src.rank=rank
	src.late=late
