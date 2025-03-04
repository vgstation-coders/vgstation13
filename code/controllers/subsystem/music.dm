var/datum/subsystem/music/SSmusic


/datum/subsystem/music
    name = "Music"
    wait = 1
    priority = SS_PRIORITY_MUSIC
    flags    = SS_NO_INIT | SS_KEEP_TIMING

    var/list/datum/musical_event/events = list()

/datum/subsystem/music/New()
	NEW_SS_GLOBAL(SSmusic)

/datum/subsystem/music/fire(resumed = FALSE)
    if (isemptylist(events))
        return
    var/list/datum/musical_event/left_events = list()
    for (var/datum/musical_event/event in events)
        event.time -= wait
        if (event.time <= 0)
            event.tick()
        else
            left_events += event
    events = left_events

/datum/subsystem/music/proc/push_event(datum/sound_player/source, mob/subject, sound/object, time, volume)
	if (istype(source) && istype(subject) && istype(object) && volume >= 0 && volume <= 100)
		events += new /datum/musical_event(source, subject, object, time, volume)
	
/datum/subsystem/music/proc/is_overloaded()
	return events.len > global.musical_config.max_events