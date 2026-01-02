/**
*		Proximity Monitor components
*
*		Normal proximity monitors are (mostly) stationary, and won't call on_entered() when the monitor itself moves within proximity of an atom.
*		For proximity monitors which need to move around, see fields.dm
**/


/datum/component/proximity_monitor
	///The atom that will receive HasProximity calls. Defaults to the parent.
	var/atom/receiver
	///The range of the proximity monitor. Things moving wihin it will trigger HasProximity calls.
	var/current_range
	///If we don't check turfs in range if the parent's loc isn't a turf
	var/ignore_if_not_on_turf = TRUE
	///The events of the connect range component, needed to monitor the turfs in range.
	var/static/list/loc_connections = list(
		/event/entered = PROC_REF(on_entered),
		/event/exited = PROC_REF(on_uncrossed),
	)

	/// We need to keep track of what's in proximity so that we can call on_uncrossed() in the case of the monitor moving.
	//var/list/in_proximity = list()


/datum/component/proximity_monitor/initialize(atom/new_receiver = parent, range, _ignore_if_not_on_turf = ignore_if_not_on_turf)
	if(!isatom(new_receiver) || isarea(new_receiver) || !ismovable(parent))
		return FALSE
	ignore_if_not_on_turf = _ignore_if_not_on_turf
	current_range = range

	receiver = new_receiver
	if(receiver != parent)
		new_receiver.register_event(/event/destroyed, src, nameof(src::on_host_or_receiver_del()))

	var/static/list/containers_connections = list(
		/event/moved = PROC_REF(on_moved),
		/event/z_transition = PROC_REF(on_z_change)
	)
	add_component(/datum/component/connect_containers, parent, containers_connections)

	parent.register_event(/event/destroyed, src, nameof(src::on_host_or_receiver_del()))
	parent.register_event(/event/moved, src, nameof(src::on_moved()))
	parent.register_event(/event/z_transition, src, nameof(src::on_z_change()))

	set_range(current_range, TRUE)
	return TRUE

/datum/component/proximity_monitor/proc/on_host_or_receiver_del(datum/source)
	qdel(src)

/datum/component/proximity_monitor/Destroy()
	parent.unregister_event(/event/destroyed, src, nameof(src::on_host_or_receiver_del()))
	parent.unregister_event(/event/moved, src, nameof(src::on_moved()))
	parent.unregister_event(/event/z_transition, src, nameof(src::on_z_change()))

	qdel(get_component(/datum/component/connect_containers))
	qdel(get_component(/datum/component/connect_range))

	receiver = null
	return ..()

/datum/component/proximity_monitor/proc/set_range(range, force_rebuild = FALSE)
	if(!force_rebuild && range == current_range)
		return FALSE
	. = TRUE
	current_range = range

	//If the connect_range component exists already, this will just update its range. No errors or duplicates.
	add_component(/datum/component/connect_range, parent, loc_connections, range, !ignore_if_not_on_turf)

/datum/component/proximity_monitor/proc/on_moved(atom/movable/mover)
//	if(mover == parent)
//		receiver?.HasProximity(parent)

/datum/component/proximity_monitor/proc/on_z_change()
	return

/datum/component/proximity_monitor/proc/set_ignore_if_not_on_turf(does_ignore = TRUE)
	if(ignore_if_not_on_turf == does_ignore)
		return
	ignore_if_not_on_turf = does_ignore
	//Update the ignore_if_not_on_turf
	add_component(/datum/component/connect_range, parent, loc_connections, current_range, ignore_if_not_on_turf)

/datum/component/proximity_monitor/proc/on_uncrossed(atom/mover, atom/location, atom/newloc)
//	in_proximity += mover //Used by the advanced subtype for effect fields.

/datum/component/proximity_monitor/proc/on_entered(atom/mover, atom/entered, atom/old_loc)
	if(mover != parent)
		receiver?.HasProximity(mover)

