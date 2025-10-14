var/datum/subsystem/weather/SSweather
var/list/climates = list()
var/list/precip_state_to_texture = list()

/datum/subsystem/weather
	name          = "Weather"
	wait          = SS_WAIT_WEATHER
	flags         = SS_NO_INIT | SS_KEEP_TIMING
	priority      = SS_PRIORITY_WEATHER
	display_order = SS_DISPLAY_WEATHER

/datum/subsystem/weather/New()
	NEW_SS_GLOBAL(SSweather)

/datum/subsystem/weather/fire(resumed = FALSE)
	if(!climates.len)
		return

	for(var/datum/climate/C in climates)
		C.tick()

/datum/subsystem/weather/proc/get_climate(var/z, var/datum/allocation/A = null)
	// Try to find exact match (z-level and allocation)
	for(var/datum/climate/C in climates)
		if(C.z == z)
			if(A && C.allocation == A)
				return C
			else if(!A && !C.allocation)
				return C
	return null

// Get the climate for a specific turf by checking its allocation or z-level
/datum/subsystem/weather/proc/get_climate_from_turf(var/turf/T)
	if(!T)
		return null

	var/datum/allocation/A = SSmapping.get_allocation(trf = T)
	if(A)
		return get_climate(T.z, A)
	else
		return get_climate(T.z)

// Set the climate for a specific z-level. Uses an allocation if provided.
/datum/subsystem/weather/proc/set_climate(var/datum/climate/climate_type, var/z = 1, var/datum/allocation/A = null, var/random_start = FALSE)
	if(A)
		z = A.z
	if(!climate_type)
		CRASH("Failed to set climate: climate_type was null.")
	var/datum/climate/C = new climate_type(z,A,random_start)
	climates += C

	// Retroactively register turfs that were created before the climate system
	// This handles legacy maps where turfs exist before climate is set up
	if(A && A.turfs)
		// Use allocation's turfs list for procedurally generated planets
		for(var/turf/unsimulated/floor/snow/S in A.turfs)
			C.register_weather_turf(S)
	else
		// For legacy maps without allocations, scan the z-level
		for(var/turf/unsimulated/floor/snow/S in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			C.register_weather_turf(S)

	return C
