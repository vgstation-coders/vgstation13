/*
Usage:
	Override /start() to run your test code.
	Call fail() to fail the test (You should specify a reason).
	Use /New() and Destroy() for setup/teardown, respectively.
	You can use the run_loc_bottom_left and run_loc_top_right if your tests require turfs.
*/

var/datum/unit_test/current_test
var/unit_test_report = "Unit tests haven't been run yet."

/datum/unit_test
	//usable vars
	var/turf/run_loc_bottom_left
	var/turf/run_loc_top_right

	//internal vars
	var/succeeded = TRUE
	var/list/fail_reasons

/datum/unit_test/New()
	run_loc_bottom_left = locate(1, 1, 1)
	run_loc_top_right = locate(5, 5, 1)

/datum/unit_test/Destroy()
	//clear the test area
	for(var/atom/movable/AM in block(run_loc_bottom_left, run_loc_top_right))
		qdel(AM)
	..()

/datum/unit_test/proc/start()
	fail("run() called parent or not implemented")

/datum/unit_test/proc/fail(var/reason = "No reason provided")
	succeeded = FALSE

	if(!istext(reason))
		reason = "FORMATTED: [isnull(reason) ? "NULL" : "reason"]"

	if(!fail_reasons)
		fail_reasons = list()
	fail_reasons.Add(reason)

/proc/run_unit_tests()
	CHECK_TICK

	var/list/log_entries = list()

	for(var/I in subtypesof(/datum/unit_test))
		var/datum/unit_test/test = new I

		global.current_test = test
		var/duration = world.timeofday

		test.start()

		duration = world.timeofday - duration
		global.current_test = null

		var/list/log_entry = list("UNIT TEST [test.succeeded ? "PASS" : "FAIL"]: [I] [duration / 10]s")
		var/list/fail_reasons = test.fail_reasons

		qdel(test)

		for(var/J in 1 to length(fail_reasons))
			log_entry.Add("\tREASON #[J]: [fail_reasons[J]]")

		log_entries += log_entry
		world.log << log_entry.Join("\n")

		CHECK_TICK

	global.unit_test_report = "<pre>[html_encode(log_entries.Join("\n"))]</pre>"

	#if UNIT_TESTS_STOP_SERVER_WHEN_DONE == 1
	del(world)
	#endif

/client/proc/unit_test_panel()
	set category = "Debug"
	set name = "Unit test report"
	set desc = "Shows the log of unit tests."

	var/datum/browser/popup = new(usr, "\ref[global.unit_test_report]", "Unit test report", 800, 800)
	popup.set_content(global.unit_test_report)
	popup.open()
