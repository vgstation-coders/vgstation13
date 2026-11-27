/mob/living/simple_animal/hostile/deer
	name = "deer"
	desc = "A large herbivore, sporting antlers on their head. Quick to spook."
	icon_state = "deer"
	icon_living = "deer"
	icon_dead = "deer_dead"
	faction = "deer"
	health = 50
	maxHealth = 50
	size = SIZE_NORMAL
	response_help  = "pets"

	attacktext = "kicks"
	melee_damage_lower = 5
	melee_damage_upper = 15

	treadmill_speed = 2.5
	minbodytemp = 200

// WIP: the tree acquires targets; the spook hook replaces the legacy target
// acquisition side of the deer behavior.
/mob/living/simple_animal/hostile/deer/New()
	..()
	stop_automated_movement = TRUE
	wander = 0
	var/datum/ai_controller/controller = new(src)
	controller.behavior_nodes = list(list(
		BT_DESC_TYPE = /datum/bt_node/composite/selector,
		BT_DESC_CHILDREN = list(
			list(
				BT_DESC_TYPE = /datum/bt_node/decorator/bb_key_exists,
				key = BB_SPOOKED,
				observer_abort = BT_ABORT_SELF,
				BT_DESC_CHILDREN = list(list(
					BT_DESC_TYPE = /datum/bt_node/ai_behavior/flee_target,
					flee_distance = 25,
					hold_while_target_alive = TRUE,
				)),
			),
			bt_hostile_combat_tree(),
		),
	))
	controller.initialize_behavior_tree()

/mob/living/simple_animal/hostile/deer/ai_target_acquired(atom/target)
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(!is_spooked(living_target))
		return
	var/list/can_see = view(src, vision_range)
	get_spooked(living_target)
	for(var/mob/living/simple_animal/hostile/deer/D in can_see)
		D.get_spooked(living_target)

/mob/living/simple_animal/hostile/deer/proc/is_spooked(var/mob/living/target)
	for(var/datum/weakref/ref in friends)
		if (ref.get() == target)
			return 0
	if(ishuman(target))
	/*
	Making it so that there is some tactics to hunting deer
		If you're running at them like a crazy man, expect for them to get spooked
		Otherwise, if you're wearing clothing made of deer, or are holding an apple, they are less likely to get spooked
	*/
		var/mob/living/carbon/human/H = target
		var/spook_prob = 30

		if(H.m_intent == "run") //Don't run while stalking deer
			spook_prob = 70
		if(istype(H.get_item_by_slot(slot_wear_suit), /obj/item/clothing/suit/leather/deer))
			spook_prob -= 10
		if(istype(H.get_item_by_slot(slot_head), /obj/item/clothing/head/leather/deer))
			spook_prob -= 10
			if(istype(H.get_item_by_slot(slot_head), /obj/item/clothing/head/leather/deer/horned))
				spook_prob -= 10
		for(var/obj/item/I in H.held_items)
			if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/grown/apple))
				spook_prob -= 10
			if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/grown/goldapple))
				spook_prob -= 20
		if(prob(spook_prob))
			return 1
	else
		if(!istype(target, /mob/living/simple_animal/hostile/deer))
			return 1

/mob/living/simple_animal/hostile/deer/proc/get_spooked(var/mob/living/T)
	// The tree does not drive stance; only set it for mobs still on the legacy AI.
	if(!ai_controller)
		stance = HOSTILE_STANCE_ATTACK
	target = T
	if(ai_controller)
		ai_controller.blackboard[BB_SPOOKED] = TRUE
		ai_controller.blackboard[BB_TARGET] = T
	visible_message("<span class='danger'>\The [src] tries to flee from \the [target]!</span>")
	retreat_distance = 25
	minimum_distance = 25

/mob/living/simple_animal/hostile/deer/get_butchering_products()
	return list(/datum/butchering_product/skin/deer, /datum/butchering_product/deer_head)

/mob/living/simple_animal/hostile/deer/Life()
	..()
	if(isDead())
		return
	if(!ai_controller || !ai_controller.blackboard[BB_SPOOKED])
		return
	var/list/can_see = view(src, vision_range)
	spawn(15)
		if(QDELETED(src) || !ai_controller)
			return
		var/someone_spooky = 0
		for(var/mob/living/L in can_see)
			if(is_spooked(L))
				someone_spooky = 1
				break
		if(!someone_spooky)
			calm_down()


/mob/living/simple_animal/hostile/deer/proc/calm_down()
	visible_message("<span class='notice'>\The [src] calms down</span>")
	retreat_distance = 0
	minimum_distance = 0
	LoseTarget()
	if(ai_controller)
		ai_controller.blackboard.Remove(BB_SPOOKED)
		ai_controller.blackboard.Remove(BB_TARGET)



/mob/living/simple_animal/hostile/deer/attackby(obj/W, mob/user)
	if(!isDead() && (istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/apple) || (istype (W, /obj/item/weapon/reagent_containers/food/snacks/grown/goldapple))))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/apple/A = W

		playsound(src,'sound/items/eatfood.ogg', rand(10,50), 1)
		visible_message("<span class='info'>\The [src] gobbles up \the [W]!")
		//user.drop_item(A, force_drop = 1)

		if(istype (W, /obj/item/weapon/reagent_containers/food/snacks/grown/goldapple))
			icon_living = "deer_flower"
			icon_dead = "deer_dead"
			icon_state = "deer_flower"

		if(prob(25))
			var/already_friend = FALSE
			for(var/datum/weakref/ref in friends)
				if (ref.get() == user)
					already_friend = TRUE
			if (!already_friend)
				friends += makeweakref(user)
				to_chat(user, "<span class='info'>You have gained \the [src]'s trust.</span>")
			name_mob(user)
		qdel(A)

		if(istype (W, /obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned))
			spawn(rand(50,150))
				death() //You dick
		return
	..()

/mob/living/simple_animal/hostile/deer/update_icons()
	.=..()

	if(stat == DEAD && butchering_drops)
		var/datum/butchering_product/deer_head/our_head = locate(/datum/butchering_product/deer_head) in butchering_drops
		if(istype(our_head))
			icon_state = "[icon_dead][(our_head.amount) ? "" : "_headless"]"

/mob/living/simple_animal/hostile/deer/cultify()
	var/mob/living/simple_animal/hostile/deer/flesh/fleshy_deer = new(get_turf(src))
	fleshy_deer.dir = dir
	qdel(src)

/mob/living/simple_animal/hostile/deer/flesh
	icon_state = "fleshdeer"
	icon_living = "fleshdeer"
	icon_dead = "fleshdeer_dead"

	supernatural = TRUE
	canRegenerate = 1
	maxRegenTime = 150
	minRegenTime = 60

/mob/living/simple_animal/hostile/deer/flesh/get_butchering_products()
	return list(/datum/butchering_product/deer_head)

/mob/living/simple_animal/hostile/deer/flesh/cultify()
	return
