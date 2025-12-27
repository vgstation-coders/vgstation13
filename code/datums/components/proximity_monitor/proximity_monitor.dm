/datum/component/proximity_monitor
	///The atom that will receive HasProximity calls. Defaults to the parent.
	var/atom/receiver
	///The range of the proximity monitor. Things moving wihin it will trigger HasProximity calls.
	var/current_range
	///If we don't check turfs in range if the parent's loc isn't a turf
	var/ignore_if_not_on_turf = FALSE
	///The events of the connect range component, needed to monitor the turfs in range.
	var/static/list/loc_connections = list(
		/event/entered = PROC_REF(on_entered),
		/event/exited = PROC_REF(on_uncrossed),
	)

/datum/component/proximity_monitor/initialize(atom/new_receiver = parent, range, _ignore_if_not_on_turf = TRUE)
	if(!isatom(new_receiver) || isarea(new_receiver) || !ismovable(parent))
		return FALSE
	ignore_if_not_on_turf = _ignore_if_not_on_turf
	current_range = range

	receiver = new_receiver
	if(receiver != parent)
		new_receiver.register_event(/event/destroyed, src, nameof(src::on_host_or_receiver_del()))

	parent.register_event(/event/destroyed, src, nameof(src::on_host_or_receiver_del()))
	parent.register_event(/event/before_move, src, nameof(src::before_move()))
	parent.register_event(/event/moved, src, nameof(src::on_moved()))
	parent.register_event(/event/z_transition, src, nameof(src::on_z_change()))

	for(var/atom/movable/container as anything in get_nested_locs(parent))
		container.register_event(/event/moved, src, nameof(src::before_move()))
		container.register_event(/event/moved, src, nameof(src::on_moved()))

	set_range(current_range, TRUE)
	return TRUE

/datum/component/proximity_monitor/proc/on_host_or_receiver_del(datum/source)
	qdel(src)

/datum/component/proximity_monitor/Destroy()
	parent.unregister_event(/event/destroyed, src, nameof(src::on_host_or_receiver_del()))
	parent.unregister_event(/event/before_move, src, nameof(src::before_move()))
	parent.unregister_event(/event/moved, src, nameof(src::on_moved()))
	parent.unregister_event(/event/z_transition, src, nameof(src::on_z_change()))

	for(var/atom/movable/container as anything in get_nested_locs(parent))
		container.unregister_event(/event/moved, src, nameof(src::on_moved()))
		container.unregister_event(/event/moved, src, nameof(src::before_move()))

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
	if(mover == parent)
		receiver?.HasProximity(parent)

	//Keep track of possible movement of all movables the target is in.
	for(var/atom/movable/container as anything in get_nested_locs(parent))
		container.register_event(/event/moved, src, nameof(src::before_move()))
		container.register_event(/event/before_move, src, nameof(src::on_moved()))

/datum/component/proximity_monitor/proc/before_move()
	//Keep track of possible movement of all movables the target is in.
	for(var/atom/movable/container as anything in get_nested_locs(parent))
		container.unregister_event(/event/moved, src, nameof(src::on_moved()))
		container.unregister_event(/event/before_move, src, nameof(src::before_move()))

/datum/component/proximity_monitor/proc/on_z_change()
	return

/datum/component/proximity_monitor/proc/set_ignore_if_not_on_turf(does_ignore = TRUE)
	if(ignore_if_not_on_turf == does_ignore)
		return
	ignore_if_not_on_turf = does_ignore
	//Update the ignore_if_not_on_turf
	add_component(/datum/component/connect_range, parent, loc_connections, current_range, ignore_if_not_on_turf)

/datum/component/proximity_monitor/proc/on_uncrossed()
	return //Used by the advanced subtype for effect fields.

/datum/component/proximity_monitor/proc/on_entered(atom/mover, atom/entered, atom/old_loc)
	if(mover != parent)
		receiver?.HasProximity(mover)
