/datum/component
	/// (protected, enum) How duplicate component types are handled when added to the datum.
	/// `COMPONENT_DUPE_UNIQUE_PASSARGS` (default): New component will never exist and instead its initialization arguments will be passed on to the old component.
    /// `COMPONENT_DUPE_ALLOWED`: The components will be treated as separate, `GetComponent()` will return the first added
	var/dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// (protected, type) Definition of a duplicate component type
    /// `null` means exact match on `type` (default)
    /// Any other type means that and all subtypes
	var/dupe_type
	var/datum/parent
	//only set to true if you are able to properly transfer this component
	//At a minimum RegisterWithParent and UnregisterFromParent should be used
	//Make sure you also implement PostTransfer for any post transfer handling
	var/can_transfer = FALSE

/datum/component/New(var/datum/P, ...)
	parent = P
	var/list/arguments = args.Copy(2)
	if(Initialize(arglist(arguments)) == COMPONENT_INCOMPATIBLE)
		qdel(src, TRUE, TRUE)
		CRASH("Incompatible [type] assigned to a [P.type]!")

	_JoinParent(P)

/datum/component/proc/_JoinParent()
	var/datum/P = parent
	//lazy init the parent's dc list
	var/list/dc = P.datum_components
	if(!dc)
		P.datum_components = dc = list()

	//set up the typecache
	var/our_type = type
	for(var/I in _GetInverseTypeList(our_type))
		var/test = dc[I]
		if(test)	//already another component of this type here
			var/list/components_of_type
			if(!length(test))
				components_of_type = list(test)
				dc[I] = components_of_type
			else
				components_of_type = test
			if(I == our_type)	//exact match, take priority
				var/inserted = FALSE
				for(var/J in 1 to components_of_type.len)
					var/datum/component/C = components_of_type[J]
					if(C.type != our_type) //but not over other exact matches
						components_of_type.Insert(J, I)
						inserted = TRUE
						break
				if(!inserted)
					components_of_type += src
			else	//indirect match, back of the line with ya
				components_of_type += src
		else	//only component of this type, no list
			dc[I] = src
	RegisterWithParent()

// If you want/expect to be moving the component around between parents, use this to register on the parent for signals
/datum/component/proc/RegisterWithParent()
	return

/datum/component/proc/Initialize(...)
	return LoadData(arglist(args))

/datum/component/Destroy(var/force = FALSE, var/silent = FALSE)
	if(!force && parent)
		_RemoveFromParent()
	if(!silent)
		SEND_SIGNAL(parent, COMSIG_COMPONENT_REMOVING, src)
	parent = null
	..()

/datum/component/proc/_RemoveFromParent()
	var/datum/P = parent
	var/list/dc = P.datum_components
	for(var/I in _GetInverseTypeList())
		var/list/components_of_type = dc[I]
		if(length(components_of_type))
			var/list/subtracted = components_of_type - src
			if(subtracted.len == 1)	//only 1 guy left
				dc[I] = subtracted[1]	//make him special
			else
				dc[I] = subtracted
		else	//just us
			dc -= I
	if(!dc.len)
		P.datum_components = null
	
	UnregisterFromParent()

/datum/component/proc/UnregisterFromParent()
	return

/datum/proc/RegisterSignal(var/datum/target, var/sig_type_or_types, var/proc_or_callback, var/override = FALSE)
	if(gcDestroyed || !target || target.gcDestroyed)
		return

	var/list/procs = signal_procs
	if(!procs)
		signal_procs = procs = list()
	if(!procs[target])
		procs[target] = list()
	var/list/lookup = target.comp_lookup
	if(!lookup)
		target.comp_lookup = lookup = list()

	if(!istype(proc_or_callback, /datum/callback)) //if it wasnt a callback before, it is now
		proc_or_callback = CALLBACK(src, proc_or_callback)

	var/list/sig_types = islist(sig_type_or_types) ? sig_type_or_types : list(sig_type_or_types)
	for(var/sig_type in sig_types)
		if(!override && procs[target][sig_type])
			stack_trace("[sig_type] overridden. Use override = TRUE to suppress this warning")

		procs[target][sig_type] = proc_or_callback

		if(!lookup[sig_type]) // Nothing has registered here yet
			lookup[sig_type] = src
		else if(lookup[sig_type] == src) // We already registered here
			continue
		else if(!length(lookup[sig_type])) // One other thing registered here
			lookup[sig_type] = list(lookup[sig_type]=TRUE)
			lookup[sig_type][src] = TRUE
		else // Many other things have registered here
			lookup[sig_type][src] = TRUE

	signal_enabled = TRUE

/datum/proc/UnregisterSignal(var/datum/target, var/sig_type_or_types)
	var/list/lookup = target.comp_lookup
	if(!signal_procs || !signal_procs[target] || !lookup)
		return
	if(!islist(sig_type_or_types))
		sig_type_or_types = list(sig_type_or_types)
	for(var/sig in sig_type_or_types)
		switch(length(lookup[sig]))
			if(2)
				lookup[sig] = (lookup[sig]-src)[1]
			if(1)
				stack_trace("[target] ([target.type]) somehow has single length list inside comp_lookup")
				if(src in lookup[sig])
					lookup -= sig
					if(!length(lookup))
						target.comp_lookup = null
						break
			if(0)
				lookup -= sig
				if(!length(lookup))
					target.comp_lookup = null
					break
			else
				lookup[sig] -= src

	signal_procs[target] -= sig_type_or_types
	if(!signal_procs[target].len)
		signal_procs -= target

/datum/component/proc/PreTransfer()
	return

/datum/component/proc/PostTransfer()
	return

