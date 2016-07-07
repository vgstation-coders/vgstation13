/*
Contains most of the procs that are called when a mob is attacked by something

bullet_act
ex_act
meteor_act
emp_act

*/

/mob/living/carbon/human/bullet_act(var/obj/item/projectile/P, var/def_zone)
	if(wear_suit && istype(wear_suit, /obj/item/clothing/suit/armor/laserproof))
		if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam) || istype(P, /obj/item/projectile/forcebolt) || istype(P, /obj/item/projectile/change))
			var/reflectchance = 60 - round(P.damage/3)
			if(!(def_zone in list(LIMB_CHEST, LIMB_GROIN)))
				reflectchance /= 2
			if(prob(reflectchance))
				visible_message("<span class='danger'>The [P.name] gets reflected by [src]'s [wear_suit.name]!</span>")

				P.reflected = 1
				P.rebound(src)

				return -1 // complete projectile permutation

	if(check_shields(P.damage, "the [P.name]"))
		P.on_hit(src, 2)
		return 2
	return (..(P , def_zone))


/mob/living/carbon/human/getarmor(var/def_zone, var/type)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isorgan(def_zone))
			return checkarmor(def_zone, type)
		var/datum/organ/external/affecting = get_organ(ran_zone(def_zone))
		return checkarmor(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/datum/organ/external/organ in organs)
		armorval += checkarmor(organ, type)
		organnum++
	return (armorval/max(organnum, 1))

/mob/living/carbon/human/proc/get_siemens_coefficient_organ(var/datum/organ/external/def_zone)
	if(!def_zone)
		return 1.0

	var/siemens_coefficient = 1.0
	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?

	for(var/obj/item/clothing/C in clothing_items)
		if(istype(C) && (C.body_parts_covered & def_zone.body_part)) // Is that body part being targeted covered?
			siemens_coefficient *= C.siemens_coefficient

	return siemens_coefficient

/mob/living/carbon/human/proc/checkarmor(var/datum/organ/external/def_zone, var/type)
	if(!type)	return 0
	var/protection = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				protection += C.armor[type]
	return protection

/mob/living/carbon/human/proc/check_body_part_coverage(var/body_part_flags=0)
	if(!body_part_flags)
		return 0
	for(var/obj/item/clothing/C in get_clothing_items())
		if(!C) continue
		if(C.body_parts_covered & body_part_flags)
			return 1
	return 0

/mob/living/carbon/human/proc/get_body_part_coverage(var/body_part_flags=0)
	if(!body_part_flags)
		return null
	for(var/obj/item/clothing/C in get_clothing_items())
		if(!C) continue
		 //Check if this piece of clothing contains ALL of the flags we want to check.
		if((C.body_parts_covered & body_part_flags) == body_part_flags)
			return C
	return null

/mob/living/carbon/human/proc/get_exposed_body_parts()
	//Because get_body_part_coverage(FULL_BODY) would only return true if the human has one piece of clothing that covers their whole body by itself.
	var/body_coverage = FULL_BODY | FULL_HEAD

	for(var/obj/item/clothing/C in get_clothing_items())
		if(!C) continue
		body_coverage &= ~(C.body_parts_covered)
	return body_coverage


/mob/living/carbon/human/proc/check_shields(var/damage = 0, var/attack_text = "the attack")
	for(var/obj/item/weapon/I in held_items)
		if(I.IsShield() && I.on_block(damage, attack_text))
			return 1

	if(istype(wear_suit, /obj/item/)) //Check armor
		var/obj/item/I = wear_suit
		if(I.IsShield() && I.on_block(damage, attack_text))
			return 1

	return 0

/mob/living/carbon/human/emp_act(severity)
	for(var/obj/item/stickybomb/B in src)
		if(B.stuck_to)
			visible_message("<span class='warning'>\the [B] stuck on \the [src] suddenly deactivates itself and falls to the ground.</span>")
			B.deactivate()
			B.unstick()

	if(flags & INVULNERABLE)
		return

	for(var/obj/O in src)
		if(!O)	continue
		O.emp_act(severity)
	for(var/datum/organ/external/O  in organs)
		if(O.status & ORGAN_DESTROYED)	continue
		O.emp_act(severity)
		for(var/datum/organ/internal/I  in O.internal_organs)
			if(I.robotic == 0)	continue
			I.emp_act(severity)
	..()


