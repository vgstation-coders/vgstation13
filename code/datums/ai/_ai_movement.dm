// AI movement adapters for the WIP behavior tree port.
// Phase 3: a basic pathfinding walker on top of vg's get_path_to().
// The full tgstation movement/cell-tracker port is still pending.

/datum/ai_movement
	/// controller -> list of turfs to walk through.
	var/list/paths = list()

/// Starts (or replaces) a path towards target. Returns FALSE if no path was found.
/datum/ai_movement/proc/start_moving_towards(datum/ai_controller/controller, atom/target, max_distance = 30)
	return FALSE

/// Advances one step. Returns TRUE if the pawn moved.
/datum/ai_movement/proc/process(datum/ai_controller/controller)
	return FALSE

/// Stops moving and drops the stored path.
/datum/ai_movement/proc/stop_moving_towards(datum/ai_controller/controller)
	paths -= controller

/datum/ai_movement/Destroy()
	paths = null
	return ..()

/datum/ai_movement/basic
	/// Recompute a path when this many steps have been consumed and the target moved.
	var/repath_after = 8

/datum/ai_movement/basic/start_moving_towards(datum/ai_controller/controller, atom/target, max_distance = 30)
	var/mob/living/pawn = controller.pawn
	if(!pawn || !target || QDELETED(target) || QDELETED(pawn))
		return FALSE
	if(!get_turf(pawn) || !get_turf(target))
		return FALSE

	// Pathfinding can be unavailable while the pathfinder subsystem is still
	// starting; fall back to one greedy step instead of runtiming.
	var/list/path
	if(SSpathfinder && SSpathfinder.mobs)
		// get_path_to() can briefly wait for a pathfinder slot; callers should not
		// treat this as an instantaneous, sleep-free operation.
		path = get_path_to(
			pawn,
			target,
			max_distance = max_distance,
			mintargetdist = 0,
			simulated_only = TRUE,
			skip_first = TRUE,
			diagonally = FALSE,
			cardinalize = TRUE,
		)

	if(!path || !length(path))
		var/turf/fallback_step = get_step_towards(pawn, target)
		if(!fallback_step)
			paths -= controller
			return FALSE
		paths[controller] = list(fallback_step)
		return TRUE

	paths[controller] = path
	return TRUE

/datum/ai_movement/basic/process(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	var/list/path = paths[controller]
	if(!pawn || QDELETED(pawn) || !path || !length(path))
		paths -= controller
		return FALSE

	var/turf/next_step = path[1]
	path.Cut(1, 2)
	if(!next_step || !pawn.Move(next_step))
		paths -= controller
		return FALSE

	return TRUE
