///////////////////////
// Breakable Objects //
//   by Hinaichigo   //
///////////////////////

/obj
	//Breakability:
	var/health		//Structural integrity of the object. If breakable_flags are set, at 0, the object breaks.
	var/maxHealth	//Maximum structural integrity of the object.
	var/breakable_flags 	//Flags for different situations the object can break in. See breakable_defines.dm for the full list and explanations of each.
	var/damage_armor		//Attacks of this much damage or below will glance off. Can be a list of the form: list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0) for damage-type-specific armor.
	var/damage_resist		//Attacks stronger than damage_armor will have their damage reduced by this much. Can be a list of the same form as damage_armor.
	var/list/breakable_exclude //List of objects that won't be used to hit the object even on harm intent, so as to allow for other interactions.
	//Fragmentation:
	var/list/breakable_fragments	//List of objects that will be produced when the object is broken apart. eg. /obj/item/weapon/shard.
	var/list/fragment_amounts		//List of the numbers of fragments of each object type in breakable_fragments to be dropped. Should be either null (1 each) or the same length as breakable_fragments.
	//Text:
	var/damaged_examine_text	//Addendum to the description when the object is damaged. eg. damaged_examine_text of "It is dented."
	var/take_hit_text 	//String or list of strings when the object is damaged but not fully broken. eg. "chipping" becomes "..., chipping it!"
	var/take_hit_text2	//String or list of strings for contexts like "cracks" becomes "the ... cracks!"
	var/glances_text	//String or list of strings when the object is attacked but the attack glances off. eg. "bounces" becomes "but it bounces off!"
	var/breaks_text		//Visible message when the object breaks. eg. "breaks apart"
	//Sounds:
	var/breaks_sound	//Audible sound when the object breaks apart. Defaults to damaged_sound if unset.
	var/damaged_sound	//Audible sound when the object is damaged by an attack, but not fully broken. Defaults to glanced_sound if unset.
	var/glanced_sound	//Audible sound when the object recives a glancing attack not strong enough to damage it.

/obj/proc/breakable_init()
	//Initialize health and maxHealth to the same value if only one is specified.
	if(isnull(health) && maxHealth)
		health = maxHealth
	else if(isnull(maxHealth) && health)
		maxHealth = health

/obj/proc/on_broken(datum/throwparams/propelparams, atom/hit_atom) //Called right before an object breaks.
	//Drop and and propel any fragments:
	drop_fragments(propelparams)
	//Drop and propel any contents:
	drop_contents(propelparams)
	//Spill any reagents:
	spill_reagents(hit_atom)
	if(breaks_text)
		visible_message("<span class='warning'>\The [src] [breaks_text]!</span>")
	if(breaks_sound)
		playsound(src, breaks_sound, 50, 1)
	else if(damaged_sound)
		playsound(src, damaged_sound, 50, 1)

/obj/proc/drop_fragments(datum/throwparams/propelparams) //Drop the object's fragments and propel them if applicable with propelparams.
	if(breakable_fragments?.len)
		var/oneeach=(isnull(fragment_amounts) || breakable_fragments.len != fragment_amounts.len) //default to 1 of each fragment type if fragment_amounts isn't specified or there's a length mismatch
		var/numtodrop
		var/thisfragment
		for(var/frag_ind in 1 to breakable_fragments.len)
			if(oneeach)
				numtodrop=1
			else
				numtodrop=fragment_amounts[frag_ind]
			thisfragment=breakable_fragments[frag_ind]
			for(var/n in 1 to numtodrop)
				var/obj/O = new thisfragment (get_turf(src))
				//Transfer fingerprints, fibers, and bloodstains to the fragment.
				transfer_fingerprints(src,O)
				transfer_obj_blood_data(src,O)
				if(propelparams)//Propel the fragment if specified.
					if(propelparams.throw_target && propelparams.throw_range && propelparams.throw_speed)
						O.throw_at(propelparams.throw_target, propelparams.throw_range, propelparams.throw_speed, propelparams.throw_override, propelparams.throw_fly_speed)

