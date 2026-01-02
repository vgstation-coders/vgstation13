/**
 * This component behaves similar to connect_loc_behalf but for all turfs in range, hooking into a event on each of them.
 * Just like connect_loc_behalf, It can react to that event on behalf of a separate listener.
 * Good for components, though it carries some overhead. Can't be an element as that may lead to bugs.
 */

/datum/component/connect_range
	/// An assoc list of event -> procpath to register to the loc this object is on.
	var/list/connections
	/// The turfs currently connected to this component
	var/list/turfs = list()
	/**
	 * The atom the component is tracking. The component will delete itself if the tracked is deleted.
	 * events will also be updated whenever it moves (if it's a movable).
	 */
	var/atom/tracked

	/// The component will hook into events only on turfs not farther from tracked than this.
	var/range
	/// Whether the component works when the movable isn't directly located on a turf.
	var/works_in_containers

	// /event/moved doesn't pass the location of the mover, so this is a workaround.
	var/old_loc
	var/turf/old_turf

/datum/component/connect_range/initialize(atom/tracked, list/connections, range, works_in_containers = TRUE)
	if(!isatom(tracked) || isarea(tracked) || range < 0)
		return FALSE
	src.connections = connections
	src.range = range
	src.works_in_containers = works_in_containers
//	old_loc = tracked.loc
//	old_turf = get_turf(tracked)
	set_tracked(tracked)
	return TRUE

/datum/component/connect_range/Destroy()
	set_tracked(null)
	old_loc = null
	old_turf = null
	return ..()

/datum/component/connect_range/inherit_component(datum/component/component, original, atom/tracked, list/connections, range, works_in_containers)
	// Not equivalent. Checks if they are not the same list via shallow comparison.
	if(!compare_list(src.connections, connections))
		CRASH("connect_range component attached to [parent] tried to inherit another connect_range component with different connections")
	if(src.tracked != tracked)
		set_tracked(tracked)
	if(src.range == range && src.works_in_containers == works_in_containers)
		return
	//Unregister the events with the old settings.
	unregister_events(isturf(tracked) ? tracked : tracked.loc, turfs)
	src.range = range
	src.works_in_containers = works_in_containers
	//Re-register the events with the new settings.
	update_events(src.tracked)

/datum/component/connect_range/proc/set_tracked(atom/new_tracked)
	if(tracked) //Unregister the events from the old tracked and its surroundings
		unregister_events(isturf(tracked) ? tracked : tracked.loc, turfs)
		tracked.unregister_event(/event/moved, src, nameof(src::on_moved()))
		tracked.unregister_event(/event/destroyed, src, nameof(src::handle_tracked_qdel()))
	tracked = new_tracked
	if(!tracked)
		return
	//Register events on the new tracked atom and its surroundings.
	tracked.register_event(/event/moved, src, nameof(src::on_moved()))
	tracked.register_event(/event/destroyed, src, nameof(src::handle_tracked_qdel()))
	update_events(tracked)

/datum/component/connect_range/proc/handle_tracked_qdel()
	qdel(src)

/datum/component/connect_range/proc/update_events(atom/target)
	var/turf/current_turf = get_turf(target)
	if(isnull(current_turf))
		unregister_events(old_loc, turfs)
		turfs = list()
		return

	var/loc_is_movable = ismovable(target.loc)

	if(loc_is_movable)
		if(!works_in_containers)
			unregister_events(old_loc, turfs)
			turfs = list()
			return

	//Only register/unregister turf events if it's moved to a new turf
	if(current_turf == old_turf)
		unregister_events(old_loc, null)
		old_loc = target.loc
		return
	var/list/old_turfs = turfs
	turfs = RANGE_TURFS(range, current_turf)
	unregister_events(old_turf, old_turfs - turfs)
	if(loc_is_movable)
		//Keep track of possible movement of all movables the target is in.
		for(var/atom/movable/container as anything in get_nested_locs(target))
			container.register_event(/event/moved, src, nameof(src::on_moved()))
	for(var/turf/target_turf as anything in turfs - old_turfs)
//		target_turf.color = "#00ff00"
		for(var/event in connections)
			target_turf.register_event(event, parent, connections[event])
	old_turf = current_turf
//	old_turf.color = "#ff0000"
	old_loc = target.loc

/datum/component/connect_range/proc/unregister_events(atom/location, list/remove_from)
	//The location is null or is a container and the component shouldn't have registered events on it
	if(isnull(location) || (!works_in_containers && !isturf(location)))
		return

	if(ismovable(location))
		for(var/atom/movable/target as anything in (get_nested_locs(location) + location))
			target.unregister_event(/event/moved, src, nameof(src::on_moved()))

	if(!length(remove_from))
		return
	for(var/turf/target_turf as anything in remove_from)
		for(var/event in connections)
			target_turf.unregister_event(event, parent, connections[event])
//		target_turf.color = "#ffffff"

/datum/component/connect_range/proc/on_moved(atom/movable/mover)
	update_events(tracked)



