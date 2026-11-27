// Test-only behavior tree nodes. These are used by the auxtools scenario while
// the real basic mob behaviors are being ported; remove once unit tests cover
// the tree with real behaviors.

/datum/bt_node/ai_behavior/test
	var/setup_calls = 0
	var/perform_calls = 0
	var/finish_calls = 0

/datum/bt_node/ai_behavior/test/setup(datum/ai_controller/controller)
	setup_calls++
	return ..()

/datum/bt_node/ai_behavior/test/finish_action(datum/ai_controller/controller, succeeded)
	finish_calls++
	return ..()

/datum/bt_node/ai_behavior/test/succeed
/datum/bt_node/ai_behavior/test/succeed/perform(seconds_per_tick, datum/ai_controller/controller)
	perform_calls++
	return AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/test/fail
/datum/bt_node/ai_behavior/test/fail/perform(seconds_per_tick, datum/ai_controller/controller)
	perform_calls++
	return AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/test/running_once
	/// Number of perform() calls that return BT_RUNNING before succeeding.
	var/ticks_to_run = 1

/datum/bt_node/ai_behavior/test/running_once/perform(seconds_per_tick, datum/ai_controller/controller)
	perform_calls++
	if(ticks_to_run > 0)
		ticks_to_run--
		return AI_BEHAVIOR_INSTANT
	return AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/decorator/test_condition
	var/condition_result = TRUE

/datum/bt_node/decorator/test_condition/check_condition(datum/ai_controller/controller)
	return condition_result
