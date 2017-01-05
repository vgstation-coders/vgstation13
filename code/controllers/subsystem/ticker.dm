var/datum/subsystem/ticker/SSticker


/datum/subsystem/ticker
	name = "Ticker"
	init_order = INIT_TICKER
	wait = 2 SECONDS

	var/lastTickerTimeDuration
	var/lastTickerTime
	var/initialized = FALSE

/datum/subsystem/ticker/New()
	NEW_SS_GLOBAL(SSticker)


/datum/subsystem/ticker/Initialize(timeofday)
	lastTickerTime = world.timeofday

	if (!ticker)
		ticker = new

	spawn (0)
		if (ticker)
			ticker.pregame()

	initialized = TRUE

	..()


/datum/subsystem/ticker/fire(resumed = FALSE)
	var/currentTime = world.timeofday

	if(currentTime < lastTickerTime) // check for midnight rollover
		lastTickerTimeDuration = (currentTime - (lastTickerTime - TICKS_IN_DAY)) / TICKS_IN_SECOND
	else
		lastTickerTimeDuration = (currentTime - lastTickerTime) / TICKS_IN_SECOND

	lastTickerTime = currentTime

	ticker.process()


/datum/subsystem/ticker/proc/getLastTickerTimeDuration()
	return lastTickerTimeDuration
