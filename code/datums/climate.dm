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
	var/datum/allocation/allocation //the allocation this climate belongs to
	var/list/allowed_weather_types = list() // List of weather types this climate can have
	var/list/weather_transitions = list() // Associative list: weather_type = list(possible_transitions)
	var/list/weather_intensities = list() // Associative list: weather_type = intensity_level
	var/starting_weather_type = null // The initial weather type for this climate
	var/weather_image_type = /obj/effect/weather_holder // The type of weather holder this climate uses
	var/obj/effect/weather_holder/weather_image = null // The weather holder object for this climate
	var/list/weather_turfs = list() // All turfs affected by this climate (includes snow turfs and other outdoor turfs)

/datum/climate/New(var/active_z,var/datum/allocation/A = null,var/random_starting_weather = FALSE)
	..()
	if(active_z)
		z = active_z
	else
		z = map.zMainStation
	if(A)
		allocation = A
	setup_weather_system()
	if(random_starting_weather)
		starting_weather_type = pick(allowed_weather_types)
	if(starting_weather_type)
		current_weather = new starting_weather_type(src)
		forecast()
	else
		WARNING("Climate tried to forecast without a starting weather.")
		message_admins("Climate tried to forecast without a starting weather.")
	if(!weather_image_type)
		return
	if(!weather_image)
		weather_image = new weather_image_type(src)
	if(current_weather)
		weather_image.UpdatePrecipitation(current_weather.precip_intensity)
	else
		weather_image.UpdatePrecipitation(WEATHER_CALM)

// Register any outdoor turf with this climate (generalized for all weather types)
/datum/climate/proc/register_weather_turf(var/turf/T,var/force = FALSE)
	if(!T)
		return
	if(!force)
		if(!isopensurface(T.loc))
			if(T in weather_turfs)
				weather_turfs -= T
			return
	weather_turfs |= T
	if(weather_image)
		T.vis_contents |= weather_image

// Unregister an outdoor turf from this climate
/datum/climate/proc/unregister_weather_turf(var/turf/T)
	if(!T)
		return
	weather_turfs -= T
	if(weather_image && (weather_image in T.vis_contents))
		T.vis_contents -= weather_image

// Override this in climate subtypes to define the weather system
/datum/climate/proc/setup_weather_system()
	return

/datum/climate/proc/forecast()
	if(!current_weather)
		CRASH("Forecast called with null current_weather on [src]")
	if(!istype(current_weather, /datum/weather))
		CRASH("Forecast called with invalid current_weather ([current_weather]) on [src] - expected weather instance, got [current_weather.type]")

	// Validate that current weather type has transitions defined
	if(!(current_weather.type in weather_transitions))
		CRASH("Forecast called but current weather type [current_weather.type] not found in weather_transitions for [src]")

	var/cycle = 1
	clear_forecast()
	forecasts = list(current_weather) //project based on current weather
	while(forecasts.len <= PREDICTION_MINIMUM+1 && cycle <= PREDICTION_MAXIMUM)
		var/datum/weather/W = forecasts[forecasts.len]
		if(!istype(W, /datum/weather))
			CRASH("Forecast found invalid weather in forecasts list: [W]")
		var/list/possible_transitions = weather_transitions[W.type]
		if(!possible_transitions || !possible_transitions.len)
			break //No further transitions possible
		var/path = pickweight(possible_transitions)
		if(isnull(path))
			CRASH("Forecast got null path from pickweight for weather type [W.type] - transitions: [json_encode(possible_transitions)]")
		if(!ispath(path, /datum/weather))
			CRASH("Forecast got invalid path [path] from pickweight for weather type [W.type] - expected weather type path")
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

