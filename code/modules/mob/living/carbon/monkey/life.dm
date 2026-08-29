

/mob/living/carbon/monkey
	base_insulation = 0.5
/mob/living/carbon/monkey/Life()
	//set background = 1
	if(timestopped)
		return 0 //under effects of time magick

	if (monkeyizing)
		return
	if (update_muts)
		update_muts=0
		domutcheck(src,null,MUTCHK_FORCED)
	..()

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

		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

		//Disabilities
		handle_disabilities()

		//Virus updates, duh
		handle_virus_updates()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null

	//Handle temperature/pressure differences between body and environment
	if(environment)	// More error checking -- TLE
		handle_environment(environment)

	handle_body_temperature()

	//Check if we're on fire
	handle_fire()

	//Status updates, death etc.
	handle_regular_status_updates()

	update_canmove()

	if(client)
		handle_regular_hud_updates()
		standard_damage_overlay_updates()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

	if(!client && stat == CONSCIOUS)

		if(prob(33) && canmove && isturf(loc) && !pulledby && !(grabbed_by?.len)) //won't move if being pulled

			INVOKE_EVENT(src, /event/before_move)
			step(src, pick(cardinal))
			INVOKE_EVENT(src, /event/after_move)

		if(prob(1))
			passive_emote()


/mob/living/carbon/monkey/proc/passive_emote()
	emote(pick("scratch","jump","roll","tail"))

/mob/living/carbon/monkey/calculate_affecting_pressure(var/pressure)
	..()
	return pressure

/mob/living/carbon/monkey/proc/handle_disabilities()


	if (disabilities & EPILEPSY)
		if ((prob(1) && paralysis < 10))
			to_chat(src, "<span class='warning'>You have a seizure!</span>")
			Paralyse(10)
	if (disabilities & COUGHING)
		if ((prob(5) && paralysis <= 1))
			drop_item()
			spawn( 0 )
				emote("cough")
				return
	if (disabilities & TOURETTES)
		if ((prob(10) && paralysis <= 1))
			Stun(10)
			spawn( 0 )
				emote("twitch")
				return
	if (disabilities & NERVOUS)
		if (prob(10))
			stuttering = max(10, stuttering)

/mob/living/carbon/monkey/proc/handle_mutations_and_radiation()
	if(flags & INVULNERABLE)
		return

	if(getFireLoss())
		if((M_RESIST_HEAT in mutations) || prob(50))
			switch(getFireLoss())
				if(1 to 50)
					adjustFireLoss(-1)
				if(51 to 100)
					adjustFireLoss(-5)

	if ((M_HULK in mutations) && health <= 25)
		mutations.Remove(M_HULK)
		to_chat(src, "<span class='warning'>You suddenly feel very weak.</span>")
		Knockdown(3)
		emote("collapse")
		if(reagents.has_reagent(CREATINE))
			var/datum/reagent/creatine/C = reagents.get_reagent(CREATINE)
			C.dehulk(src)

	if (radiation)

		if(istype(src,/mob/living/carbon/monkey/diona)) //Filthy check. Dionaea don't take rad damage.
			var/rads = radiation/25
			radiation -= rads
			nutrition += rads
			heal_overall_damage(rads,rads)
			adjustOxyLoss(-(rads))
			adjustToxLoss(-(rads))
			updatehealth()
			return

		if (radiation > 100)
			radiation = 100
			Knockdown(10)
			to_chat(src, "<span class='warning'>You feel weak.</span>")
			emote("collapse")

		switch(radiation)
			if(1 to 49)
				radiation--
				if(prob(25))
					adjustToxLoss(1)
					updatehealth()

			if(50 to 74)
				radiation -= 2
				adjustToxLoss(1)
				if(prob(5))
					radiation -= 5
					Knockdown(3)
					to_chat(src, "<span class='warning'>You feel weak.</span>")
					emote("collapse")
				updatehealth()

			if(75 to 100)
				radiation -= 3
				adjustToxLoss(3)
				if(prob(1))
					to_chat(src, "<span class='warning'>You mutate!</span>")
					randmutb(src)
					domutcheck(src,null)
					emote("gasp")
				updatehealth()

