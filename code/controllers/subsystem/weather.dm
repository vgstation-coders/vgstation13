var/datum/subsystem/weather/SSweather


/datum/subsystem/weather
	name          = "weather"
	wait          = SS_WAIT_WEATHER
	flags         = SS_NO_INIT | SS_KEEP_TIMING
	priority      = SS_PRIORITY_WEATHER
	display_order = SS_DISPLAY_WEATHER


/datum/subsystem/weather/New()
	NEW_SS_GLOBAL(SSweather)

/datum/subsystem/weather/fire(resumed = FALSE)
	if(flags & SS_NO_FIRE)
		return
	if(map.climate)
		var/datum/climate/C = map.climate
		C.tick()
	else
		flags |= SS_NO_FIRE
		pause()
		message_admins("Weather subsystem was paused due to lack of climate.")
