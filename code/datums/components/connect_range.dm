/**
 * This component behaves similar to connect_loc_behalf but for all turfs in range, hooking into a event on each of them.
 * Just like connect_loc_behalf, It can react to that event on behalf of a seperate listener.
 * Good for components, though it carries some overhead. Can't be an element as that may lead to bugs.
 */
/datum/component/connect_range
	/// An assoc list of event -> procpath to register to the loc this object is on.
	var/list/connections
	/**
	 * The atom the component is tracking. The component will delete itself if the tracked is deleted.
	 * Events will also be updated whenever it moves (if it's a movable).
	 */
	var/atom/tracked

	/// The component will hook into events only on turfs not farther from tracked than this.
	var/range
	/// Whether the component works when the movable isn't directly located on a turf.
	var/works_in_containers

	// /event/moved doesn't pass the location of the mover, so this is a workaround.
	var/oldloc

	passargs = TRUE

/datum/component/connect_range/initialize(atom/tracked, list/connections, range, works_in_containers = TRUE)

	if(!ismovable(tracked) || range < 0)
		return FALSE
	src.connections = connections
	src.range = range
	src.works_in_containers = works_in_containers
	src.oldloc = tracked.loc
	set_tracked(tracked)
	return TRUE

/datum/component/connect_range/Destroy()
	unregister_events(tracked.loc)
	set_tracked(null)
	return ..()

/datum/component/connect_range/inherit_component(atom/tracked, list/connections, new_range, new_works_in_containers)
	// Not equivalent. Checks if they are not the same list via shallow comparison.
	if(!compare_list(src.connections, connections))
		stack_trace("connect_range component attached to [parent] tried to inherit another connect_range component with different connections")
		return
	if(src.tracked != tracked)
		set_tracked(tracked)
	if(src.range == range && src.works_in_containers == works_in_containers)
		return
	//Unregister the events with the old settings.
	unregister_events(tracked.loc)
	src.range = range
	src.works_in_containers = works_in_containers
	//Re-register the events with the new settings.
	if(isturf(tracked.loc) || works_in_containers)
		register_events(tracked.loc)


/datum/component/connect_range/proc/set_tracked(atom/new_tracked)
	if(tracked) //Unregister the events from the old tracked and its surroundings
		unregister_events(tracked.loc)
		tracked.unregister_event(/event/moved, src, nameof(src::on_moved()))
		tracked.unregister_event(/event/destroyed, src, nameof(src::handle_tracked_qdel()))
	tracked = new_tracked
	if(!tracked)
		return
	//Register events on the new tracked atom and its surroundings.
	tracked.register_event(/event/moved, src, nameof(src::on_moved()))
	tracked.register_event(/event/destroyed, src, nameof(src::handle_tracked_qdel()))
	if(isturf(tracked.loc) || works_in_containers)
		register_events(tracked.loc)

/datum/component/connect_range/proc/handle_tracked_qdel()
	qdel(src)

/datum/component/connect_range/proc/register_events(atom/location)
	if(ismovable(location))
		if(!works_in_containers)
			return
		//Keep track of possible movement of all movables the target is in.
		for(var/atom/movable/container as anything in get_nested_locs(location) + location)
			container.register_event(/event/moved, src, nameof(src::on_moved()))
	var/turf/curturf = get_turf(location)
	for(var/turf/target_turf in RANGE_TURFS(range, curturf))
		for(var/event in connections)
			target_turf.register_event(event, parent, connections[event])


/datum/component/connect_range/proc/unregister_events(atom/location)
	for(var/atom/movable/container as anything in (get_nested_locs(location) + location))
		container.unregister_event(/event/moved, src, nameof(src::on_moved()))

	var/turf/curturf = get_turf(location)
	for(var/turf/target_turf in RANGE_TURFS(range, curturf))
		for(var/event in connections)
			target_turf.unregister_event(event, parent, connections[event])


/datum/component/connect_range/proc/on_moved(atom/movable/mover)
	unregister_events(oldloc)
	oldloc = tracked.loc
	register_events(tracked.loc)