// Get the planet associated with this climate's allocation
/datum/climate/proc/get_planet()
	if(!allocation)
		return null
	for(var/datum/planet_type/planet in SSmapping.planets)
		if(planet.allocation == allocation)
			return planet
	return null

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
		if(weather == current_weather.type) //This is a separate check so that we can have our warning work.
			return //No need to change, this is our current type.
		else
			if(force)
				if(current_weather)
					current_weather.stop_weather_sounds()
				qdel(current_weather)
				current_weather = new weather(src)
				current_weather.execute()
				current_weather.update_weather_sounds()
			else
				weather_transitions[current_weather.type] = list()
				weather_transitions[current_weather.type][weather] = 100

	else if(istype(weather,/datum/weather))
		//We have been given a specific weather datum. It may be modified, so run it no matter what.
		if(force)
			if(current_weather)
				current_weather.stop_weather_sounds()
			qdel(current_weather)
			current_weather = weather
			current_weather.execute()
		else
			var/datum/weather/W = weather
			weather_transitions[current_weather.type] = list()
			weather_transitions[current_weather.type][W.type] = 100

	else
		WARNING("Change weather was called with [weather], neither a weather datum nor a path.")

/datum/climate/arctic
	name = "snow" //what scoreboard displays

	starting_weather_type = /datum/weather/snow/calm
	weather_image_type = /obj/effect/weather_holder/blizzard
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

/datum/climate/temperate
	name = "temperate"
	starting_weather_type = /datum/weather/standard
	weather_image_type = /obj/effect/weather_holder/temperate
	allowed_weather_types = list(
		/datum/weather/standard,
		/datum/weather/cloudy,
		/datum/weather/cloudy/rain,
		/datum/weather/cloudy/rain/heavy,
		/datum/weather/cloudy/storm,
	)
	weather_intensities = list(
		/datum/weather/standard = 0,
		/datum/weather/cloudy = 1,
		/datum/weather/cloudy/rain = 2,
		/datum/weather/cloudy/rain/heavy = 3,
		/datum/weather/cloudy/storm = 4,
	)
	weather_transitions = list(
		/datum/weather/standard = list(
			/datum/weather/standard = 60,
			/datum/weather/cloudy = 40,
		),
		/datum/weather/cloudy = list(
			/datum/weather/standard = 30,
			/datum/weather/cloudy = 40,
			/datum/weather/cloudy/rain = 30
		),
		/datum/weather/cloudy/rain = list(
			/datum/weather/cloudy = 30,
			/datum/weather/cloudy/rain = 40,
			/datum/weather/cloudy/rain/heavy = 30
		),
		/datum/weather/cloudy/rain/heavy = list(
			/datum/weather/cloudy/rain = 40,
			/datum/weather/cloudy/rain/heavy = 30,
			/datum/weather/cloudy/storm = 30
		),
		/datum/weather/cloudy/storm = list(
			/datum/weather/cloudy/rain/heavy = 70,
			/datum/weather/cloudy/storm = 30
		)
	)

/datum/climate/tropical
	name = "tropical"
	starting_weather_type = /datum/weather/standard
	weather_image_type = /obj/effect/weather_holder/tropical
	allowed_weather_types = list(
		/datum/weather/standard,
		/datum/weather/cloudy,
		/datum/weather/cloudy/rain,
		/datum/weather/cloudy/storm,
	)
	weather_intensities = list(
		/datum/weather/standard = 0,
		/datum/weather/cloudy = 1,
		/datum/weather/cloudy/rain = 2,
		/datum/weather/cloudy/storm = 3,
	)
	weather_transitions = list(
		/datum/weather/standard = list(
			/datum/weather/standard = 80,
			/datum/weather/cloudy = 20,
		),
		/datum/weather/cloudy = list(
			/datum/weather/standard = 50,
			/datum/weather/cloudy = 25,
			/datum/weather/cloudy/rain = 25,
		),
		/datum/weather/cloudy/rain = list(
			/datum/weather/cloudy = 50,
			/datum/weather/cloudy/rain = 25,
			/datum/weather/cloudy/storm = 25,
		),
		/datum/weather/cloudy/storm = list(
			/datum/weather/cloudy/rain = 70,
			/datum/weather/cloudy/storm = 30
		)
	)