/mob/living/carbon/human/proc/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone, var/originator = null)
	. = 1
	if(!I || !user)
		return 0
	var/target_zone = null
	if(originator)
		if(ismob(originator))
			var/mob/M = originator
			target_zone = get_zone_with_miss_chance(M.zone_sel.selecting, src)
	else
		target_zone = get_zone_with_miss_chance(user.zone_sel.selecting, src)
	if(user == src) // Attacking yourself can't miss
		target_zone = user.zone_sel.selecting
	if(!target_zone && !src.stat)
		visible_message("<span class='danger'>[user] misses [src] with \the [I]!</span>")
		return 0
	if(istype(I, /obj/item/weapon/kitchen/utensil/knife/large/butch/meatcleaver) && src.stat == DEAD && user.a_intent == I_HURT)
		var/obj/item/weapon/reagent_containers/food/snacks/meat/human/newmeat = new /obj/item/weapon/reagent_containers/food/snacks/meat/human(get_turf(src.loc))
		newmeat.name = src.real_name + newmeat.name
		newmeat.subjectname = src.real_name
		newmeat.subjectjob = src.job
		newmeat.reagents.add_reagent (NUTRIMENT, (src.nutrition / 15) / 3)
		src.reagents.trans_to (newmeat, round ((src.reagents.total_volume) / 3, 1))
		src.loc.add_blood(src)
		--src.meatleft
		to_chat(user, "<span class='warning'>You hack off a chunk of meat from [src.name]</span>")
		if(!src.meatleft)
			src.attack_log += "\[[time_stamp()]\] Was chopped up into meat by <b>[user]/[user.ckey]</b>"
			user.attack_log += "\[[time_stamp()]\] Chopped up <b>[src]/[src.ckey]</b> into meat</b>"
			msg_admin_attack("[user.name] ([user.ckey]) chopped up [src] ([src.ckey]) into meat (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			if(!iscarbon(user))
				LAssailant = null
			else
				LAssailant = user
			qdel(src)
			return
	var/datum/organ/external/affecting = get_organ(target_zone)
	if (!affecting)
		return
	if(affecting.status & ORGAN_DESTROYED)
		if(originator)
			to_chat(originator, "What [affecting.display_name]?")
		else
			to_chat(user, "What [affecting.display_name]?")
		return
	var/hit_area = affecting.display_name

	if((user != src) && check_shields(I.force, "the [I.name]"))
		return 0

	if(istype(I,/obj/item/weapon/card/emag))
		if(!(affecting.status & ORGAN_ROBOT))
			to_chat(user, "<span class='warning'>That limb isn't robotic.</span>")
			return 0
		if(affecting.sabotaged)
			to_chat(user, "<span class='warning'>[src]'s [affecting.display_name] is already sabotaged!</span>")
		else
			to_chat(user, "<span class='warning'>You sneakily slide [I] into the dataport on [src]'s [affecting.display_name] and short out the safeties.</span>")
			affecting.sabotaged = 1
		return 0

	if(istype(I.attack_verb, /list) && I.attack_verb.len)
		visible_message("<span class='danger'>[user] [pick(I.attack_verb)] [src] in the [hit_area] with \the [I.name]!</span>", \
			"<span class='userdanger'>[user] [pick(I.attack_verb)] you in the [hit_area] with \the [I.name]!</span>")
	else
		visible_message("<span class='danger'>[user] attacks [src] in the [hit_area] with \the [I.name]!</span>", \
			"<span class='userdanger'>[user] attacks you in the [hit_area] with \the [I.name]!</span>")

	var/armor = run_armor_check(affecting, "melee", "Your armor protects your [hit_area].", "Your armor softens the hit to your [hit_area].")
	if(armor >= 2)	return 1 //We still connected
	if(!I.force)	return 1

	//Knocking teeth out!
	var/knock_teeth = 0
	if(originator)
		if(ismob(originator))
			var/mob/M = originator
			if(M.zone_sel.selecting == "mouth" && target_zone == LIMB_HEAD)
				knock_teeth = 1
		else if(user.zone_sel.selecting == "mouth" && target_zone == LIMB_HEAD)
			knock_teeth = 1
	else if(user.zone_sel.selecting == "mouth" && target_zone == LIMB_HEAD)
		knock_teeth = 1
	if(knock_teeth) //You can't actually hit people in the mouth - this checks if the user IS targetting mouth, and if he didn't miss!
		if((!armor) && (I.force >= 8 || I.w_class >= W_CLASS_SMALL) && (I.is_sharp() < 1))//Minimum force=8, minimum w_class=2. Sharp items can't knock out teeth. Armor prevents this completely!
			var/datum/butchering_product/teeth/T = locate(/datum/butchering_product/teeth) in src.butchering_drops
			if(T && T.amount > 0) //If the guy has some teeth
				var/chance = min(I.force * I.w_class, 40) //an item with w_class = W_CLASS_MEDIUM and force of 10 has a 30% chance of knocking a few teeth out. Chance is capped at 40%
				if(prob(chance))
					knock_out_teeth(user)

	apply_damage(I.force, I.damtype, affecting, armor , I.is_sharp(), I)

	var/bloody = 0
	if(((I.damtype == BRUTE) || (I.damtype == HALLOSS)) && prob(25 + (I.force * 2)))
		I.add_blood(src)	//Make the weapon bloody, not the person.
//		if(user.hand)	user.update_inv_l_hand()	//updates the attacker's overlay for the (now bloodied) weapon
//		else			user.update_inv_r_hand()	//removed because weapons don't have on-mob blood overlays
		if(prob(33))
			bloody = 1
			var/turf/location = loc
			if(istype(location, /turf/simulated))
				location.add_blood(src)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(get_dist(H, src) <= 1) //people with TK won't get smeared with blood
					H.bloody_body(src)
					H.bloody_hands(src)

		switch(hit_area)
			if(LIMB_HEAD)//Harder to score a stun but if you do it lasts a bit longer
				if(prob(I.force))
					apply_effect(20, PARALYZE, armor)
					visible_message("<span class='danger'>[src] has been knocked unconscious!</span>")
					if(src != user && I.damtype == BRUTE)
						ticker.mode.remove_revolutionary(mind)

				if(bloody)//Apply blood
					if(wear_mask)
						wear_mask.add_blood(src)
						update_inv_wear_mask(0)
					if(head)
						head.add_blood(src)
						update_inv_head(0)
					if(glasses && prob(33))
						glasses.add_blood(src)
						update_inv_glasses(0)

			if(LIMB_CHEST)//Easier to score a stun but lasts less time
				if(prob((I.force + 10)))
					apply_effect(5, WEAKEN, armor)
					visible_message("<span class='danger'>[src] has been knocked down!</span>")

				if(bloody)
					bloody_body(src)
	return .

/mob/living/carbon/human/proc/knock_out_teeth(mob/user)
	var/mob/living/L = user
	var/datum/butchering_product/teeth/T = locate(/datum/butchering_product/teeth) in src.butchering_drops
	if(!istype(T) || T.amount == 0) return

	var/amount = rand(1,3)
	if(user)
		if(M_HULK in L.mutations) //just like the mountain
			amount += 8

	var/obj/item/stack/teeth/teeth = T.spawn_result(get_turf(src), src, amount)

	var/turf/throw_to = get_step(get_turf(src), src.dir) //Throw them in the direction we're facing!
	teeth.throw_at(throw_to, 2, 2)

	if(user)
		src.visible_message(\
			"<span class='danger'>[user] knocks [(amount < 3) ? "some" : "a bunch"] of [src]'s teeth out!</span>",\
			"<span class='danger'>[user] knocks [(amount < 3) ? "some" : "a bunch"] of your teeth out!</span>",\

			drugged_message = "<span class='info'>[user] starts brushing [src]'s teeth.</span>",\
			self_drugged_message = "<span class='info'>[user] has removed some of your wisdom teeth.</span>")
	else
		src.visible_message(\
			"<span class='danger'>[(amount < 3) ? "Some" : "A bunch"] of [src]'s teeth fall out!</span>",\
			"<span class='danger'>[(amount < 3) ? "Some" : "A bunch"] of your teeth fall out!</span>",\

			drugged_message = "<span class='info'>The tooth fairy takes some of [src]'s teeth out!</span>",\
			self_drugged_message = "<span class='info'>The tooth fairy takes some of your teeth out, and gives you a dollar.</span>")

/mob/living/carbon/human/proc/bloody_hands(var/mob/living/source, var/amount = 2)
	if (gloves)
		gloves.add_blood(source)
		gloves:transfer_blood = amount
		gloves:bloody_hands_mob = source
	else
		add_blood(source)
		bloody_hands = amount
		bloody_hands_mob = source
	update_inv_gloves()		//updates on-mob overlays for bloody hands and/or bloody gloves

/mob/living/carbon/human/proc/bloody_body(var/mob/living/source,var/update = 0)
	if(wear_suit)
		wear_suit.add_blood(source)
		update_inv_wear_suit(update)
	if(w_uniform)
		w_uniform.add_blood(source)
		update_inv_w_uniform(update)

/mob/living/carbon/human/ex_act(severity,var/noblind = FALSE)
	if(flags & INVULNERABLE)
		return

	if(!blinded && !noblind)
		flash_eyes(visual = 1)

	var/shielded = 0
	var/b_loss = null
	var/f_loss = null

	switch (severity)
		if (1.0)
			b_loss += 500
			if (!prob(getarmor(null, "bomb")))
				gib()
				return
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)
			//return
