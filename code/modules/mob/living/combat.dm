/mob/living/proc/grab_mob(mob/living/target)
	if(grab_check(target))
		return

	if (is_pacified(VIOLENCE_DEFAULT,target))
		return

	if(target.locked_to)
		to_chat(src, "<span class='notice'>You cannot grab \the [target], \he is buckled in!</span>")
		return

	var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(src, target)
	if(!G)	//the grab will delete itself in New if affecting is anchored
		return

	put_in_active_hand(G)
	target.grabbed_by += G

	G.synch()
	target.LAssailant = src
	target.grabbed_by(src)
	target.assaulted_by(src)

	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	visible_message("<span class='warning'>[src] grabs [target] passively!</span>")
	return 1

/mob/living/proc/grabbed_by(mob/living/grabber)
	return

/mob/living/proc/disarm_mob(mob/living/target)
	return

/mob/living/proc/disarmed_by(mob/living/disarmer) //For if you want to do something specific on disarm and nothing else.
	return FALSE

/mob/living/proc/break_grabs(mob/living/target)
	for(var/obj/item/weapon/grab/G in target.held_items)
		if(G.affecting)
			visible_message("<span class='danger'>[src] has broken [target]'s grip on [G.affecting]!</span>")
		spawn(1)
			qdel(G)
			G = null

		. = TRUE

/mob/living/proc/can_be_grabbed(mob/living/grabber)
	return TRUE

/mob/living/proc/break_pulls(mob/living/target)
	if(target.pulling)
		visible_message("<span class='danger'>[src] has broken [target]'s grip on [target.pulling]!</span>")
		target.stop_pulling()
		return TRUE

/mob/living/proc/get_unarmed_damage(var/atom/victim)
	return rand(0,10)

/mob/living/proc/get_unarmed_sharpness(mob/living/victim)
	return 0

/mob/living/proc/get_unarmed_verb(mob/living/victim)
	return "hits"

/mob/living/proc/get_unarmed_hit_sound(mob/living/victim)
	return "punch"

/mob/living/proc/get_unarmed_miss_sound(mob/living/victim)
	return 'sound/weapons/punchmiss.ogg'

/mob/living/proc/get_unarmed_damage_type(mob/living/victim)
	return BRUTE

/mob/living/proc/get_unarmed_damage_zone(mob/living/victim)
	if(zone_sel)
		return zone_sel.selecting

	return pick(LIMB_CHEST, LIMB_LEFT_HAND, LIMB_RIGHT_HAND, LIMB_LEFT_ARM, LIMB_RIGHT_ARM, LIMB_LEFT_LEG, LIMB_RIGHT_LEG, LIMB_LEFT_FOOT, LIMB_RIGHT_FOOT, LIMB_HEAD)

/mob/living/proc/miss_unarmed_attack(mob/living/target)
	var/miss_sound = get_unarmed_miss_sound(target)

	if(miss_sound)
		playsound(loc, miss_sound, 25, 1, -1)

	visible_message("<span class='borange'>[src] misses [target]!</span>")
	return TRUE

/mob/living/proc/get_attack_message(mob/living/target, attack_verb)
	return "<span class='danger'>[src] [attack_verb] \the [target]!</span>"

//Armor modifier is a value that multiplies effect of armor on the attack's target. The higher it is, the less effective your attacks are vs armor. 2 means armor is twice as effective, etc.
/mob/living/proc/get_armor_modifier(mob/living/target)
	return 1

