/**
 * This component is for large objects extending beyond standard WORLD_ICON_SIZE that might block player visibility. (i.e. snowmap pine trees)
 * When a player walks behind an object with this component, the objects sprite will become visible transparent to them.
 * Unfortunately, it doesn't support changing icon_states (or overlays), because there's no event to check for that (as of now).
 * If an appearance does change appearance, be sure to call update_transparency() on this component to change the transparent image's appearance.
 */


/datum/component/see_behind
	var/image/transparent
	var/static/list/loc_connections = list(
		/event/entered = PROC_REF(give_transparency),
		/event/exited = PROC_REF(remove_transparency),
	)

/datum/component/see_behind/initialize(range = 1)
	if(!isobj(parent) || !range)
		return FALSE
	add_component(/datum/component/connect_range/see_behind, parent, loc_connections, range, FALSE)
	spawn(10)
		update_transparency()
	return TRUE

/datum/component/see_behind/proc/update_transparency()
	if(transparent)
		QDEL_NULL(transparent)
	var/atom/A = parent
	transparent = image(A.icon,A,A.icon_state)
	transparent.overlays = A.overlays
	transparent.color = "[A.color ? A.color : "#FFFFFF"]"+"7F"
	transparent.override = TRUE

/datum/component/see_behind/proc/give_transparency(mover, location, oldloc)
	if(!transparent)
		update_transparency()
	if(!ismob(mover))
		return
	var/mob/M = mover
	if(!M.client)
		return
	var/client/C = M.client
	C.images += transparent

/datum/component/see_behind/proc/remove_transparency(mover, location, newloc)
	if(!ismob(mover))
		return
	var/mob/M = mover
	if(!M.client)
		return
	var/client/C = M.client
	C.images -= transparent

/datum/component/connect_range/see_behind/get_turfs(var/turf/current_turf)
	var/offset_x = round(tracked.pixel_x / WORLD_ICON_SIZE, 1)
	var/offset_y = round(tracked.pixel_y / WORLD_ICON_SIZE, 1)

	var/turf/adjusted_turf = locate(tracked.x + offset_x, tracked.y + offset_y, tracked.z)
	if(!adjusted_turf)
		adjusted_turf = current_turf

	var/list/turfs = list()
	for(var/turf/T in  RANGE_TURFS(range, adjusted_turf))
		if(T.y > adjusted_turf.y)
			turfs += T
	return turfs
