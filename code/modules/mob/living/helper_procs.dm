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

	. = strength

/mob/living/proc/feels_pain()
	return TRUE

/mob/living/proc/isDeadorDying()	//returns 1 if dead or in crit
	if(stat == DEAD || health <= config.health_threshold_crit)
		return TRUE