/obj/proc/drop_contents(datum/throwparams/propelparams) //Drop the contents of the object and propel them if the object itself received a propulsive blow.
	if(contents.len)
		for(var/obj/item/thiscontent in contents)
			thiscontent.forceMove(src.loc)
			if(propelparams)
				if(propelparams.throw_target && propelparams.throw_range && propelparams.throw_speed) //Propel the content if specified.
					thiscontent.throw_at(propelparams.throw_target, propelparams.throw_range, propelparams.throw_speed, propelparams.throw_override, propelparams.throw_fly_speed)

/obj/proc/spill_reagents(atom/hit_atom) //Spill any reagents contained within the object onto the floor, and the atom it hit when it broke, if applicable.
	if(!isnull(reagents))
		if(!isnull(hit_atom) && hit_atom != get_turf(src)) //If it hit something other than the floor, spill it onto that.
			reagents.reaction(hit_atom, TOUCH)
		reagents.reaction(get_turf(src), TOUCH) //Then spill it onto the floor.

/obj/proc/take_damage(incoming_damage, damage_type = "melee", skip_break = FALSE, mute = TRUE)
	var/thisdmg = modify_incoming_damage(incoming_damage, damage_type)
	health -= thisdmg
	play_hit_sounds(thisdmg)
	if(thisdmg)
		if(health > 0) //Only if the object isn't ready to break.
			message_take_hit(mute)
		damaged_updates()
		if(!skip_break)
			try_break()
	return thisdmg //return the amount of damage taken

/obj/proc/modify_incoming_damage(incoming_damage, damage_type)
	var/dmg_arm = 0
	if(islist(damage_armor))
		dmg_arm = damage_armor[damage_type]
	else if(damage_armor)
		dmg_arm = damage_armor
	var/dmg_rst = 0
	if(islist(damage_resist))
		dmg_rst = damage_resist[damage_type]
	else if(damage_resist)
		dmg_rst = damage_resist
	return (incoming_damage > max(dmg_arm, dmg_rst)) * (incoming_damage - dmg_rst) //damage is 0 if the incoming damage is less than either damage_armor or damage_resist, to prevent negative damage by weak attacks

/obj/proc/play_hit_sounds(thisdmg, hear_glanced = TRUE, hear_damaged = TRUE) //Plays any relevant sounds whenever the object is hit. glanced_sound overrides damaged_sound if the latter is not set or hear_damaged is set to FALSE.
	if(health <= 0) //Don't play a sound here if the object is ready to break, because sounds are also played by on_broken().
		return
	if(thisdmg && damaged_sound && hear_damaged)
		playsound(src, damaged_sound, 50, 1)
	else if(glanced_sound && hear_glanced)
		playsound(src, glanced_sound, 50, 1)

/obj/proc/message_take_hit(mute = FALSE) //Give a visible message when the object takes damage.
	if(!isnull(take_hit_text2) && !mute)
		visible_message("<span class='warning'>\The [src] [pick(take_hit_text2)]!</span>")

/obj/proc/damaged_updates() //Put any damage-related updates to the object here.
	return

/obj/examine(mob/user, size = "", show_name = TRUE, show_icon = TRUE)
	..()
	if(health<maxHealth && damaged_examine_text)
		user.simple_message("<span class='info'>[damaged_examine_text]</span>",\
			"<span class='notice'>It seems kinda messed up somehow.</span>")

/obj/proc/transfer_obj_blood_data(obj/A, obj/B)	//Transfers blood data from one object to another.
	if(!A || !B)
		return
	if(A.had_blood)
		B.blood_color = A.blood_color
		B.blood_DNA = A.blood_DNA
		B.had_blood = TRUE

/obj/item/transfer_obj_blood_data(obj/item/A, obj/item/B)
	..()
	if(!blood_overlays[B.type]) //If there isn't a precreated blood overlay make one
		B.set_blood_overlay()
	if(B.blood_overlay != null) // Just if(blood_overlay) doesn't work.  Have to use isnull here.
		B.overlays.Remove(B.blood_overlay)
	else
		B.blood_overlay = blood_overlays["[B.type][B.icon_state]"]
	B.blood_overlay.color = B.blood_color
	B.overlays += B.blood_overlay