/datum/climate/desert
	name = "desert"
	starting_weather_type = /datum/weather/desert
	weather_image_type = /obj/effect/weather_holder/desert
	allowed_weather_types = list(
		/datum/weather/desert,
		/datum/weather/dust_storm,
		/datum/weather/sand_storm,
		/datum/weather/heatwave,
	)
	weather_intensities = list(
		/datum/weather/desert = 0,
		/datum/weather/dust_storm = 1,
		/datum/weather/sand_storm = 2,
		/datum/weather/heatwave = 3,
	)
	weather_transitions = list(
		/datum/weather/desert = list(
			/datum/weather/desert = 60,
			/datum/weather/dust_storm = 40,
		),
		/datum/weather/dust_storm = list(
			/datum/weather/standard = 25,
			/datum/weather/dust_storm = 50,
			/datum/weather/sand_storm = 25,
		),
		/datum/weather/sand_storm = list(
			/datum/weather/dust_storm = 40,
			/datum/weather/sand_storm = 30,
			/datum/weather/heatwave = 30,
		),
		/datum/weather/heatwave = list(
			/datum/weather/sand_storm = 50,
			/datum/weather/heatwave = 50,
		)
	)

/datum/climate/lava
	name = "lava"
	starting_weather_type = /datum/weather/lava
	weather_image_type = /obj/effect/weather_holder/lava
	allowed_weather_types = list(
		/datum/weather/lava,
		/datum/weather/ash,
		/datum/weather/ash/storm,
	)
	weather_intensities = list(
		/datum/weather/lava = 0,
		/datum/weather/ash = 1,
		/datum/weather/ash/storm = 2,
	)
	weather_transitions = list(
		/datum/weather/lava = list(
			/datum/weather/lava = 50,
			/datum/weather/ash = 50,
		),
		/datum/weather/ash = list(
			/datum/weather/lava = 30,
			/datum/weather/ash = 40,
			/datum/weather/ash/storm = 30
		),
		/datum/weather/ash/storm = list(
			/datum/weather/ash = 60,
			/datum/weather/ash/storm = 40,
		)
	)

/datum/climate/wasteland
	name = "wasteland"
	starting_weather_type = /datum/weather/desert
	weather_image_type = /obj/effect/weather_holder/fallout
	allowed_weather_types = list(
		/datum/weather/fallout,
		/datum/weather/fallout/storm,
		/datum/weather/desert,
		/datum/weather/cloudy/rain/toxic,
		/datum/weather/cloudy/rain/heavy/toxic,
	)
	weather_intensities = list(
		/datum/weather/fallout/storm = 0,
		/datum/weather/fallout = 1,
		/datum/weather/desert = 2,
		/datum/weather/cloudy/rain/toxic = 3,
		/datum/weather/cloudy/rain/heavy/toxic = 4,
	)
	weather_transitions = list(
		/datum/weather/fallout/storm = list(
			/datum/weather/fallout = 60,
			/datum/weather/fallout/storm = 40,
		),
		/datum/weather/fallout = list(
			/datum/weather/fallout/storm = 30,
			/datum/weather/fallout = 40,
			/datum/weather/desert = 30
		),
		/datum/weather/desert = list(
			/datum/weather/fallout = 30,
			/datum/weather/desert = 40,
			/datum/weather/cloudy/rain/toxic = 30,
		),
		/datum/weather/cloudy/rain/toxic = list(
			/datum/weather/desert = 30,
			/datum/weather/cloudy/rain/toxic = 40,
			/datum/weather/cloudy/rain/heavy/toxic = 30,
		),
		/datum/weather/cloudy/rain/heavy/toxic = list(
			/datum/weather/cloudy/rain/toxic = 60,
			/datum/weather/cloudy/rain/heavy/toxic = 40,
		)
	)

