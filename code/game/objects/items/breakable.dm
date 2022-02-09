//Breakable items

/////////////////////
//Areas for expansion:
/////////////////////
//Specify multiple copies of a given fragment type with a number
//Break upon being bitten
//Break upon being used AS a weapon
//Getting hurt when holding an item as it breaks
//Hurting yourself when hitting an item bare-handed
//Break upon being shot by, and blocking or slowing, a projectile, if density = TRUE
//Damage considerations for the strength of the weapon wielder
//Make breakability into a component
//Specifying glance text
//Generalize to /obj
//Sounds when the item is hit.
//If the item has contents or reagents or components, spill them when it breaks
//Generalize momentum transfer from thrown item to fragments, out of kick-specific context.
//Integrate existing shrapnel system into fragments.
/////////////////////

/obj/item

	//Destructability parameters:
	var/breakable_flags = 0 /*possible flags include BREAKABLE_ALL | BREAKABLE_HIT | BREAKABLE_MELEE_UNARMED | BREAKABLE_MELEE_WEAPON | BREAKABLE_THROW
							BREAKABLE_HIT encompasses both BREAKABLE_MELEE_UNARMED and BREAKABLE_MELEE_WEAPON */
	var/health_item= 15 //Structural integrity of the item. at 0, the item breaks.
	var/health_item_max= 15
	var/damage_armor = 5 //Attacks of this much damage or below will glance off
	var/damage_resist = 5 //Attacks stronger than damage_armor will have their damage reduced by this much
	var/damaged_examine_text	//Addendum to the description when it's damaged eg. damaged_examine_text of "It is dented." null will skip this addendum.
	var/take_hit_text 	//String or list of strings when the item is damaged but not fully broken. eg. "chipping" becomes "..., chipping it!"
	var/breaks_text		//Visible message when the items breaks. eg. "breaks apart" null skips this.
	var/breaks_sound	//Path to audible sound when the item breaks. null skips this.
	var/glances_text	//String or list of strings when the item is attacked but the attack glances off. eg. "bounces" becomes "but it bounces off!"
	var/list/breakable_fragments //List of objects that will be produced when the item is broken apart. eg. /obj/weapon/item/shard
	var/list/breakable_exclude //List of objects that won't be used to hit the item even on harm intent, so as to allow for other interactions.

/obj/item/proc/on_broken(var/atom/target, var/range, var/speed, var/override, var/fly_speed) //Called right before an object breaks.
	if(breakable_fragments.len)
		drop_fragments(target,range,speed,override,fly_speed)
	if(breaks_text)
		visible_message("<span class='warning'>\The [src] [breaks_text]!</span>")
	if(breaks_sound)
		playsound(src, breaks_sound, 50, 1)

/obj/item/proc/drop_fragments(var/atom/target, var/range, var/speed, var/override, var/fly_speed) //Separate proc in case special stuff happens with a given item's fragments. Parameters are for throwing the fragments.
	if(breakable_fragments.len)
		for(var/thisfragment in breakable_fragments)
			var/obj/item/O = new thisfragment (get_turf(src))
			//Transfer fingerprints, fibers, and bloodstains to the fragment.
			transfer_fingerprints(src,O)
			transfer_item_blood_data(src,O)
			if(target && range && speed) //Propel the fragment if specified.
				O.throw_at(target,range,speed,override,fly_speed)

/obj/item/proc/take_damage(var/incoming_damage)
	var/thisdmg=(incoming_damage>max(damage_armor,damage_resist)) * (incoming_damage-damage_resist) //damage is 0 if the incoming damage is less than either damage_armor or damage_resist, to prevent negative damage by weak attacks
	health_item-=thisdmg
	if(!thisdmg)
		return 0 //return 0 if the item took no damage (glancing attack)
	else
		return 1 //return 1 if the item took damage

/obj/item/examine(mob/user, var/size = "", var/show_name = TRUE, var/show_icon = TRUE)
	..()
	if(health_item<health_item_max && damaged_examine_text)
		user.simple_message("<span class='info'> [damaged_examine_text]</span>",\
			"<span class='notice'> It seems kinda messed up somehow.</span>")
/obj/item/proc/transfer_item_blood_data(obj/item/A,obj/item/B)	//Transfers blood data from one item to another.
	if(!A || !B)
		return
	if(A.had_blood)
		B.blood_color = A.blood_color
		B.blood_DNA = A.blood_DNA
		B.had_blood = TRUE

		if(!blood_overlays[B.type]) //If there isn't a precreated blood overlay make one
			B.generate_blood_overlay()

		if(B.blood_overlay != null) // Just if(blood_overlay) doesn't work.  Have to use isnull here.
			B.overlays.Remove(B.blood_overlay)
		else
			B.blood_overlay = blood_overlays[B.type]

		B.blood_overlay.color = B.blood_color
		B.overlays += B.blood_overlay