/mob/living/carbon/monkey/check_breath_block(var/flag_check = BLOCK_BREATHING)
	return (flag_check & BLOCK_GAS_SMOKE_EFFECT) ? istype(wear_mask, /obj/item/clothing/mask/gas) : FALSE

/mob/living/carbon/monkey/get_thermal_protection_flags()
	var/thermal_protection_flags = 0
	if(hat)
		thermal_protection_flags |= hat.body_parts_covered
	if(wear_mask)
		thermal_protection_flags |= wear_mask.body_parts_covered
	if(uniform)
		thermal_protection_flags |= uniform.body_parts_covered
	return thermal_protection_flags

/mob/living/carbon/monkey/get_cold_protection()

	var/thermal_protection = 0.0

	if(hat)
		thermal_protection += hat.return_thermal_protection()
	if(wear_mask)
		thermal_protection += wear_mask.return_thermal_protection()
	if(uniform)
		thermal_protection += uniform.return_thermal_protection()

	var/max_protection = max(get_thermal_protection(get_thermal_protection_flags()),base_insulation) // monkies have fur, silly!
	return min(thermal_protection,max_protection)

/mob/living/carbon/monkey/get_heat_protection_flags(temperature)
	var/thermal_protection_flags = 0
	if(hat && hat.max_heat_protection_temperature >= temperature)
		thermal_protection_flags |= hat.body_parts_covered
	if(wear_mask && wear_mask.max_heat_protection_temperature >= temperature)
		thermal_protection_flags |= wear_mask.body_parts_covered
	if(uniform && uniform.max_heat_protection_temperature >= temperature)
		thermal_protection_flags |= uniform.body_parts_covered
	return thermal_protection_flags


