//BITES
/mob/living/carbon/human/bite_act(mob/living/carbon/human/M as mob)

	var/dam_check = !(istype(loc, /turf) && istype(loc.loc, /area/start)) // 0 or 1

	if(M == src)
		return //Can't bite yourself

	//Vampire code
	if(M.zone_sel && M.zone_sel.selecting == LIMB_HEAD && src != M)
		var/datum/role/vampire/V = isvampire(M)
		if(V)
			if (V.draining)
				return 0
			if(!V.can_suck(src))
				return 0

			if(mind)
				var/datum/role/vampire/V_target = src.mind.GetRole(VAMPIRE)
				if (V_target)
					to_chat(M, "<span class='warning'>Your fangs fail to pierce [src.name]'s cold flesh.</span>")
					return 0
			//we're good to suck the blood, blaah

			playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
			src.visible_message("<span class='danger'>\The [M] has bitten \the [src]!</span>", "<span class='userdanger'>You were bitten by \the [M]!</span>")
			V.handle_bloodsucking(src)
			return
	//end vampire code

	var/armor_modifier = 30
	var/damage = rand(1, 5)*dam_check

	if(M.organ_has_mutation(LIMB_HEAD, M_BEAK)) //Beaks = stronger bites
		armor_modifier = 5
		damage += 4*dam_check

	var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))

	var/armorblock = run_armor_check(affecting, modifier = armor_modifier) //Bites are easy to stop, hence the modifier value
	switch(armorblock)
		if(1) //Partial block
			damage = max(0, damage - 3)
		if(2) //Full block
			damage = 0

	damage = run_armor_absorb(affecting, "melee", damage)
	if(!damage && dam_check)
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		visible_message("<span class='danger'>\The [M] has attempted to bite \the [src]!</span>")
		return 0

	playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
	src.visible_message("<span class='danger'>\The [M] has bitten \the [src]!</span>", "<span class='userdanger'>You were bitten by \the [M]!</span>")
	M.do_attack_animation(src, M)

	for(var/datum/disease/D in M.viruses)
		if(D.spread == "Bite")
			contract_disease(D,1,0)

	apply_damage(damage, BRUTE, affecting)

	M.attack_log += text("\[[time_stamp()]\] <font color='red'>bit [src.name] ([src.ckey]) for [damage] damage</font>")
	src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been bitten by [M.name] ([M.ckey]) for [damage] damage</font>")
	if(!iscarbon(M))
		LAssailant = null
	else
		LAssailant = M
	log_attack("[M.name] ([M.ckey]) bitten by [src.name] ([src.ckey])")
	return

//KICKS
/mob/living/carbon/human/kick_act(mob/living/carbon/human/M)

	var/dam_check = !(istype(loc, /turf) && istype(loc.loc, /area/start)) // 0 or 1

	//Pick a random usable foot to perform the kick with
	var/datum/organ/external/foot_organ = pick_usable_organ(LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT)

	M.delayNextAttack(20) //Kicks are slow

	if((src == M) || (M_CLUMSY in M.mutations) && prob(20)) //Kicking yourself (or being clumsy) = stun
		M.visible_message("<span class='notice'>\The [M] trips while attempting to kick \the [src]!</span>", "<span class='userdanger'>While attempting to kick \the [src], you trip and fall!</span>")
		var/incapacitation_duration = rand(1,10)
		M.Knockdown(incapacitation_duration)
		M.Stun(incapacitation_duration)
		return

	var/stomping = 0
	var/attack_verb = "kicks"

	if(lying && (M.size >= size)) //On the ground, the kicker is bigger than/equal size of the victim = stomp
		stomping = 1

	var/armor_modifier = 1
	var/damage = rand(0,7)*dam_check
	var/knockout = damage

	if(stomping) //Stomps = more damage and armor bypassing
		armor_modifier = 0.5
		damage += rand(0,7)*dam_check
		attack_verb = "stomps on"
	else if(M.reagents && M.reagents.has_reagent(GYRO))
		damage += rand(0,4)*dam_check
		knockout += rand(0,3)
		attack_verb = "roundhouse kicks"

	if(!damage && dam_check) // So that people still think they are biting each other
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		visible_message("<span class='danger'>\The [M] attempts to kick \the [src]!</span>")
		return 0

	if(M_HULK in M.mutations)
		damage +=  3
		knockout += 3

	//Handle shoes
	var/obj/item/clothing/shoes/S = M.shoes
	if(istype(S))
		damage += S.bonus_kick_damage
		S.on_kick(M, src)
	else if(organ_has_mutation(foot_organ, M_TALONS)) //Not wearing shoes and having talons = bonus 1-6 damage
		damage += rand(1,6)

	playsound(loc, "punch", 30, 1, -1)
	visible_message("<span class='danger'>[M] [attack_verb] \the [src]!</span>", "<span class='userdanger'>[M] [attack_verb] you!</span>")
	M.do_attack_animation(src, M)

	if(M.size != size) //The bigger the kicker, the more damage
		damage = max(damage + (rand(1,5) * (1 + M.size - size)), 0)

	var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))

	var/armorblock = run_armor_check(affecting, modifier = armor_modifier) //Bites are easy to stop, hence the modifier value
	damage = max(0, (damage/100)*(100-armorblock))
	damage = run_armor_absorb(affecting, "melee", damage)
	if(knockout >= 7 && prob(33))
		visible_message("<span class='danger'>[M] weakens [src]!</span>")
		apply_effect(3, WEAKEN, armorblock)

	if(isrambler(src) && !(M == src)) //Redundant check for kicking a soul rambler. Punching is in carbon/human/combat.dm
		M.say(pick("Take that!", "Taste the pain!"))

	apply_damage(damage, BRUTE, affecting)

	if(!stomping) //Kicking somebody while holding them with a grab sends the victim flying
		var/obj/item/weapon/grab/G = M.get_inactive_hand()
		if(istype(G) && G.affecting == src)
			spawn()
				returnToPool(G)

				var/throw_dir = M.dir
				if(M.loc != src.loc)
					throw_dir = get_dir(M, src)

				var/turf/T = get_edge_target_turf(get_turf(src), throw_dir)
				var/throw_strength = 3 * M.get_strength()
				throw_at(T, throw_strength, 1)

	M.attack_log += text("\[[time_stamp()]\] <font color='red'>Kicked [src.name] ([src.ckey]) for [damage] damage</font>")
	src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been kicked by [M.name] ([M.ckey]) for [damage] damage</font>")
	if(!iscarbon(M))
		LAssailant = null
	else
		LAssailant = M
	log_attack("[M.name] ([M.ckey]) kicked by [src.name] ([src.ckey])")

