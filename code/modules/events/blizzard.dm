var/blizzard_ready = TRUE //Whether a new blizzard can be started.
var/blizzard_cooldown = 5 MINUTES
var/blizzardz = 1


/datum/event/blizzard/can_start()
	for(var/datum/climate/C in climates)
		if(istype(C,/datum/climate/arctic))
			return 80

/datum/event/blizzard/start()
	if(blizzard_ready)
		var/list/arctic_climates = list()
		for(var/datum/climate/C in climates)
			if(istype(C, /datum/climate/arctic))
				arctic_climates += C
		if(!arctic_climates.len)
			CRASH("BLIZZARD: No arctic climates found")
		var/datum/climate/C = pick(arctic_climates)
		var/datum/weather/W = C.current_weather
		if(!W)
			CRASH("BLIZZARD: Current weather is null for climate [C]")
		if(istype(W,/datum/weather/snow/blizzard))
			command_alert(/datum/command_alert/blizzard_extended)
			W.timeleft += round(rand(4 MINUTES, 10 MINUTES),SS_WAIT_WEATHER)
		else
			blizzard_ready = FALSE
			command_alert(/datum/command_alert/blizzard_start)
			W.timeleft = round(rand(2 MINUTES, 4 MINUTES),SS_WAIT_WEATHER)
			C.clear_forecast()
			var/datum/weather/blizzard = new /datum/weather/snow/blizzard(C)
			blizzard.timeleft = round(rand(C.cycle_freq[1], C.cycle_freq[2]), SS_WAIT_WEATHER)
			C.forecasts = list(blizzard)
			for(var/i = 1; i <= PREDICTION_MINIMUM; i++)
				var/datum/weather/last = C.forecasts[C.forecasts.len]
				var/list/possible = C.weather_transitions[last.type]
				if(!possible || !possible.len)
					break
				var/next_path = pickweight(possible)
				if(!next_path)
					break
				var/datum/weather/next = new next_path(C)
				C.forecasts += next
		spawn(blizzard_cooldown)
			blizzard_ready = TRUE

/datum/event/omega_blizzard
	oneShot = 1

/datum/event/omega_blizzard/can_start()
	return 0

/datum/event/omega_blizzard/start() //Oh god oh fuck
	if(blizzard_ready)
		blizzard_ready = 0
		command_alert(/datum/command_alert/omega_blizzard)
		var/list/arctic_climates = list()
		for(var/datum/climate/C in climates)
			if(istype(C, /datum/climate/arctic))
				arctic_climates += C
		if(!arctic_climates.len)
			CRASH("OMEGA BLIZZARD: No arctic climates found")
		var/datum/climate/C = pick(arctic_climates)
		var/datum/weather/W = C.current_weather
		if(!W)
			CRASH("OMEGA BLIZZARD: Current weather is null for climate [C]")
		W.timeleft = round(rand(8 MINUTES, 10 MINUTES),SS_WAIT_WEATHER)
		C.clear_forecast()
		var/datum/weather/omega = new /datum/weather/snow/blizzard/omega(C)
		C.forecasts = list(omega)
		for(var/i = 1; i <= PREDICTION_MINIMUM; i++)
			var/datum/weather/last = C.forecasts[C.forecasts.len]
			var/list/possible = C.weather_transitions[last.type]
			if(!possible || !possible.len)
				break
			var/next_path = pickweight(possible)
			if(!next_path)
				break
			var/datum/weather/next = new next_path(C)
			C.forecasts += next
