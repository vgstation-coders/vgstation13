/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	if(check_shields(0, M))
		return 0

	M.unarmed_attack_mob(src)