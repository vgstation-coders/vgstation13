//Mostly for component system stuff.
//Sorry about the underscores, but it's the simplest way to make sure we avoid collisions.

/atom
    var/list/_components = list()
    var/list/_initial_components = list() //assoc list, entries: list(/path/to/component = list([insert list of arguments here]))

/atom/proc/InitializeComponents()
    if(!_initial_components.len)
        return

    for(var/new_component_path in _initial_components)
        if(!ispath(new_component_path, /datum/component))
            log_debug("Invalid type path [new_component_path] found in _initial_components of [src], somebody fucked up!")
        _components.Add(new new_component_path(src))

    for(var/datum/component/new_component in _components)
        new_component.InitializeComponent(_initial_components[new_component])

    if(_components.len)
        active_component_owners.Add(src)

/*
    Attempts to get a component, either returns the component or returns null if it's not found
    Spits out an error in debug logs if someone tries to get an invalid type (or something that's not a typepath at all).
    target: what type of component we're looking for
*/

/atom/proc/TryGetComponent(var/target)
    if(!ispath(target, /datum/component))
        log_debug("TryGetComponent() called on [src] with invalid type [target], somebody fucked up!")
        return //if you're not looking for a component then you fucked up

    for(var/comp in _components)
        if(istype(comp, target))
            return comp

/*
    Upon receiving a signal, we need to disperse it to every component in the datum.
    message_type: see __DEFINES/component_signals.dm for a list of valid signals
    args: list of arguments to send with the signal
 */
/atom/proc/SignalComponents(var/message_type, var/list/args)
	for(var/datum/component/C in _components)
		C.RecieveSignal(message_type, args)

/**
 * Send a signal, and see if anyone replies with information.
 *
 * @param message_type: String(DEFINE): The message to send
 * @param args: List(ref): The arguments associated with this message
 */
/atom/proc/ReturnFromSignalFirst(var/message_type, var/list/args)
	for(var/datum/component/C in _components)
		var/received_information = C.RecieveAndReturnSignal(message_type, args)
		if(received_information)
			return received_information