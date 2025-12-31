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
	attacktext = "pinches"
	attack_sound = 'sound/weapons/bite.ogg'
	harm_intent_damage = 1
	melee_damage_lower = 1
	melee_damage_upper = 1
	environment_smash_flags = 0
	var/datum/seed/seed

/mob/living/simple_animal/hostile/retaliate/crabapple/reagent_act(id, method, volume)
	.=..()

	switch(id)
		if(PLANTBGONE)
			death(FALSE)

/mob/living/simple_animal/hostile/retaliate/crabapple/death(var/gibbed = FALSE)
	..(TRUE)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/crabmeat(src.loc)
	var/obj/item/weapon/reagent_containers/food/snacks/grown/crabapple/T
	T = new(src.loc)
	T.alive = FALSE
	if(seed)
		T.seed = seed
	qdel(src)
