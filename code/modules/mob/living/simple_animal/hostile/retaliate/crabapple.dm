/mob/living/simple_animal/hostile/retaliate/crabapple
	name = "crab apple"
	desc = "No one likes crabs..."
	icon_state = "crab_apple"
	icon_living = "crab_apple"
	faction = "tomato"
	speak_chance = 0
	turns_per_move = 3
	maxHealth = 5
	health = 5
	response_help  = "prods the"
	response_disarm = "pushes aside the"
	response_harm   = "snaps the"
	attacktext = "snips"
	attack_sound = 'sound/weapons/toolhit.ogg'
	harm_intent_damage = 1
	melee_damage_lower = 1
	melee_damage_upper = 1
	environment_smash_flags = 0
	var/datum/seed/sneed = null

/mob/living/simple_animal/hostile/retaliate/crabapple/reagent_act(id, method, volume)
	.=..()

	switch(id)
		if(PLANTBGONE)
			death(FALSE)

/mob/living/simple_animal/hostile/retaliate/crabapple/death(var/gibbed = FALSE)
	..(TRUE)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/crabmeat(loc)
	if(sneed)
		var/product_type = pick(sneed.products)
		var/obj/item/weapon/reagent_containers/food/snacks/grown/apple/crabapple/apple = new product_type(loc, custom_plantname = sneed.name)
		if(istype(apple, /obj/item/weapon/reagent_containers/food/snacks/grown/apple/crabapple))
			apple.alive = FALSE
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/crabapple/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.is_wirecutter(user))
		if(stat == DEAD)
			return ..()
		to_chat(user, "<span class='danger'>This kills the crab.</span>")
		health -= 25
		death()
	else
		return ..()
