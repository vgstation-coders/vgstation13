var/datum/subsystem/weather/SSweather
var/list/climates = list()
var/list/precip_state_to_texture = list()

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

/datum/subsystem/weather/proc/get_climate(var/z, var/datum/allocation/A = null)
	// Try to find exact match (z-level and allocation)
	for(var/datum/climate/C in climates)
		if(C.z == z)
			if(A && C.allocation == A)
				return C
			else if(!A && !C.allocation)
				return C
	// No exact match found - return null
	return null

// Set the climate for a specific z-level. Uses an allocation if provided.
/datum/subsystem/weather/proc/set_climate(var/datum/climate/climate_type, var/z = 1, var/datum/allocation/A = null)
	if(A)
		z = A.z
	if(!climate_type)
		CRASH("Failed to set climate: climate_type was null.")
	var/datum/climate/C = new climate_type(z,A)
	climates += C

	// Register existing snow turfs from this z-level/allocation with the climate
	for(var/turf/unsimulated/floor/snow/S in global_snowtiles)
		if(S.z == z)
			var/datum/allocation/turf_alloc = SSmapping.get_allocation(trf = S)
			// Only register if allocation matches (or both are null)
			if(A == turf_alloc)
				C.register_snow_turf(S)

	return C
