
/mob/living/carbon/hitby(var/obj/item/I, var/speed, var/dir)
	if(istype(I) && isturf(I.loc) && in_throw_mode) //Only try to catch things while we have throwing mode active (also only items please)
		if(can_catch(I, speed) && put_in_hands(I))
			visible_message("<span class='warning'>\The [src] catches \the [I][speed > EMBED_THROWING_SPEED ? ". Wow!" : "!"]</span>")
			throw_mode_off()
			return TRUE
		else
			to_chat(src, "<span class='warning'>You fail to catch \the [I]!")
	INVOKE_EVENT(on_touched, list("user" = src, "hit by" = I))
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
	var/target_zone = null
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
		return FALSE

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
	INVOKE_EVENT(on_touched, list("user" = src, "attacked by" = I))
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