/mob/living/carbon/monkey/proc/handle_environment(datum/gas_mixture/environment)
	if(!environment || (flags & INVULNERABLE))
		return
	var/spaceproof = 0
	if(hat && istype(hat, /obj/item/clothing/head/helmet/space) && uniform && istype(uniform, /obj/item/clothing/monkeyclothes/space))
		spaceproof = 1	//quick and dirt cheap. no need for the Life() of monkeys to become as complicated as the Life() of humans. man that's deep.
	var/loc_temp = get_loc_temp(environment)
	var/environment_heat_capacity = environment.heat_capacity() / environment.volume * CELL_VOLUME
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		environment_heat_capacity = heat_turf.heat_capacity

	if(!on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		if(loc_temp < get_skin_temperature())
			var/thermal_loss = get_thermal_loss(environment)
			bodytemperature -= thermal_loss
		else
			var/thermal_protection = get_thermal_protection(get_heat_protection_flags(loc_temp)) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				bodytemperature += min((1 - thermal_protection) * ((loc_temp - get_skin_temperature()) / BODYTEMP_HEAT_DIVISOR), BODYTEMP_HEATING_MAX)

	if(stat!=DEAD)//this is sweating/shiverring, right?....
		bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

	if (status_flags & GODMODE)
		fire_alert = 0
		pressure_alert = 0
		return

	// Slimed carbons are protected against heat damage
	if (bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT || (bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT))
		// Update fire/cold overlay
		var/temp_alert = (bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT) ? 1 : 2
		fire_alert = max(fire_alert, temp_alert)
		if(!(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)))
			var/temp_damage = get_body_temperature_damage(bodytemperature)
			var/temp_weapon = (bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT) ? WPN_LOW_BODY_TEMP : WPN_HIGH_BODY_TEMP
			apply_damage(temp_damage, BURN, used_weapon = temp_weapon)
	else
		fire_alert = 0

	//Account for massive pressure differences
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			adjustBruteLoss( min( ( (adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
			pressure_alert = 2
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

	return
/*
/mob/living/carbon/monkey/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(status_flags & GODMODE)
		return
	var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
	//adjustFireLoss(2.5*discomfort)

	if(exposed_temperature > bodytemperature)
		adjustFireLoss(20.0*discomfort)

	else
		adjustFireLoss(5.0*discomfort)*/

/mob/living/carbon/monkey/proc/get_body_temperature_damage(var/temperature)
	var/datum/species/species = all_species[greaterform]
	if (temperature < species.cold_level_3)
		return COLD_DAMAGE_LEVEL_3
	else if (temperature < species.cold_level_2)
		return COLD_DAMAGE_LEVEL_2
	else if (temperature < species.cold_level_1)
		return COLD_DAMAGE_LEVEL_1
	else if (temperature >= species.heat_level_1)
		return HEAT_DAMAGE_LEVEL_1
	else if (temperature >= species.heat_level_2)
		return HEAT_DAMAGE_LEVEL_2
	else if (temperature >= species.heat_level_3)
		return HEAT_DAMAGE_LEVEL_3
	else
		return 0

/mob/living/carbon/monkey/proc/handle_chemicals_in_body()


	if(alien) //Diona nymphs are the only alien monkey currently.
		var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
		if(isturf(loc)) //else, there's considered to be no light
			var/turf/T = loc
			if(T.dynamic_lighting)
				light_amount = (T.get_lumcount() * 10) - 5
			else
				light_amount = 5
		nutrition += light_amount
		pain_shock_stage -= light_amount

		if(nutrition > 500)
			nutrition = 500
		if(light_amount > 2) //if there's enough light, heal
			adjustBruteLoss(-1)
			adjustToxLoss(-1)
			adjustOxyLoss(-1)
	burn_calories(HUNGER_FACTOR,1)
	if(reagents)
		reagents.metabolize(src,alien)

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

/mob/living/carbon/monkey/proc/handle_regular_status_updates()
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
		if((getOxyLoss() > 25 || config.health_threshold_crit > health) && !(status_flags & BUDDHAMODE))
			if( health <= 20 && prob(1) )
				spawn(0)
					emote("gasp")
			if(!reagents.has_any_reagents(list(INAPROVALINE,PRESLOMITE)))
				adjustOxyLoss(1)
			Paralyse(3)
		if(halloss > 100)
			to_chat(src, "<span class='notice'>You're in too much pain to keep going...</span>")
			for(var/mob/O in oviewers(src, null))
				O.show_message("<B>[src]</B> slumps to the ground, too weak to continue fighting.", 1)
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

		if(stuttering)
			stuttering = max(stuttering-1, 0)

		if(say_mute)
			say_mute = max(say_mute-1, 0)

		if(silent)
			silent = max(silent-1, 0)

		if(druggy)
			druggy = max(druggy-1, 0)
	return 1


/mob/living/carbon/monkey/handle_regular_hud_updates()
	if(!client)
		return

	regular_hud_updates()

	if (stat == 2 || (M_XRAY in mutations))
		change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if (stat != 2)
		change_sight(removing = SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 2
		see_invisible = SEE_INVISIBLE_LIVING

		if(glasses)
			handle_glasses_vision_updates(glasses)


	if (healths)
		if (stat != 2)
			switch(health)
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(80 to 100)
					healths.icon_state = "health1"
				if(60 to 80)
					healths.icon_state = "health2"
				if(40 to 60)
					healths.icon_state = "health3"
				if(20 to 40)
					healths.icon_state = "health4"
				if(0 to 20)
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

	if (stat != 2)
		if (machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(client && !client.adminobs && !isTeleViewing(client.eye))
				reset_view(null)

	return 1

/mob/living/carbon/monkey/proc/handle_random_events()
	if (prob(1) && prob(2))
		spawn(0)
			emote("scratch")
			return

/**
 * Returns a number between -2 to 2.
 * TODO: What's the default return value?
 */
/mob/living/carbon/monkey/eyecheck()
	. = 0
	var/obj/item/clothing/head/headwear = src.hat
	var/obj/item/clothing/glasses/eyewear = src.glasses

	if (istype(headwear))
		. += headwear.eyeprot

	if (istype(eyewear))
		. += eyewear.eyeprot

	return clamp(., -2, 2)

///FIRE CODE
/mob/living/carbon/monkey/handle_fire()
	if(..())
		return
	adjustFireLoss(6)
	return
//END FIRE CODE
