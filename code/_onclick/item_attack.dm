#define NORMAL_HIT 0
#define CRITICAL_HIT 1

// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	. = INVOKE_EVENT(src, /event/item_attack_self, "user" = user)
	if(flags & TWOHANDABLE)
		if(!(flags & MUSTTWOHAND))
			if(wielded)
				. = src.unwield(user)
			else
				. = src.wield(user)
	if(material_type)
		material_type.on_use(src, user, user)

// No comment
/atom/proc/attackby(obj/item/W, mob/user)
	return

/atom/movable/attackby(obj/item/W, mob/user)
	if(W && !(W.flags&NO_ATTACK_MSG))
		user.do_attack_animation(src, W)
		visible_message("<span class='danger'>[src] has been hit by [user] with [W].</span>")
	if(W.material_type)
		W.material_type.on_use(W, src, user)
	return emag_check()

/atom/movable/proc/emag_check(obj/item/weapon/card/emag/E, mob/user)
	if(can_emag() && istype(E) && E.canUse(user,src))
		if(E.arcanetampered && prob(50))
			arcane_act(user)
			if(prob(50))
				return TRUE
		emag_act(user)
		return TRUE
	return FALSE

/mob/living/attackby(obj/item/I, mob/user, var/no_delay = 0, var/originator = null, var/def_zone = null)
	if(!no_delay)
		user.delayNextAttack(10)
	if(istype(I) && ismob(user))
		if(originator)
			I.attack(src, user, def_zone, originator)
		else
			I.attack(src, user, def_zone)
	INVOKE_EVENT(src, /event/attackby, "attacker" = user, "item" = I)



// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target, /obj/structure/reagent_dispensers) && user.Adjacent(target))
		target.attempt_heating(src,user)
	if(daemon && daemon.flags & DAEMON_AFTATT)
		daemon.afterattack(target, user, proximity_flag, click_parameters)
	return

// Overrides the weapon attack so it can attack any atoms like when we want to have an effect on an object independent of attackby
// It is a powerful proc but it should be used wisely, if there are other alternatives instead use those
// If it returns 1 it exits click code. Always . = 1 at start of the function if you delete src.
/obj/item/proc/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	return

/obj/item/proc/attack(mob/living/M as mob, mob/living/user as mob, def_zone, var/originator = null)
	if(restraint_resist_time > 0)
		if(restraint_apply_check(M, user))
			return attempt_apply_restraints(M, user)
	if(originator)
		return handle_attack(src, M, user, def_zone, originator)
	else
		return handle_attack(src, M, user, def_zone)

// Making this into a helper proc because of inheritance wonkyness making children of reagent_containers being nigh impossible to attack with.
/obj/item/proc/handle_attack(obj/item/I, mob/living/M as mob, mob/living/user as mob, def_zone, var/mob/originator = null)
	. = 1
	if (!istype(M)) // not sure if this is the right thing...
		return 0
	//var/messagesource = M
	if (can_operate(M, user, I))        //Checks if mob is lying down on table for surgery
		if (do_surgery(M,user,I))
			return 1

	if (user.is_pacified(VIOLENCE_DEFAULT,M))
		return 0

	//if (istype(M,/mob/living/carbon/brain))
	//	messagesource = M:container
	/////////////////////////
	if(originator)
		if(ismob(originator))
			originator.lastattacked = M
			M.lastattacker = originator
			add_logs(originator, M, "attacked", object=I.name, addition="(INTENT: [uppertext(originator.a_intent)]) (DAMTYE: [uppertext(I.damtype)])")
	else
		user.lastattacked = M
		M.lastattacker = user
		add_logs(user, M, "attacked", object=I.name, addition="(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)])")

	//spawn(1800)            // this wont work right
	//	M.lastattacker = null
	/////////////////////////

	var/power = I.force

	if(M_HULK in user.mutations)
		power *= 2

	power = I.modify_attack_power(power, M, user) //Apply any special modifiers to the power here.

	var/is_crit = I.on_attack(M,user)
	if (is_crit == CRITICAL_HIT)
		power *= CRIT_MULTIPLIER


	if(!(ishuman(M) || ismonkey(M)))
		if(istype(M, /mob/living/carbon/slime))
			var/mob/living/carbon/slime/slime = M
			if(prob(25))
				to_chat(user, "<span class='warning'>[I] passes right through [M]!</span>")
				return 0
			//Handles pushing slimes off of targets, making them hostile from being attacked etc.
			slime.slime_item_attacked(src, user, power) //The code has been moved to code/modules/mob/living/carbon/slime/slime.dm

		var/showname = ""
		if(user)
			showname = "[user]"
		if(!(user in viewers(M, null)) && !istype(M.loc,/obj/item/weapon/holder) && !(user in viewers(M.loc, null)))
			showname = "Someone" // was previously a dot, why???

		if(originator)
			if(istype(originator, /mob/living/simple_animal/borer))
				var/mob/living/simple_animal/borer/B = originator
				if(B.host == user)
					if(B.hostlimb == LIMB_RIGHT_ARM)
						showname = "[user]'s right arm"
					else if(B.hostlimb == LIMB_LEFT_ARM)
						showname = "[user]'s left arm"

		//make not the same mistake as me, these messages are only for slimes (not the case anymore, this applies to simple_animals as well)
		if(I.force == 0)
			M.visible_message("<span class='danger'>[showname] [pick("taps","pats")] [M] with [I].</span>", \
				"<span class='userdanger'>[showname] [pick("taps","pats")] you with [I].</span>")
		else if(istype(I.attack_verb,/list) && I.attack_verb.len)
			M.visible_message("<span class='danger'>[showname] [pick(I.attack_verb)] [M] with [I].</span>", \
				"<span class='userdanger'>[showname] [pick(I.attack_verb)] you with [I].</span>")
		else
			M.visible_message("<span class='danger'>[showname] attacks [M] with [I].</span>", \
				"<span class='userdanger'>[showname] attacks you with [I].</span>")

		if(!showname && user)
			if(user.client)
				if(originator)
					if(istype(originator, /mob/living/simple_animal/borer))
						var/mob/living/simple_animal/borer/BO = originator
						if(BO.host == user)
							if(BO.hostlimb == LIMB_RIGHT_ARM)
								to_chat(user, "<span class='warning'>Your right arm attacks [M] with [I]!</span>")
							else if(BO.hostlimb == LIMB_LEFT_ARM)
								to_chat(user, "<span class='warning'>Your left arm attacks [M] with [I]!</span>")
					else
						to_chat(user, "<span class='warning'>You attack [M] with [I]!</span>")
				else
					to_chat(user, "<span class='warning'>You attack [M] with [I]!</span>")

	if(istype(M, /mob/living/carbon))
		var/mob/living/carbon/C = M
		if(originator)
			. = C.attacked_by(I, user, def_zone, originator, crit = is_crit)
		else
			. = C.attacked_by(I, user, def_zone, crit = is_crit)
	else
		switch(I.damtype)
			if("brute")
				M.take_organ_damage(power)
				if (prob(33) && I.force) // Added blood for whacking non-humans too
					var/turf/simulated/location = M.loc
					if (istype(location))
						location.add_blood_floor(M)
			if("fire")
				if (!(M_RESIST_COLD in M.mutations))
					M.take_organ_damage(0, power)

	//Break the item if applicable.
	if(power && (I.breakable_flags & BREAKABLE_AS_MELEE) && (I.breakable_flags & BREAKABLE_MOB) && (I.damtype == BRUTE))
		take_damage(min(power, BREAKARMOR_MEDIUM), skip_break = TRUE, mute = FALSE) //Cap recoil damage at BREAKARMOR_MEDIUM to avoid a powerful weapon also needing really strong armor to avoid breaking apart when used. Be verbose about the item being damaged if applicable.
		try_break(hit_atom = M) //Break the item and spill any reagents onto the target.

		M.updatehealth()
	I.add_fingerprint(user)

