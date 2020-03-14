var/datum/subsystem/ticker/SSticker


/datum/subsystem/ticker
	name          = "Ticker"
	init_order    = SS_INIT_TICKER
	wait          = SS_WAIT_TICKER
	flags         = SS_KEEP_TIMING
	priority      = SS_PRIORITY_TICKER
	display_order = SS_DISPLAY_TICKER

	var/lastTickerTimeDuration
	var/lastTickerTime


/datum/subsystem/ticker/New()
	NEW_SS_GLOBAL(SSticker)


/datum/subsystem/ticker/Initialize(timeofday)
	lastTickerTime = world.timeofday

	if (!ticker)
		ticker = new

	spawn (0)
		if (ticker)
			ticker.pregame()

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
