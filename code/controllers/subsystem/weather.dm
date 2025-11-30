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

// Restart a specific climate in case it gets corrupted
/datum/subsystem/weather/proc/restart_climate(var/datum/climate/C)
	if(!C || !istype(C))
		return FALSE

	var/climate_type = C.type
	var/climate_z = C.z
	var/datum/allocation/climate_allocation = C.allocation

	climates -= C

	C.clear_forecast()
	if(C.current_weather)
		qdel(C.current_weather)
	if(C.weather_image)
		for(var/turf/T in C.weather_turfs)
			T.vis_contents -= C.weather_image
		qdel(C.weather_image)
	qdel(C)

	var/datum/climate/new_climate = new climate_type(climate_z, climate_allocation, FALSE)
	climates += new_climate

	if(climate_allocation && climate_allocation.turfs)
		for(var/turf/unsimulated/floor/snow/S in climate_allocation.turfs)
			new_climate.register_weather_turf(S)
	else
		for(var/turf/unsimulated/floor/snow/S in block(locate(1, 1, climate_z), locate(world.maxx, world.maxy, climate_z)))
			new_climate.register_weather_turf(S)

	return TRUE
