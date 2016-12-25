/mob/living/carbon/slime/unarmed_attacked(mob/living/attacker, damage, damage_type, zone)
	.=..()

	if(health > 10)
		attacked += 10
