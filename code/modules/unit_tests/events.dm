/event/demo_event
/datum/unit_test
	var/did_something = FALSE
/datum/unit_test/event_does_stuff/start()
	var/datum/demo_datum = new
	demo_datum.register_event(/event/demo_event, src, nameof(src::do_something()))
	INVOKE_EVENT(demo_datum, /event/demo_event)
	if(!did_something)
		fail("lazy event did nothing")
/datum/unit_test/event_does_stuff/proc/do_something()
	did_something = TRUE

/datum/unit_test/event_cleanup/start()
	var/datum/demo_datum = new
	if(!isnull(demo_datum.registered_events))
		fail("registered_events is not null by default")
	demo_datum.register_event(/event/demo_event, src, nameof(src::do_nothing()))
	assert_eq(demo_datum.registered_events.len, 1)
	assert_eq(demo_datum.registered_events[/event/demo_event].len, 1)
	demo_datum.unregister_event(/event/demo_event, src, nameof(src::do_nothing()))
	if(!isnull(demo_datum.registered_events))
		fail("registered_events is not null after removing the last handler")
/datum/unit_test/event_cleanup/proc/do_nothing()

/datum/unit_test/event_arguments/start()
	var/datum/demo_datum = new
	demo_datum.register_event(/event/demo_event, src, nameof(src::do_stuff_with_args()))
	INVOKE_EVENT(demo_datum, /event/demo_event, "abc", 123)
	demo_datum.unregister_event(/event/demo_event, src, nameof(src::do_stuff_with_args()))

	demo_datum.register_event(/event/demo_event, src, nameof(src::do_something_with_named_args()))
	INVOKE_EVENT(demo_datum, /event/demo_event, "second_parameter"=1)
/datum/unit_test/event_arguments/proc/do_stuff_with_args(string, number)
	assert_eq(string, "abc")
	assert_eq(number, 123)
/datum/unit_test/event_arguments/proc/do_something_with_named_args(first_parameter, second_parameter)
	assert_eq(first_parameter, null)
	assert_eq(second_parameter, 1)
