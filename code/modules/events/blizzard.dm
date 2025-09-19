var/blizzard_ready = TRUE //Whether a new blizzard can be started.
var/blizzard_cooldown = 5 MINUTES
var/blizzardz = 1


/datum/event/blizzard/can_start()
	for(var/datum/climate/C in climates)
		if(istype(C,/datum/climate/arctic))
			return 80

/datum/event/blizzard/start()
	if(blizzard_ready)
		var/datum/climate/C = pick(climates) //one lucky z-level gets a blizzard!
		var/datum/weather/W = C.current_weather
		if(istype(W,/datum/weather/snow/blizzard))
			command_alert(/datum/command_alert/blizzard_extended)
			W.timeleft += round(rand(4 MINUTES, 10 MINUTES),SS_WAIT_WEATHER)
		else
			blizzard_ready = FALSE
			command_alert(/datum/command_alert/blizzard_start)
			W.timeleft = round(rand(2 MINUTES, 4 MINUTES),SS_WAIT_WEATHER)
			// Temporarily override transitions to force blizzard
			var/list/old_transitions = C.weather_transitions[W.type]
			C.change_weather(/datum/weather/snow/blizzard, force = FALSE)
			C.forecast()
			// Restore original transitions after forecasting
			C.weather_transitions[W.type] = old_transitions
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
		var/datum/climate/C = pick(climates)
		var/datum/weather/W = C.current_weather
		W.timeleft = round(rand(8 MINUTES, 10 MINUTES),SS_WAIT_WEATHER)
		var/list/old_transitions = C.weather_transitions[W.type]
		C.weather_transitions[W.type] = list(/datum/weather/snow/blizzard/omega = 100)
		C.forecast()
		C.weather_transitions[W.type] = old_transitions
