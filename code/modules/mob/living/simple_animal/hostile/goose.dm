/mob/living/simple_animal/hostile/goose
	name = "space goose"
	desc = "One of the most twisted space avians in existence."
	icon_state = "goose"
	icon_living = "goose"
	icon_dead = "goose_dead"
	icon_gib = "goose_gib"
	speak = list("Quack","Wenk", "Guwaak", "Wamp", "Whomp", "Qwark")
	speak_emote = list("honks", "hinks", "henks")
	speak_chance = 5
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/goosemeat
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	speed = 1
	maxHealth = 35
	health = 35
	size = SIZE_BIG
	meat_amount = 2

	harm_intent_damage = 8
	melee_damage_lower = 8
	melee_damage_upper = 12
	attacktext = "bites"
	attack_sound = 'sound/items/quack.ogg'

	//Space Geese aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

/mob/living/simple_animal/hostile/goose/Process_Spacemove(var/check_drift = 0)
	return 1