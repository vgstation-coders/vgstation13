/datum/component
	var/datum/parent

	// If TRUE, when a duplicate component is created, pass the new arguments to the original component, instead of immediately failing.
	// inherit_component() must be defined if set to TRUE
	var/passargs = FALSE


/datum/component/New(datum/parent, ...)
	src.parent = parent
	var/list/arguments = args.Copy(2)
	if(!initialize(arglist(arguments)))
		CRASH("Incompatible [type] assigned to a [parent.type]! args: [json_encode(arguments)]")
		qdel(src)
		return

	_join_parent(parent)

/datum/component/Destroy()
	if(parent)
		_remove_from_parent()
		parent = null
	..()

/datum/component/proc/_join_parent()
	var/datum/P = parent
	var/list/dc = P.datum_components
	if(!dc)
		P.datum_components = dc = list()

	dc[type] = src

	register_with_parent()

/datum/component/proc/_remove_from_parent()
	var/datum/P = parent
	var/list/dc = P.datum_components
	dc -= type
	if(!dc.len)
		P.datum_components = null

	unregister_from_parent()

/datum/component/proc/register_with_parent()
	return

/datum/component/proc/unregister_from_parent()
	return

/datum/component/proc/remove()
	if(!parent)
		return
	_remove_from_parent()
	parent = null

/datum/component/proc/inherit_component(...)
	return

/datum/proc/get_component(datum/component/c_type)
	RETURN_TYPE(c_type)
	var/list/dc = datum_components
	if(!dc)
		return null
	return dc[c_type]

/datum/proc/add_component(...)
	var/datum/component/new_type = args[1]

	if(!ispath(new_type))
		CRASH("add_component called with non-path first argument: [new_type]")

	var/datum/component/old_comp = get_component(new_type)
	if(!isnull(old_comp))
		if(initial(old_comp.passargs))
			var/list/arguments = args.Copy(2)
			old_comp.inherit_component(arglist(arguments))
		else
			CRASH("add_component called but [new_type] already exists, and passargs is set to FALSE.")


	args[1] = src
	var/datum/component/new_component = new new_type(arglist(args))

	if(!new_component || new_component.gcDestroyed)
		CRASH("add_component tried to create new [new_type] but it was deleted")

	return new_component

/datum/proc/load_component(datum/component/c_type, ...)
	. = get_component(c_type)
	if(!.)
		return add_component(arglist(args))

/datum/component/proc/process()
	set waitfor = FALSE
