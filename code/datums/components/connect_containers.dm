/// This component behaves similar to connect_loc_behalf, but it's nested and hooks a event onto all MOVABLES containing this atom.
/datum/component/connect_containers
	/// An assoc list of event -> procpath to register to the loc this object is on.
	var/list/connections
	/**
	 * The atom the component is tracking. The component will delete itself if the tracked is deleted.
	 * events will also be updated whenever it moves.
	 */
	var/atom/movable/tracked

	// on_moved() doesn't pass oldloc, so this is a workaround
	var/old_loc

/datum/component/connect_containers/initialize(atom/movable/tracked, list/connections)
	. = ..()
	if (!ismovable(tracked))
		return FALSE

	src.connections = connections
	set_tracked(tracked)
	return TRUE

/datum/component/connect_containers/Destroy()
	set_tracked(null)
	return ..()

/datum/component/connect_containers/inherit_component(datum/component/component, original, atom/movable/tracked, list/connections)
	// Not equivalent. Checks if they are not the same list via shallow comparison.
	if(!compare_list(src.connections, connections))
		CRASH("connect_containers component attached to [parent] tried to inherit another connect_containers component with different connections")
	if(src.tracked != tracked)
		set_tracked(tracked)

/datum/component/connect_containers/proc/set_tracked(atom/movable/new_tracked)
	if(tracked)
		tracked.unregister_event(/event/moved, src, nameof(src::on_moved()))
		tracked.unregister_event(/event/destroyed, src, nameof(src::handle_tracked_qdel()))
		unregister_events(tracked.loc)
	tracked = new_tracked
	if(!tracked)
		return
	tracked.unregister_event(/event/moved, src, nameof(src::on_moved()))
	tracked.unregister_event(/event/destroyed, src, nameof(src::handle_tracked_qdel()))
	update_events(tracked)

/datum/component/connect_containers/proc/handle_tracked_qdel()
	qdel(src)

/datum/component/connect_containers/proc/update_events(atom/movable/listener)
	if(!ismovable(listener.loc))
		return

	for(var/atom/movable/container as anything in get_nested_locs(listener))
		container.register_event(/event/moved, src, nameof(src::on_moved()))
		for(var/event in connections)
			container.register_event(event, parent, connections[event])

/datum/component/connect_containers/proc/unregister_events(atom/movable/location)
	if(!ismovable(location))
		return

	for(var/atom/movable/target as anything in (get_nested_locs(location) + location))
		target.unregister_event(/event/moved, src, nameof(src::on_moved()))
		for(var/event in connections)
			target.unregister_event(event, parent, connections[event])

/datum/component/connect_containers/proc/on_moved(atom/movable/mover)
	unregister_events(old_loc)
	update_events(tracked)
	old_loc = tracked.loc