/mob/living/carbon/human/attack_hand(var/mob/living/carbon/human/M)
	//M.delayNextAttack(10)
	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	var/datum/organ/external/temp = M.get_active_hand_organ()
	if(temp && !temp.is_usable())
		to_chat(M, "<span class='warning'>You can't use your [temp.display_name].</span>")
		return

	..()

	if((M != src) && check_shields(0, M))
		visible_message("<span class='borange'>[M] attempts to touch [src]!</span>")
		return 0

	var/datum/organ/external/S = src.get_organ(M.zone_sel.selecting)
	if (!(!S || S.status & ORGAN_DESTROYED))
		var/touch_zone = get_part_from_limb(M.zone_sel.selecting)
		var/block = 0
		var/bleeding = 0
		if (M.check_contact_sterility(HANDS) || check_contact_sterility(touch_zone))//only one side has to wear protective clothing to prevent contact infection
			block = 1
		if (M.check_bodypart_bleeding(HANDS) && check_bodypart_bleeding(touch_zone))//both sides have to be bleeding to allow for blood infections
			bleeding = 1
		share_contact_diseases(M,block,bleeding)

	// CHEATER CHECKS
	if(M.mind)
		var/punishment = FALSE
		var/bad_behavior = FALSE
		if(M.mind.special_role == HIGHLANDER)
			switch(M.a_intent)
				if(I_DISARM)
					bad_behavior = "disarm"
				//if(I_HURT)
				//	bad_behavior = "punch/kick"
				//if(I_GRAB)
				//	bad_behavior = "grab"
			if(bad_behavior)
				// In case we change our minds later...
				//M.set_species("Tajaran")
				//M.Cluwneize()
				for(var/datum/organ/external/arm in M.organs)
					if(istype(arm, /datum/organ/external/r_arm) || istype(arm, /datum/organ/external/l_arm))
						arm.droplimb(1)
				M.audible_scream()
				visible_message("<span class='sinister'>[M] tried to [bad_behavior] [src]! [ticker.Bible_deity_name] has frowned upon the disgrace!</span>")
				punishment = "disarmed"
		if(M.mind.special_role == BOMBERMAN)
			switch(M.a_intent)
				if(I_DISARM)
					bad_behavior = "disarm"
				//if(I_HURT)
				//	bad_behavior = "punch/kick"
				//if(I_GRAB)
				//	bad_behavior = "grab"
			if(bad_behavior)
				M.gib()
				visible_message("<span class='sinister'>[M] tried to [bad_behavior] [src]! DISQUALIFIED!</span>")
				punishment = "gibbed"
		if(punishment)
			message_admins("[M] tried to disarm [src] as a [M.mind.special_role] and was [punishment].")
			return

	switch(M.a_intent)
		if(I_HELP)
			if(health >= config.health_threshold_crit)
				help_shake_act(M)
				return 1
			else if(ishuman(M))
				M.perform_cpr(src)

		if(I_GRAB)
			return M.grab_mob(src)

		if(I_HURT)
			return M.unarmed_attack_mob(src)

		if(I_DISARM)
			return M.disarm_mob(src)
	return

/mob/living/carbon/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return
