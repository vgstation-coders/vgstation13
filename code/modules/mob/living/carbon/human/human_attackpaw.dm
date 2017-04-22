/mob/living/carbon/human/attack_paw(mob/living/M)
	..()
	//M.delayNextAttack(10)
	switch(M.a_intent)
		if(I_HELP)
			help_shake_act(M)
		else
			M.unarmed_attack_mob(src)