/datum/component/proc/_GetInverseTypeList(var/our_type = type)
	//we can do this one simple trick
	var/current_type = parent_type
	. = list(our_type, current_type)
	//and since most components are root level + 1, this won't even have to run
	while (current_type != /datum/component)
		current_type = type2parent(current_type)
		. += current_type

/datum/proc/_SendSignal(var/sigtype, var/list/arguments)
	var/target = comp_lookup[sigtype]
	if(!length(target))
		var/datum/C = target
		if(!C.signal_enabled)
			return NONE
		var/datum/callback/CB = C.signal_procs[src][sigtype]
		return CB.InvokeAsync(arglist(arguments))
	. = NONE
	for(var/I in target)
		var/datum/C = I
		if(!C.signal_enabled)
			continue
		var/datum/callback/CB = C.signal_procs[src][sigtype]
		. |= CB.InvokeAsync(arglist(arguments))


/// (public, final)
/// Returns a reference to a component of `component_type` if it exists in the datum, null otherwise
/datum/proc/GetComponent(var/component_type)
	var/list/dc = datum_components
	if(!dc)
		return null
	. = dc[component_type]
	if(length(.))
		return .[1]

/// (public, final)
/// Returns a list of references to all components of `component_type` that exist in the datum
/datum/proc/GetComponentsOfType(var/component_type)
	var/list/dc = datum_components
	if(!dc)
		return null
	. = dc[component_type]
	if(!length(.))
		return list(.)

/// (public, final)
/// Returns a reference to a component whose type MATCHES `component_type` if that component exists in the datum, null otherwise
/datum/proc/GetExactComponent(var/component_type)
	var/list/dc = datum_components
	if(!dc)
		return null
	var/datum/component/C = dc[component_type]
	if(C)
		if(length(C))
			C = C[1]
		if(C.type == component_type)
			return C
	return null


/// (public, final)
/// Creates an instance of `component_type` in the datum and passes `...` to its `Initialize()` call
/// Alternatively adds an existing instance of a component to the datum.
/// Sends the `COMSIG_COMPONENT_ADDED` signal to the datum
/// All components a datum owns are deleted with the datum
/// Returns the component that was created. Or the old component in a dupe situation where `COMPONENT_DUPE_UNIQUE_PASSARGS` was set
/// If this tries to add an component to an incompatible type, the component will be deleted and the result will be `null`. This is very unperformant, try not to do it
/// Properly handles duplicate situations based on the `dupe_mode` var
/datum/proc/AddComponent(var/type_or_instance, ...)
	var/datum/component/nt = type_or_instance
	var/dm = initial(nt.dupe_mode)
	var/dt = initial(nt.dupe_type)

	var/datum/component/old_comp
	var/datum/component/new_comp

	if(istext(nt))
		CRASH("[nt] is a string but should be a type path")
	if(ispath(nt))
		if(nt == /datum/component)
			CRASH("[nt] attempted instantiation!")
	else
		new_comp = nt
		nt = new_comp.type

	args[1] = src

	if(dm != COMPONENT_DUPE_ALLOWED)
		if(!dt)
			old_comp = GetExactComponent(nt)
		else
			old_comp = GetComponent(dt)
		if(old_comp)
			switch(dm)
				if(COMPONENT_DUPE_UNIQUE_PASSARGS)
					if(!new_comp)
						var/list/arguments = args.Copy(2)
						old_comp.LoadData(arglist(arguments))
					else
						old_comp.InheritComponent(new_comp)
						qdel(new_comp)
						new_comp = null

		else if(!new_comp)
			new_comp = new nt(arglist(args)) // There's a valid dupe mode but there's no old component, act like normal
	else if(!new_comp)
		new_comp = new nt(arglist(args)) // Dupes are allowed, act like normal

	if(!old_comp && new_comp && !new_comp.gcDestroyed) // Nothing related to duplicate components happened and the new component is healthy
		SEND_SIGNAL(src, COMSIG_COMPONENT_ADDED, new_comp)
		return new_comp
	return old_comp

/// (abstract, no-sleep)
/// Called on a component when a component of the same type was added to the same parent.
/// Use it to extract the data from `C`, which will then be deleted.
/datum/component/proc/InheritComponent(datum/component/C)
	return

/// (public, final)
/// Equivalent to calling `GetComponent(component_type)` where, if the result would be `null`, returns `AddComponent(component_type, ...)` instead
/datum/proc/LoadComponent(var/component_type, ...)
	. = GetComponent(component_type)
	if(!.)
		return AddComponent(arglist(args))

/// (public, final)
/// Removes the component from the parent.
/datum/component/proc/RemoveComponent()
	if(!parent)
		return
	var/datum/old_parent = parent
	PreTransfer()
	_RemoveFromParent()
	parent = null
	SEND_SIGNAL(old_parent, COMSIG_COMPONENT_REMOVING, src)

/datum/proc/TakeComponent(var/datum/component/target)
	if(!target || target.parent == src)
		return
	if(target.parent)
		target.RemoveComponent()
	target.parent = src
	if(target.PostTransfer() == COMPONENT_INCOMPATIBLE)
		var/c_type = target.type
		qdel(target)
		CRASH("Incompatible [c_type] transfer attempt to a [type]!")
	if(target == AddComponent(target))
		target._JoinParent()

/datum/proc/TransferComponents(var/datum/target)
	var/list/dc = datum_components
	if(!dc)
		return
	var/comps = dc[/datum/component]
	if(islist(comps))
		for(var/datum/component/I in comps)
			if(I.can_transfer)
				target.TakeComponent(I)
	else
		var/datum/component/C = comps
		if(C.can_transfer)
			target.TakeComponent(comps)

/// (abstract, no-sleep)
/// Called by `Initialize` or `AddComponent`, when creating a new component or handling an attempted duplicate creation, respectively.
/datum/proc/LoadData(var/list/arguments)
	return