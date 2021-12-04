var/blizzard_ready = TRUE //Whether a new blizzard can be started.
var/blizzard_cooldown = 5 MINUTES


/datum/event/blizzard/can_start()
	return 80 * istype(map.climate,/datum/climate/arctic)

/datum/event/blizzard/start()
	if(blizzard_ready)

		var/datum/climate/C = map.climate
		var/datum/weather/W = C.current_weather
		if(istype(W,/datum/weather/snow/blizzard))
			command_alert(/datum/command_alert/blizzard_extended)
			W.timeleft += round(rand(4 MINUTES, 10 MINUTES),SS_WAIT_WEATHER)
		else
			blizzard_ready = FALSE
			command_alert(/datum/command_alert/blizzard_start)
			W.timeleft = round(rand(2 MINUTES, 4 MINUTES),SS_WAIT_WEATHER)
			W.next_weather = list(/datum/weather/snow/blizzard = 100)
			C.forecast()
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
		var/datum/climate/C = map.climate
		var/datum/weather/W = C.current_weather
		W.timeleft = round(rand(8 MINUTES, 10 MINUTES),SS_WAIT_WEATHER)
		W.next_weather = list(/datum/weather/snow/blizzard/omega = 100)
		C.forecast()
