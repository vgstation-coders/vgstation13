/********************************************
*                IN THIS FILE               *
*          Climate Datum, Weather Datum     *
*                                           *
********************************************/

#define PREDICTION_MINIMUM 4 //minimum number of forecast entries, counts separate weather entries indifferent to their length
#define PREDICTION_MAXIMUM 10 //maximum attempts we will try to forecast, this matters because the same weather might get rolled repeatedly
//this is important because if the next forecasted weather is the same as the one before it, it just adds to the first's timer instead
//Forecast will stay unchanged until there are less than PREDICTION_MINIMUM weathers, at which point it will make a new forecast
//Every forecast is freshly generated, which means forecasts change!

#define INTENSIFY 1
#define ABATE -1

var/list/weathertracker = list() //associative list, gathers time spent one each weather for scoreboard

/datum/climate
	var/name = "climate"
	var/datum/weather/current_weather
	var/list/datum/weather/forecasts = list()
	var/cycle_freq = list(3 MINUTES,6 MINUTES) //shortest possible time, longest possible time until next weather
	var/z //z-level the climate is occupying
	var/list/allowed_weather_types = list() // List of weather types this climate can have
	var/list/weather_transitions = list() // Associative list: weather_type = list(possible_transitions)
	var/list/weather_intensities = list() // Associative list: weather_type = intensity_level
	var/starting_weather_type = null // The initial weather type for this climate

/datum/climate/New(var/active_z)
	..()
	if(active_z)
		z = active_z
	else
		z = map.zMainStation
	setup_weather_system()
	if(starting_weather_type)
		current_weather = new starting_weather_type(src)
		forecast()
	else
		WARNING("Climate tried to forecast without a starting weather.")
		message_admins("Climate tried to forecast without a starting weather.")

// Override this in climate subtypes to define the weather system
/datum/climate/proc/setup_weather_system()
	return

/datum/climate/proc/forecast()
	var/cycle = 1
	clear_forecast()
	forecasts = list(current_weather) //project based on current weather
	while(forecasts.len <= PREDICTION_MINIMUM+1 && cycle <= PREDICTION_MAXIMUM)
		var/datum/weather/W = forecasts[forecasts.len]
		var/list/possible_transitions = weather_transitions[W.type]
		if(!possible_transitions || !possible_transitions.len)
			break //No further transitions possible
		var/path = pickweight(possible_transitions)
		if(path == W.type)
			W.timeleft += round(rand(cycle_freq[1],cycle_freq[2]),SS_WAIT_WEATHER)
		else
			var/datum/weather/future = new path(src)
			forecasts += future
		if(possible_transitions.len == 1)
			break //Forecast no further.
		cycle++
	forecasts -= current_weather //remove it from our future weather

/datum/climate/proc/clear_forecast()
	while(forecasts.len)
		var/datum/weather/W = forecasts[1]
		forecasts -= W
		qdel(W)

/datum/climate/proc/tick()
	if(!current_weather)
		return
	current_weather.tick()
	if(current_weather.timeleft <= 0)
		change_weather(forecasts[1],force = TRUE)
		forecasts -= forecasts[1]
	if(forecasts.len < PREDICTION_MINIMUM)
		forecast()

#define INVALID_STEP -1
#define CANNOT_CHANGE -2
//step -1 to go down a step, 1 to go up a step
/datum/climate/proc/weather_shift(var/direction = INTENSIFY)
	if(direction**2 != 1)
		return INVALID_STEP //must be 1 or -1
	if(current_weather)
		var/current_intensity = weather_intensities[current_weather.type]
		if(isnull(current_intensity))
			return CANNOT_CHANGE
		var/target_intensity = current_intensity + direction
		var/preferred_weather = null
		for(var/weather_type in allowed_weather_types)
			if(weather_intensities[weather_type] == target_intensity)
				var/list/possible_transitions = weather_transitions[current_weather.type]
				if(possible_transitions && (weather_type in possible_transitions))
					preferred_weather = weather_type
					break
		if(!preferred_weather)
			return CANNOT_CHANGE
		if(preferred_weather == current_weather.type)
			return FALSE
		current_weather.timeleft = min(1 MINUTES, current_weather.timeleft)
		var/list/old_transitions = weather_transitions[current_weather.type]
		weather_transitions[current_weather.type] = list()
		weather_transitions[current_weather.type][preferred_weather] = 100
		forecast()
		weather_transitions[current_weather.type] = old_transitions
		return TRUE

