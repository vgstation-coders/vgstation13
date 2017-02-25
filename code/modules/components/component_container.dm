// Basic multipurpose component container.
/datum/component_container

	// Where the components themselves are stored after initialization.
	var/list/components=list()

	// The types to initialize the holder with. Later, holds unique list of all types in container.
	var/list/types=list()

	// The entity that holds this datum.
	var/atom/holder

	// Used for dependency management.

/datum/component_container/New(var/atom/holder_atom)
	holder=holder_atom

/datum/component_container/proc/AddComponentsByType(var/list/new_types)
	var/list/newtypes=list()
	for(var/new_type in new_types)
		AddComponent(new_type,TRUE)
		if(!(new_type in newtypes))
			newtypes.Add(new_type)
	types=newtypes

/**
 * Add component to the container.
 *
 * @param new_type The type we wish to instantiate in the component_container.
 * @param initializing Do not use, only used in container New() for internal purposes.
 */
/datum/component_container/proc/AddComponent(var/new_type, var/initializing=FALSE)
	if(!initializing && !(new_type in types))
		types.Add(new_type)
	var/datum/component/C = new new_type(src)
	components.Add(C)
	SendSignal(COMSIG_COMPONENT_ADDED,list("component"=C))
	return C

/**
 * Removes a component from the container.
 *
 * @param C The component to remove
 */
/datum/component_container/proc/RemoveComponent(var/datum/component/C)
	SendSignal(COMSIG_COMPONENT_REMOVING,list("component"=C))
	components.Remove(C)
	types.Cut()
	for(var/datum/component/CC in components)
		if(!(CC.type in types))
			types.Add(CC.type)
	//qdel(C) Will most likely get GC'd anyway.

/**
 * Send a signal to all components in the container.
 *
 * @param message_type Name of the signal.
 * @param args List of arguments to send with the signal.
 */
/datum/component_container/proc/SendSignal(var/message_type, var/list/args)
	for(var/datum/component/C in components)
		if(C.enabled)
			C.RecieveSignal(message_type, args)

/**
 * Send a signal to the first component of type accepting a signal.
 *
 * @param component_type
 * @param message_type Name of the signal.
 * @param args List of arguments to send with the signal.
 */
/datum/component_container/proc/SendSignalToFirst(var/desired_type, var/message_type, var/list/args, var/shuffle=TRUE)
	var/list/shuffled=list(components) // Copy list so we don't disorder the container.
	if(shuffle)
		shuffled=shuffle(shuffled)
	for(var/datum/component/C in components)
		if(C.enabled && istype(C, desired_type))
			if(C.RecieveSignal(message_type, args)) // return 1 to accept signal.
				return


/**
 * Get the first component matching the specified type.
 */
/datum/component_container/proc/GetComponent(var/desired_type)
	for(var/datum/component/C in components)
		if(istype(C, desired_type))
			return C
	return null

/**
 * Get the all components matching the specified type.
 */
/datum/component_container/proc/GetComponents(var/desired_type)
	. = list()
	for(var/datum/component/C in components)
		if(istype(C, desired_type))
			. += C
	return .