/mob/living/proc/unarmed_attack_mob(mob/living/target)
	if(is_pacified(VIOLENCE_DEFAULT,target))
		return
	if(target.rps_in_combat)
		visible_message("<span class='borange'>[src] notices [target] is concentrating on the battle, and decides not to attack [target].</span>")
		return

	var/damage = get_unarmed_damage(target)

	if(!damage)
		if(miss_unarmed_attack(target))
			target.on_dodge(src)
			return

	var/zone = ran_zone(get_unarmed_damage_zone(target))
	var/datum/organ/external/affecting = target.get_organ(zone)
	var/armor_block = target.run_armor_check(affecting, "melee", modifier = get_armor_modifier(target))
	var/damage_type = get_unarmed_damage_type(target)
	var/sharpness = get_unarmed_sharpness(target)
	var/attack_verb = get_unarmed_verb(target)
	var/attack_sound = get_unarmed_hit_sound(target)

	if(attack_sound)
		playsound(loc, attack_sound, 25, 1, -1)

	do_attack_animation(target, src)
	var/damage_done
	var/rps_percentage = 0
	if(ishuman(target))
		//if(target.ckey || src.ckey) for later
		if((target.rps_curse || src.rps_curse) && !(target == src)) //Rock Paper Scissors battle is here
			rps_percentage = rps_battle(src, target)//this is seriously the most fucked up thing ever, I have NO idea why i need to set target to the defender input, it works perfectly fine on the item attack section. I'm going to tear my nuts off if I don't figure this out.
			src.rps_in_combat = 0
			target.rps_in_combat = 0
			if(rps_percentage > 0)
				damage = damage * rps_percentage
				damage_done = target.apply_damage(damage, damage_type, affecting, armor_block)
				visible_message(get_attack_message(target, attack_verb))
			else if(rps_percentage < 0)
				damage = damage * (rps_percentage * -1) //Since you can only return one output in a proc, I decided to make the output multiplier inversed, as a way to differentiate attacker and defender wins
				damage_done = src.apply_damage(damage, damage_type, affecting, armor_block)
				visible_message(target.get_attack_message(src, attack_verb))
		else
			damage_done = target.apply_damage(damage, damage_type, affecting, armor_block, sharpness)
	else
		damage += sharpness
		if((target.rps_curse || src.rps_curse) && !(target == src)) //Rock Paper Scissors battle is here
			src.rps_in_combat = 1
			target.rps_in_combat = 1
			rps_percentage = rps_battle(src, target)
			src.rps_in_combat = 0
			target.rps_in_combat = 0
			if(rps_percentage > 0)
				damage = damage * rps_percentage
				damage_done = target.apply_damage(damage, damage_type, affecting, armor_block)
				visible_message(get_attack_message(target, attack_verb))
			else if(rps_percentage < 0)
				damage = damage * (rps_percentage * -1) //Since you can only return one output in a proc, I decided to make the output multiplier inversed, as a way to differentiate attacker and defender wins
				damage_done = src.apply_damage(damage, damage_type, affecting, armor_block)
				visible_message(target.get_attack_message(src, attack_verb))
		else
			damage_done = target.apply_damage(damage, damage_type, affecting, armor_block)
			visible_message(get_attack_message(target, attack_verb))

	unarmed_attacked(target, damage, damage_type, zone)
	after_unarmed_attack(target, damage, damage_type, affecting, armor_block, rps_percentage)

	INVOKE_EVENT(src, /event/unarmed_attack, "attacker" = target, "attacked" = src)

	add_logs(src, target, "attacked ([damage_done]dmg)", admin = (src.ckey && target.ckey) ? TRUE : FALSE) //Only add this to the server logs if both mobs were controlled by player
	return damage_done


