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

/datum/climate/New()
	..()
	if(current_weather)
		forecast()
	else
		WARNING("Climate tried to forecast without a starting weather.")
		message_admins("Climate tried to forecast without a starting weather.")

/datum/climate/proc/forecast()
	var/cycle = 1
	clear_forecast()
	forecasts = list(current_weather) //project based on current weather
	while(forecasts.len <= PREDICTION_MINIMUM+1 && cycle <= PREDICTION_MAXIMUM)
		var/datum/weather/W = forecasts[forecasts.len]
		var/path = pickweight(W.next_weather)
		if(path == W.type)
			W.timeleft += round(rand(cycle_freq[1],cycle_freq[2]),SS_WAIT_WEATHER)
		else
			var/datum/weather/future = new path(src)
			forecasts += future
		if(W.next_weather.len == 1)
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
		change_weather(forecasts[1])
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
		var/weathers = current_weather.next_weather.len
		if(weathers == 1)
			return CANNOT_CHANGE
		var/preferred_weather
		if(direction == INTENSIFY)
			preferred_weather = current_weather.next_weather[weathers] //the last value
		else if(direction == ABATE)
			preferred_weather = current_weather.next_weather[1] //the first value
		if(preferred_weather == current_weather.type)
			return FALSE
		current_weather.timeleft = min(1 MINUTES, current_weather.timeleft)
		current_weather.next_weather.Cut()
		current_weather.next_weather[preferred_weather] = 100
		forecast()
		return TRUE

/datum/climate/proc/change_weather(weather)
	if(ispath(weather))
		//We have been provided a path. Let's see if it's identical to the one we have.
		if(ispath(weather, current_weather.type)) //This is a separate check so that we can have our warning work.
			return //No need to change, this is our current type.
		else
			qdel(current_weather)
			current_weather = new weather(src)
			current_weather.execute()

	else if(istype(weather,/datum/weather))
		//We have been given a specific weather datum. It may be modified, so run it no matter what.
		qdel(current_weather)
		current_weather = weather
		current_weather.execute()

	else
		WARNING("Change weather was called with [weather], neither a weather datum nor a path.")

/datum/climate/arctic
	name = "snow" //what scoreboard displays
	//some day this may not be the norm

/datum/climate/arctic/New()
	current_weather = new /datum/weather/snow/calm(src)
	..()

///////////////////////////////////  WEATHER DATUMS //////////////////////////////

/datum/weather
	var/name = "weather"
	var/list/next_weather = list() //associative list
	//for next_weather, order matters: put in order of weather intensity, so that step() will work
	//only one in list means it can't be changed by the weather control device
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
var/list/snow_state_to_texture = list()
var/snowtiles_setup = 0 //has the blizzard parent been initialized?

/datum/weather/snow
	var/snow_intensity = SNOW_CALM
	var/tile_interval = 5
	var/snowfall_prob = 0
	var/snowfall_rate = list(0,0)
	var/snow_fluff_estimate = "snowing"

/datum/weather/snow/execute()
	for(var/obj/machinery/teleport/hub/emergency/E in machines)
		E.alarm(!(snow_intensity % SNOW_BLIZZARD))
		//sends 1 if snow_intensity equals blizzard exactly, otherwise sends 0
	for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
		if(tile.ignore_blizzard_updates)
			continue
		tile.snow_state = snow_intensity
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
			if(tile.snowprint_parent)
				tile.snowprint_parent.ClearSnowprints()
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
	next_weather = list(/datum/weather/snow/calm = 60, /datum/weather/snow/light = 40)
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
	next_weather = list(/datum/weather/snow/calm = 25, /datum/weather/snow/light = 55, /datum/weather/snow/heavy = 20)
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
	next_weather = list(/datum/weather/snow/light = 30, /datum/weather/snow/heavy = 60, /datum/weather/snow/blizzard = 10)
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
	next_weather = list(/datum/weather/snow/heavy = 65, /datum/weather/snow/blizzard = 35)
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

datum/weather/snow/blizzard/omega
	name = "<font color='purple'>dark season</font>"
	next_weather = list(/datum/weather/snow/heavy = 100)
	snowfall_prob = 15
	snow_fluff_estimate = "<font color='purple'>more than 13.5cm/minute (Dark Season)</font>"

datum/weather/snow/blizzard/omega/New()
	..()
	timeleft = 2 HOURS