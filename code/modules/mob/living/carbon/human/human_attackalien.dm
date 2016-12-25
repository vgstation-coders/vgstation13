/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	//M.delayNextAttack(10)
	if(check_shields(0, M.name))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>")
		return 0

	switch(M.a_intent)
		if (I_HELP)
			visible_message(text("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>"))
		if (I_GRAB)
			return M.grab_mob(src)

		if(I_HURT)
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = rand(15, 30)
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has lunged at [src]!</span>")
				return 0
			var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>")

			apply_damage(damage, BRUTE, affecting, armor_block)
			if (damage >= 25)
				visible_message("<span class='danger'>[M] has wounded [src]!</span>")
				apply_effect(rand(0.5,3), WEAKEN, armor_block)
			updatehealth()

		if(I_DISARM)
			return M.disarm_mob(src)

	return