/mob/proc/rps_battle(var/mob/living/attacker, var/mob/living/defender)
	visible_message("<span class='borange'>curse check success</span>")
	var/attacker_wins = 0
	var/defender_wins = 0
	var/i
	var/j
	var/b = 3
	var/returner
	var/chance_mercy = 0
	var/winner_beg_stance
	var/loser_beg_stance
	attacker.rps_in_combat = 1
	defender.rps_in_combat = 1
	attacker.anchored = 1//to keep players from moving during a battle
	attacker.canmove = 0
	defender.anchored = 1
	defender.canmove = 0
	update_canmove(defender)
	update_canmove(defender)
	for(j=0, j<1, j=j)
		attacker.DisplayUI("Rock Paper Scissors Cards")
		defender.DisplayUI("Rock Paper Scissors Cards")
		for(i=0, i < b, i=i)
			sleep(30)
			switch(rps_win_check(attacker, defender))
				if(0)
					attacker_wins++
					visible_message("<span class='borange'>[attacker] wins this round!</span>")
					i++
				if(1)
					defender_wins++
					visible_message("<span class='borange'>[defender] wins this round!</span>")
					i++
				if(2)
					visible_message("<span class='borange'>[attacker] and [defender] both picked [defender.rps_intent]. Stalemate!</span>")
		if(attacker_wins == 0)
			attacker_wins = 1
		if(defender_wins == 0)
			defender_wins = 1
		attacker.HideUI("Rock Paper Scissors Cards")
		defender.HideUI("Rock Paper Scissors Cards")
		if(attacker_wins > defender_wins) //attacker wins
			visible_message("<span class='borange'>[attacker] wins!</span>")
			visible_message("<span class='borange'>[attacker_wins/defender_wins] percentage!</span>")
			returner = attacker_wins/defender_wins
			attacker.DisplayUI("RPS Winner Beg Cards")
			defender.DisplayUI("RPS Loser Beg Cards")
			sleep(30)
			attacker.HideUI("RPS Winner Beg Cards")
			defender.HideUI("RPS Loser Beg Cards")
			winner_beg_stance = attacker.rps_mercy_or_more
			loser_beg_stance = defender.rps_mercy_or_more
		else							//defender wins
			visible_message("<span class='borange'>[defender] wins!</span>")
			visible_message("<span class='borange'>[(defender_wins/attacker_wins) * -1] percentage!</span>")
			returner = (defender_wins/attacker_wins) * -1
			defender.DisplayUI("RPS Winner Beg Cards")
			attacker.DisplayUI("RPS Loser Beg Cards")
			sleep(30)
			defender.HideUI("RPS Winner Beg Cards")
			attacker.HideUI("RPS Loser Beg Cards")
			winner_beg_stance = defender.rps_mercy_or_more
			loser_beg_stance = attacker.rps_mercy_or_more
		if(winner_beg_stance == loser_beg_stance)//There must be a better way, but code optimization is for LATER
			if(winner_beg_stance == "mercy")
				attacker.rps_in_combat = 0
				defender.rps_in_combat = 0
				attacker.anchored = 0
				attacker.canmove = 1
				defender.anchored = 0
				defender.canmove = 1
				return returner
			if(winner_beg_stance == "more")
				chance_mercy = 100
		else
			if((winner_beg_stance == "more") && (loser_beg_stance == "mercy"))
				chance_mercy = 77
			if((winner_beg_stance == "mercy") && (loser_beg_stance == "more"))
				chance_mercy = 33
		if(prob(chance_mercy))
			if(b % 2)//Hopefully makes sure that the total round ammount is always odd
				b = 2
			else
				b = 3
		else
			attacker.rps_in_combat = 0
			defender.rps_in_combat = 0
			attacker.anchored = 0
			attacker.canmove = 1
			defender.anchored = 0
			defender.canmove = 1
			return returner

/mob/proc/rps_win_check(var/mob/living/attacker, var/mob/living/defender)
	if((attacker.rps_intent=="rock" && defender.rps_intent=="scissors") || (attacker.rps_intent=="scissors" && defender.rps_intent=="paper") || (attacker.rps_intent=="paper" && defender.rps_intent=="rock"))
		return 0
	else if((defender.rps_intent=="rock" && attacker.rps_intent=="scissors") || (defender.rps_intent=="scissors" && attacker.rps_intent=="paper") || (defender.rps_intent=="paper" && attacker.rps_intent=="rock"))
		return 1
	else if(defender.rps_intent == attacker.rps_intent)
		return 2
	else
		return 3

/mob/living/proc/after_unarmed_attack(mob/living/target, damage, damage_type, organ, armor)
	return

/mob/living/proc/unarmed_attacked(mob/living/attacker, damage, damage_type, zone)
	return

//Affects the chance of getting stunned by a punch
//Chance is multiplied by the returned value
/mob/living/proc/knockout_chance_modifier()
	return 0

/mob/living/proc/calcTackleForce()
	return 0

/mob/living/proc/calcTackleDefense()
	return 0

/mob/living/proc/calcTackleRange()
	return 0