/obj/proc/generate_break_text(glanced = FALSE, suppress_glance_text) //Generates text for when an object is hit.
	if(glanced)
		if(suppress_glance_text)
			return "!"
		else if(glances_text)
			return ", but it [pick(glances_text)] off!"
		else
			return ", but it glances off!"
	else if(health > 0 && take_hit_text)
		return ", [pick(take_hit_text)] it!"
	else
		return "!" //Don't say "cracking it" if it breaks because on_broken() will subsequently say "The object shatters!"

/obj/proc/try_break(datum/throwparams/propelparams, hit_atom) //Breaks the object if its health is 0 or below. Passes throw-related parameters to on_broken() to allow for an object's fragments to be propelled upon breaking.
	if(!isnull(health) && health <= 0)
		on_broken(propelparams, hit_atom)
		qdel(src)
		return TRUE //Return TRUE if the object was broken
	else if(propelparams)
		throw_at(propelparams.throw_target, propelparams.throw_range, propelparams.throw_speed, propelparams.throw_override, propelparams.throw_fly_speed)
	return FALSE //Return FALSE if the object wasn't broken

/datum/throwparams //throw_at() input parameters as a datum to make function inputs neater
	var/throw_target
	var/throw_range
	var/throw_speed
	var/throw_override
	var/throw_fly_speed

/datum/throwparams/New(target, range, speed, override, fly_speed)
	throw_target = target
	throw_range = range
	throw_speed = speed
	throw_override = override
	throw_fly_speed = fly_speed

/obj/proc/get_total_scaled_w_class(scalepower=3) //Returns a scaled sum of the weight class of the object itself and all of its contents, if any.
	//scalepower raises the w_class of each object to that exponent before adding it to the total. This helps avoid things like a container full of tiny objects being heavier than it should.
	var/total_w_class = (isnull(w_class) ? W_CLASS_MEDIUM : w_class) ** scalepower
	if(!isnull(contents) && contents.len)
		for(var/obj/item/thiscontent in contents)
			total_w_class += (thiscontent.w_class ** scalepower)
	return total_w_class

/obj/proc/breakable_check_weapon(obj/item/this_weapon) //Check if a weapon isn't excluded from being used to attempt to break an object.
	if(breakable_exclude)
		for(var/obj/item/this_excl in breakable_exclude)
			if(istype(this_weapon, this_excl))
				return FALSE
	return TRUE

/obj/proc/valid_item_attack(obj/item/this_weapon, mob/user) //Check if an object is in valid circumstances to be attacked with a wielded weapon.
	if(user.a_intent == I_HURT && breakable_flags & BREAKABLE_WEAPON && breakable_check_weapon(this_weapon) && isturf(loc)) //Smash objects on the ground, but not in your inventory.
		return TRUE
	else
		return FALSE

/obj/proc/get_obj_kick_damage(mob/living/carbon/human/kicker, datum/organ/external/kickingfoot)
	if(!kickingfoot)
		kickingfoot = kicker.pick_usable_organ(LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT)
	var/damage = kicker.get_strength() * 5
	if(kicker.reagents && kicker.reagents.has_reagent(GYRO))
		damage += 5
	damage *= 1 + min(0,(kicker.size - SIZE_NORMAL)) //The bigger the kicker, the more damage
	var/obj/item/clothing/shoes/S = kicker.shoes
	if(istype(S))
		damage += S.bonus_kick_damage
	else if(kicker.organ_has_mutation(kickingfoot, M_TALONS)) //Not wearing shoes and having talons = bonus damage
		damage += 3
	return damage

/////////////////////

//Breaking objects:

//Attacking the object with a wielded weapon or other item

