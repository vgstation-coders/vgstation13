#define HOG_MAX 450
#define HOG_FED 300
#define HOG_HUNGRY 250
#define HOG_VHUNGRY 150

/mob/living/simple_animal/hostile/spacehog
	name = "feral space hog"
	desc = "This one isn't greased up."
	icon_state = "pig_4"
	icon_living = "pig_4"
	icon_dead = "pig_4_dead"
	speak_chance = 1
	turns_per_move = 5
	speak = list("Oink!","Squee!","Sqwaa!","Ounch!", "SQUEEEEE!","Oink...","Oink, oink", "Oink, oink, oink", "Oink!", "Oiiink.")
	emote_hear = list("squeals hauntingly")
	emote_see = list("roots about","squeals hauntingly")
	emote_sound = list("sound/voice/pigsnort.ogg","sound/voice/pigsqueal.ogg")
	response_help = "pats"
	response_disarm = "shoves"
	response_harm = "hits"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/box/pig
	speed = 1
	maxHealth = 80
	health = 80
	can_butcher = TRUE
	size = SIZE_BIG

	harm_intent_damage = 10
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "gores"
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "HOG"

	nutrition = HOG_FED

/mob/living/simple_animal/hostile/spacehog/mama
	name = "mama hog"
	desc = "Manslaughter."
	speed = 2.5
	maxHealth = 450
	health = 450

	nutrition = HOG_MAX

/mob/living/simple_animal/hostile/spacehog/Life()
	..()
	if((nutrition > HOG_HUNGRY) && prob(10))
		nutrition -= 15
		new /mob/living/simple_animal/hostile/spacehog/piglet(loc)


/mob/living/simple_animal/hostile/spacehog/greased
	name = "greased up feral space hog"
	desc = "Oh no, it's greased."
	speed = 0.8 //faster due to grease
	pass_flags = PASSMOB|PASSDOOR //greased hogs can move through doors

/mob/living/simple_animal/hostile/spacehog/greased/over
	name = "overgreased feral space hog"
	desc = "It leaves a sickly trail of grease, like a particularly slimy slug."
	speed = 0.7

/mob/living/simple_animal/hostile/spacehog/greased/over/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	//Before departing
	var/turf/T = loc
	if(istype(loc) && !T.is_wet())
		new /obj/effect/overlay/puddle(loc, TURF_WET_LUBE, 5 SECONDS) //leave 5 seconds of lube behind
	..() //move on

/mob/living/simple_animal/hostile/spacehog/piglet
	name = "feral space piglet"
	desc = "This one isn't old enough for grease."
	icon_state = "pig_1"
	icon_living = "pig_1"
	icon_dead = "pig_1_dead"
	maxHealth = 40
	health = 40
	size = SIZE_SMALL
	retreat_distance = 8 //Retreats and does not approach when it sees a hostile
	minimum_distance = 8

/mob/living/simple_animal/hostile/spacehog/Process_Spacemove(var/check_drift = 0)
	return 1 //All spacehogs are proficient in space navigation

/mob/living/simple_animal/hostile/spacehog/Life()
	..()
	nutrition--
	handle_hunger()


/mob/living/simple_animal/hostile/spacehog/proc/handle_hunger()
	switch(nutrition)
		if(HOG_FED to INFINITY)
			retreat_distance = 8
			minimum_distrance = 8 //skiddish, move away completely
		if(HOG_HUNGRY to HOG_FED-1)
			retreat_distance = 2
			minimum_distance = 1 //skiddish, hit and run tactics
		if(0 to HOG_HUNGRY-1)
			retreat_distance = null
			minimum_distance = 1 //hungry!