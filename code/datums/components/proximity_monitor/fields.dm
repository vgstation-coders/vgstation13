#define FIELD_TURFS_KEY "field_turfs"
#define EDGE_TURFS_KEY "edge_turfs"

/**
 * Movable and easily code-modified fields! Allows for custom AOE effects that affect movement
 * and anything inside of them, and can do custom turf effects!
 * Supports automatic recalculation/reset on movement.
 *
 * "What do I gain from using advanced over standard prox monitors?"
 * - You can set different effects on edge vs field entrance
 * - You can set effects when the proximity monitor starts and stops tracking a turf
 */

/datum/component/proximity_monitor/advanced
	/// If TRUE, edge turfs will be included as "in the field" for effects
	/// Can be used in certain situations where you may have effects that trigger only at the edge,
	/// while also wanting the field effect to trigger at edge turfs as well
	var/edge_is_a_field = FALSE
	/// All turfs on the inside of the proximity monitor - range - 1 turfs
	var/list/turf/field_turfs = list()
	/// All turfs on the very last tile of the proximity monitor's radius
	var/list/turf/edge_turfs = list()
	/// Necessary since /event/moved only returns the mover.
	var/old_loc

/datum/component/proximity_monitor/advanced/initialize(...)
	..()
	var/atom/AM = parent
	old_loc = get_turf(AM)
	return TRUE

/datum/component/proximity_monitor/advanced/Destroy()
	cleanup_field()
	return ..()

/datum/component/proximity_monitor/advanced/proc/cleanup_field()
	for(var/turf/turf as anything in edge_turfs)
		cleanup_edge_turf(turf)
	edge_turfs = list()
	for(var/turf/turf as anything in field_turfs)
		cleanup_field_turf(turf)
	field_turfs = list()

//Call every time the field moves (done automatically if you use update_center) or a setup specification is changed.
// If full recalc is TRUE, then every turf in the field will have setup called again.
/datum/component/proximity_monitor/advanced/proc/recalculate_field(full_recalc = FALSE)
	var/list/new_turfs = update_new_turfs()

	var/list/old_field_turfs = field_turfs
	var/list/old_edge_turfs = edge_turfs
	field_turfs = new_turfs[FIELD_TURFS_KEY]
	edge_turfs = new_turfs[EDGE_TURFS_KEY]

//	if(!full_recalc)
//		field_turfs = list()
//		edge_turfs = list()

	for(var/turf/old_turf as anything in old_field_turfs - field_turfs)
		if(QDELETED(src))
			return
		cleanup_field_turf(old_turf)
	for(var/turf/old_turf as anything in old_edge_turfs - edge_turfs)
		if(QDELETED(src))
			return
		cleanup_edge_turf(old_turf)

	if(full_recalc)
		old_field_turfs = list()
		old_edge_turfs = list()
		field_turfs = new_turfs[FIELD_TURFS_KEY]
		edge_turfs = new_turfs[EDGE_TURFS_KEY]

	for(var/turf/new_turf as anything in field_turfs - old_field_turfs)
		if(QDELETED(src))
			return
		setup_field_turf(new_turf)

	for(var/turf/new_turf as anything in edge_turfs - old_edge_turfs)
		if(QDELETED(src))
			return
		setup_edge_turf(new_turf)

/datum/component/proximity_monitor/advanced/on_entered(atom/movable/mover, turf/location, atom/oldloc)
	. = ..()
	if(get_dist(mover, parent) == current_range)
		field_edge_crossed(mover, oldloc, location)
	else
		field_turf_crossed(mover, oldloc, location)

/datum/component/proximity_monitor/advanced/on_moved(atom/movable/mover)
	. = ..()
	if(ignore_if_not_on_turf)
		//Early return if it's not the host that has moved.
		if(mover != parent)
			return
		//Cleanup the field if the host was on a turf but isn't anymore.
		var/atom/movable/AM = parent
		if(!isturf(AM.loc))
			if(isturf(old_loc))
				cleanup_field()
			return
	recalculate_field(full_recalc = FALSE)

/datum/component/proximity_monitor/advanced/on_uncrossed(atom/movable/mover, turf/location, atom/newloc)
	if(get_dist(mover, parent) == current_range)
		field_edge_uncrossed(mover, location, get_turf(newloc))
	else
		field_turf_uncrossed(mover, location, get_turf(newloc))

/// Called when a turf in the field of the monitor is linked
/datum/component/proximity_monitor/advanced/proc/setup_field_turf(turf/target)
	return

/// Called when a turf in the field of the monitor is unlinked
/// Do NOT call this manually, requires management of the field_turfs list
/datum/component/proximity_monitor/advanced/proc/cleanup_field_turf(turf/target)
	return