/obj/proc/handle_item_attack(obj/item/W, mob/user)
	if(isobserver(user) || !Adjacent(user) || user.is_in_modules(src))
		return FALSE
	if(valid_item_attack(W, user))
		user.do_attack_animation(src, W)
		user.delayNextAttack(1 SECONDS)
		add_fingerprint(user)
		var/glanced=!take_damage(W.force, damage_type = W.damtype == BURN ? "energy" : "melee", skip_break = TRUE)
		if(W.hitsound)
			playsound(src, W.hitsound, 50, 1)
		user.visible_message("<span class='warning'>\The [user] [pick(W.attack_verb)] \the [src] with \the [W][generate_break_text(glanced,TRUE)]</span>","<span class='notice'>You [shift_verb_tense(pick(W.attack_verb))] \the [src] with \the [W][generate_break_text(glanced)]<span>")
		try_break()
		//Break the weapon as well, if applicable, based on its own force.
		if(W.breakable_flags & BREAKABLE_AS_MELEE && W.damtype == BRUTE)
			W.take_damage(min(W.force, BREAKARMOR_MEDIUM), skip_break = FALSE, mute = FALSE) //Cap it at BREAKARMOR_MEDIUM to avoid a powerful weapon also needing really strong armor to avoid breaking apart when used.
		return TRUE
	else
		return FALSE

//Simple animals attacking the object

/obj/attack_animal(mob/living/simple_animal/M)
	if(M.melee_damage_upper && M.a_intent == I_HURT && breakable_flags & BREAKABLE_UNARMED)
		M.do_attack_animation(src, M)
		M.delayNextAttack(1 SECONDS)
		var/glanced=!take_damage(rand(M.melee_damage_lower,M.melee_damage_upper), skip_break = TRUE)
		if(M.attack_sound)
			playsound(src, M.attack_sound, 50, 1)
		M.visible_message("<span class='warning'>\The [M] [M.attacktext] \the [src][generate_break_text(glanced,TRUE)]</span>","<span class='notice'>You [shift_verb_tense(M.attacktext)] \the [src][generate_break_text(glanced)]</span>")
		try_break()
	else
		. = ..()

//Object ballistically colliding with something

/obj/throw_impact(atom/impacted_atom, speed, mob/user)
	..()
	if(!(breakable_flags & BREAKABLE_AS_THROWN))
		return
	if(!(breakable_flags & BREAKABLE_MOB) && istype(impacted_atom, /mob)) //Don't break when it hits a mob if it's not flagged with BREAKABLE_MOB
		return
	if(isturf(loc)) //Don't take damage if it was caught mid-flight.
		//Unless the object falls to the floor unobstructed, impacts happens twice, once when it hits the target, and once when it falls to the floor.
		var/thisdmg = 5 * get_total_scaled_w_class(1) / (speed ? speed : 1) //impact damage scales with the weight class and speed of the object. since a smaller speed is faster, it's a divisor.
		if(istype(impacted_atom, /turf/simulated/floor))
			take_damage(thisdmg/2, skip_break = TRUE)
		else
			take_damage(thisdmg, skip_break = TRUE, mute = FALSE) //Be verbose about the object taking damage.
		try_break(null, impacted_atom)

//Something ballistically colliding with the object

/obj/hitby(atom/movable/AM)
	. = ..()
	if(.)
		return
	if(breakable_flags & BREAKABLE_HIT)
		var/thisdmg = 0
		if(ismob(AM))
			if(!(breakable_flags & BREAKABLE_MOB))
				return
			var/mob/thismob = AM
			thisdmg = thismob.size * 3 + 1
		else if(isobj(AM))
			var/obj/thisobj = AM
			thisdmg = max(thisobj.throwforce, thisobj.get_total_scaled_w_class(2) + 1)
		take_damage(thisdmg, damage_type = "bullet")

//Object being hit by a projectile

/obj/bullet_act(obj/item/projectile/proj)
	. = ..()
	var/impact_power = max(0,round((proj.damage_type == BRUTE) * (proj.damage / 3 - (get_total_scaled_w_class(3))))) //The range of the impact-throw is increased by the damage of the projectile, and decreased by the total weight class of the object.
	var/turf/T = get_edge_target_turf(loc, get_dir(proj.starting, proj.target))
	var/thispropel = new /datum/throwparams(T, impact_power, proj.projectile_speed)
	if(breakable_flags & BREAKABLE_WEAPON)
		take_damage(proj.damage, damage_type = proj.flag, skip_break = TRUE)
	//Throw the object in the direction the projectile was traveling
		if(try_break(impact_power ? thispropel : null))
			return
	if(impact_power && !anchored)
		throw_at(T, impact_power, proj.projectile_speed)

//Kicking the object

