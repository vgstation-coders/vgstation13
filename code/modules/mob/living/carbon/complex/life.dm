/mob/living/carbon/complex/Life()

	if(timestopped)
		return 0 //under effects of time magick

	..()

	blinded = null
	var/datum/gas_mixture/environment // Added to prevent null location errors-- TLE
	if(loc)
		environment = loc.return_air()

	if (stat != DEAD) //still breathing
		//Lungs required beyond this point
		if(flag != NO_BREATHE)
			//First, resolve location and get a breath
			if(SSair.current_cycle%4==2)
				//Only try to take a breath every 4 seconds, unless suffocating
				breathe()
			else //Still give containing object the chance to interact
				if(istype(loc, /obj/))
					var/obj/location_as_object = loc
					location_as_object.handle_internal_lifeform(src, 0)

		handle_chemicals_in_body()

	//Handle temperature/pressure differences between body and environment
	if(environment)	// More error checking -- TLE
		handle_environment(environment)

		handle_body_temperature() //Whomever coded this needs a stern talking to about how to use HUD elements over spamming chat

	//Check if we're on fire
	handle_fire()

	//Status updates, death etc.
	handle_regular_status_updates()

	update_canmove()

	if(client)
		handle_regular_hud_updates()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()



// ATMOSPHERE, BREATHING, ALL THINGS INVOLVING AIR//

/mob/living/carbon/complex/get_breath_from_internal(volume_needed)
	return null

/mob/living/carbon/complex/proc/handle_environment(datum/gas_mixture/environment)
	if(!environment || (flags & INVULNERABLE))
		return
	var/loc_temp = get_loc_temp(environment)
	var/spaceproof = is_spaceproof()
	var/environment_heat_capacity = environment.heat_capacity() / environment.volume * CELL_VOLUME
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		environment_heat_capacity = heat_turf.heat_capacity

	if(!on_fire && !spaceproof) //If you're on fire, you do not heat up or cool down based on surrounding gases
		if(loc_temp < get_skin_temperature())
			var/thermal_loss = get_thermal_loss(environment)
			bodytemperature -= thermal_loss
		else
			var/thermal_protection = get_thermal_protection(get_heat_protection_flags(loc_temp)) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				bodytemperature += min((1 - thermal_protection) * ((loc_temp - get_skin_temperature()) / BODYTEMP_HEAT_DIVISOR), BODYTEMP_HEATING_MAX)
	if(stat==DEAD)
		bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)


	//Account for massive pressure differences
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			if( !(M_RESIST_HEAT in mutations) )
				adjustBruteLoss( min( ( (adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
				pressure_alert = 2
			else
				pressure_alert = 1
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			pressure_alert = 1
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			pressure_alert = 0
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			if(!spaceproof)
				pressure_alert = -1
		else
			if(!spaceproof)
				if( !(M_RESIST_COLD in mutations) )
					adjustBruteLoss( LOW_PRESSURE_DAMAGE )
					pressure_alert = -2
				else
					pressure_alert = -1

/mob/living/carbon/complex/proc/is_spaceproof()
	if(flags & INVULNERABLE)
		return TRUE
	return FALSE


/mob/living/carbon/complex/get_thermal_protection_flags()
	return 0

/mob/living/carbon/complex/calculate_affecting_pressure(var/pressure)
	..()
	return pressure

/mob/living/carbon/complex/get_cold_protection()

	if(M_RESIST_COLD in mutations)
		return 1 //Fully protected from the cold.

	var/thermal_protection = 0.0

	var/max_protection = get_thermal_protection(get_thermal_protection_flags())
	return min(thermal_protection,max_protection)



/mob/living/carbon/complex/proc/handle_regular_status_updates()
	updatehealth()

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		updatehealth()
		if((health < config.health_threshold_dead || !has_brain()) && !(status_flags & BUDDHAMODE))
			death()
			blinded = 1
			stat = DEAD
			silent = 0
			return 1

		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 25) || (config.health_threshold_crit > health) )
			if( health <= 20 && prob(1) )
				spawn(0)
					emote("gasp")
			if(!reagents.has_any_reagents(list(INAPROVALINE,PRESLOMITE)))
				adjustOxyLoss(1)
			Paralyse(3)
		if(halloss > 100)
			visible_message("<B>[src]</B> slumps to the ground, too weak to continue fighting.","<span class='notice'>You're in too much pain to keep going.</span>")
			Paralyse(10)
			setHalLoss(99)

		if(paralysis)
			AdjustParalysis(-1)
			blinded = 1
			stat = status_flags & BUDDHAMODE ? CONSCIOUS : UNCONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-3)
		else if(sleeping)
			handle_dreams()
			adjustHalLoss(-3)
			sleeping = max(sleeping-1, 0)
			blinded = 1
			stat = status_flags & BUDDHAMODE ? CONSCIOUS : UNCONSCIOUS
			if( prob(10) && health && !hal_crit )
				spawn(0)
					emote("snore")
		else if(resting)
			if(halloss > 0)
				adjustHalLoss(-3)
		//CONSCIOUS
		else if(undergoing_hypothermia() >= SEVERE_HYPOTHERMIA)
			stat = status_flags & BUDDHAMODE ? CONSCIOUS : UNCONSCIOUS
		else
			stat = CONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-1)

		//Eyes
		if(sdisabilities & BLIND)	//disabled-blind, doesn't get better on its own
			blinded = 1
		else if(eye_blind)			//blindness, heals slowly over time
			eye_blind = max(eye_blind-1,0)
			blinded = 1
		else if(eye_blurry)			//blurry eyes heal slowly
			eye_blurry = max(eye_blurry-1, 0)

		//Ears
		if(sdisabilities & DEAF)		//disabled-deaf, doesn't get better on its own
			ear_deaf = max(ear_deaf, 1)
		else if(ear_deaf)			//deafness, heals slowly over time
			ear_deaf = max(ear_deaf-1, 0)
		else if(ear_damage < 25)	//ear damage heals slowly under this threshold. otherwise you'll need earmuffs
			ear_damage = max(ear_damage-0.05, 0)

		//Other
		if(stunned)
			AdjustStunned(-1)

		if(knockdown)
			knockdown = max(knockdown-1,0)	//before you get mad Rockdtben: I done this so update_canmove isn't called multiple times

		if(say_mute)
			say_mute = max(say_mute-1, 0)

		if(stuttering)
			stuttering = max(stuttering-1, 0)

		if(silent)
			silent = max(silent-1, 0)

		if(druggy)
			druggy = max(druggy-1, 0)
	return 1

