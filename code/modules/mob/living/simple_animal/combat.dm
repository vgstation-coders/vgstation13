#define is_nuzzling (melee_damage_upper == 0)

/mob/living/simple_animal/get_unarmed_damage()
	return rand(melee_damage_lower, melee_damage_upper)

/mob/living/simple_animal/get_unarmed_damage_type()
	return melee_damage_type

/mob/living/simple_animal/get_unarmed_verb()
	return (is_nuzzling ? friendly : attacktext)

/mob/living/simple_animal/get_unarmed_hit_sound()
	return attack_sound

/mob/living/simple_animal/unarmed_attack_mob()
	if(!melee_damage_upper && size == SIZE_TINY) //No nuzzling for mice
		return
	return ..()

/mob/living/simple_animal/get_attack_message(mob/living/target, attack_verb)
	if(attack_verb == friendly)
		return "<span class='info'>[src] [attack_verb] \the [target].</span>" //Different span class (default is 'danger')
	return ..()

/mob/living/simple_animal/miss_unarmed_attack()
	if(is_nuzzling)
		return
	return ..()

#undef is_nuzzling