/datum/climate/xeno
	name = "xenoclime"
	starting_weather_type = /datum/weather/standard
	weather_image_type = /obj/effect/weather_holder/xeno
	allowed_weather_types = list(
		/datum/weather/standard,
		/datum/weather/cloudy/rain/acid,
		/datum/weather/cloudy/rain/heavy/acid,
	)
	weather_intensities = list(
		/datum/weather/standard = 0,
		/datum/weather/cloudy/rain/acid = 1,
		/datum/weather/cloudy/rain/heavy/acid = 2,
	)
	weather_transitions = list(
		/datum/weather/standard = list(
			/datum/weather/standard = 50,
			/datum/weather/cloudy/rain/acid = 50,
		),
		/datum/weather/cloudy/rain/acid = list(
			/datum/weather/standard = 40,
			/datum/weather/cloudy/rain/acid = 30,
			/datum/weather/cloudy/rain/heavy/acid = 30
		),
		/datum/weather/cloudy/rain/heavy/acid = list(
			/datum/weather/cloudy/rain/acid = 60,
			/datum/weather/cloudy/rain/heavy/acid = 40,
		)
	)

///////////////////////////////////  WEATHER DATUMS //////////////////////////////
/datum/weather
	var/name = "weather"
	var/timeleft = 1
	var/datum/climate/parent
	var/temperature = T20C
	var/precip_intensity = WEATHER_CALM
	var/tile_interval = 5
	var/precip_prob = 0
	var/precip_rate = list(0,0)
	var/precip_estimate = "snowing"
	var/weather_sound = null // Sound file for this weather type
	var/weather_sound_volume = 50 // Volume for the weather sound
	var/light_modifier = 1 // Light reduction multiplier (1 = normal, 0.8 = 20% darker, etc.)
	var/exposed_damage = 0 //damage per tick to unprotected limbs
	var/damage_type = BRUTE //type of damage to deal
	var/slowdown = 0 //speed reduction to apply to mobs
	var/vision_reduction = 0 //tiles of vision reduction (0 = none, 1 = slight, 3 = significant)

/datum/weather/New(var/datum/climate/C)
	parent = C
	timeleft = round(rand(parent.cycle_freq[1],parent.cycle_freq[2]),SS_WAIT_WEATHER)
	//round to 2 seconds, since that's how often we check in

/datum/weather/proc/execute()
	if(parent.weather_image)
		parent.weather_image.UpdatePrecipitation(precip_intensity)

	// Update lighting based on weather conditions
	var/datum/planet_type/planet = parent.get_planet()
	if(planet)
		planet.weather_mod = light_modifier
		SSDayNight.update_planet_lighting(planet, immediate = TRUE)
	else if(parent.z)
		SSDayNight.weather_mod = light_modifier
		SSDayNight.update_global_lighting()

/datum/weather/proc/tick()
	timeleft -= SS_WAIT_WEATHER
	weathertracker[name] += SS_WAIT_WEATHER


/datum/weather/proc/weather_details()
	return //additional info to report to the climate computer

/datum/weather/proc/get_weather_affected_players()
	var/list/playerlist = list()
	var/list/players_near_weather = list()

	if(parent.allocation)
		players_near_weather = mobs_in_allocation(parent.allocation, client_needed = TRUE)
	else
		players_near_weather = mobs_in_zlevel(parent.z, client_needed = TRUE)

	// Filter to only players in open surface areas (not caves/indoors)
	for(var/mob/M in players_near_weather)
		if(!istype(M, /mob/living))
			continue
		var/mob/living/L = M
		var/area/A = get_area(L)
		if(A && isopensurface(A))
			playerlist += L

	return playerlist

/datum/weather/proc/update_weather_sounds()
	var/list/affected_players = get_weather_affected_players()
	for(var/mob/living/M in affected_players)
		M.update_weather_sounds(FALSE)

/datum/weather/proc/stop_weather_sounds()
	var/list/affected_players = get_weather_affected_players()
	for(var/mob/living/M in affected_players)
		M.update_weather_sounds(TRUE)

/datum/weather/snow
	precip_intensity = WEATHER_CALM
	tile_interval = 5
	precip_prob = 0
	precip_rate = list(0,0)
	precip_estimate = "snowing"

/datum/weather/snow/weather_details()
	return "<b>Snowfall:</b> <div class='line'>[precip_estimate] </div>"

/datum/weather/snow/New(var/datum/climate/C)
	..()