/mob/living/carbon/complex/proc/handle_chemicals_in_body()

	burn_calories(HUNGER_FACTOR,1)
	if(reagents)
		reagents.metabolize(src)

	if (drowsyness > 0)
		drowsyness = max(0, drowsyness - 1)
		eye_blurry = max(2, eye_blurry)
		if (prob(5))
			sleeping += 1
			Paralyse(5)

	remove_confused(1)
	handle_dizziness()
	handle_jitteriness()

	updatehealth()
	return //TODO: DEFERRED


/mob/living/carbon/complex/handle_regular_hud_updates()
	if(!client)
		return

	regular_hud_updates()

	if (stat == DEAD || (M_XRAY in mutations))
		change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if (stat != DEAD)
		change_sight(removing = SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 2
		see_invisible = SEE_INVISIBLE_LIVING


	if (healths)
		if (stat != DEAD)
			switch(health)
				if(150 to INFINITY)
					healths.icon_state = "health0"
				if((150/6*5) to 150)
					healths.icon_state = "health1"
				if((150/6*4) to (150/6*5))
					healths.icon_state = "health2"
				if((150/6*3) to (150/6*4))
					healths.icon_state = "health3"
				if((150/6*2) to (150/6*3))
					healths.icon_state = "health4"
				if(0 to (150/6*2))
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	switch(bodytemperature) //310.055 optimal body temp
		if(345 to INFINITY)
			temperature_alert = TEMP_ALARM_HEAT_STRONG
		if(335 to 345)
			temperature_alert = TEMP_ALARM_HEAT_MILD
		if(327 to 335)
			temperature_alert = TEMP_ALARM_HEAT_WEAK
		if(295 to 327)
			temperature_alert = TEMP_ALARM_SAFE
		if(280 to 295)
			temperature_alert = TEMP_ALARM_COLD_WEAK
		if(260 to 280)
			temperature_alert = TEMP_ALARM_COLD_MILD
		else
			temperature_alert = TEMP_ALARM_COLD_STRONG

	update_pull_icon()

	if(pressure_alert)
		throw_alert(SCREEN_ALARM_PRESSURE, pressure_alert < 0 ? /obj/abstract/screen/alert/carbon/pressure/low : /obj/abstract/screen/alert/carbon/pressure/high, pressure_alert)
	else
		clear_alert(SCREEN_ALARM_PRESSURE)
	if(oxygen_alert)
		throw_alert(SCREEN_ALARM_BREATH, /obj/abstract/screen/alert/carbon/breath)
	else
		clear_alert(SCREEN_ALARM_BREATH)
	if(toxins_alert)
		throw_alert(SCREEN_ALARM_TOXINS, /obj/abstract/screen/alert/tox)
	else
		clear_alert(SCREEN_ALARM_TOXINS)
	if(fire_alert)
		throw_alert(SCREEN_ALARM_FIRE, /obj/abstract/screen/alert/carbon/burn/fire, fire_alert)
	else
		clear_alert(SCREEN_ALARM_FIRE)
	if(temperature_alert)
		throw_alert(SCREEN_ALARM_TEMPERATURE, temperature_alert < 0 ? /obj/abstract/screen/alert/carbon/temp/cold : /obj/abstract/screen/alert/carbon/temp/hot, temperature_alert)
	else
		clear_alert(SCREEN_ALARM_TEMPERATURE)


	if(stat != DEAD)
		var/impaired_vision = get_impaired_vision_range()
		if(impaired_vision > 0)
			enable_nearsightedness(impaired_vision)
		else if (perception_filters.enabled_filters & P_FILTER_IMPAIRED_VISION)
			disable_nearsightedness()

		if(eye_blurry)
			enable_blurriness(eye_blurry)
		else if (perception_filters.enabled_filters & P_FILTER_BLURRY_VISION)
			disable_blurriness()

		if(druggy)
			enable_druggy_overlays()
		else
			disable_druggy_overlays()
	else
		if (perception_filters.enabled_filters & P_FILTER_IMPAIRED_VISION)
			disable_nearsightedness()
		if (perception_filters.enabled_filters & P_FILTER_BLURRY_VISION)
			disable_blurriness()

	if (stat != DEAD)
		if (machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(client && !client.adminobs && !isTeleViewing(client.eye))
				reset_view(null)

	return 1

/mob/living/carbon/complex/undergoing_hypothermia()
	if((status_flags & GODMODE) || (flags & INVULNERABLE) || istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		return NO_HYPOTHERMIA

	switch(bodytemperature)
		if(295 to 300)
			return MILD_HYPOTHERMIA // awake and shivering
		if(280 to 295)
			return MODERATE_HYPOTHERMIA // drowsy and not shivering
		if(260 to 280)
			return SEVERE_HYPOTHERMIA // unconcious, not shivering
		if(-T0C to 260)
			return PROFOUND_HYPOTHERMIA // no vital signs
	return NO_HYPOTHERMIA
