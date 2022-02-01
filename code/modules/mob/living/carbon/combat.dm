
/mob/living/carbon/hitby(var/obj/item/I, var/speed, var/dir)
	if(istype(I) && isturf(I.loc) && in_throw_mode) //Only try to catch things while we have throwing mode active (also only items please)
		if(can_catch(I, speed) && put_in_hands(I))
			visible_message("<span class='warning'>\The [src] catches \the [I][speed > EMBED_THROWING_SPEED ? ". Wow!" : "!"]</span>")
			throw_mode_off()
			return TRUE
		else
			to_chat(src, "<span class='warning'>You fail to catch \the [I]!")
	INVOKE_EVENT(src, /event/hitby, "victim" = src, "item" = I)
	return ..()

/mob/living/carbon/proc/can_catch(var/obj/item/I, var/speed)
	if(restrained() || get_active_hand())
		return FALSE
	if(speed > EMBED_THROWING_SPEED) //Can't catch things going too fast unless you're a special boy
		if((M_RUN in mutations) || (reagents && reagents.has_reagent(METHYLIN)))
			return TRUE
		else
			return FALSE
	return TRUE


//Checks armor, special attackby of object instances, and miss chance
/mob/living/carbon/proc/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone, var/originator = null, var/crit = FALSE)
	if(!I || !user)
		return FALSE
	target_zone = null
	var/power = I.force
	if (crit)
		power *= CRIT_MULTIPLIER

	if(def_zone)
		target_zone = get_zone_with_miss_chance(def_zone, src)
	else if(originator)
		if(ismob(originator))
			var/mob/M = originator
			target_zone = get_zone_with_miss_chance(M.zone_sel.selecting, src)
	else
		target_zone = get_zone_with_miss_chance(user.zone_sel.selecting, src)

	if(user == src) // Attacking yourself can't miss
		target_zone = user.zone_sel.selecting
	if(!target_zone && !src.stat)
		visible_message("<span class='borange'>[user] misses [src] with \the [I]!</span>")
		add_logs(user, src, "missed", admin=1, object=I, addition="intended damage: [power]")
		if(I.miss_sound)
			playsound(loc, I.miss_sound, 50)
		on_dodge(user, I)
		return FALSE
	if(I.hitsound)
		playsound(loc, I.hitsound, 50, 1, -1)
	if((user != src) && check_shields(power, I))
		add_logs(user, src, "shieldbounced", admin=1, object=I, addition="intended damage: [power]")
		return FALSE

	user.do_attack_animation(src, I)

	var/datum/organ/external/affecting = get_organ(target_zone)
	var/armor
	if(affecting)
		var/hit_area = affecting.display_name
		armor = run_armor_check(affecting, "melee", "Your armor protects your [hit_area].", "Your armor softens the hit to your [hit_area].", armor_penetration = I.armor_penetration)
		if(armor >= 100)
			add_logs(user, src, "armor bounced", admin=1, object=I, addition="weapon force vs armor: [power] - [armor]")
			return TRUE //We still connected
		if(!power)
			add_logs(user, src, "ineffectively attacked", admin=1, object=I, addition="weapon force: [power]")
			return TRUE
	var/damage = run_armor_absorb(target_zone, I.damtype, power)
	if(originator)
		add_logs(originator, src, "damaged", admin=1, object=I, addition="DMG: [max(damage - armor, 0)]")
	else
		add_logs(user, src, "damaged", admin=1, object=I, addition="DMG: [max(damage - armor, 0)]")

	apply_damage(damage, I.damtype, affecting, armor , I.is_sharp(), used_weapon = I)
	INVOKE_EVENT(src, /event/attacked_by, "attacked" = src, "attacker" = user, "item" = I)
	return TRUE

/mob/living/carbon/proc/check_shields(var/damage = 0, var/atom/A)
	if(!incapacitated())
		for(var/obj/item/I in held_items)
			if(I.IsShield() && I.on_block(damage, A))
				return 1

	return 0

/mob/living/carbon/PreImpact(atom/movable/A, speed)
	if(isobj(A))
		var/obj/O = A
		if(check_shields(O.throwforce*(speed/5),O))
			return TRUE
	else
		return ..()

//Tackle procs/////

/mob/proc/doTackle(var/atom/A)
	return

