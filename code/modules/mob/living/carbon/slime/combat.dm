/mob/living/carbon/slime/unarmed_attacked(mob/living/attacker, damage, damage_type, zone)
	.=..()

	if(health > 10)
		attacked += 10

/mob/living/carbon/slime/get_unarmed_verb()
	return "glomps on"

/mob/living/carbon/slime/get_unarmed_damage(mob/living/target)
	if(isslime(target))
		return rand(1,3)

	return rand(5, 35)

/mob/living/carbon/slime/adult/get_unarmed_damage(mob/living/target)
	if(isslime(target))
		return rand(1,6)

	return rand(15, 40)

/mob/living/carbon/slime/get_unarmed_hit_sound()
	return 'sound/weapons/welderattack.ogg'

/mob/living/carbon/slime/proc/get_stun_chance()
	switch(powerlevel)
		if(1 to 2)
			return 20
		if(3 to 4)
			return 30
		if(5 to 6)
			return 40
		if(7 to 8)
			return 60
		if(9)
			return 70
		if(10)
			return 95
		else
			return 10

/mob/living/carbon/slime/unarmed_attack_mob(mob/living/target)
	if(target.isDead())
		to_chat(src, "<span class='notice'>\The [target] is already dead.</span>")
		return

	if(Victim)
		to_chat(src, "<span class='notice'>You can't attack while eating.</span>")
		return

	add_attacklogs(src, target, "attacked")

	.=..()


	if(powerlevel > 0)
		if(isalien(target) || ishuman(target) || ismonkey(target) || ismartian(target))
			var/stunprob = get_stun_chance()
			var/power = powerlevel + rand(0,3)

			if(prob(stunprob))
				powerlevel = max(powerlevel-3, 0)

				stun_mob(target, power)

				spark(src, 5)

				if (prob(stunprob) && powerlevel >= 8)
					target.adjustFireLoss(powerlevel * rand(6,10))

/mob/living/carbon/slime/proc/stun_mob(mob/living/target, power)
	if(isliving(target))
		target.Knockdown(power)
		target.Stun(power)
		if (target.stuttering < power)
			target.stuttering = power

		visible_message("<span class='danger'>\The [src] has shocked \the [target]!</span>")
	else if(issilicon(target))
		target.flash_eyes(visual = 1, type = /obj/abstract/screen/fullscreen/flash/noise)
		if(powerlevel >= 8)
			adjustBruteLoss(powerlevel * rand(6,10))

		visible_message("<span class='danger'>\The [src] has electrified \the [target]!</span>")