/datum/climate/proc/change_weather(weather, force = FALSE)
	if(ispath(weather))
		//We have been provided a path. Let's see if it's identical to the one we have.
		if(ispath(weather, current_weather.type)) //This is a separate check so that we can have our warning work.
			return //No need to change, this is our current type.
		else
			if(force)
				qdel(current_weather)
				current_weather = new weather(src)
				current_weather.execute()
			else
				weather_transitions[current_weather.type] = list(weather = 100)

	else if(istype(weather,/datum/weather))
		//We have been given a specific weather datum. It may be modified, so run it no matter what.
		if(force)
			qdel(current_weather)
			current_weather = weather
			current_weather.execute()
		else
			var/datum/weather/W = weather
			weather_transitions[current_weather.type] = list(W.type = 100)

	else
		WARNING("Change weather was called with [weather], neither a weather datum nor a path.")

/datum/climate/arctic
	name = "snow" //what scoreboard displays

	starting_weather_type = /datum/weather/snow/calm
	allowed_weather_types = list(
		/datum/weather/snow/calm,
		/datum/weather/snow/light,
		/datum/weather/snow/heavy,
		/datum/weather/snow/blizzard,
		/datum/weather/snow/blizzard/omega
	)
	weather_intensities = list(
		/datum/weather/snow/calm = 0,
		/datum/weather/snow/light = 1,
		/datum/weather/snow/heavy = 2,
		/datum/weather/snow/blizzard = 3,
		/datum/weather/snow/blizzard/omega = 4
	)
	weather_transitions = list(
		/datum/weather/snow/calm = list(
			/datum/weather/snow/calm = 60,
			/datum/weather/snow/light = 40
		),
		/datum/weather/snow/light = list(
			/datum/weather/snow/calm = 25,
			/datum/weather/snow/light = 55,
			/datum/weather/snow/heavy = 20
		),
		/datum/weather/snow/heavy = list(
			/datum/weather/snow/light = 30,
			/datum/weather/snow/heavy = 60,
			/datum/weather/snow/blizzard = 10
		),
		/datum/weather/snow/blizzard = list(
			/datum/weather/snow/heavy = 65,
			/datum/weather/snow/blizzard = 35
		),
		/datum/weather/snow/blizzard/omega = list(
			/datum/weather/snow/heavy = 100
		)
	)

/datum/climate/arctic/New()
	..()
	if(!blizzard_image)
		blizzard_image = new(src)
	blizzard_image.UpdateSnowfall(SNOW_CALM)

///////////////////////////////////  WEATHER DATUMS //////////////////////////////
/datum/weather
	var/name = "weather"
	var/timeleft = 1
	var/datum/climate/parent
	var/temperature = T20C

/datum/weather/New(var/datum/climate/C)
	parent = C
	timeleft = round(rand(parent.cycle_freq[1],parent.cycle_freq[2]),SS_WAIT_WEATHER)
	//round to 2 seconds, since that's how often we check in

/datum/weather/proc/execute()

/datum/weather/proc/tick()
	timeleft -= SS_WAIT_WEATHER
	weathertracker[name] += SS_WAIT_WEATHER

var/list/global_snowtiles = list()
var/list/environment_snowtiles = list()
var/list/snow_state_to_texture = list()

/datum/weather/proc/weather_details()
	return //additional info to report to the climate computer

/datum/weather/snow
	var/snow_intensity = SNOW_CALM
	var/tile_interval = 5
	var/snowfall_prob = 0
	var/snowfall_rate = list(0,0)
	var/snow_fluff_estimate = "snowing"

/datum/weather/snow/weather_details()
	return "<b>Snowfall:</b> <div class='line'>[snow_fluff_estimate] </div>"

var/obj/effect/blizzard_holder/blizzard_image = null

/datum/weather/snow/New(var/datum/climate/C)
	..()

/datum/weather/snow/execute()
	for(var/obj/machinery/teleport/hub/emergency/E in machines)
		E.alarm(!(snow_intensity % SNOW_BLIZZARD))
		//sends 1 if snow_intensity equals blizzard exactly, otherwise sends 0
	blizzard_image.UpdateSnowfall(snow_intensity)
	for(var/turf/unsimulated/floor/snow/tile in environment_snowtiles)
		tile.update_environment()
	force_update_snowfall_sfx()