/mob/living/carbon/doTackle(var/atom/A)
	if(throw_delayer.blocked())
		return
	delayNextThrow(10)
	throw_mode_off()
	if(!get_turf(src) || istype(get_turf(src), /turf/space))
		to_chat(src, "<span class='warning'>You need more footing to do that!</span>")
		return
	if(restrained() || lying || locked_to || stat)
		return
	var/tRange = calcTackleRange()
	isTackling = TRUE
	knockdown = max(knockdown, 3)	//Not using the Knockdown() proc as it created odd behaviour with hulks and another knockdown immune
	update_canmove()
	throw_at(A, tRange, 1)

/mob/living/carbon/throw_impact(atom/hit_atom, speed, user)
	if(isTackling)
		if(!throwing)
			isTackling = FALSE	//Safety from throw_at being a jerk
		else
			var/tackleForce = calcTackleForce()
			if(isliving(hit_atom))
				add_attacklogs(src, hit_atom, "tackled")
				var/mob/living/L = hit_atom
				visible_message("<span class='warning'>[src] tackles [L]!</span>")

				var/tackleDefense = L.calcTackleDefense(src)
				var/rngForce = rand(tackleForce/2, tackleForce)	//RNG or else most people would just bounce off each other.
				var/rngDefense = rand(tackleDefense/2, tackleDefense)
				var/tKnock = max(0, rngDefense - rngForce)
				tKnock /= 10	//Numbers were inflated a digit to allow flexibility, now they need to be smaller
				Knockdown(min(4, tKnock)) //To prevent eternity knockdown from tackling an 8 riot shield martian or something
				tKnock = max(0, rngForce - rngDefense)	//Calculating their knockdown, they might not get knocked down at all
				if(tKnock)
					tKnock /= 10
					L.Knockdown(min(3, tKnock))
					if(M_HORNS in mutations)
						tKnock += 5
					L.adjustBruteLoss(tKnock)
					for (var/obj/held in L.held_items)
						var/dir = pick(alldirs)
						var/turf/target = get_turf(src)
						for(var/i in 1 to 3)
							target = get_step(target, dir)
						L.throw_item(target, held)
			spawn(3)	//Just to let throw_impact stop throwing a tantrum
				isTackling = FALSE
	..()

/mob/living/carbon/to_bump(atom/Obstacle)
	..()
	if(isTackling)
		if(!throwing)
			isTackling = FALSE	//Safety from throw_at being a jerk
		else
			playsound(src, "trayhit", 75, 1)
			var/tPain = rand(5,15)
			adjustBruteLoss(tPain)
			Knockdown(tPain/2)

/mob/living/carbon/calcTackleRange(var/tR = 0)
	tR += bonusTackleRange()
	if(isninja(src))
		tR += 1	//Avoiding tR++ for readability and ease of editing later
	if(M_RUN in mutations)
		tR += 1
	return tR

/mob/living/carbon/calcTackleForce(var/tForce = 50)
	if(world.time > last_moved + 1 SECONDS)	//If you haven't moved in the last second you do a weaker "standing tackle"
		tForce -= 20
	else
		tForce += 10
	tForce += get_strength()*10
	tForce += offenseMutTackle()
	tForce += bonusTackleForce()
	return max(0, tForce)

/mob/living/carbon/proc/offenseMutTackle(var/tF = 0)
	for(var/M in mutations)
		switch(M)
			if(M_HULK)
				tF += 20 //hulk also contributes to get_strength() so the bonus is higher than appears here
			if(M_FAT)
				tF += 15
			if(M_VEGAN)
				tF -= 15
			if(M_DWARF)
				tF -= 20
	return tF

/mob/living/carbon/calcTackleDefense(atom/attacker, var/tDef = 50)
	tDef += get_strength()*10
	if(check_shields(15, attacker))
		tDef += 35
	tDef += defenseMutTackle()
	tDef += bonusTackleDefense()
	return max(0, tDef)

/mob/living/carbon/proc/defenseMutTackle(var/tD = 0)
	for(var/M in mutations)
		switch(M)
			if(M_FAT)
				tD += 25
			if(M_VEGAN)
				tD -= 15
			if(M_CLUMSY)	//The clown fears fatsec
				tD -= 20
				playsound(loc, 'sound/items/bikehorn.ogg', 20, 1)
			if(M_DWARF)
				tD -= 20
	return tD

/mob/living/carbon/proc/bonusTackleForce(var/tF = 25)
	return tF

/mob/living/carbon/proc/bonusTackleDefense(var/tD = 25)
	return tD

/mob/living/carbon/proc/bonusTackleRange(var/tR = 3)
	return tR