/obj/item/proc/generate_break_text(var/glanced = FALSE, var/suppress_glance_text) //Generates text for when an item is hit.
	if(glanced)
		if(suppress_glance_text)
			return "!"
		else if(glances_text)
			return ", but it [pick(glances_text)] off!"
		else
			return ", but it [pick("bounces","gleams","glances")] off!"
	else if(health_item > 0 && !isnull(take_hit_text))
		return ", [pick(take_hit_text)] it!"
	else
		return "!" //Don't say "cracking it" if it breaks because on_broken() will subsequently say "The item shatters!"

/obj/item/proc/break_item(var/atom/target, var/range, var/speed, var/override , var/fly_speed) //Breaks the item if its health_item is 0 or below. Passes throw-related parameters to on_broken() to allow for an object's fragments to be thrown upon breaking.
	if(health_item<=0)
		on_broken(target,range,speed,override,fly_speed)
		qdel(src)
		return TRUE //Return TRUE if the item was broken
	else
		return FALSE //Return FALSE if the item wasn't broken

/////////////////////

//Breaking items:

//Attacking the item with a wielded weapon or other item
/obj/item/attackby(obj/item/W, mob/user)
	if(isobserver(user) || !Adjacent(user) || user.is_in_modules(src))
		return

	if(user.a_intent == I_HURT && breakable_flags & BREAKABLE_MELEE_WEAPON)
		if(!isnull(breakable_exclude)) //Check that the weapon isn't specifically excluded from hitting this item
			for(var/obj/item/this_excl in breakable_exclude)
				if(istype(W,this_excl))
					return ..()
		user.do_attack_animation(src, W)
		user.delayNextAttack(1 SECONDS)
		add_fingerprint(user)
		var/glanced=!take_damage(W.force)
		user.visible_message("<span class='warning'>\The [user] [pick(W.attack_verb)] \the [src] with \the [W][generate_break_text(glanced,TRUE)]</span>","<span class='notice'>You hit \the [src] with \the [W][generate_break_text(glanced)]<span>")
		break_item()
		//Break the weapon as well, if applicable, based on its own force.
		if(W.breakable_flags & BREAKABLE_AS_MELEE)
			W.take_damage(W.force)
			W.break_item()
	else
		..()

//Simple animals attacking the item
/obj/item/attack_animal(mob/living/simple_animal/M)
	if(M.melee_damage_upper && M.a_intent == I_HURT && breakable_flags & BREAKABLE_MELEE_UNARMED)
		M.do_attack_animation(src, M)
		M.delayNextAttack(1 SECONDS)
		var/glanced=!take_damage(rand(M.melee_damage_lower,M.melee_damage_upper))
		M.visible_message("<span class='warning'>\The [M] [M.attacktext] \the [src][generate_break_text(glanced,TRUE)]</span>","<span class='notice'>You hit \the [src][generate_break_text(glanced)]</span>")
		break_item()
	else
		..()

//Item ballistically colliding with something

/obj/item/throw_impact(atom/hit_atom, var/speed, mob/user)
	..()
	if(!(breakable_flags & BREAKABLE_AS_THROWN))
		return
	if(breakable_flags & BREAKABLE_NOMOB && istype(hit_atom, /mob)) //Don't break when it hits a mob if it's flagged with BREAKABLE_NOMOB
		return
	if(isturf(loc))
		//Unless the item falls to the floor unobstructed, impacts happens twice, once when it hits the target, and once when it falls to the floor.
		if(istype(hit_atom, /turf/simulated/floor))
			take_damage(speed/2)
		else
			take_damage(speed)
		break_item()



//TODO:
/*
//Items being used to hit a mob
*/


/*
//Biting the item
/obj/item/bite_act(mob/living/carbon/human/biter)
	if(user.a_intent == I_HURT && breakable_flags & BREAKABLE_MELEE_UNARMED)
	else
		..()
*/

//Unused:

/*
#define USER_TYPE_HUMAN	 1 //User is a carbon/human
#define USER_TYPE_BEAST  2 //User is a simple_animal
#define USER_TYPE_ALIEN  3 //User is a carbon/alien
#define USER_TYPE_ROBOT  4 //User is a silicon
#define USER_TYPE_OTHER  5 //User is another type of mob/living
*/

/*
/obj/item/proc/user_type_check(mob/living/user)
	if(istype(user, /mob/living/carbon/human))
		return USER_TYPE_HUMAN
	else if(istype(user, /mob/living/simple_animal))
		return USER_TYPE_BEAST
	else if(istype(user, /mob/living/carbon/alien/humanoid))
		return USER_TYPE_ALIEN
	else if(istype(user, /mob/living/silicon))
		return USER_TYPE_ROBOT
	else
		return USER_TYPE_OTHER
*/