/datum/weather/snow/execute()
	for(var/obj/machinery/teleport/hub/emergency/E in machines)
		E.alarm(!(precip_intensity % WEATHER_SEVERE))
		//sends 1 if precip_intensity equals blizzard exactly, otherwise sends 0
	..()
	// Update environment for snow turfs that respond to weather changes
	for(var/turf/unsimulated/floor/snow/tile in parent.weather_turfs)
		if(tile.real_snow_tile && !tile.ignore_blizzard_updates)
			tile.update_environment()
	force_update_snowfall_sfx()

/datum/weather/snow/tick()
	..()
	if(!prob(precip_prob))
		return
	var/i = rand(1,tile_interval)
	for(var/turf/unsimulated/floor/snow/tile in parent.weather_turfs)
		if(i == tile_interval)
			tile.change_snowballs(precip_rate[1],precip_rate[2])
			tile.ClearSnowprints()
			i = 1
		else
			i++

/datum/weather/snow/proc/force_update_snowfall_sfx() //Since the vision blocking UI only updates on Entered, let's call it.
	var/list/affected_players = get_weather_affected_players()
	for(var/mob/M in affected_players)
		if(M && M.client)
			var/turf/unsimulated/floor/snow/snow = get_turf(M)
			if(snow && istype(snow))
				snow.Entered(M)
	update_weather_sounds()

//////////////////////// SNOW SUBTYPES ////////////////////////

/datum/weather/snow/calm
	name = "calm"
	precip_intensity = WEATHER_CALM
	precip_prob = 3
	precip_rate = list(-1,0)
	temperature = T_ARCTIC
	precip_estimate = "minimal"
	weather_sound = 'sound/misc/snowstorm/snowfall_calm.ogg'
	weather_sound_volume = 30

/datum/weather/snow/calm/execute()
	..()
	research_shuttle.lockdown = FALSE //note: blob can't happen on this map
	mining_shuttle.lockdown = FALSE
	security_shuttle.lockdown = FALSE

/datum/weather/snow/light
	name = "light"
	precip_intensity = WEATHER_MODERATE
	precip_prob = 5
	precip_rate = list(1,8)
	temperature = T_ARCTIC - 5
	precip_estimate = "about 1.5cm/minute (light)"
	weather_sound = 'sound/misc/snowstorm/snowfall_average.ogg'
	weather_sound_volume = 40
	vision_reduction = 1

/datum/weather/snow/light/execute()
	..()
	research_shuttle.lockdown = FALSE
	mining_shuttle.lockdown = FALSE
	security_shuttle.lockdown = FALSE

/datum/weather/snow/heavy
	name = "<font color='orange'>heavy</font>"
	precip_intensity = WEATHER_HEAVY
	precip_prob = 8
	precip_rate = list(2,15)
	temperature = T_ARCTIC - 10
	precip_estimate = "<font color='orange'>about 4.8cm/minute (heavy)</font>"
	weather_sound = 'sound/misc/snowstorm/snowfall_hard.ogg'
	weather_sound_volume = 60
	vision_reduction = 2

/datum/weather/snow/heavy/execute()
	..()
	research_shuttle.lockdown = FALSE
	mining_shuttle.lockdown = FALSE
	security_shuttle.lockdown = FALSE

/datum/weather/snow/blizzard
	name = "<font color='red'>blizzard</font>"
	precip_intensity = WEATHER_SEVERE
	tile_interval = 3
	precip_prob = 12
	precip_rate = list(3,20)
	temperature = T_ARCTIC - 20
	precip_estimate = "<font color='red'>about 10.8cm/minute (ALERT)</font>"
	weather_sound = 'sound/misc/snowstorm/snowfall_blizzard.ogg'
	weather_sound_volume = 80
	vision_reduction = 3

/datum/weather/snow/blizzard/execute()
	..()
	research_shuttle.lockdown = "Under directive 1-49, surface-to-space light craft have been locked for duration of blizzard. Only escape-class shuttles are rated for stability in blizzards."
	mining_shuttle.lockdown = "Under directive 1-49, surface-to-space light craft have been locked for duration of blizzard. Only escape-class shuttles are rated for stability in blizzards."
	security_shuttle.lockdown = "Under directive 1-49, surface-to-space light craft have been locked for duration of blizzard. Only escape-class shuttles are rated for stability in blizzards."

