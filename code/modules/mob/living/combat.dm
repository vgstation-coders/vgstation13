/mob/living/proc/grab_mob(mob/living/target)
	if(grab_check(target))
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

/mob/living/proc/disarmed_by(mob/living/disarmer)
	return

/mob/living/proc/break_grabs(mob/living/target)
	for(var/obj/item/weapon/grab/G in target.held_items)
		if(G.affecting)
			visible_message("<span class='danger'>[src] has broken [target]'s grip on [G.affecting]!</span>")
		spawn(1)
			qdel(G)
			G = null

		. = TRUE

/mob/living/proc/break_pulls(mob/living/target)
	if(target.pulling)
		visible_message("<span class='danger'>[src] has broken [target]'s grip on [target.pulling]!</span>")
		target.stop_pulling()
		return TRUE

/mob/living/proc/get_unarmed_damage(mob/living/victim)
	return rand(0,10)

/mob/living/proc/get_unarmed_verb(mob/living/victim)
	return "hit"

/mob/living/proc/get_unarmed_hit_sound(mob/living/victim)
	return "punch"

/mob/living/proc/get_unarmed_miss_sound(mob/living/victim)
	return 'sound/weapons/punchmiss.ogg'

/mob/living/proc/get_unarmed_damage_type(mob/living/victim)
	return BRUTE

/mob/living/proc/unarmed_attack_mob(mob/living/target)
	var/damage = get_unarmed_damage(target)

	if(!damage)
		playsound(loc, get_unarmed_miss_sound(target), 25, 1, -1)
		visible_message("<span class='danger'>[src] has missed [target]!</span>")
		return

	var/zone = ran_zone(zone_sel.selecting)
	var/datum/organ/external/affecting = target.get_organ(zone)
	var/armor_block = target.run_armor_check(affecting, "melee")
	var/damage_type = get_unarmed_damage_type(target)
	var/attack_verb = get_unarmed_verb(target)

	playsound(loc, get_unarmed_hit_sound(target), 25, 1, -1)
	visible_message("<span class='danger'>[src] has [attack_verb] [target]!</span>")

	var/damage_done = target.apply_damage(damage, damage_type, affecting, armor_block)
	target.unarmed_attacked(src, damage, damage_type, zone)
	after_unarmed_attack(target, damage, damage_type, affecting, armor_block)

	return damage_done

/mob/living/proc/after_unarmed_attack(mob/living/target, damage, damage_type, organ, armor)
	return

/mob/living/proc/unarmed_attacked(mob/living/attacker, damage, damage_type, zone)
	return