/datum/weather/snow/tick()
	..()
	if(!prob(snowfall_prob))
		return
	var/i = rand(1,tile_interval)
	for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
		if(i == tile_interval)
			tile.change_snowballs(snowfall_rate[1],snowfall_rate[2])
			tile.ClearSnowprints()
			i = 1
		else
			i++

var/list/snowstorm_ambience = list('sound/misc/snowstorm/snowfall_calm.ogg','sound/misc/snowstorm/snowfall_average.ogg','sound/misc/snowstorm/snowfall_hard.ogg','sound/misc/snowstorm/snowfall_blizzard.ogg')
var/list/snowstorm_ambience_volumes = list(30,40,60,80)
/datum/weather/snow/proc/force_update_snowfall_sfx() //Since the vision blocking UI only updates on Entered, let's call it.
	for(var/mob/M in player_list)
		if(M && M.client)
			var/turf/unsimulated/floor/snow/snow = get_turf(M)
			if(snow && istype(snow))
				snow.Entered(M)
				M << sound(snowstorm_ambience[snow_intensity+1], repeat = 1, wait = 0, channel = CHANNEL_WEATHER, volume = snowstorm_ambience_volumes[snow_intensity+1])

//////////////////////// SNOW SUBTYPES ////////////////////////

/datum/weather/snow/calm
	name = "calm"
	snow_intensity = SNOW_CALM
	snowfall_prob = 3
	snowfall_rate = list(-1,0)
	temperature = T_ARCTIC
	snow_fluff_estimate = "minimal"

/datum/weather/snow/calm/execute()
	..()
	research_shuttle.lockdown = FALSE //note: blob can't happen on this map
	mining_shuttle.lockdown = FALSE
	security_shuttle.lockdown = FALSE

/datum/weather/snow/light
	name = "light"
	snow_intensity = SNOW_AVERAGE
	snowfall_prob = 5
	snowfall_rate = list(1,8)
	temperature = T_ARCTIC - 5
	snow_fluff_estimate = "about 1.5cm/minute (light)"

/datum/weather/snow/light/execute()
	..()
	research_shuttle.lockdown = FALSE
	mining_shuttle.lockdown = FALSE
	security_shuttle.lockdown = FALSE

/datum/weather/snow/heavy
	name = "<font color='orange'>heavy</font>"
	snow_intensity = SNOW_HARD
	snowfall_prob = 8
	snowfall_rate = list(2,15)
	temperature = T_ARCTIC - 10
	snow_fluff_estimate = "<font color='orange'>about 4.8cm/minute (heavy)</font>"

/datum/weather/snow/heavy/execute()
	..()
	research_shuttle.lockdown = FALSE
	mining_shuttle.lockdown = FALSE
	security_shuttle.lockdown = FALSE

/datum/weather/snow/blizzard
	name = "<font color='red'>blizzard</font>"
	snow_intensity = SNOW_BLIZZARD
	tile_interval = 3
	snowfall_prob = 12
	snowfall_rate = list(3,20)
	temperature = T_ARCTIC - 20
	snow_fluff_estimate = "<font color='red'>about 10.8cm/minute (ALERT)</font>"

/datum/weather/snow/blizzard/execute()
	..()
	research_shuttle.lockdown = "Under directive 1-49, surface-to-space light craft have been locked for duration of blizzard. Only escape-class shuttles are rated for stability in blizzards."
	mining_shuttle.lockdown = "Under directive 1-49, surface-to-space light craft have been locked for duration of blizzard. Only escape-class shuttles are rated for stability in blizzards."
	security_shuttle.lockdown = "Under directive 1-49, surface-to-space light craft have been locked for duration of blizzard. Only escape-class shuttles are rated for stability in blizzards."

/datum/weather/snow/blizzard/omega
	name = "<font color='purple'>dark season</font>"
	snowfall_prob = 15
	snow_fluff_estimate = "<font color='purple'>more than 13.5cm/minute (Dark Season)</font>"

/datum/weather/snow/blizzard/omega/New()
	..()
	timeleft = 2 HOURS
