/mob/living/simple_animal/hostile/retaliate/tomato
	name = "tomato"
	desc = "It's a horrifyingly enormous beef tomato, and it's packing extra beef!"
	icon_state = "tomato"
	icon_living = "tomato"
	icon_dead = "tomato_dead"
	faction = "tomato"
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 15
	health = 15
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/tomatomeat
	response_help  = "prods the"
	response_disarm = "pushes aside the"
	response_harm   = "smacks the"
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	environment_smash_flags = 0

/mob/living/simple_animal/hostile/retaliate/tomato/reagent_act(id, method, volume)
	if(isDead())
		return

	.=..()

	switch(id)
		if(PLANTBGONE)
			death(FALSE)
