/mob/living/carbon/complex/get_unarmed_damage_zone(mob/living/victim)
	return zone_sel.selecting

/mob/living/carbon/complex/knockout_chance_modifier()
	return 0 //Punches don't stun

/mob/living/carbon/complex/bullet_act(var/obj/item/projectile/P, var/def_zone)
	if(check_shields(P.damage, P))
		P.on_hit(src, 2)
		return 2
	return (..(P , def_zone))

/mob/living/carbon/complex/attack_hand(mob/living/M)
	switch(M.a_intent)
		if(I_HELP)
			help_shake_act(M)

		if(I_HURT)
			M.unarmed_attack_mob(src)

		if(I_GRAB)
			M.grab_mob(src)

		if(I_DISARM)
			M.disarm_mob(src)

/mob/living/carbon/complex/attack_alien(mob/living/M)
	switch(M.a_intent)
		if (I_HELP)
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")

		if (I_HURT)
			return M.unarmed_attack_mob(src)

		if (I_GRAB)
			return M.grab_mob(src)

		if (I_DISARM)
			return M.disarm_mob(src)

/mob/living/carbon/complex/attack_slime(mob/living/carbon/slime/M)
	M.unarmed_attack_mob(src)

/mob/living/carbon/complex/attack_martian(mob/M)
	return attack_hand(M)

/mob/living/carbon/complex/attack_paw(mob/M)
	return attack_hand(M)

/mob/living/carbon/complex/disarm_mob(mob/living/target)
	add_logs(src, target, "disarmed", admin = (src.ckey && target.ckey) ? TRUE : FALSE) //Only add this to the server logs if both mobs were controlled by player

	if(target.disarmed_by(src))
		return

	if(prob(40)) //40% miss chance
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		visible_message("<span class='danger'>[src] has attempted to disarm [target]!</span>")
		return

	do_attack_animation(target, src)

	var/datum/organ/external/affecting = get_organ(ran_zone(zone_sel.selecting))

	if(prob(40)) //True chance of something happening per click is hit_chance*event_chance, so in this case the stun chance is actually 0.6*0.4=24%
		target.apply_effect(4, WEAKEN, run_armor_check(affecting, "melee"))
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		visible_message("<span class='danger'>[src] has pushed [target]!</span>")
		add_logs(src, target, "pushed", admin = (src.ckey && target.ckey) ? TRUE : FALSE) //Only add this to the server logs if both mobs were controlled by player
		return

	var/talked = 0

	//Disarming breaks pulls
	talked |= break_pulls(target)

	//Disarming also breaks a grab - this will also stop someone being choked, won't it?
	talked |= break_grabs(target)

	if(!talked)
		target.drop_item()
		visible_message("<span class='danger'>[src] has disarmed [target]!</span>")
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)