/// Called when a turf in the edge of the monitor is linked
/datum/component/proximity_monitor/advanced/proc/setup_edge_turf(turf/target)
	if(edge_is_a_field) // If the edge is considered a field, set it up like one
		setup_field_turf(target)

/// Called when a turf in the edge of the monitor is unlinked
/// Do NOT call this manually, requires management of the edge_turfs list
/datum/component/proximity_monitor/advanced/proc/cleanup_edge_turf(turf/target)
	if(edge_is_a_field) // If the edge is considered a field, clean it up like one
		cleanup_field_turf(target)

/datum/component/proximity_monitor/advanced/proc/update_new_turfs()
	var/atom/movable/AM = parent
	if(ignore_if_not_on_turf && !isturf(AM.loc))
		return list(FIELD_TURFS_KEY = list(), EDGE_TURFS_KEY = list())
	var/list/local_field_turfs = list()
	var/list/local_edge_turfs = list()
	var/turf/center = get_turf(parent)
	if(current_range > 0)
		local_field_turfs += RANGE_TURFS(current_range - 1, center)
	if(current_range > 1)
		local_edge_turfs = RANGE_TURFS(current_range, center) - local_field_turfs
	return list(FIELD_TURFS_KEY = local_field_turfs, EDGE_TURFS_KEY = local_edge_turfs)

//Gets edge direction/corner, only works with square radius/WDH fields!
/datum/component/proximity_monitor/advanced/proc/get_edgeturf_direction(turf/T, turf/center_override = null)
	var/turf/checking_from = get_turf(parent)
	if(istype(center_override))
		checking_from = center_override
	if(!(T in edge_turfs))
		return
	if(((T.x == (checking_from.x + current_range)) || (T.x == (checking_from.x - current_range))) && ((T.y == (checking_from.y + current_range)) || (T.y == (checking_from.y - current_range))))
		return get_dir(checking_from, T)
	if(T.x == (checking_from.x + current_range))
		return EAST
	if(T.x == (checking_from.x - current_range))
		return WEST
	if(T.y == (checking_from.y - current_range))
		return SOUTH
	if(T.y == (checking_from.y + current_range))
		return NORTH

/datum/component/proximity_monitor/advanced/proc/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	return

/datum/component/proximity_monitor/advanced/proc/field_turf_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	return

/datum/component/proximity_monitor/advanced/proc/field_edge_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(edge_is_a_field) // If the edge is considered a field, pass crossed to that
		field_turf_crossed(movable, old_location, new_location)

/datum/component/proximity_monitor/advanced/proc/field_edge_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(edge_is_a_field) // If the edge is considered a field, pass uncrossed to that
		field_turf_uncrossed(movable, old_location, new_location)


//DEBUG FIELD ITEM
/obj/item/device/multitool/field_debug
	name = "strange multitool"
	desc = "Seems to project a colored field!"
	var/operating = FALSE
	var/datum/component/proximity_monitor/advanced/debug/current = null

/obj/item/device/multitool/field_debug/New()
	..()


/obj/item/device/multitool/field_debug/Destroy()
	QDEL_NULL(current)
	return ..()

/obj/item/device/multitool/field_debug/proc/setup_debug_field()
	current = add_component(/datum/component/proximity_monitor/advanced/debug, src, 5, FALSE)
	current.set_fieldturf_color = "#aaffff"
	current.set_edgeturf_color = "#ffaaff"
	current.recalculate_field()

/obj/item/device/multitool/field_debug/attack_self(mob/user)
	operating = !operating
	to_chat(user, span_notice("You turn [src] [operating? "on":"off"]."))
	if(!istype(current) && operating)
		setup_debug_field()
	else if(!operating)
		QDEL_NULL(current)

//DEBUG FIELDS
/datum/component/proximity_monitor/advanced/debug
	current_range = 5
	var/set_fieldturf_color = "#aaffff"
	var/set_edgeturf_color = "#ffaaff"

/datum/component/proximity_monitor/advanced/debug/setup_edge_turf(turf/target)
	. = ..()
	target.color = set_edgeturf_color

/datum/component/proximity_monitor/advanced/debug/cleanup_edge_turf(turf/target)
	. = ..()
	target.color = initial(target.color)

/datum/component/proximity_monitor/advanced/debug/setup_field_turf(turf/target)
	. = ..()
	target.color = set_fieldturf_color

/datum/component/proximity_monitor/advanced/debug/cleanup_field_turf(turf/target)
	. = ..()
	target.color = initial(target.color)

#undef FIELD_TURFS_KEY
#undef EDGE_TURFS_KEY