//				var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
				//user.throw_at(target, 200, 4)

		if (2.0)
			if (stat == 2 && client)
				gib()
				return

			else if (stat == 2 && !client)
				gibs(loc, viruses)
				qdel(src)
				return

			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (prob(getarmor(null, "bomb")))
				b_loss = b_loss/1.5
				f_loss = f_loss/1.5

			if (!earprot())
				ear_damage += 30
				ear_deaf += 120
			if (prob(70) && !shielded)
				Paralyse(10)

		if(3.0)
			b_loss += 30
			var/gotarmor = min(100,max(0,getarmor(null, "bomb")))

			if (prob(gotarmor))
				b_loss = (b_loss*((gotarmor-100)*-1))/100//equipments with armor[bomb]=100 will fully negate the damage of light explosives.
			if (!earprot())
				ear_damage += 15
				ear_deaf += 60
			if (prob(50) && !shielded)
				if (!prob((gotarmor-100)*-1))
					Paralyse(10)

	var/update = 0

	// focus most of the blast on one organ
	var/datum/organ/external/take_blast = pick(organs)
	update |= take_blast.take_damage(b_loss * 0.9, f_loss * 0.9, used_weapon = "Explosive blast")

	// distribute the remaining 10% on all limbs equally
	b_loss *= 0.1
	f_loss *= 0.1

	var/weapon_message = "Explosive Blast"

	for(var/datum/organ/external/temp in organs)
		switch(temp.name)
			if(LIMB_HEAD)
				update |= temp.take_damage(b_loss * 0.2, f_loss * 0.2, used_weapon = weapon_message)
			if(LIMB_CHEST)
				update |= temp.take_damage(b_loss * 0.4, f_loss * 0.4, used_weapon = weapon_message)
			if(LIMB_LEFT_ARM)
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if(LIMB_RIGHT_ARM)
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if(LIMB_LEFT_LEG)
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if(LIMB_RIGHT_LEG)
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if(LIMB_RIGHT_FOOT)
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if(LIMB_LEFT_FOOT)
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if(LIMB_RIGHT_ARM)
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if(LIMB_LEFT_ARM)
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
	if(update)	UpdateDamageIcon()


/mob/living/carbon/human/blob_act()
	if(flags & INVULNERABLE)
		return
	if(cloneloss < 120)
		playsound(loc, 'sound/effects/blobattack.ogg',50,1)
		if(stat == DEAD)
			..()
			adjustCloneLoss(rand(5,25))
		else
			..()
			show_message("<span class='warning'>The blob attacks you!</span>")
			var/dam_zone = pick(LIMB_CHEST, LIMB_LEFT_HAND, LIMB_RIGHT_HAND, LIMB_LEFT_LEG, LIMB_RIGHT_LEG)
			var/datum/organ/external/affecting = get_organ(ran_zone(dam_zone))
			apply_damage(rand(30,40), BRUTE, affecting, run_armor_check(affecting, "melee"))
	return
