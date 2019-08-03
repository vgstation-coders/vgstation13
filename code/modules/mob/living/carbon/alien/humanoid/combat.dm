/mob/living/carbon/alien/humanoid/disarm_mob(mob/living/target)
	if(target.disarmed_by(src))
		return
	var/datum/organ/external/affecting = get_organ(ran_zone(zone_sel.selecting))
	var/disarm_chance_modifier = target.run_armor_check(affecting, "melee", quiet = 1)
	if(prob(100-disarm_chance_modifier))
		do_attack_animation(target, src)
		playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
		target.apply_effect(4, WEAKEN, target.run_armor_check(affecting, "melee"))
		visible_message("<span class='danger'>[src] has tackled down [target]!</span>")

	else if (prob(100-disarm_chance_modifier))
		do_attack_animation(target, src)
		playsound(loc, get_unarmed_hit_sound(), 25, 1, -1)
		target.drop_item()
		break_pulls(target)
		break_grabs(target)
		visible_message("<span class='danger'>[src] has disarmed [target]!</span>")
	else
		playsound(loc, get_unarmed_miss_sound(), 50, 1, -1)
		visible_message("<span class='danger'>[src] has tried to disarm [target]!</span>")

/mob/living/carbon/alien/humanoid/get_unarmed_hit_sound()
	return 'sound/weapons/slash.ogg'

/mob/living/carbon/alien/humanoid/get_unarmed_miss_sound()
	return 'sound/weapons/slashmiss.ogg'

/mob/living/carbon/alien/humanoid/knockout_chance_modifier()
	return 0.25

/mob/living/carbon/alien/humanoid/get_unarmed_verb(mob/living/target)
	if(isalien(target))
		return "bites"

	return "slashes at"

/mob/living/carbon/alien/humanoid/get_unarmed_damage(var/atom/target)
	if(isalien(target))
		return rand(1,3)

	if(prob(5)) //5% miss chance
		return 0

	return rand(15,30)

/mob/living/carbon/alien/humanoid/unarmed_attack_mob(mob/living/target)
	if(isalien(target))
		var/mob/living/carbon/alien/A = target
		if(A.health <= 0)
			to_chat(src, "<span class='alien'>[target] is too injured for that.</span>")
			return

	return ..()

/mob/living/carbon/alien/humanoid/after_unarmed_attack(mob/living/target, damage, damage_type, organ, armor)
	if(iscarbon(target) && !isslime(target))
		if(damage > 25)
			visible_message("<span class='danger'>[src] has wounded [target]!</span>")
			target.apply_effect(rand(5,30)/10, WEAKEN, armor)
