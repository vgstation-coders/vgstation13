/mob/living/simple_animal/get_unarmed_damage()
	return rand(melee_damage_lower, melee_damage_upper)

/mob/living/simple_animal/get_unarmed_damage_type()
	return melee_damage_type

/mob/living/simple_animal/get_unarmed_verb()
	return (melee_damage_upper == 0 ? friendly : attacktext)

/mob/living/simple_animal/get_unarmed_hit_sound()
	return attack_sound
