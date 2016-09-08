/mob/living/simple_animal/hostile/snake
	name = "snake"
	icon_state = "poisonsnake"
	icon_living = "poisonsnake"
	icon_dead = "poisonsnake_dead"
	icon_gib = "poisonsnake_dead"

	speak = list("hiss", "hisssss", "hissss")
	maxHealth = 10
	health = 10
	speed = 2
	vision_range = 3	   //snake only attacks if you are close
	aggro_vision_range = 3 //snake only attacks if you are close
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"

	harm_intent_damage = 1
	melee_damage_lower = 2
	melee_damage_upper = 1
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	environment_smash = 0
	size = SIZE_TINY

	var/poison_chance = 25
	var/poison_per_bite = 5
	var/poison_type = SVENOM


/mob/living/simple_animal/hostile/snake/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			if(prob(poison_chance))
				visible_message("<span class='warning'>\the [src] injects a powerful toxin into [L]!</span>")
				L.reagents.add_reagent(poison_type, poison_per_bite)