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
	..()

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

#define EVENT_HANDLER_OBJREF_INDEX 1
#define EVENT_HANDLER_PROCNAME_INDEX 2

/proc/CallAsync(datum/source, proctype, list/arguments)
	set waitfor = FALSE
	return call(source, proctype)(arglist(arguments))

// Declare children of this type path to use as identifiers for the events.
/lazy_event

// TODO: Document here the arguments that need to be passed to the procs invoked by each event
/lazy_event/on_z_transition
/lazy_event/on_post_z_transition

/datum
	/// Associative list of type path -> list(),
	/// where the type path is a descendant of /event_type.
	/// The inner list is itself an associative list of string -> list(),
	/// where string is the \ref of an object + the proc to be called.
	/// The list associated with the string above contains the hard-ref
	/// to an object and the proc to be called.
	var/list/list/registered_events

/**
  * Calls all registered event handlers with the specified parameters, if any.
  * Arguments:
  * * lazy_event/event_type Required. The typepath of the event to invoke.
  * * list/arguments Optional. List of parameters to be passed to the event handlers.
  */
/datum/proc/lazy_invoke_event(lazy_event/event_type, list/arguments)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!length(registered_events))
		// No event at all is registered for this datum.
		return
	var/list/event_handlers = registered_events[event_type]
	if(!length(event_handlers))
		// This datum does not have any handler registered for this event_type.
		return
	. = NONE
	for(var/key in event_handlers)
		var/list/handler = event_handlers[key]
		var/objRef = handler[EVENT_HANDLER_OBJREF_INDEX]
		var/procName = handler[EVENT_HANDLER_PROCNAME_INDEX]
		. |= CallAsync(objRef, procName, arguments)

/**
  * Registers a proc to be called on an object whenever the specified event_type
  * is invoked on this datum.
  * Arguments:
  * * lazy_event/event_type Required. The typepath of the event to register.
  * * datum/target Required. The object that the proc will be called on.
  * * procname Required. The proc to be called.
  */
/datum/proc/lazy_register_event(lazy_event/event_type, datum/target, procname)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!registered_events)
		registered_events = list()
	if(!registered_events[event_type])
		registered_events[event_type] = list()
	var/key = "[ref(target)]:[procname]"
	registered_events[event_type][key] = list(
		EVENT_HANDLER_OBJREF_INDEX = target,
		EVENT_HANDLER_PROCNAME_INDEX = procname
	)

/**
  * Unregisters a proc so that it is no longer called when the specified
  * event is invoked.
  * Arguments:
  * * lazy_event/event_type Required. The typepath of the event to unregister.
  * * datum/target Required. The object that's been previously registered.
  * * procname Required. The proc of the object.
  */
/datum/proc/lazy_unregister_event(lazy_event/event_type, datum/target, procname)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!registered_events)
		return
	if(!registered_events[event_type])
		return
	var/key = "[ref(target)]:[procname]"
	registered_events[event_type] -= key
	if(!registered_events[event_type].len)
		registered_events -= event_type
	if(!registered_events.len)
		registered_events = null

#undef EVENT_HANDLER_OBJREF_INDEX
#undef EVENT_HANDLER_PROCNAME_INDEX