/obj/item/proc/modify_attack_power(power, mob/attackee, mob/attacker)
	return power

/obj/item/proc/on_attack(var/atom/attacked, var/mob/user)
	. = NORMAL_HIT
	if (!user.gcDestroyed)
		user.do_attack_animation(attacked, src)
		user.delayNextAttack(attack_delay)

	// Critical hits!
	if ((Holiday == APRIL_FOOLS_DAY) && istype(attacked, /mob))
		var/mob/M = attacked
		if (M.client)
			user.crit_rampup[num2text(world.time)] = src.force

	if (is_melee_crit_hit(src, user))
		playsound(attacked.loc, 'sound/weapons/criticalshit.ogg', 75, 0, -1, channel = CHANNEL_CRITSOUNDS)
		. = CRITICAL_HIT
		var/atom/movable/overlay/crit/animation = new(get_turf(attacked))
		animation.master = attacked
		animate(animation, alpha = 255, time = 2)
		animate(alpha = 0, time = 6)
		spawn(8)
			animation.master = null
			qdel(animation)

	if(material_type)
		material_type.on_use(src,attacked, user)

/proc/is_melee_crit_hit(var/obj/item/I, var/mob/attacker)
	if (Holiday != APRIL_FOOLS_DAY)
		return 0

	if (attacker.status_flags & ALWAYS_CRIT)
		return 1

	var/base_chance = I.crit_chance_melee
	var/total_damage = 0
	for (var/time in attacker.crit_rampup)
		total_damage += attacker.crit_rampup[time]
	var/bonus_chance = RULE_OF_THREE(MAX_DAMAGE_FOR_RAMPUP_MELEE, MAX_PROB_RAMPUP_MELEE, total_damage) // 80 damage in the last 20 minutes for 80 bonus chance
	bonus_chance = clamp(bonus_chance, 0, MAX_PROB_RAMPUP_MELEE) // capped at MAX_PROB_RAMPUP

	return (prob(base_chance + bonus_chance))

/proc/is_ranged_crit(var/obj/item/I, var/mob/attacker)
	if (Holiday != APRIL_FOOLS_DAY)
		return 0

	if (attacker.status_flags & ALWAYS_CRIT)
		return 1

	var/base_chance = I.crit_chance
	var/total_damage = 0
	for (var/time in attacker.crit_rampup)
		total_damage += attacker.crit_rampup[time]
	var/bonus_chance = RULE_OF_THREE(MAX_DAMAGE_FOR_RAMPUP_DIST, MAX_PROB_RAMPUP_DIST, total_damage) // 80 damage in the last 20 minutes for 80 bonus chance
	bonus_chance = clamp(bonus_chance, 0, MAX_PROB_RAMPUP_DIST) // capped at MAX_PROB_RAMPUP

	return (prob(base_chance + bonus_chance))

#undef NORMAL_HIT
#undef CRITICAL_HIT
