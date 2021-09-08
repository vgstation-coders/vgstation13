
/mob/living/carbon/hitby(var/obj/item/I, var/speed, var/dir)
	if(istype(I) && isturf(I.loc) && in_throw_mode) //Only try to catch things while we have throwing mode active (also only items please)
		if(can_catch(I, speed) && put_in_hands(I))
			visible_message("<span class='warning'>\The [src] catches \the [I][speed > EMBED_THROWING_SPEED ? ". Wow!" : "!"]</span>")
			throw_mode_off()
			return TRUE
		else
			to_chat(src, "<span class='warning'>You fail to catch \the [I]!")
	invoke_event(/event/hitby, list("victim" = src, "item" = I))
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
	invoke_event(/event/attacked_by, list("attacked" = src, "attacker" = user, "item" = I))
	return TRUE

/mob/living/carbon/proc/check_shields(var/damage = 0, var/atom/A)
	if(!incapacitated())
		for(var/obj/item/weapon/I in held_items)
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
	delayNextThrow(3)
	throw_mode_off()
	if(!get_turf(src) || istype(get_turf(src), /turf/space))
		to_chat(src, "<span class='warning'>You need more footing to do that!")
		return
	if(restrained() || lying || stat)
		return
	var/tRange = calcTackleRange()
	isTackling = TRUE
	Knockdown(2)
	throw_at(A, tRange, 3)

/mob/living/carbon/throw_impact(atom/hit_atom, speed, user)
	if(isTackling)
		var/tackleForce = calcTackleForce()
		if(isliving(hit_atom))
			var/mob/living/L = hit_atom
			var/tackleDefense = L.calcTackleDefense()
			var/rngForce = rand(tackleForce/2, tackleForce)	//RNG or else most people would just bounce off each other.
			var/rngDefense = rand(tackleDefense/2, tackleDefense)
			var/tKnock = max(0, rngDefense - rngForce)	//Calculating our knockdown, we always get knocked down at least a little
			Knockdown(tKnock)
			tKnock = max(0, rngForce - rngDefense)	//Calculating their knockdown, they might not get knocked down at all
			if(tKnock)
				L.Knockdown(tKnock)
				if(M_HORNS in mutations)
					tKnock += 5
				L.adjustBruteLoss(tKnock)
		else if(hit_atom.density)
			var/tPain = rand(1,10)
			adjustBruteLoss(tPain)
			Knockdown(tPain/2)
		spawn(3)	//Just to let throw_impact stop throwing a tantrum
			isTackling = FALSE
	..()

/mob/living/carbon/calcTackleRange(var/tR = 0)
	tR += bonusTackleRange()
	if(isninja(src))
		tR += 1	//Avoiding tR++ for readability and ease of editing later
	if(M_RUN in mutations)
		tR += 1
	return tR

/mob/living/carbon/calcTackleForce(var/tForce = 0)
	tForce += get_strength()*2
	if(M_HULK in mutations)
		tForce += 2	//hulk also contributes to get_strength() so the bonus is higher than appears here
	if(M_FAT in mutations)
		tForce += 3
	tForce += bonusTackleForce()
	if(M_VEGAN in mutations)
		tForce -= 1
	return max(0, tForce)

/mob/living/carbon/calcTackleDefense(var/tDef = 0)
	tDef += get_strength()
	if(M_FAT in mutations)
		tDef += 2
	for(var/obj/item/weapon/I in held_items)
		if(I.IsShield())
			tDef += 5
	tDef += bonusTackleDefense()
	if(M_VEGAN in mutations)
		tDef -= 1
	if(M_CLUMSY in mutations)	//The clown fears fatsec
		tDef -= 2
	return max(0, tDef)

/mob/living/carbon/proc/bonusTackleForce(var/tF = 1)
	return tF

/mob/living/carbon/proc/bonusTackleDefense(var/tD = 1)
	return tD

/mob/living/carbon/proc/bonusTackleRange(var/tR = 1)
	return tR
