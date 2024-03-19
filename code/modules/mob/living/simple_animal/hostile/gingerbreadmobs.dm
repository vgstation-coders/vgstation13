/mob/living/simple_animal/hostile/ginger
	name = ""
	desc = ""
	icon_state = ""
	icon_living = ""
	icon_dead = ""
	environment_smash_flags = 0
	wander = 0
	turns_per_move = 15
	move_to_delay = 3
	speak_chance = 1
	speak = list("")
	speak_emote = list("crumbles","grumbles","shouts")
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/gingerbread_man
	response_help = "doughs up"
	response_disarm = "crumbs"
	response_harm = "breaks into"
	maxHealth = 75
	health = 75
	attacktext = "slices"
	melee_damage_lower = 10
	melee_damage_upper = 30
	attack_sound = "sound/weapons/pierce.ogg"
	vision_range = 7
	aggro_vision_range = 7
	idle_vision_range = 7
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

	blooded = FALSE

/mob/living/simple_animal/hostile/ginger/gingerchefman
	name = "gingerchef man"
	desc = "Prepare to meet your baker."
	icon_state = "gingerchefman"
	icon_living = "gingerchefman"
	icon_dead = "gingerchefman_dead"
	turns_per_move = 15
	move_to_delay = 3
	speak_chance = 1
	speak = list("Ready for the oven", "More meat for the pantry")
	maxHealth = 75
	health = 75
	attacktext = "slices"
	melee_damage_lower = 10
	melee_damage_upper = 30

/mob/living/simple_animal/hostile/ginger/gingerfatman
	name = "gingerfat man"
	desc = "Over frosted."
	icon_state = "gingerfatman"
	icon_living = "gingerfatman"
	icon_dead = "gingerfatman_dead"
	turns_per_move = 15
	move_to_delay = 5
	speak_chance = 1
	speak = list("I'll eat the legs first", "You look so tasty")
	maxHealth = 110
	health = 110
	attacktext = "bites"
	melee_damage_lower = 15
	melee_damage_upper = 20

/mob/living/simple_animal/hostile/ginger/gingerknightman
	name = "gingerknight man"
	desc = "Full of honor and calories."
	icon_state = "gingerknightman"
	icon_living = "gingerknightman"
	icon_dead = "gingerknightman_dead"
	move_to_delay = 3
	turns_per_move = 15
	speak_chance = 1
	speak = list("For kingdom and crumble")
	maxHealth = 85
	health = 85
	attacktext = "stabs"
	melee_damage_lower = 20
	melee_damage_upper = 30

/mob/living/simple_animal/hostile/ginger/gingerboneman
	name = "gingerbone man"
	desc = "Has mixed feelings about milk."
	icon_state = "gingerboneman"
	icon_living = "gingerboneman"
	icon_dead = "gingerboneman_dead"
	move_to_delay = 3
	turns_per_move = 15
	speak_chance = 1
	speak = list("Don't rattle me dough", "Careful, my friend, or I'll rattle and bake!")
	speak_emote = list("crumbles","grumbles","rattles")
	maxHealth = 50
	health = 50
	attacktext = "smacks"
	melee_damage_lower = 5
	melee_damage_upper = 10
	attack_sound = "sound/effects/rattling_bones.ogg"

/mob/living/simple_animal/hostile/ginger/gingerbomination
	name = "gingerbomination man"
	desc = "Stale dough and frosting holds loose, pale heaps of flesh together. The tiniest spark of the man he once was still trembles in his eyes. Although not entirely sentient, he is, at the very least, aware and awake. This poor creature has a pretty crumby life."
	icon_state = "gingerbominationman"
	icon_living = "gingerbominationman"
	icon_dead = "gingerbominationman_dead"
	move_to_delay = 2
	turns_per_move = 20
	speak_chance = 1
	speak = list("h-hhhe-el", "wh-why")
	speak_emote = list("crumbles","sputters","whimpers")
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human
	//Why did I do this. This started as a cute gingerbread house.
	maxHealth = 30
	health = 30
	attacktext = "stabs"
	melee_damage_lower = 10
	melee_damage_upper = 15
	attack_sound = "sound/weapons/pierce.ogg"
	vision_range = 8
	aggro_vision_range = 8
	idle_vision_range = 8
	speed = 3

