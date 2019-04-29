/mob/living/proc/grab_mob(mob/living/target)
	if(grab_check(target))
		return

	if (is_pacified(VIOLENCE_DEFAULT,target))
		return

	if(target.locked_to)
		to_chat(src, "<span class='notice'>You cannot grab \the [target], \he is buckled in!</span>")
		return

	var/obj/item/weapon/grab/G = getFromPool(/obj/item/weapon/grab, src, target)
	if(!G)	//the grab will delete itself in New if affecting is anchored
		return

	put_in_active_hand(G)
	target.grabbed_by += G

	G.synch()
	target.LAssailant = src
	target.grabbed_by(src)

	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	visible_message("<span class='warning'>[src] grabs [target] passively!</span>")
	return 1

/mob/living/proc/grabbed_by(mob/living/grabber)
	return

/mob/living/proc/disarm_mob(mob/living/target)
	return

/mob/living/proc/disarmed_by(mob/living/disarmer) //For if you want to do something specific on disarm and nothing else.
	return FALSE

/mob/living/proc/break_grabs(mob/living/target)
	for(var/obj/item/weapon/grab/G in target.held_items)
		if(G.affecting)
			visible_message("<span class='danger'>[src] has broken [target]'s grip on [G.affecting]!</span>")
		spawn(1)
			qdel(G)
			G = null

		. = TRUE

/mob/living/proc/can_be_grabbed(mob/living/grabber)
	return TRUE

/mob/living/proc/break_pulls(mob/living/target)
	if(target.pulling)
		visible_message("<span class='danger'>[src] has broken [target]'s grip on [target.pulling]!</span>")
		target.stop_pulling()
		return TRUE

/mob/living/proc/get_unarmed_damage(var/atom/victim)
	return rand(0,10)

/mob/living/proc/get_unarmed_sharpness(mob/living/victim)
	return 0

/mob/living/proc/get_unarmed_verb(mob/living/victim)
	return "hits"

/mob/living/proc/get_unarmed_hit_sound(mob/living/victim)
	return "punch"

/mob/living/proc/get_unarmed_miss_sound(mob/living/victim)
	return 'sound/weapons/punchmiss.ogg'

/mob/living/proc/get_unarmed_damage_type(mob/living/victim)
	return BRUTE

/mob/living/proc/get_unarmed_damage_zone(mob/living/victim)
	if(zone_sel)
		return zone_sel.selecting

	return pick(LIMB_CHEST, LIMB_LEFT_HAND, LIMB_RIGHT_HAND, LIMB_LEFT_ARM, LIMB_RIGHT_ARM, LIMB_LEFT_LEG, LIMB_RIGHT_LEG, LIMB_LEFT_FOOT, LIMB_RIGHT_FOOT, LIMB_HEAD)

/mob/living/proc/miss_unarmed_attack(mob/living/target)
	var/miss_sound = get_unarmed_miss_sound(target)

	if(miss_sound)
		playsound(loc, miss_sound, 25, 1, -1)

	visible_message("<span class='borange'>[src] misses [target]!</span>")
	return TRUE

/mob/living/proc/get_attack_message(mob/living/target, attack_verb)
	return "<span class='danger'>[src] [attack_verb] \the [target]!</span>"

//Armor modifier is a value that multiplies effect of armor on the attack's target. The higher it is, the less effective your attacks are vs armor. 2 means armor is twice as effective, etc.
/mob/living/proc/get_armor_modifier(mob/living/target)
	return 1

/mob/living/proc/unarmed_attack_mob(mob/living/target)
	if(is_pacified(VIOLENCE_DEFAULT,target))
		return

	var/damage = get_unarmed_damage(target)

	if(!damage)
		if(miss_unarmed_attack(target))
			return

	var/zone = ran_zone(get_unarmed_damage_zone(target))
	var/datum/organ/external/affecting = target.get_organ(zone)
	var/armor_block = target.run_armor_check(affecting, "melee", modifier = get_armor_modifier(target))
	var/damage_type = get_unarmed_damage_type(target)
	var/sharpness = get_unarmed_sharpness(target)
	var/attack_verb = get_unarmed_verb(target)
	var/attack_sound = get_unarmed_hit_sound(target)

	if(attack_sound)
		playsound(loc, attack_sound, 25, 1, -1)

	visible_message(get_attack_message(target, attack_verb))
	do_attack_animation(target, src)

	var/damage_done
	if(ishuman(target))
		damage_done = target.apply_damage(damage, damage_type, affecting, armor_block, sharpness)
	else
		damage += sharpness
		damage_done = target.apply_damage(damage, damage_type, affecting, armor_block)

	if(target.BrainContainer)
		target.BrainContainer.SendSignal(COMSIG_ATTACKEDBY, list("assailant"=src,"damage"=damage_done))
	target.unarmed_attacked(src, damage, damage_type, zone)
	after_unarmed_attack(target, damage, damage_type, affecting, armor_block)

	add_logs(src, target, "attacked ([damage_done]dmg)", admin = (src.ckey && target.ckey) ? TRUE : FALSE) //Only add this to the server logs if both mobs were controlled by player

	return damage_done

/mob/living/proc/after_unarmed_attack(mob/living/target, damage, damage_type, organ, armor)
	return

/mob/living/proc/unarmed_attacked(mob/living/attacker, damage, damage_type, zone)
	return

//Affects the chance of getting stunned by a punch
//Chance is multiplied by the returned value
/mob/living/proc/knockout_chance_modifier()
	return 0
