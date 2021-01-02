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

// Called by human/proc/apply_radiation()
// Arguments:
// mob/carbon/living/human/user: The human.
// rads: The amount of radiation.
/lazy_event/on_irradiate

// Called whenever an atom's z-level changes.
// Seems to be invoked all over the place, actually. Someone should sort this out.
// Arguments:
// atom/movable/user: The atom that moved.
// to_z: The new z.
// from_z: The old z.
/lazy_event/on_z_transition

// TODO: docs
/lazy_event/on_post_z_transition

// Called whenever an /atom/movable moves.
// Arguments:
// atom/movable/mover: the movable itself.
/lazy_event/on_moved

// Called whenever a datum is destroyed.
// Currently, as an optimization, only /atom/movable invokes this but
// it can be changed to /datum if the need arises.
/lazy_event/on_destroyed
// Arguments:
// datum/thing: the datum being destroyed.

// Called whenever an atom's density changes.
// Arguments:
// atom/atom: the atom whose density changed.
/lazy_event/on_density_change

// Called whenever a mob uses the "resist" verb.
// Arguments:
// mob/user: the mob that's resisting
/lazy_event/on_resist

// Called whenever a mob casts a spell.
// Arguments:
// spell/spell: the spell that's being cast.
// mob/user: the mob that's casting the spell.
// list/targets: the list of targets the spell is being cast against. May not always be a list.
/lazy_event/on_spellcast

// Called whenever a mob attacks something with an empty hand.
// Arguments:
// atom/atom: The atom that's being attacked.
/lazy_event/on_uattack

// Called whenever a mob attacks something while restrained.
// Arguments:
// atom/atom: The atom that's being attacked.
/lazy_event/on_ruattack

// Called by mob/Logout().
// Arguments:
// mob/user: The mob that's logging out.
/lazy_event/on_logout

// Called whenever a mob takes damage.
// Truthy return values will prevent the damage.
// Arguments:
// kind: the kind of damage the mob is being dealt.
// amount: the amount of damage the mob is being dealt.
/lazy_event/on_damaged

// Called whenever a mob dies.
// Arguments:
// mob/user: The mob that's dying.
// body_destroyed: Whether the mob is about to be gibbed.
/lazy_event/on_death

// Called by /mob/proc/ClickOn.
// The list of modifiers can be changed by the event listeners.
// Arguments:
// mob/user: the user that's doing the clicking.
// list/modifiers: list of key modifiers (shift, alt, etcetera).
// atom/target: the atom that's being clicked on.
/lazy_event/on_clickon

// Called when an atom is attacked with an empty hand.
// Currently only used by xenoarch artifacts, should probably be moved to the base proc.
// Arguments:
// mob/user: the guy who is attacking.
// atom/target: the atom that's being attacked.
/lazy_event/on_attackhand

// Called whenever an atom bumps into another.
// Currently only used by xenoarch artifacts, should probably be moved to the base proc.
// Arguments:
// mob/user: the guy who is bumping.
// atom/target: the atom that's being bumped into.
/lazy_event/on_bumped

// Called when mind/transfer_to() finishes.
// Arguments:
// datum/mind/mind: the mind that just got transferred.
/lazy_event/after_mind_transfer

// Called when mob equips an item
// Arguments:
// atom/item: the item
// slot: the slot
/lazy_event/on_equipped

// Called when mob unequippes an item
// Arguments:
// atom/item: the item
/lazy_event/on_unequipped

//Called when movable moves into a new turf
// Arguments:
// atom/movable/mover: thing that moved
// location: turf it entered
// oldloc: atom it exited
/lazy_event/on_entered

//Called when movable moves from a turf
// Arguments:
// atom/movable/mover: thing that moved
// location: turf it exited
// newloc: atom it is entering
/lazy_event/on_exited


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
