/lazy_event/demo_event
/datum/unit_test
	var/did_something = FALSE
/datum/unit_test/lazy_event_does_stuff/start()
	var/datum/demo_datum = new
	demo_datum.lazy_register_event(/lazy_event/demo_event, src, .proc/do_something)
	demo_datum.lazy_invoke_event(/lazy_event/demo_event)
	if(!did_something)
		fail("lazy event did nothing")
/datum/unit_test/lazy_event_does_stuff/proc/do_something()
	did_something = TRUE

/datum/unit_test/lazy_event_cleanup/start()
	var/datum/demo_datum = new
	if(!isnull(demo_datum.registered_events))
		fail("registered_events is not null by default")
	demo_datum.lazy_register_event(/lazy_event/demo_event, src, .proc/do_nothing)
	assert_eq(demo_datum.registered_events.len, 1)
	assert_eq(demo_datum.registered_events[/lazy_event/demo_event].len, 1)
	demo_datum.lazy_unregister_event(/lazy_event/demo_event, src, .proc/do_nothing)
	if(!isnull(demo_datum.registered_events))
		fail("registered_events is not null after removing the last handler")
/datum/unit_test/lazy_event_cleanup/proc/do_nothing()

/datum/unit_test/lazy_event_arguments/start()
	var/datum/demo_datum = new
	demo_datum.lazy_register_event(/lazy_event/demo_event, src, .proc/do_stuff_with_args)
	demo_datum.lazy_invoke_event(/lazy_event/demo_event, list("abc", 123))
	demo_datum.lazy_unregister_event(/lazy_event/demo_event, src, .proc/do_stuff_with_args)

	demo_datum.lazy_register_event(/lazy_event/demo_event, src, .proc/do_something_with_named_args)
	demo_datum.lazy_invoke_event(/lazy_event/demo_event, list("second_parameter"=1))
/datum/unit_test/lazy_event_arguments/proc/do_stuff_with_args(string, number)
	assert_eq(string, "abc")
	assert_eq(number, 123)
/datum/unit_test/lazy_event_arguments/proc/do_something_with_named_args(first_parameter, second_parameter)
	assert_eq(first_parameter, null)
	assert_eq(second_parameter, 1)