/datum/weather/snow/blizzard/omega
	name = "<font color='purple'>dark season</font>"
	precip_prob = 15
	precip_estimate = "<font color='purple'>more than 13.5cm/minute (Dark Season)</font>"

/datum/weather/snow/blizzard/omega/New()
	..()
	timeleft = 2 HOURS

//////////////////////// STANDARD ////////////////////////
/datum/weather/standard
	name = "sunny"
	precip_intensity = WEATHER_CALM
	temperature = T20C
	precip_estimate = "none expected"
	light_modifier = 1 // Normal brightness

//////////////////////// CLOUDY ////////////////////////
/datum/weather/cloudy
	name = "cloudy"
	precip_intensity = WEATHER_CALM
	temperature = T20C
	precip_estimate = "none expected"
	light_modifier = 0.8 // 20% light reduction

/datum/weather/cloudy/fog
	name = "fog"
	precip_intensity = WEATHER_HEAVY
	precip_estimate = "none expected"

/datum/weather/cloudy/rain
	name = "rain shower"
	precip_intensity = WEATHER_MODERATE
	precip_rate = list(0,-1)
	temperature = T20C - 2
	precip_estimate = "about 5mm/hour (average)"
	weather_sound = 'sound/effects/weather/rain_light.ogg'
	weather_sound_volume = 40

/datum/weather/cloudy/rain/heavy
	name = "heavy rainfall"
	precip_intensity = WEATHER_HEAVY
	precip_rate = list(1,-2)
	precip_estimate = "<font color='orange'>about 50mm/hour (heavy)</font>"
	weather_sound = 'sound/effects/weather/rain_heavy.ogg'
	weather_sound_volume = 60
	vision_reduction = 1

/datum/weather/cloudy/storm
	name = "severe thunderstorm"
	precip_intensity = WEATHER_SEVERE
	precip_rate = list(3,-2)
	temperature = T20C - 2
	precip_estimate = "<font color='red'>about 100mm/hour (ALERT)</font>"
	var/lightning_chance = 10
	var/list/thunder_sounds = list('sound/effects/weather/thunder1.ogg', 'sound/effects/weather/thunder2.ogg', 'sound/effects/weather/thunder3.ogg')
	weather_sound = 'sound/effects/weather/rain_storm.ogg'
	weather_sound_volume = 80
	vision_reduction = 2

/datum/weather/cloudy/storm/tick()
	..()
	if(prob(lightning_chance))
		lightning()
		var/delay = rand(1,5) SECONDS
		spawn(delay)
			thunder()
	else if(prob(lightning_chance))
		thunder()

/datum/weather/cloudy/storm/proc/thunder()
	var/playerlist = get_weather_affected_players()
	var/chosen_sound = pick(thunder_sounds)
	var/sound/S = sound(chosen_sound, 0, 0, 0, 100)
	var/sound/S_quiet = sound('sound/effects/explosionfar.ogg', 0, 0, 0, 100)
	for(var/mob/living/M in playerlist)
		if(istype(get_area(M),/area/planet/cave))
			M << S_quiet
		else
			M << S

/datum/weather/cloudy/storm/proc/lightning()
	var/playerlist = get_weather_affected_players()
	for(var/mob/living/ML in playerlist)
		if(!istype(ML))
			continue
		if(istype(get_area(ML),/area/planet/cave))
			continue
		ML.flash_eyes(visual = 1)

/datum/weather/cloudy/storm/dry
	name = "dry thunderstorm"
	precip_intensity = WEATHER_HEAVY
	precip_rate = list(0,0)
	temperature = T20C
	precip_estimate = "none expected"
	lightning_chance = 20

/datum/weather/desert
	name = "desert"
	precip_intensity = WEATHER_CALM
	temperature = T20C + 10
	precip_estimate = "none expected"

