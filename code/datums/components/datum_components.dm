/*
	Datum component stuff. Underscore in list name is to avoid collisions with stuff like robot components.
*/

/datum
	var/list/_components

/datum/New()
	..()
	InitializeComponents()
	if(_components)
		active_component_owners.Add(src)

/*
	Override with component initialization logic.
	Typically this will just be a list of TryAttachComponent(/path/to/component),
	but you could do other stuff too if needed.
*/

/datum/proc/InitializeComponents()
	return

/*
	Called when a datum with components is Destroy()'d so we can "cleanly" shut down all of its components.
*/
/datum/proc/DeinitializeComponents()
	for(var/datum/component/C in _components)
		C.Deinitialize()
		_components.Remove(C)
		qdel(C)

/*
	Attempts to create and attach a component of the given type.
	Fails if an instance of the component type already exists in the atom's component list.
	comp_type: Type of component we're trying to attach.
	args: list of arguments to be passed to the component's InitializeComponent() proc
*/

/datum/proc/TryAttachComponent(var/comp_type, var/list/args)
	if(!_components)
		_components = list()
	for(var/datum/component/comp in _components)
		if(istype(comp, comp_type))
			. = FALSE
			CRASH("Attempted to attach duplicate component of type [comp_type] to atom [src], somebody fucked up!")
	var/datum/component/new_comp = new comp_type(src)
	new_comp.InitializeComponent(arglist(args))
	_components.Add(new_comp)
	return TRUE

/*
	Attempts to detach a component of a given type from the atom.
	If the component interacts with other component types then you're responsible for making sure it doesn't cause the atom to explode.
	Returns true if successful, false if not.
	comp_type: Type of component we're trying to detach.
*/

/datum/proc/TryDetachComponent(var/comp_type)
	for(var/datum/component/comp in _components)
		if(istype(comp, comp_type))
			if(comp.TryDetach())
				_components.Remove(comp)
				return TRUE
	return FALSE

/*
	Attempts to get a component, either returns the component or FALSE if it's not found
	Spits out an error in debug logs if someone tries to get an invalid type (or something that's not a typepath at all).
	target: what type of component we're looking for
*/

/datum/proc/TryGetComponent(var/target)
	if(!ispath(target, /datum/component))
		. = FALSE
		CRASH("TryGetComponent() called on [src] with invalid type [target], somebody fucked up!")

	for(var/datum/component/comp in _components)
		if(istype(comp, target))
			return comp

	return FALSE

/*
	Attempts to get all components of a type and its subtypes, returns a list of them or FALSE if none are found.
	target: what type of component we're looking for
*/

/datum/proc/TryGetComponents(var/target)
	if(!ispath(target, /datum/component))
		. = FALSE
		CRASH("TryGetComponents() called on [src] with invalid type [target], somebody fucked up!")

	var/list/found_components = list()

	for(var/datum/component/comp in _components)
		if(istype(comp, target))
			found_components.Add(comp)

	if(found_components.len)
		return found_components

	return FALSE

/*
	Upon receiving a signal, we need to disperse it to every component in the datum.

	message_type: see __DEFINES/component_signals.dm for a list of valid signals
	args: list of arguments to send with the signal
 */
/datum/proc/SignalComponents(var/message_type, var/list/args)
	for(var/datum/component/C in _components)
		C.ReceiveSignal(message_type, args)

/*
	Send a signal, and see if anyone replies with information.

	message_type: The message to send
	args: The arguments associated with this message
 */
/datum/proc/ReturnFromSignalFirst(var/message_type, var/list/args)
	for(var/datum/component/C in _components)
		var/received_information = C.RecieveAndReturnSignal(message_type, args)
		if(received_information)
			return received_information