/obj/kick_act/(mob/living/carbon/human/kicker)
	if(breakable_flags & BREAKABLE_UNARMED && kicker.can_kick(src))
		if(arcanetampered && density && anchored)
			to_chat(kicker,"<span class='sinister'>[src] kicks YOU!</span>")
			kicker.Knockdown(10)
			kicker.Stun(10)
			return
		//Pick a random usable foot to perform the kick with
		var/datum/organ/external/foot_organ = kicker.pick_usable_organ(LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT)
		kicker.delayNextAttack(2 SECONDS) //Kicks are slow
		if((M_CLUMSY in kicker.mutations) && prob(20)) //Kicking yourself (or being clumsy) = stun
			kicker.visible_message("<span class='notice'>\The [kicker] trips while attempting to kick \the [src]!</span>", "<span class='userdanger'>While attempting to kick \the [src], you trip and fall!</span>")
			var/incapacitation_duration = rand(1,10)
			kicker.Knockdown(incapacitation_duration)
			kicker.Stun(incapacitation_duration)
			return
		var/attack_verb = "kick"
		var/recoil_damage = BREAKARMOR_FLIMSY
		if(kicker.reagents && kicker.reagents.has_reagent(GYRO))
			attack_verb = "roundhouse kick"
			recoil_damage = 0
		if(M_HULK in kicker.mutations)
			recoil_damage = 0
		//Handle shoes
		var/obj/item/clothing/shoes/S = kicker.shoes
		if(istype(S))
			S.on_kick(kicker, src)
		playsound(loc, "punch", 30, 1, -1)
		kicker.do_attack_animation(src, kicker)
		var/glanced = !take_damage(get_obj_kick_damage(kicker, foot_organ), skip_break = TRUE, mute = TRUE)
		kicker.visible_message("<span class='warning'>\The [kicker] [attack_verb]s \the [src][generate_break_text(glanced,TRUE)]</span>",
		"<span class='notice'>You [attack_verb] \the [src][generate_break_text(glanced)]</span>")
		var/kick_dir = get_dir(kicker, src)
		if(kicker.loc == loc)
			kick_dir = kicker.dir
		var/turf/T = get_edge_target_turf(loc, kick_dir)
		var/kick_power = get_kick_power(kicker)
		var/thispropel = new /datum/throwparams(T, kick_power, 1)
		if(kick_power < 1)
			kick_power = 0
			thispropel = null
		if(try_break(thispropel))
			recoil_damage = 0 //Don't take recoil damage if the item broke.
		else if(kick_power && !anchored)
			throw_at(T, kick_power, 1)
		if(recoil_damage) //Recoil damage to the foot.
			kicker.foot_impact(src, recoil_damage, ourfoot = foot_organ)
		Crossed(kicker)
	else
		. = ..()

//Biting the object

/obj/bite_act(mob/living/carbon/human/biter)
	if(breakable_flags & BREAKABLE_UNARMED && biter.can_bite(src))
		var/thisdmg = BREAKARMOR_FLIMSY
		var/attacktype = "bite"
		var/attacktype2 = "bites"
		if(biter.organ_has_mutation(LIMB_HEAD, M_BEAK)) //Beaks = stronger bites
			thisdmg += 4
		else
			var/datum/butchering_product/teeth/T = locate(/datum/butchering_product/teeth) in biter.butchering_drops
			if(!T?.amount)
				attacktype = "gum"
				attacktype2 = "gums"
				thisdmg = 1
		biter.do_attack_animation(src, biter)
		biter.delayNextAttack(1 SECONDS)
		var/glanced=!take_damage(thisdmg, skip_break = TRUE)
		biter.visible_message("<span class='warning'>\The [biter] [loc == biter ? "[attacktype2] down on" : "leans over and [attacktype2]"] \the [src]!</span>",
		"<span class='notice'>You [loc == biter ? "[attacktype] down on" : "lean over and [attacktype]"] \the [src][glanced ? "... ouch!" : "[generate_break_text()]"]</span>")
		try_break()
		if(glanced)
			//Damage the biter's mouth.
			biter.apply_damage(BREAKARMOR_FLIMSY, BRUTE, TARGET_MOUTH)
	else
		. = ..()

/////////////////////