/*
/obj/item/proc/item_attack_unarmed(mob/living/user)
	user.do_attack_animation(src,user)
	user.delayNextAttack(1 SECONDS)
	var/glanced
	switch(user_type_check(user))
		if(USER_TYPE_HUMAN)
			glanced=!take_damage(user.get_unarmed_damage())
			var/mob/living/carbon/human/H = user
			H.visible_message("<span class='warning'>\The [H] [H.species.attack_verb] \the [src][generate_break_text(glanced)]</span>","<span class='notice'>You hit \the [src][generate_break_text(glanced)]</span>")
		if(USER_TYPE_BEAST)
			var/mob/living/simple_animal/M = user
			glanced=!take_damage(rand(M.melee_damage_lower,M.melee_damage_upper))
			M.visible_message("<span class='warning'>\The [M] [M.attacktext] \the [src][generate_break_text(glanced)]</span>","<span class='notice'>You hit \the [src][generate_break_text(glanced)]</span>")
		if(USER_TYPE_ALIEN)
			glanced=!take_damage(user.get_unarmed_damage())
			user.visible_message("<span class='warning'>\The [user] [pick("slashes","claws")] \the [src][generate_break_text(glanced)]</span>","<span class='notice'>You [pick("slash","claw")] \the [src][generate_break_text(glanced)]</span>")
		if(USER_TYPE_ROBOT)
			return ..()				//not setup for now
		if(USER_TYPE_OTHER)
			return ..()				//not setup for now
	break_item()
*/

/*
//Aliens
/obj/item/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(user.a_intent == I_HURT && breakable_flags & BREAKABLE_MELEE_UNARMED)
		user.do_attack_animation(src, user)
		user.delayNextAttack(1 SECONDS)
		var/glanced=!take_damage(user.get_unarmed_damage())
		user.visible_message("<span class='warning'>\The [user] [pick("slashes","claws")] \the [src][generate_break_text(glanced,TRUE)]</span>","<span class='notice'>You [pick("slash","claw")] \the [src][generate_break_text(glanced)]</span>")
		break_item()
	else
		..()

*/

/*
//Empty-handed attacks
/obj/item/attack_hand(mob/living/carbon/human/user)
	if(isobserver(user) || !Adjacent(user))
		return
	if(user.a_intent == I_HURT && breakable_flags & BREAKABLE_MELEE_UNARMED)
		user.do_attack_animation(src, user)
		user.delayNextAttack(1 SECONDS)
		add_fingerprint(user)
		var/glanced=!take_damage(user.get_unarmed_damage())
		user.visible_message("<span class='warning'>\The [user] [user.species.attack_verb] \the [src][generate_break_text(glanced,TRUE)]</span>","<span class='notice'>You hit \the [src][generate_break_text(glanced,TRUE)]</span>")
		break_item()
	else
		..()
*/

/////////////////////


/////////////////////
//Testing items
/obj/item/device/flashlight/test
	name = "breakable flashlight"
	desc = "This flashlight looks particularly flimsy."
	breakable_flags = BREAKABLE_ALL
	health_item = 30
	health_item_max = 30
	damaged_examine_text = "It has gone bad."
	breaks_text = "crumbles apart"
	take_hit_text = "cracking"
	breaks_sound = 'sound/misc/balloon_pop.ogg'
	breakable_fragments = list(/obj/item/weapon/shard, /obj/item/weapon/reagent_containers/food/snacks/hotdog, /obj/item/weapon/reagent_containers/food/snacks/hotdog)

/obj/item/weapon/kitchen/utensil/knife/large/test
	name = "breakable knife"
	desc = "This knife looks like it could break under pressure."
	breakable_flags = BREAKABLE_ALL
	health_item = 30
	health_item_max = 30
	damaged_examine_text = "It's seen better days."
	breaks_text = "splinters into little bits"
	take_hit_text = list("denting","cracking")
	breaks_sound = 'sound/items/trayhit1.ogg'
	breakable_fragments = list(/obj/item/weapon/shard, /obj/item/weapon/kitchen/utensil/knife/large/test)

/obj/item/weapon/kitchen/utensil/knife/large/test/weak
	name = "flimsy breakable knife"
	desc = "This flimsy knife looks like it could fall apart at any time."
	breakable_flags = BREAKABLE_ALL
	health_item = 0.1
	health_item_max = 1
	damaged_examine_text = "It's seen much better days."
	damage_armor = BREAKARMOR_NOARMOR
	damage_resist = 0
	breaks_text = "falls apart into dust"
	breakable_fragments = list(/obj/item/weapon/shard, /obj/item/weapon/kitchen/utensil/knife/large/test/weak)

/obj/item/weapon/pen/fountain/test
	name = "breakable fountain pen"
	desc = "This pen looks really weak."
	breakable_flags = BREAKABLE_ALL
	health_item = 10
	health_item_max = 10
	damaged_examine_text = "It's seen much better days."
	damage_armor = 0
	damage_resist = 0
	breaks_text = "falls apart into dust"
	breakable_fragments = list(/obj/item/weapon/pen/fountain/test, /obj/item/weapon/shard)

/obj/item/weapon/pen/fountain/test/strong
	name = "invincible fountain pen"
	desc = "This pen looks really, really tough."
	breakable_flags = BREAKABLE_ALL
	health_item = 10
	health_item_max = 10
	damaged_examine_text = "Somehow it has a crack in it..."
	damage_armor = BREAKARMOR_INVINCIBLE
	damage_resist = 0
	breaks_text = "implodes"
	breakable_fragments = list(/obj/item/weapon/reagent_containers/food/snacks/hotdog)


/////////////////////