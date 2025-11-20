//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_weather()
	if(flags & INVULNERABLE)
		return

	if(!climates.len)
		return

	var/turf/T = get_turf(src)
	if(!T)
		clear_weather_effects()
		return

	var/datum/climate/climate = SSweather.get_climate_from_turf(T)
	if(!climate?.current_weather)
		clear_weather_effects()
		return

	var/datum/weather/weather = climate.current_weather

	// Check if we're in an open surface area (weather-affected area)
	var/area/A = get_area(src)
	if(!A || !isopensurface(A))
		clear_weather_effects()
		return

	apply_weather_effects(weather)


/mob/living/carbon/human/proc/apply_weather_effects(var/datum/weather/weather)
	if(!weather)
		return

	var/list/exposed_parts = get_exposed_organs()

	// Apply damage to exposed parts if the weather has exposed_damage
	if(weather.exposed_damage > 0 && exposed_parts.len)
		for(var/datum/organ/external/E in exposed_parts)
			if(weather.damage_type == BURN)
				E.take_damage(0, weather.exposed_damage, used_weapon = weather.name)
			else if(weather.damage_type == BRUTE)
				E.take_damage(weather.exposed_damage, 0, used_weapon = weather.name)
			else if(weather.damage_type == TOX)
				adjustToxLoss(weather.exposed_damage) // one tox damage hit per exposed organ
			else if(weather.damage_type == IRRADIATE)
				apply_radiation(weather.exposed_damage, RAD_EXTERNAL) // one rad hit per tick (rads are spicy enough)
				break

	apply_weather_slowdown(weather)
	update_weather_vision(weather)

/mob/living/carbon/human/proc/get_exposed_organs()
	var/list/exposed = list()
	var/exposed_flags = get_exposed_body_parts()
	for(var/datum/organ/external/E in organs)
		if(E.body_part & exposed_flags)
			exposed += E
	return exposed

/mob/living/carbon/human/proc/apply_weather_slowdown(var/datum/weather/weather)
	if(!weather?.slowdown || weather.slowdown >= 1)
		if(weather_slowdown_applied)
			movement_speed_modifier /= weather_slowdown_applied
			weather_slowdown_applied = 0
		return
	if(weather_slowdown_applied)
		movement_speed_modifier /= weather_slowdown_applied
	movement_speed_modifier *= weather.slowdown
	weather_slowdown_applied = weather.slowdown

/mob/living/carbon/human/proc/update_weather_vision(var/datum/weather/weather)
	if(!weather)
		weather_vision_reduction = 0
		clear_fullscreen("weather_vision")
		return

	var/new_reduction = weather.vision_reduction
	if(new_reduction != weather_vision_reduction)
		weather_vision_reduction = new_reduction
		clear_fullscreen("weather_vision")

		if(weather_vision_reduction > 0)
			// 1 = slight (average), 2 = moderate (hard), 3+ = severe (blizzard/storm)
			var/overlay_type
			switch(weather_vision_reduction)
				if(1)
					overlay_type = /obj/abstract/screen/fullscreen/snowfall_average
				if(2)
					overlay_type = /obj/abstract/screen/fullscreen/snowfall_hard
				else // 3 or higher
					overlay_type = /obj/abstract/screen/fullscreen/snowfall_blizzard

			overlay_fullscreen("weather_vision", overlay_type)

/mob/living/carbon/human/proc/clear_weather_effects()
	if(weather_slowdown_applied)
		movement_speed_modifier /= weather_slowdown_applied
		weather_slowdown_applied = 0
	weather_vision_reduction = 0
	clear_fullscreen("weather_vision")
	// Stop weather sounds when clearing effects
	if(client)
		src << sound(null, repeat = 0, wait = 0, channel = CHANNEL_WEATHER, volume = 0)
