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
			var/obj/item/clothing/suit/armor/laserproof/armor = wear_suit
			var/reflectchance = armor.basereflectchance - round(P.damage/3)
			if(!(def_zone in list(LIMB_CHEST, LIMB_GROIN)))
				reflectchance /= 2
			if(prob(reflectchance))
				visible_message("<span class='danger'>The [P.name] gets reflected by [src]'s [wear_suit.name]!</span>")

				if(!istype(P, /obj/item/projectile/beam)) //beam has its own rebound-call-logic
					P.reflected = 1
					P.rebound(src)

				return PROJECTILE_COLLISION_REBOUND // complete projectile permutation

	if(wear_suit && istype(wear_suit, /obj/item/clothing/suit/space/rig/grey/leader))
		if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam) || istype(P, /obj/item/projectile/forcebolt) || istype(P, /obj/item/projectile/change))
			var/reflectchance = 50 - round(P.damage/3)
			if(prob(reflectchance))
				visible_message("<span class='danger'>The [P.name] gets reflected by [src]'s [wear_suit.name]!</span>")

				if(!istype(P, /obj/item/projectile/beam)) //beam has its own rebound-call-logic
					P.reflected = 1
					P.rebound(src)

				return PROJECTILE_COLLISION_REBOUND // complete projectile permutation

	if(check_shields(P.damage, P))
		P.on_hit(src, 100)
		return PROJECTILE_COLLISION_BLOCKED

	var/obj/structure/railing/R = locate(/obj/structure/railing) in get_turf(src)
	if(R)
		var/turf/T = get_step(R,R.dir)
		if(isopenspace(T) && P.get_damage())
			R.hurdle(src) // Railing kill!

	return (..(P , def_zone))


