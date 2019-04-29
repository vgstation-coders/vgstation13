/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	//M.delayNextAttack(10)
	if(check_shields(0, M))
		visible_message("<span class='borange'>[M] attempted to touch [src]!</span>")
		return 0

	switch(M.a_intent)
		if (I_HELP)
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")

		if (I_GRAB)
			return M.grab_mob(src)

		if(I_HURT)
			return M.unarmed_attack_mob(src)

		if(I_DISARM)
			return M.disarm_mob(src)
