/////////////////////
//Breakability testing items
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
	breakable_fragments = list(/obj/item/weapon/shard, /obj/item/weapon/reagent_containers/food/snacks/hotdog)
	fragment_amounts = list(2,1) //Will break into 2 shards, 1 hotdog.

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
	density = 1
	breakable_fragments = list(/obj/item/weapon/pen/fountain/test, /obj/item/weapon/kitchen/utensil/knife/)
	fragment_amounts = list(1,3)

/obj/item/weapon/pen/fountain/test/strong
	name = "invincible fountain pen"
	desc = "This pen looks really, really tough."
	breakable_flags = BREAKABLE_ALL
	health_item = 10
	health_item_max = 10
	damaged_examine_text = "Somehow it has a crack in it..."
	damage_armor = BREAKARMOR_INVINCIBLE
	damage_resist = 0
	density = 1
	breaks_text = "implodes"
	breakable_fragments = list(/obj/item/weapon/reagent_containers/food/snacks/hotdog)

/obj/item/weapon/reagent_containers/glass/jar/erlenmeyer/test
	name = "huge breakable flask"
	desc = "A huge flask that could break at any time, under the right conditions."
	breakable_flags = BREAKABLE_ALL
	health_item = 1
	health_item_max = 1
	damaged_examine_text = "It has a big crack down the side."
	damage_armor = BREAKARMOR_NOARMOR
	damage_resist = 0
	density = 1
	breaks_text = "shatters"

/obj/item/weapon/reagent_containers/glass/jar/erlenmeyer/test/New()
	..()
	reagents.add_reagent(BLOOD, 250)
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/test
	name = "breakable beaker"
	desc = "A breakable beaker. Can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	breakable_flags = BREAKABLE_ALL
	health_item = 1
	health_item_max = 1
	damaged_examine_text = "It has a big crack down the side."
	damage_armor = BREAKARMOR_NOARMOR
	damage_resist = 0
	breaks_text = "shatters"
	starting_materials = list(MAT_GLASS = 500)
	origin_tech = Tc_MATERIALS + "=1"
	layer = ABOVE_OBJ_LAYER //So it always gets layered above pills and bottles

/obj/item/weapon/reagent_containers/glass/jar/erlenmeyer/test/New()
	..()
	reagents.add_reagent(BLOOD, 50)
	update_icon()

/obj/item/weapon/storage/box/survival/test
	name = "breakable survival box"
	desc = "A box that holds survival equipment, but is also somewhat fragile."
	icon_state = "box_emergency"
	item_state = "box_emergency"
	breakable_flags = BREAKABLE_ALL
	health_item = 10
	health_item_max = 10
	density = 1
	damaged_examine_text = "It's all banged up."
	damage_armor = BREAKARMOR_NOARMOR
	damage_resist = 0
	breaks_text = "blows apart"
//	breakable_fragments = list(/obj/item/weapon/storage/box/survival/test)
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/food/snacks/hotdog,
		/obj/item/weapon/reagent_containers/food/snacks/hotdog,
		/obj/item/weapon/reagent_containers/food/snacks/hotdog,
	)






/////////////////////




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