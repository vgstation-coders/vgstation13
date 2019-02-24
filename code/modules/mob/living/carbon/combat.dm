/mob/living/carbon/unarmed_attacked(mob/living/carbon/C)
	if(istype(C))
		share_contact_diseases(C)

	return ..()

/mob/living/carbon/hitby(var/obj/item/I, var/speed, var/dir)
	if(istype(I) && isturf(I.loc) && in_throw_mode) //Only try to catch things while we have throwing mode active (also only items please)
		if(can_catch(I, speed) && put_in_hands(I))
			visible_message("<span class='warning'>\The [src] catches \the [I][speed > EMBED_THROWING_SPEED ? ". Wow!" : "!"]</span>")
			throw_mode_off()
			return TRUE
		else
			to_chat(src, "<span class='warning'>You fail to catch \the [I]!")
	return ..()

/mob/living/carbon/proc/can_catch(var/item/I, var/speed)
	if(restrained() || get_active_hand())
		return FALSE
	if(speed > EMBED_THROWING_SPEED) //Can't catch things going too fast unless you're a special boy
		if((M_RUN in mutations) || (reagents && reagents.has_reagent(METHYLIN)))
			return TRUE
		else
			return FALSE
	return TRUE


//Checks armor, special attackby of object instances, and miss chance
/mob/living/carbon/proc/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone, var/originator = null)
	if(!I || !user)
		return FALSE
	var/target_zone = null
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
		visible_message("<span class='danger'>[user] misses [src] with \the [I]!</span>")
		return FALSE

	if((user != src) && check_shields(I.force, "the [I.name]"))
		return FALSE

	user.do_attack_animation(src, I)

	var/datum/organ/external/affecting = get_organ(target_zone)
	var/armor
	if(affecting)
		var/hit_area = affecting.display_name
		armor = run_armor_check(affecting, "melee", "Your armor protects your [hit_area].", "Your armor softens the hit to your [hit_area].", armor_penetration = I.armor_penetration)
		if(armor >= 2)
			return TRUE //We still connected
		if(!I.force)
			return TRUE
	var/damage = run_armor_absorb(target_zone, I.damtype, I.force)
	apply_damage(damage, I.damtype, affecting, armor , I.is_sharp(), used_weapon = I)

	return TRUE