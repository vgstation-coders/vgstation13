var/datum/subsystem/weather/SSweather
var/list/climates = list()

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
	if(climates.len)
		for(var/datum/climate/C in climates)
			C.tick()
	else
		flags |= SS_NO_FIRE
		pause()
		message_admins("Weather subsystem was paused due to lack of climate.")

/datum/subsystem/weather/proc/get_climate(var/z)
	for(var/datum/climate/C in climates)
		if(C.z == z)
			return C
	if(climates?.len)
		return climates[1] //failsafe
	else
		return null //even more powerful failsave

/datum/subsystem/weather/proc/set_climate(var/datum/climate/climate_type, var/z = 1)
	if(!climate_type)
		CRASH("Failed to set climate: climate_type was null.")
	var/datum/climate/C = new climate_type(z)
	climates += C
