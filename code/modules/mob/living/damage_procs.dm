
/*
	apply_damage(a,b,c)
	args
	a:damage - How much damage to take
	b:damage_type - What type of damage to take, brute, burn
	c:def_zone - Where to take the damage if its brute or burn
	Returns
	standard 0 if fail
*/
/mob/living/proc/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/used_weapon = null, ignore_events = 0)
	if(!damage)
		return 0
	var/damage_done = (damage/100)*(100-blocked)
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage_done)
		if(BURN)
			if(M_RESIST_HEAT in mutations)
				damage_done = 0
			adjustFireLoss(damage_done)
		if(TOX)
			adjustToxLoss(damage_done)
		if(OXY)
			adjustOxyLoss(damage_done)
		if(CLONE)
			adjustCloneLoss(damage_done)
		if(HALLOSS)
			adjustHalLoss(damage_done)
		if(BRAIN)
			adjustBrainLoss(damage_done)
	updatehealth()

	return damage_done


/mob/living/proc/apply_damages(var/brute = 0, var/burn = 0, var/tox = 0, var/oxy = 0, var/clone = 0, var/halloss = 0, var/def_zone = null, var/blocked = 0)
	if(blocked >= 100)
		return 0
	if(brute)
		apply_damage(brute, BRUTE, def_zone, blocked)
	if(burn)
		apply_damage(burn, BURN, def_zone, blocked)
	if(tox)
		apply_damage(tox, TOX, def_zone, blocked)
	if(oxy)
		apply_damage(oxy, OXY, def_zone, blocked)
	if(clone)
		apply_damage(clone, CLONE, def_zone, blocked)
	if(halloss)
		apply_damage(halloss, HALLOSS, def_zone, blocked)
	return 1



/mob/living/proc/apply_effect(var/effect = 0,var/effecttype = STUN, var/blocked = 0)
	if(!effect)
		return 0
	var/altered = (effect/100)*(100-blocked)
	switch(effecttype)
		if(STUN)
			Stun(altered)
		if(WEAKEN)
			Knockdown(altered)
		if(PARALYZE)
			Paralyse(altered)
		if(AGONY)
			altered = effect
			halloss += altered // Useful for objects that cause "subdual" damage. PAIN!
		if(IRRADIATE)
			altered = max(0, (effect/100)*(100-getarmor(null, "rad"))) //Get overall radiation protection, rather than point-exposure
			radiation += altered
		if(STUTTER)
			if(status_flags & CANSTUN) // stun is usually associated with stutter
				altered = max(stuttering,altered)
				stuttering = altered
		if(EYE_BLUR)
			altered = max(eye_blurry,altered)
			eye_blurry = altered
		if(DROWSY)
			altered = max(drowsyness,altered)
			drowsyness = altered
	updatehealth()
	return altered


/mob/living/proc/apply_effects(var/stun = 0, var/weaken = 0, var/paralyze = 0, var/irradiate = 0, var/stutter = 0, var/eyeblur = 0, var/drowsy = 0, var/agony = 0, var/blocked = 0)
	if(blocked >= 100)
		return 0
	if(stun)
		apply_effect(stun, STUN, blocked)
	if(weaken)
		apply_effect(weaken, WEAKEN, blocked)
	if(paralyze)
		apply_effect(paralyze, PARALYZE, blocked)
	if(irradiate)
		apply_effect(irradiate, IRRADIATE, blocked)
	if(stutter)
		apply_effect(stutter, STUTTER, blocked)
	if(eyeblur)
		apply_effect(eyeblur, EYE_BLUR, blocked)
	if(drowsy)
		apply_effect(drowsy, DROWSY, blocked)
	if(agony)
		apply_effect(agony, AGONY, blocked)
	return 1

/mob/living/ashify()
	return //let's not go ashy, shall we?

/mob/living/proc/apply_radiation(var/rads, var/application = RAD_EXTERNAL)
	if(application == RAD_EXTERNAL) //Supermatter, PA particles, jukebox, transmitter
		return apply_effect(rads, IRRADIATE)
	if(application == RAD_INTERNAL) //
		radiation += rads
		return rads
