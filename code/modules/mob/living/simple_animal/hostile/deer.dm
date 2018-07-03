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

	minbodytemp = 200

/mob/living/simple_animal/hostile/deer/GiveTarget(var/new_target)
	if(isDead())
		return //The deers problems are over now, try not to be too jealous
	if(isliving(new_target))
		if(is_spooked(new_target))
			var/list/can_see = view(src, vision_range)
			get_spooked(new_target)
			for(var/mob/living/simple_animal/hostile/deer/D in can_see)
				D.get_spooked(new_target)

/mob/living/simple_animal/hostile/deer/proc/is_spooked(var/mob/living/target)
	if(friends.Find(target))
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
	stance = HOSTILE_STANCE_ATTACK
	target = T
	visible_message("<span class='danger'>\The [src] tries to flee from \the [target]!</span>")
	retreat_distance = 25
	minimum_distance = 25

/mob/living/simple_animal/hostile/deer/Life()
	..()
	if(isDead())
		return
	var/list/can_see = view(src, vision_range)
	if(stance == HOSTILE_STANCE_ATTACK)
		spawn(15)
			var/is_spooked = 0
			for(var/mob/living/L in can_see)
				if(is_spooked(L))
					is_spooked = 1
			if(!is_spooked)
				calm_down()


/mob/living/simple_animal/hostile/deer/proc/calm_down()
	visible_message("<span class='notice'>\The [src] calms down</span>")
	retreat_distance = 0
	minimum_distance = 0
	LoseTarget()



/mob/living/simple_animal/hostile/deer/attackby(obj/W, mob/user)
	if(!isDead() && (istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/apple) || (istype (W, /obj/item/weapon/reagent_containers/food/snacks/grown/goldapple))))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/apple/A = W

		playsound(get_turf(src),'sound/items/eatfood.ogg', rand(10,50), 1)
		visible_message("<span class='info'>\The [src] gobbles up \the [W]!")
		//user.drop_item(A, force_drop = 1)

		if(istype (W, /obj/item/weapon/reagent_containers/food/snacks/grown/goldapple))
			icon_living = "deer_flower"
			icon_dead = "deer_dead"
			icon_state = "deer_flower"

		if(prob(25))
			if(!friends.Find(user))
				friends.Add(user)
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
	new /mob/living/simple_animal/hostile/deer/flesh(get_turf(src))
	qdel(src)

/mob/living/simple_animal/hostile/deer/flesh
	icon_state = "fleshdeer"
	icon_living = "fleshdeer"
	icon_dead = "fleshdeer_dead"

	canRegenerate = 1
	maxRegenTime = 150
	minRegenTime = 60

/mob/living/simple_animal/hostile/deer/flesh/cultify()
	return