/datum/weather/dust_storm
	name = "dust storm"
	precip_intensity = WEATHER_MODERATE
	temperature = T20C + 10
	precip_estimate = "none expected"
	light_modifier = 0.8
	exposed_damage = 1
	weather_sound = 'sound/effects/wind/wind_4_1.ogg'
	weather_sound_volume = 50
	slowdown =  0.9
	vision_reduction = 1

/datum/weather/sand_storm
	name = "sand storm"
	precip_intensity = WEATHER_HEAVY
	temperature = T20C + 10
	precip_estimate = "none expected"
	light_modifier = 0.5
	exposed_damage = 2
	weather_sound = 'sound/effects/wind/wind_5_1.ogg'
	weather_sound_volume = 80
	slowdown = 0.7
	vision_reduction = 3

/datum/weather/heatwave
	name = "heatwave"
	precip_intensity = WEATHER_SEVERE
	temperature = T20C + 30
	precip_estimate = "none expected"
	light_modifier = 1.5

/datum/weather/heatwave/New()
	..()
	if(Holiday == APRIL_FOOLS_DAY)
		weather_sound = 'sound/effects/weather/desert.ogg'
		weather_sound_volume = 80

/datum/weather/lava
	name = "scorched air"
	precip_intensity = WEATHER_CALM
	temperature = T20C + 15
	precip_estimate = "none expected"

/datum/weather/ash
	name = "light ashfall"
	precip_intensity = WEATHER_MODERATE
	temperature = T20C + 30
	precip_estimate = "none expected"
	light_modifier = 0.8
	exposed_damage = 1
	damage_type = BURN
	weather_sound = 'sound/effects/wind/wind_4_1.ogg'
	weather_sound_volume = 50
	vision_reduction = 1

/datum/weather/ash/storm
	name = "ash storm"
	precip_intensity = WEATHER_HEAVY
	temperature = T20C + 60
	precip_estimate = "none expected"
	light_modifier = 0.5
	exposed_damage = 2
	damage_type = BURN
	weather_sound = 'sound/effects/wind/wind_5_1.ogg'
	weather_sound_volume = 80
	vision_reduction = 2


/datum/weather/fallout
	name = "nuclear fallout"
	precip_intensity = WEATHER_MODERATE
	temperature = T20C
	precip_estimate = "none expected"
	light_modifier = 0.8
	exposed_damage = 1
	damage_type = IRRADIATE
	weather_sound = 'sound/effects/wind/wind_4_1.ogg'
	weather_sound_volume = 50

/datum/weather/fallout/storm
	name = "heavy nuclear fallout"
	precip_intensity = WEATHER_HEAVY
	light_modifier = 0.5
	exposed_damage = 2
	weather_sound = 'sound/effects/wind/wind_5_1.ogg'
	weather_sound_volume = 80
	vision_reduction = 1

/datum/weather/cloudy/rain/toxic
	name = "toxic rain"
	precip_intensity = WEATHER_SEVERE
	exposed_damage = 1
	damage_type = TOX

/datum/weather/cloudy/rain/heavy/toxic
	name = "toxic downpour"
	precip_intensity = WEATHER_EXTREME
	exposed_damage = 2
	damage_type = TOX
	vision_reduction = 1

/datum/weather/cloudy/rain/acid
	name = "acid rain"
	precip_intensity = WEATHER_MODERATE
	exposed_damage = 1
	damage_type = BURN

/datum/weather/cloudy/rain/heavy/acid
	name = "acid downpour"
	precip_intensity = WEATHER_HEAVY
	exposed_damage = 2
	damage_type = BURN
	vision_reduction = 1

/mob/living/proc/update_weather_sounds(var/clear = FALSE)
	if(clear)
		src << sound(null, repeat = 0, wait = 0, channel = CHANNEL_WEATHER, volume = 0)
		return
	var/datum/climate/C = SSweather.get_climate_from_turf(get_turf(src))
	if(!C?.current_weather)
		return
	var/datum/weather/W = C.current_weather
	if(!W.weather_sound)
		return
	src << sound(W.weather_sound, repeat = 1, wait = 0, channel = CHANNEL_WEATHER, volume = W.weather_sound_volume)
