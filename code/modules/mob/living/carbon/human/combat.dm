//#define COMBAT_STATS
#ifdef COMBAT_STATS
#define show_combat_stat(x) to_chat(usr, "[x]")
#else
#define show_combat_stat(x) null << x
#endif

/mob/living/carbon/human/grabbed_by(mob/living/grabber)
	if(ishuman(grabber) && w_uniform)
		w_uniform.add_fingerprint(grabber)
	return ..()

/mob/living/carbon/human/disarmed_by(mob/living/disarmer)
	if(ishuman(disarmer) && w_uniform)
		w_uniform.add_fingerprint(disarmer)

	for(var/obj/item/weapon/gun/G in held_items)
		var/index = is_holding_item(G)
		var/chance = (index == active_hand ? 40 : 20)

		if(prob(chance))
			visible_message("<spawn class=danger>[G], held by [src], goes off during struggle!")
			var/list/turfs = list()
			for(var/turf/T in view())
				turfs += T
			var/turf/target = pick(turfs)
			return G.afterattack(target, src, "struggle" = 1)

/mob/living/carbon/human/disarm_mob(mob/living/target)
	add_logs(src, target, "disarmed", admin = (src.ckey && target.ckey) ? TRUE : FALSE) //Only add this to the server logs if both mobs were controlled by player

	if(target.disarmed_by(src))
		return

	var/datum/organ/external/affecting = get_organ(ran_zone(zone_sel.selecting))
	if(prob(40)) //40% miss chance
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		visible_message("<span class='danger'>[src] has attempted to disarm [target]!</span>")
		return

	if(prob(40)) //True chance of something happening per click is hit_chance*event_chance, so in this case the stun chance is actually 0.6*0.4=24%
		target.apply_effect(4, WEAKEN, run_armor_check(affecting, "melee"))
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		visible_message("<span class='danger'>[src] has pushed [target]!</span>")
		add_logs(src, target, "pushed", admin = (src.ckey && target.ckey) ? TRUE : FALSE) //Only add this to the server logs if both mobs were controlled by player
		return

	var/talked = 0

	//Disarming breaks pulls
	talked |= break_pulls(target)

	//Disarming also breaks a grab - this will also stop someone being choked, won't it?
	talked |= break_grabs(target)

	if(!talked)
		target.drop_item()
		visible_message("<span class='danger'>[src] has disarmed [target]!</span>")
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)




/mob/living/carbon/human/get_unarmed_verb()
	return species.attack_verb

/mob/living/carbon/human/get_unarmed_hit_sound()
	return (species.attack_verb == "punches" ? "punch" : 'sound/weapons/slice.ogg')

/mob/living/carbon/human/get_unarmed_miss_sound()
	return (species.attack_verb == "punches" ? 'sound/weapons/punchmiss.ogg' : 'sound/weapons/slashmiss.ogg')

/mob/living/carbon/human/get_unarmed_damage_type(mob/living/target)
	if(ishuman(target) && istype(gloves , /obj/item/clothing/gloves/boxing/hologlove))
		return HALLOSS
	return ..()

/mob/living/carbon/human/get_unarmed_damage()
	var/damage = rand(0, species.max_hurt_damage)
	damage += species.punch_damage

	if(mutations.Find(M_HULK))
		damage += 5
	if(mutations.Find(M_CLAWS) && !istype(gloves))
		damage += 3
	if(istype(gloves))
		var/obj/item/clothing/gloves/G = gloves
		damage += G.damage_added //Increase damage by the gloves' damage modifier

	return damage

/mob/living/carbon/human/proc/get_knockout_chance(mob/living/victim)
	var/base_chance = 8

	if(mutations.Find(M_HULK))
		base_chance += 12
	if(istype(gloves))
		var/obj/item/clothing/gloves/G = gloves
		base_chance += G.bonus_knockout

	base_chance *= victim.knockout_chance_modifier()

	return base_chance

/mob/living/carbon/human/knockout_chance_modifier()
	return 1

/mob/living/carbon/human/after_unarmed_attack(mob/living/target, damage, damage_type, organ, armor)
	var/knockout_chance = get_knockout_chance(target)

	show_combat_stat("Knockout chance: [knockout_chance]")
	if(prob(knockout_chance))
		visible_message("<span class='danger'>[src] has knocked down \the [target]!</span>")
		target.apply_effect(2, WEAKEN, armor)

	if(species.punch_throw_range && prob(25))
		target.visible_message("<span class='danger'>[target] is thrown by the force of the assault!</span>")
		var/turf/T = get_turf(target)
		var/turf/destination
		if(istype(T, /turf/space)) // if ended in space, then range is unlimited
			destination = get_edge_target_turf(T, src.dir)
		else						// otherwise limit to 10 tiles
			destination = get_ranged_target_turf(T, src.dir, src.species.punch_throw_range)
		target.throw_at(destination, 100, src.species.punch_throw_speed)

/mob/living/carbon/human/unarmed_attacked(mob/living/attacker, damage, damage_type, zone)
	if(ishuman(attacker) && w_uniform)
		w_uniform.add_fingerprint(attacker)

	if(zone == "head")
		var/chance = 0.5 * damage
		if(attacker.mutations.Find(M_HULK))
			chance += 50
		if(prob(chance))
			knock_out_teeth(attacker)

	..()

/mob/living/carbon/human/proc/perform_cpr(mob/living/target)
	if(src.check_body_part_coverage(MOUTH))
		to_chat(src, "<span class='notice'><B>Remove your [src.get_body_part_coverage(MOUTH)]!</B></span>")
		return 0
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_body_part_coverage(MOUTH))
			to_chat(src, "<span class='notice'><B>Remove their [H.get_body_part_coverage(MOUTH)]!</B></span>")
			return 0

	if(!target.cpr_time)
		return 0

	src.visible_message("<span class='danger'>\The [src] is trying perform CPR on \the [target]!</span>")

	target.cpr_time = 0
	if(do_after(src, target, 3 SECONDS))
		target.adjustOxyLoss(-min(target.getOxyLoss(), 7))
		src.visible_message("<span class='danger'>\The [src] performs CPR on \the [target]!</span>")
		to_chat(target, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
		to_chat(src, "<span class='warning'>Repeat at least every 7 seconds.</span>")
	target.cpr_time = 1