/mob/living/simple_animal/hostile/ginger/gingerbroodmother
	name = "gingerbroodmother"
	icon = 'icons/mob/giantmobs.dmi'
	icon_state = "gingerbroodmother"
	icon_living = "gingerbroodmother"
	icon_dead = "gingerbroodmother_dead"
	pixel_x = -16 * PIXEL_MULTIPLIER
	wander = 0
	move_to_delay = 40
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/gingerbroodmother
	meat_amount = 1
	ranged = 1
	vision_range = 8
	aggro_vision_range = 9
	idle_vision_range = 8
	speed = 10
	maxHealth = 400
	health = 400
	harm_intent_damage = 5
	melee_damage_lower = 20
	melee_damage_upper = 35
	attacktext = "crumbles"
	ranged_cooldown = 2
	ranged_cooldown_cap = 18
	mob_property_flags = MOB_NO_LAZ

/mob/living/simple_animal/hostile/ginger/gingerbroodmother/OpenFire(var/the_target)
	var/mob/living/simple_animal/hostile/ginger/gingerbomination/A = new /mob/living/simple_animal/hostile/ginger/gingerbomination(src.loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction
	return

/mob/living/simple_animal/hostile/ginger/gingerbroodmother/AttackingTarget()
	OpenFire()

/mob/living/simple_animal/hostile/ginger/gingerbroodmother/death(var/gibbed = FALSE)
	..(gibbed)
	visible_message("What could be described as flesh crumbles apart and slough off the doughy monstrosity. In an instant, her once wriggling abdomen becomes still and she crumbles to the floor.")
	playsound(src, 'sound/effects/stone_crumble.ogg', 100, 1)

/mob/living/simple_animal/hostile/ginger/gingerbarman
	name = "gingerbar man"
	desc = "Upon closer inspection you notice his suit jacket is actually just a layer of frosting."
	icon_state = "gingerbarman"
	icon_living = "gingerbarman"
	icon_dead = "gingerbarman_dead"
	faction = "neutral"
	turns_per_move = 5
	move_to_delay = 3
	speak_chance = 30
	speak = list("I don't want any trouble")
	speak_emote = list("crumbles")
	maxHealth = 75
	health = 75
	attacktext = "slices"
	melee_damage_lower = 15
	melee_damage_upper = 25
	attack_sound = "sound/weapons/pierce.ogg"
	vision_range = 6
	aggro_vision_range = 6
	idle_vision_range = 6

/mob/living/simple_animal/hostile/ginger/gingerstripperman
	name = "gingerstripper man"
	desc = "Hey, everyone gets lonely."
	icon_state = "gingerregretman" //Our father who art in heaven, hallowed be thy name. They kingdom come. Thy will be done on earth as it is in heaven.
	icon_living = "gingerregretman" //Give us this day our daily bread, and forgive us our trespasses, as we forgive those who trespass against us
	icon_dead = "gingerregretman_dead"
	turns_per_move = 15
	move_to_delay = 2
	response_help = "doughs up"
	response_disarm = "crumbs"
	response_harm = "breaks into"
	maxHealth = 75
	health = 75
	attacktext = "smacks"
	melee_damage_lower = 15
	melee_damage_upper = 25

/mob/living/simple_animal/hostile/ginger/gingerprostituteman
	name = "gingerprostitute man"
	desc = "The oldest profession in the world."
	icon_state = "gingerregretman_mistake" //haha what if there was a gingerbread man hooker haha wouldn't that be funny haha
	icon_living = "gingerregretman_mistake"
	icon_dead = "gingerregretman_mistake_dead"
	turns_per_move = 15
	move_to_delay = 4 //can't run in those heels
	maxHealth = 90
	health = 90
	attacktext = "whips"
	melee_damage_lower = 20
	melee_damage_upper = 35

/mob/living/simple_animal/hostile/ginger/gingerclownman
	name = "gingerclown man"
	desc = "Even compared to normal clowns his jokes are crumby."
	icon_state = "gingerclownman"
	icon_living = "gingerclownman"
	icon_dead = "gingerclownman_dead"
	turns_per_move = 15
	move_to_delay = 2
	speak_chance = 1
	speak = list("Honk")
	speak_emote = list("crumbles","honks")
	maxHealth = 75
	health = 75
	attacktext = "honks"
	melee_damage_lower = 5
	melee_damage_upper = 15
	attack_sound = "sound/items/bikehorn.ogg"
	speed = 3
