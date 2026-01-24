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

// Gets the climate from a specified virtual z-level
/datum/subsystem/weather/proc/get_climate(var/datum/virtual_z/vz)
	for(var/datum/climate/C in climates)
		if(C.v == vz)
			return C
	return null

// Gets the climate from a specific turf
/datum/subsystem/weather/proc/get_climate_from_turf(var/turf/T)
	if(!T)
		return null
	var/datum/virtual_z/vz = T.get_virtual_z()
	if(!vz)
		return null
	return get_climate(vz)

// Sets a climate on a specific virtual z-level
/datum/subsystem/weather/proc/set_climate(var/datum/climate/climate_type, var/datum/virtual_z/vz = null, var/datum/zLevel/zLevel = null, var/random_start = FALSE)
	if(zLevel)
		if(!istype(zLevel))
			zLevel = map.zLevels[zLevel]
		vz = zLevel.virtual_z_levels[1]
	if(!vz)
		CRASH("Failed to set climate: virtual_z was null.")
	if(!climate_type)
		CRASH("Failed to set climate: climate_type was null.")
	var/datum/climate/C = new climate_type(vz,random_start)
	climates += C

	// Last remnant of hard-coding required to keep the snow falling in Snaxi
	var/list/turf/turfs = vz.get_turfs()
	if(turfs)
		for(var/turf/unsimulated/floor/snow/S in turfs)
			C.register_weather_turf(S)
	return C

// Restart a specific climate in case it gets corrupted
/datum/subsystem/weather/proc/restart_climate(var/datum/climate/C)
	if(!C || !istype(C))
		return FALSE

	var/climate_type = C.type
	var/datum/virtual_z/vz = C.v

	climates -= C

	C.clear_forecast()
	if(C.current_weather)
		qdel(C.current_weather)
	if(C.weather_image)
		for(var/turf/T in C.weather_turfs)
			T.vis_contents -= C.weather_image
		qdel(C.weather_image)
	qdel(C)

	var/datum/climate/new_climate = new climate_type(vz, FALSE)
	climates += new_climate

	var/list/turf/turfs = vz.get_turfs()
	if(!turfs)
		return FALSE
	for(var/turf/T in turfs)
		new_climate.register_weather_turf(T)

	return TRUE
