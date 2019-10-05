var/list/global_snowtiles = list()
var/list/snow_state_to_texture = list()
var/snowtiles_setup = 0
var/snow_intensity = SNOW_CALM
var/blizzard_ready = 1 //Whether a new blizzard can be started.
var/list/snowstorm_ambience = list('sound/misc/snowstorm/snowfall_calm.ogg','sound/misc/snowstorm/snowfall_average.ogg','sound/misc/snowstorm/snowfall_hard.ogg','sound/misc/snowstorm/snowfall_blizzard.ogg')
var/list/snowstorm_ambience_volumes = list(30,40,60,80)
var/blizzard_cooldown = 3000 //5 minutes minimum

/datum/event/blizzard/can_start()
	return 80

/datum/event/blizzard/start()
	if(blizzard_ready)
		blizzard_ready = 0
		command_alert(/datum/command_alert/blizzard_start)
		sleep(rand(20 SECONDS, 2 MINUTES))
		greaten_snowfall()
		sleep(rand(3 MINUTES, 6 MINUTES))
		greaten_snowfall()
		sleep(rand(8 MINUTES, 13 MINUTES))
		lessen_snowfall()
		sleep(rand(3 MINUTES, 6 MINUTES))
		lessen_snowfall()
		sleep(rand(20 SECONDS, 40 SECONDS))
		command_alert(/datum/command_alert/blizzard_end)
		spawn(blizzard_cooldown)
			blizzard_ready = 1

/datum/event/omega_blizzard
	oneShot = 1

/datum/event/omega_blizzard/can_start()
	return 3

/datum/event/omega_blizzard/start() //Oh god oh fuck
	if(blizzard_ready)
		blizzard_ready = 0
		command_alert(/datum/command_alert/omega_blizzard)
		sleep(rand(20 SECONDS, 30 SECONDS))
		greaten_snowfall()
		sleep(rand(50 SECONDS, 2 MINUTES))
		greaten_snowfall()
		sleep(rand(3 MINUTES, 5 MINUTES))
		greaten_snowfall() //Never-ending MISERY

/proc/force_update_snowfall_sfx() //Since the vision blocking UI only updates on Entered, let's call it.
	for(var/mob/M in player_list)
		if(M && M.client)
			var/turf/unsimulated/floor/snow/snow = get_turf(M)
			if(snow && istype(snow))
				snow.Entered(M)
				M << sound(snowstorm_ambience[snow_intensity+1], repeat = 1, wait = 0, channel = CHANNEL_WEATHER, volume = snowstorm_ambience_volumes[snow_intensity+1])





/proc/greaten_snowfall()
	if(snow_intensity == SNOW_BLIZZARD)
		return
	snow_intensity++
	for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
		tile.snow_state = snow_intensity
		tile.update_environment()
	force_update_snowfall_sfx()

/proc/lessen_snowfall()
	if(snow_intensity == SNOW_CALM)
		return
	snow_intensity--
	for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
		tile.snow_state = snow_intensity
		tile.update_environment()
	force_update_snowfall_sfx()

/proc/snowfall_tick()
	switch(snow_intensity)
		if(SNOW_CALM)
			snowfall_calm_tick()
		if(SNOW_AVERAGE)
			snowfall_average_tick()
		if(SNOW_HARD)
			snowfall_hard_tick()
		if(SNOW_BLIZZARD)
			snowfall_blizzard_tick()

/proc/snowfall_calm_tick()
	var/tile_interval = 5
	if(prob(3))
		var/i = rand(1,tile_interval) //Efficiently selects a set of random tiles to melt snow on.
		for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
			if(i == tile_interval)
				tile.change_snowballs(-1,0)
				if(tile.snowprint_parent)
					tile.snowprint_parent.ClearSnowprints()
				i = 1
			else
				i++
/proc/snowfall_average_tick()
	var/tile_interval = 5
	if(prob(5))
		var/i = rand(1,tile_interval)
		for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
			if(i == tile_interval)
				tile.change_snowballs(1,8)
				if(tile.snowprint_parent)
					tile.snowprint_parent.ClearSnowprints()
				i = 1
			else
				i++


/proc/snowfall_hard_tick()
	var/tile_interval = 5
	if(prob(8))
		var/i = rand(1,tile_interval)
		for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
			if(i == tile_interval)
				tile.change_snowballs(2,15)
				if(tile.snowprint_parent)
					tile.snowprint_parent.ClearSnowprints()
				i = 1
			else
				i++


/proc/snowfall_blizzard_tick()
	var/tile_interval = 3
	if(prob(12))
		var/i = rand(1,tile_interval)
		for(var/turf/unsimulated/floor/snow/tile in global_snowtiles)
			if(i == tile_interval)
				tile.change_snowballs(3,20)
				if(tile.snowprint_parent)
					tile.snowprint_parent.ClearSnowprints()
				i = 1
			else
				i++
