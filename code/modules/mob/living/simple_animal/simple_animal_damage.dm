/mob/living/simple_animal/adjustBruteLoss(damage)

	if(INVOKE_EVENT(on_damaged, list("type" = BRUTE, "amount" = damage)))
		return 0
	if(skinned())
		damage = damage * 2
	if(purge)
		damage = damage * 2

	health = Clamp(health - damage, 0, maxHealth)
	if(health < 1 && stat != DEAD)
		death()

/mob/living/simple_animal/adjustFireLoss(damage)
	if(status_flags & GODMODE)
		return 0
	if(mutations.Find(M_RESIST_HEAT))
		return 0
	if(INVOKE_EVENT(on_damaged, list("type" = BURN, "amount" = damage)))
		return 0
	if(skinned())
		damage = damage * 2
	if(purge)
		damage = damage * 2
	health = Clamp(health - damage, 0, maxHealth)
	if(health < 1 && stat != DEAD)
		death()

/mob/living/simple_animal/ex_act(severity)
	if(flags & INVULNERABLE)
		return
	..()
	switch (severity)
		if (1.0)
			adjustBruteLoss(500)
			gib()
			return

		if (2.0)
			adjustBruteLoss(60)


		if(3.0)
			adjustBruteLoss(30)

/mob/living/simple_animal/proc/reagent_act(id, method, volume)
	if(isDead())
		return

	switch(id)
		if(SACID)
			if(!supernatural)
				adjustBruteLoss(volume * 0.5)
		if(PACID)
			if(!supernatural)
				adjustBruteLoss(volume * 0.5)