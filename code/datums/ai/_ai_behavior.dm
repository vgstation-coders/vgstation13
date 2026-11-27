// Base type for AI behavior leaf nodes in the behavior tree system.
// Ported from tgstation/tgstation (code/datums/ai/_ai_behavior.dm) with the
// async perform path and event logging deferred to the controller phase.

/datum/bt_node/ai_behavior
	/// Flags for extra behavior (reserved; see the controller port).
	var/behavior_flags = NONE
	/// Cooldown between perform() calls; read through get_cooldown().
	var/time_between_perform = 0
	/// TRUE after setup() has been called and before finish_action() completes.
	var/running = FALSE
	/// world.time when perform() may next be called.
	var/next_perform_time = 0
	/// TRUE when the last perform() failed and we are waiting out next_perform_time to say we failed.
	var/failed_last_perform = FALSE
	/// TRUE while an async_perform() background action is running.
	var/async_running = FALSE
	/// BT_SUCCESS/BT_FAILURE reported by the finished background action.
	var/async_result = null
	/// Bumped on start/cancel so a stale background action is ignored.
	var/async_token = 0

/datum/bt_node/ai_behavior/has_active_descendants()
	return running

/datum/bt_node/ai_behavior/get_status_marker()
	if(running)
		return "*"
	return ..()

/**
 * Behavior leaf tick. Runs setup() once on first activation, then perform() each tick.
 * Respects per-controller cooldowns set by AI_BEHAVIOR_DELAY.
 * Returns BT_SUCCESS / BT_FAILURE on completion, BT_RUNNING while active.
 */
/datum/bt_node/ai_behavior/tick(datum/ai_controller/controller, seconds_per_tick)
	var/previous_execution_index = controller.ticking_execution_index
	controller.ticking_execution_index = execution_index

	if(next_perform_time > world.time)
		if(!running && failed_last_perform)
			controller.ticking_execution_index = previous_execution_index
			return BT_FAILURE
		controller.active_execution_index = execution_index
		controller.ticking_execution_index = previous_execution_index
		return BT_RUNNING

	if(!running)
		if(!setup(controller))
			controller.ticking_execution_index = previous_execution_index
			return BT_FAILURE
		running = TRUE

	// A background action finished between ticks: consume its result.
	if(!isnull(async_result))
		var/final_result = async_result
		async_result = null
		finish_action(controller, final_result == BT_SUCCESS)
		controller.ticking_execution_index = previous_execution_index
		return final_result
	if(async_running)
		if(!controller.cancelled_during_tick)
			controller.active_execution_index = execution_index
		controller.ticking_execution_index = previous_execution_index
		return BT_RUNNING

	var/process_flags = perform(seconds_per_tick, controller)

	if(process_flags & AI_BEHAVIOR_ASYNC)
		start_async(controller, seconds_per_tick)
		if(!controller.cancelled_during_tick)
			controller.active_execution_index = execution_index
		controller.ticking_execution_index = previous_execution_index
		return BT_RUNNING
	if(process_flags & AI_BEHAVIOR_DELAY)
		next_perform_time = world.time + get_cooldown(controller)
	if(process_flags & AI_BEHAVIOR_SUCCEEDED)
		failed_last_perform = FALSE
		finish_action(controller, TRUE)
		controller.ticking_execution_index = previous_execution_index
		return BT_SUCCESS
	if(process_flags & AI_BEHAVIOR_FAILED)
		failed_last_perform = TRUE
		finish_action(controller, FALSE)
		controller.ticking_execution_index = previous_execution_index
		return BT_FAILURE

	if(!controller.cancelled_during_tick)
		controller.active_execution_index = execution_index
	controller.ticking_execution_index = previous_execution_index
	return BT_RUNNING

/// Returns the cooldown to apply after an AI_BEHAVIOR_DELAY perform(). Override for conditional delays.
/datum/bt_node/ai_behavior/proc/get_cooldown(datum/ai_controller/controller)
	return time_between_perform

/// Called when this behavior first activates on a controller. Return FALSE to abort (returns BT_FAILURE).
/datum/bt_node/ai_behavior/proc/setup(datum/ai_controller/controller)
	return TRUE

/// Called each tick while the behavior is running. Returns AI_BEHAVIOR_* flags.
/datum/bt_node/ai_behavior/proc/perform(seconds_per_tick, datum/ai_controller/controller)
	SHOULD_NOT_SLEEP(TRUE)
	return AI_BEHAVIOR_INSTANT

/// Called when the behavior finishes (succeeded or failed). Subtypes should call ..().
/datum/bt_node/ai_behavior/proc/finish_action(datum/ai_controller/controller, succeeded)
	SHOULD_CALL_PARENT(TRUE)
	running = FALSE
	// Invalidate any in-flight background action; its result must not leak into
	// the next activation of this leaf.
	async_token++
	async_running = FALSE
	async_result = null

/// Override for actions that may sleep (do_after and friends). Runs in its own
/// background context; return AI_BEHAVIOR_SUCCEEDED/FAILED at the end.
/datum/bt_node/ai_behavior/proc/async_perform(seconds_per_tick, datum/ai_controller/controller)
	SHOULD_NOT_SLEEP(FALSE)
	return AI_BEHAVIOR_SUCCEEDED

/// Starts the background action for a leaf whose perform() returned
/// AI_BEHAVIOR_ASYNC.
/datum/bt_node/ai_behavior/proc/start_async(datum/ai_controller/controller, seconds_per_tick)
	async_running = TRUE
	async_result = null
	async_token++
	var/token = async_token
	spawn(0)
		run_async(controller, seconds_per_tick, token)

/datum/bt_node/ai_behavior/proc/run_async(datum/ai_controller/controller, seconds_per_tick, token)
	var/result = async_perform(seconds_per_tick, controller)
	if(QDELETED(src) || token != async_token)
		return
	async_running = FALSE
	async_result = (result & AI_BEHAVIOR_SUCCEEDED) ? BT_SUCCESS : BT_FAILURE

/datum/bt_node/ai_behavior/reset_tick_state()
	if(running)
		finish_action(owning_controller, FALSE)
	..()
