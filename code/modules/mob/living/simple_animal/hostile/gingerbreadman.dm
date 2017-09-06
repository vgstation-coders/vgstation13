/mob/living/simple_animal/hostile/gingerbread
	name = "gingerbread man"
	desc = "Once upon a time somebody got really hungry, so they prayed to the gods to be able to bake a large piece of gingerbread...\n This is the result."
	icon_state = "gingerbreadman"
	icon_living = "gingerbreadman"
	icon_dead = "gingerbreadman_dead"
	turns_per_move = 15 //You can't catch me, I'm the Gingerbread man!
	speak_chance = 1
	speak = list("Nya ha ha", "They couldn't catch me!", "I'd like to see somebody take a bite outta me now!")
	speak_emote = list("crumbles","grumbles","shouts")
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/gingerbread_man
	//Ideally they'd drop gingerbread loaves or slices, but this is all we have at the moment.
	response_help = "doughs up"
	response_disarm = "crumbs"
	response_harm = "breaks into"
	maxHealth = 75
	health = 75
	attacktext = "stabs"
	melee_damage_lower = 10
	melee_damage_upper = 25
	attack_sound = "sound/weapons/pierce.ogg"
	mob_property_flags = MOB_CONSTRUCT
	//This dough's hard baked
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	speed = 5
