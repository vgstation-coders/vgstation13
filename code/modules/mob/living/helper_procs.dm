/mob/living/proc/can_inject()
	return 1

/mob/living/proc/InCritical()
	return (src.health < 0 && src.health > -95.0 && stat == UNCONSCIOUS)

/*one proc, four uses
swapping: if it's 1, the mobs are trying to switch, if 0, non-passive is pushing passive
default behaviour is:
 - non-passive mob passes the passive version
 - passive mob checks to see if its mob_bump_flag is in the non-passive's mob_bump_flags
 - if si, the proc returns
*/
/mob/living/proc/can_move_mob(var/mob/living/swapped, swapping = 0, passive = 0)
	if(!swapped)
		return 1
	if(!passive)
		return swapped.can_move_mob(src, swapping, 1)
	else
		var/context_flags = 0
		if(swapping)
			context_flags = swapped.mob_swap_flags
		else
			context_flags = swapped.mob_push_flags
		if(!mob_bump_flag) //nothing defined, go wild
			return 1
		if(mob_bump_flag & context_flags)
			return 1
		return 0

/mob/living/proc/get_strength() //Returns a mob's strength. Isn't used in damage calculations, but rather in things like cutting down trees etc.
	var/strength = 1.0

	strength += (M_HULK in src.mutations)
	strength += (M_STRONG in src.mutations)
	if(reagents)
		strength += (reagents.get_sportiness() >= 5)

	. = strength

/mob/living/proc/feels_pain()
	return TRUE

/mob/living/proc/isDeadorDying()	//returns 1 if dead or in crit
	if(stat == DEAD || health <= config.health_threshold_crit)
		return TRUE

/mob/living/proc/get_splash_burn_damage(splash_vol, splash_temp)
	return round(TEMPERATURE_DAMAGE_COEFFICIENT * SPLASH_SCALD_DAMAGE_COEFFICIENT * abs(splash_vol ** (1/3) * log(get_safe_temperature_excursion(splash_temp) + 1)))

/mob/living/proc/get_safe_temperature_excursion(the_temp)
	//Returns how many degrees K a temperature is outside of the safe range the mob can tolerate. returns 0 if within the safe range. can be negative for cold.
	return 0

/mob/living/simple_animal/get_safe_temperature_excursion(the_temp)
	if (the_temp > maxbodytemp)
		return the_temp - maxbodytemp
	else if (the_temp < minbodytemp)
		return the_temp - minbodytemp
	return 0

/mob/living/carbon/monkey/get_safe_temperature_excursion(the_temp)
	if (the_temp > BODYTEMP_HEAT_DAMAGE_LIMIT)
		return the_temp - BODYTEMP_HEAT_DAMAGE_LIMIT
	else if (the_temp < BODYTEMP_COLD_DAMAGE_LIMIT)
		return the_temp - BODYTEMP_COLD_DAMAGE_LIMIT
	return 0

/mob/living/carbon/human/get_safe_temperature_excursion(the_temp)
	if (species)
		if (the_temp > species.heat_level_1)
			return the_temp - species.heat_level_1
		else if (the_temp < FRIDGETEMP_DEFAULT)//Something below freezing temperature should feel adequately freezing.
			return the_temp - FRIDGETEMP_DEFAULT
		//else if (the_temp < species.cold_level_1)
		//	return the_temp - species.cold_level_1
	else if (the_temp > BODYTEMP_HEAT_DAMAGE_LIMIT)
		return the_temp - BODYTEMP_HEAT_DAMAGE_LIMIT
	else if (the_temp < BODYTEMP_COLD_DAMAGE_LIMIT)
		return the_temp - BODYTEMP_COLD_DAMAGE_LIMIT
	return 0