/mob/living/carbon/human/getarmor(var/def_zone, var/type)
	if(def_zone)
		if(isorgan(def_zone))
			return checkarmor(def_zone, type)
		var/datum/organ/external/affecting = get_organ(check_zone(def_zone))
		return checkarmor(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	var/armorval = 0
	var/organnum = 0
	for(var/datum/organ/external/organ in organs)
		armorval += checkarmor(organ, type)
		organnum++
	return (armorval/max(organnum, 1))

/mob/living/carbon/human/getarmorabsorb(var/def_zone, var/type)
	if(def_zone)
		if(isorgan(def_zone))
			return checkarmorabsorb(def_zone, type)
		var/datum/organ/external/affecting = get_organ(ran_zone(def_zone))
		return checkarmorabsorb(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	var/armorval = 0
	var/organnum = 0
	for(var/datum/organ/external/organ in organs)
		armorval += checkarmorabsorb(organ, type)
		organnum++
	return (armorval/max(organnum, 1))

/mob/living/carbon/human/proc/getthermalprot(var/def_zone)
	if(def_zone)
		if(isorgan(def_zone))
			return checkthermalprot(def_zone)
		var/datum/organ/external/affecting = get_organ(ran_zone(def_zone))
		return checkthermalprot(affecting)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	var/thermal_prot = 0
	var/organnum = 0
	for(var/datum/organ/external/organ in organs)
		thermal_prot += checkthermalprot(organ, type)
		organnum++
	return (thermal_prot/max(organnum, 1))

/mob/living/carbon/human/proc/checkthermalprot(var/datum/organ/external/def_zone)
	var/thermal_pass = 1 //1 means no protection, 0 means total protection
	for(var/ci in get_clothing_items())
		if(isitem(ci))
			var/obj/item/C = ci
			if(C.body_parts_covered & def_zone.body_part)
				thermal_pass *= C.heat_conductivity
			if(istype(C, /obj/item/clothing))
				var/obj/item/clothing/CC = C
				for(var/obj/item/clothing/accessory/A in CC.accessories)
					if(A.body_parts_covered & def_zone.body_part)
						thermal_pass *= A.heat_conductivity
	return thermal_pass


/mob/living/carbon/human/proc/get_siemens_coefficient_organ(var/datum/organ/external/def_zone)
	if(!def_zone)
		return 1.0

	var/siemens_coefficient = 1.0
	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?

	for(var/obj/item/C in clothing_items)
		if(istype(C) && (C.body_parts_covered & def_zone.body_part)) // Is that body part being targeted covered?
			siemens_coefficient *= C.siemens_coefficient

	return siemens_coefficient

/mob/living/carbon/human/proc/checkarmor(var/datum/organ/external/def_zone, var/type)
	if(!type)
		return 0
	var/protection = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(isitem(bp))
			var/obj/item/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				protection += C.get_armor(type)
			if(istype(C, /obj/item/clothing))
				var/obj/item/clothing/CC = C
				for(var/obj/item/clothing/accessory/A in CC.accessories)
					if(A.body_parts_covered & def_zone.body_part)
						protection += A.get_armor(type)
	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		protection += M.rad_protection
	return protection

/mob/living/carbon/human/proc/checkarmorabsorb(var/datum/organ/external/def_zone, var/type)
	if(!type)
		return 0
	var/protection = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
	for(var/bp in body_parts)
		if(isitem(bp))
			var/obj/item/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				protection += C.get_armor_absorb(type)
			if(istype(C, /obj/item/clothing))
				var/obj/item/clothing/CC = C
				for(var/obj/item/clothing/accessory/A in CC.accessories)
					if(A.body_parts_covered & def_zone.body_part)
						protection += A.get_armor_absorb(type)
	return protection

/mob/living/carbon/human/proc/check_body_part_coverage(var/body_part_flags=0, var/obj/item/ignored)
	if(!body_part_flags)
		return 0
	var/parts_to_check = body_part_flags
	for(var/obj/item/C in get_clothing_items())
		if(!C)
			continue
		if(ignored && C == ignored)
			continue
		if((C.body_parts_covered & body_part_flags) == body_part_flags)
			return 1
		parts_to_check &= ~(C.body_parts_covered)
		if(!parts_to_check)
			return 1
	return 0

/mob/living/carbon/human/proc/get_body_part_coverage(var/body_part_flags=0)
	if(!body_part_flags)
		return null
	for(var/obj/item/C in get_clothing_items())
		if(!C)
			continue
		 //Check if this piece of clothing contains ALL of the flags we want to check.
		if((C.body_parts_covered & body_part_flags) == body_part_flags)
			return C
	return null

/mob/living/carbon/human/proc/get_exposed_body_parts()
	//Because get_body_part_coverage(FULL_BODY) would only return true if the human has one piece of clothing that covers their whole body by itself.
	var/body_coverage = FULL_BODY | FULL_HEAD

	for(var/obj/item/C in get_clothing_items())
		if(!C)
			continue
		body_coverage &= ~(C.body_parts_covered)
	return body_coverage

/mob/living/carbon/human/check_shields(damage, atom/A)
	if(..())
		return 1

	if(istype(wear_suit, /obj/item)) //Check armor
		var/obj/item/I = wear_suit
		if(I.IsShield() && I.on_block(damage, A))
			return 1

/mob/living/carbon/human/emp_act(severity)
	for(var/obj/item/stickybomb/B in src)
		if(B.stuck_to)
			visible_message("<span class='warning'>\the [B] stuck on \the [src] suddenly deactivates itself and falls to the ground.</span>")
			B.deactivate()
			B.unstick()

	if(flags & INVULNERABLE)
		return

	for(var/obj/O in src)
		if(!O)
			continue
		O.emp_act(severity)
	for(var/datum/organ/external/O  in organs)
		if(O.status & ORGAN_DESTROYED)
			continue
		O.emp_act(severity)
		for(var/datum/organ/internal/I  in O.internal_organs)
			if(I.robotic == 0)
				continue
			I.emp_act(severity)
	..()


/mob/living/carbon/human/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone, var/originator = null, var/crit = FALSE, var/flavor)
	if(!..())
		return
	var/power = I.force
	if (crit)
		power *= CRIT_MULTIPLIER

	if(def_zone)
		target_zone = def_zone

	var/datum/organ/external/affecting = get_organ(target_zone)

	if (!affecting)
		return FALSE
	if(affecting.status & ORGAN_DESTROYED)
		if(originator)
			to_chat(originator, "What [affecting.display_name]?")
		else
			to_chat(user, "What [affecting.display_name]?")
		return FALSE
	var/hit_area = affecting.display_name

	if(istype(I.attack_verb, /list) && I.attack_verb.len && !(I.flags & NO_ATTACK_MSG))
		visible_message("<span class='danger'>\The [user] [flavor ? "[flavor] " : ""][pick(I.attack_verb)] [user == src ? "[get_reflexive_pronoun(user.gender)]" : "\the [src]"] in \the [hit_area] with \the [I]!</span>", \
			"<span class='userdanger'>[user == src ? "You" : "\The [user]"] [flavor ? "[flavor] " : ""][user == src ? "[shift_verb_tense(pick(I.attack_verb))] yourself": "[pick(I.attack_verb)] you"] in \the [hit_area] with \the [I]!</span>")
	else if(!(I.flags & NO_ATTACK_MSG))
		visible_message("<span class='danger'>\The [user] [flavor ? "[flavor] " : ""]attacks [user == src ? "[get_reflexive_pronoun(user.gender)]" : "\the [src]"] in \the [hit_area] with \the [I.name]!</span>", \
			"<span class='userdanger'>[user == src ? "You" : "\The [user]"] [flavor ? "[flavor] " : ""]attack[user == src ? " yourself" : "s you"] in \the [hit_area] with \the [I.name]!</span>")

	//Contact diseases on the weapon?
	I.disease_contact(src,get_part_from_limb(target_zone))

	//Knocking teeth out!
	var/knock_teeth = 0
	if(originator)
		if(ismob(originator))
			var/mob/M = originator
			if(M.zone_sel.selecting == "mouth" && target_zone == LIMB_HEAD)
				knock_teeth = 1
		else if(user.zone_sel.selecting == "mouth" && target_zone == LIMB_HEAD)
			knock_teeth = 1
	else if(user.zone_sel && user.zone_sel.selecting == "mouth" && target_zone == LIMB_HEAD)
		knock_teeth = 1

	var/armor = run_armor_check(affecting, "melee", quiet = 1)
	var/final_force = run_armor_absorb(affecting, "melee", power)
	if(knock_teeth) //You can't actually hit people in the mouth - this checks if the user IS targetting mouth, and if he didn't miss!
		if((!armor) && (final_force >= 8 || I.w_class >= W_CLASS_SMALL) && (I.is_sharp() < 1))//Minimum force=8, minimum w_class=2. Sharp items can't knock out teeth. Armor prevents this completely!
			var/chance = min(final_force * I.w_class, 40) //an item with w_class = W_CLASS_MEDIUM and force of 10 has a 30% chance of knocking a few teeth out. Chance is capped at 40%
			if(prob(chance))
				knock_out_teeth(user)

	var/bloody = FALSE
	if(final_force && ((I.damtype == BRUTE) || (I.damtype == HALLOSS)) && (affecting.status & ORGAN_BLEEDING))
		if(!(src.species.anatomy_flags & NO_BLOOD))
			I.add_blood(src)	//Make the weapon bloody, not the person.
			if(prob(33))
				bloody = TRUE
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
				if(prob(final_force))
					if(apply_effect(20, PARALYZE, armor))
						visible_message("<span class='danger'>[src] has been knocked unconscious!</span>")
						// if(src != user && I.damtype == BRUTE && isrev(src))
						// 	ticker.mode.remove_revolutionary(mind)
						// 	add_attacklogs(user, src, "de-converted from Revolutionary!")

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
				if(prob((final_force + 10)))
					apply_effect(5, WEAKEN, armor)
					visible_message("<span class='danger'>[src] has been knocked down!</span>")

				if(bloody)
					bloody_body(src)

	return TRUE

/mob/living/carbon/human/proc/knock_out_teeth(var/mob/living/L)
	var/datum/butchering_product/teeth/T = locate(/datum/butchering_product/teeth) in src.butchering_drops
	if(!istype(T) || T.amount == 0)
		return FALSE

	var/datum/organ/external/head/head = get_organ(LIMB_HEAD)
	if(!head || head.status & ORGAN_DESTROYED) //if they don't have a head then there's no teeth
		return FALSE

	var/amount = rand(1,3)
	if(L)
		if(M_HULK in L.mutations) //just like the mountain
			amount += 8

	var/obj/item/stack/teeth/teeth = T.spawn_result(get_turf(src), src, amount)

	var/turf/throw_to = get_step(get_turf(src), src.dir) //Throw them in the direction we're facing!
	teeth.throw_at(throw_to, 2, 2)

	if(L)
		src.visible_message(\
			"<span class='danger'>\The [L] knocks [(amount < 3) ? "some" : "a bunch"] of \the [src]'s teeth out!</span>",\
			"<span class='danger'>\The [L] knocks [(amount < 3) ? "some" : "a bunch"] of your teeth out!</span>",\

			drugged_message = "<span class='info'>\The [L] starts brushing \the [src]'s teeth.</span>",\
			self_drugged_message = "<span class='info'>\The [L] has removed some of your wisdom teeth.</span>")
	else
		src.visible_message(\
			"<span class='danger'>[(amount < 3) ? "Some" : "A bunch"] of \the [src]'s teeth fall out!</span>",\
			"<span class='danger'>[(amount < 3) ? "Some" : "A bunch"] of your teeth fall out!</span>",\

			drugged_message = "<span class='info'>The tooth fairy takes some of \the [src]'s teeth out!</span>",\
			self_drugged_message = "<span class='info'>The tooth fairy takes some of your teeth out, and gives you a dollar.</span>")

/mob/living/carbon/human/proc/foot_impact(var/atom/source, var/damage, var/datum/organ/external/ourfoot) //When our foot is hurt, for example by kicking something stationary
	//note: as per can_kick() in human.dm, kicking requires both feet intact
	if(shoes && istype(shoes, /obj/item/clothing/shoes))
		var/obj/item/clothing/shoes/S = shoes
		damage = S.impact_dampen(source, damage)
	if(!damage)
		return FALSE
	if(!ourfoot)
		ourfoot = get_organ(pick(LIMB_LEFT_FOOT,LIMB_RIGHT_FOOT))
	apply_damage(damage, BRUTE, ourfoot)
	return TRUE

/mob/living/carbon/human/proc/bloody_hands(var/mob/living/source, var/amount = 3)
	if (ishuman(source))
		var/mob/living/carbon/human/H = source
		if (H.species.anatomy_flags & NO_BLOOD)
			return
	//we're getting splashed with blood, so let's check for viruses
	var/block = check_contact_sterility(HANDS)
	var/bleeding = check_bodypart_bleeding(HANDS)
	oneway_contact_diseases(source,block,bleeding)

	if (gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood(source)
		if (istype(G))
			G.transfer_blood = amount
			G.bloody_hands_data = source.get_blood_data()
	else
		add_blood(source)
		bloody_hands += amount
		bloody_hands_data = source.get_blood_data()
	update_inv_gloves()		//updates on-mob overlays for bloody hands and/or bloody gloves

/mob/living/carbon/human/proc/bloody_body(var/mob/living/source, var/update = 0)
	if (ishuman(source))
		var/mob/living/carbon/human/H = source
		if (H.species.anatomy_flags & NO_BLOOD)
			return
	//we're getting splashed with blood, so let's check for viruses
	var/block = check_contact_sterility(FULL_TORSO)
	var/bleeding = check_bodypart_bleeding(FULL_TORSO)
	oneway_contact_diseases(source,block,bleeding)

	if(wear_suit)
		wear_suit.add_blood(source)
		update_inv_wear_suit(update)
	if(w_uniform)
		w_uniform.add_blood(source)
		update_inv_w_uniform(update)

//=======================================================================================================================
//The two procs bellow are for when getting bloodied with blood that doesn't come straight from a mob, but from a beaker or something else
//Since the original donor might not exist anymore

/mob/living/carbon/human/proc/bloody_hands_from_data(var/list/blood_data, var/amount = 3, var/source)
	//we're getting splashed with blood, so let's check for viruses
	var/block = check_contact_sterility(HANDS)
	var/bleeding = check_bodypart_bleeding(HANDS)
	assume_contact_diseases(blood_data["virus2"],source,block,bleeding)

	if (gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood_from_data(blood_data)
		if (istype(G))
			G.transfer_blood = amount
			G.bloody_hands_data = copy_blood_data(blood_data)
	else
		add_blood_from_data(blood_data)
		bloody_hands += amount
		bloody_hands_data = copy_blood_data(blood_data)
	update_inv_gloves()		//updates on-mob overlays for bloody hands and/or bloody gloves

/mob/living/carbon/human/proc/bloody_body_from_data(var/list/blood_data, var/update = 0, var/source)
	//we're getting splashed with blood, so let's check for viruses
	var/block = check_contact_sterility(FULL_TORSO)
	var/bleeding = check_bodypart_bleeding(FULL_TORSO)
	assume_contact_diseases(blood_data["virus2"],source,block,bleeding)

	if(wear_suit)
		wear_suit.add_blood_from_data(blood_data)
		update_inv_wear_suit(update)
	if(w_uniform)
		w_uniform.add_blood_from_data(blood_data)
		update_inv_w_uniform(update)

//=======================================================================================================================

/mob/living/carbon/human/apply_luminol(var/update = FALSE) //Despite what you might think with FALSE this will update things as normal.
	if(wear_suit)
		wear_suit.apply_luminol()
		update_inv_wear_suit(update)
	if(w_uniform)
		w_uniform.apply_luminol()
		update_inv_w_uniform(update)

/mob/living/carbon/human/ex_act(var/severity, var/child=null, var/mob/whodunnit, var/noblind = FALSE)
	if(flags & INVULNERABLE)
		return FALSE

	if(!blinded && !noblind)
		flash_eyes(visual = 1)

	var/shielded = 0
	var/b_loss = null
	var/f_loss = null
	var/gotarmor = clamp(getarmor(null, "bomb"),0,100)
	var/msg_admin = (src.key || src.ckey || (src.mind && src.mind.key)) && whodunnit
	switch (severity)
		if (BLOB_ACT_STRONG)
			b_loss += 300
			if(!prob(gotarmor)) //Percent chance equal to their armor resist to not gib instantly.
				add_attacklogs(src, whodunnit, "got caught in an explosive blast[whodunnit ? " from" : ""]", addition = "Severity: [severity], Gibbed", admin_warn = msg_admin)
				gib()
				return
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)
				b_loss *= (120-gotarmor)/100 //Reduce blast power by a function of bomb armor, but even 100 won't be enough.
				//100 = 20%,  60  b_loss (bomb suit, advanced EOD suit)
				//50  = 70%,  210 b_loss (captain's armor/rig, ancient space suit)
				//45  = 65%,  225 b_loss (sec hardsuit)
				//35  = 85%,  255 b_loss (eng hardsuit, blood red hardsuit, gem encrusted hardsuit)
				//30  = 90%,  270 b_loss (ERT armor, red syndie suit)
				//25  = 95%,  285 b_loss (security armor)
				//20  = 100%, 300 b_loss (RD's labcoat)
				//0   = 120%, 360 b_loss (most suits)

		if (BLOB_ACT_MEDIUM)
			if (stat == 2 && client)
				add_attacklogs(src, whodunnit, "got caught in an explosive blast[whodunnit ? " from" : ""]", addition = "Severity: [severity], Gibbed", admin_warn = msg_admin)
				gib()
				return

			else if (stat == 2 && !client)
				gibs(loc, virus2)
				add_attacklogs(src, whodunnit, "got caught in an explosive blast[whodunnit ? " from" : ""]", addition = "Severity: [severity], Gibbed", admin_warn = msg_admin)
				qdel(src)
				return

			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (gotarmor)
				b_loss *= (100-gotarmor)/100 //reduce damage by percent equal to bomb armor
				f_loss *= (100-gotarmor)/100

			if (!earprot())
				ear_damage += 30
				ear_deaf += 120
			if (prob(70) && !shielded)
				Paralyse(10)

		if(BLOB_ACT_WEAK)
			b_loss += 30
			if(gotarmor)
				b_loss *= (100-gotarmor)/100 //reduce damage by percent equal to bomb armor
			if (!earprot())
				ear_damage += 15
				ear_deaf += 60
			if (prob(50) && !shielded)
				if (!prob((gotarmor-100)*-1))
					Paralyse(10)


	//Deal damage

	//The on_damaged event returns 1 if the damage should be blocked
	//There are two types of damage at once (brute & burn), so do it through bitflags, because
	//if(INVOKE_EVENT(brute) || INVOKE_EVENT(burn)) won't call the second proc if the first one returns 1
	//This way both of the events are called, and the damage is blocked if either of them return 1
	var/damage_blocked = 0

	//INVOKE_EVENT may return null sometimes - this doesn't work nice with bitflags (which is what's being done here). Hence the !! operator - it turns a null into a 0.
	var/brute_resolved = !!INVOKE_EVENT(src, /event/damaged, "kind" = BRUTE, "amount" = b_loss)
	var/burn_resolved = !!INVOKE_EVENT(src, /event/damaged, "kind" = BURN, "amount" = f_loss)
	damage_blocked |= (brute_resolved | burn_resolved)

	if(damage_blocked)
		return FALSE

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
	if(update)
		add_attacklogs(src, whodunnit, "got caught in an explosive blast[whodunnit ? " from" : ""]", addition = "Severity: [severity]", admin_warn = msg_admin)
		UpdateDamageIcon()


/mob/living/carbon/human/blob_act()
	if(flags & INVULNERABLE)
		return
	var/obj/item/clothing/suit/reticulatedvest/RV = wear_suit
	if(istype(RV) && RV.hits>0) //will fail if not wearing a suit or wearing one not of this type
		RV.hits--
		if(RV.hits)
			to_chat(src, "<big><span class='good'>Your reticulated vest groans as it resists the blob!</span></big>")
		else
			to_chat(src, "<big><span class='danger'>Your reticulated vest rips apart as it resists the blob one last time!</span></big>")
		RV.update_icon()
		update_inv_wear_suit()
		return
	if(cloneloss < 120)
		playsound(loc, 'sound/effects/blobattack.ogg',50,1)
		if(isDead(src))
			..()
			adjustCloneLoss(rand(5,25))
		else
			..()
			show_message("<span class='warning'>The blob attacks you!</span>")
			var/dam_zone = pick(organs_by_name)
			var/datum/organ/external/affecting = get_organ(ran_zone(dam_zone))

			apply_damage(run_armor_absorb(affecting, "melee", rand(30,40)), BRUTE, affecting, run_armor_check(affecting, "melee"))

/mob/living/carbon/human/dissolvable()
	if(species && species.anatomy_flags & ACID4WATER)
		return WATER
	else
		return PACID

/mob/living/carbon/human/beam_defense(var/obj/effect/beam/B)
	return is_wearing_item(/obj/item/clothing/suit/reticulatedvest) ? 0.4 : 1
