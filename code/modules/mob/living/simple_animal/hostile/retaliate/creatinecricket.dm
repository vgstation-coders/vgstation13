/mob/living/simple_animal/hostile/retaliate/creatinecricket
	name = "creatine cricket"
	desc = "A cricket that got exposed to large quantities of steroids. It is quite tame if not provoked, unlike it's cockroach cousins. Has never skipped leg day, ever."

	icon_state = "cricket_creatine"
	icon_living = "cricket_creatine"
	icon_dead = "cricket_creatine_dead"
	
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps on the"
	
	emote_hear = list("chirps")
	emote_sound = list("sound/effects/creatine_cricket_chirp.ogg")

	pass_flags = PASSTABLE | PASSGRILLE | PASSMACHINE

	speak_chance = 1

	treadmill_speed = 2	//Look at those legs man, they ain't skipping leg day that's for sure
	move_to_delay = 4

	maxHealth = 50 //tweak this if I ever add cricket breeding
	health = 50

	size = SIZE_SMALL

	minbodytemp = 223.15		//Can't survive at below -50 °C
	maxbodytemp = INFINITY		//You think a nuke can stop us?
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/cricket/big

	melee_damage_lower = 7
	melee_damage_upper = 12
	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'
	//to do: make it so the attack animation is a kick or the ayylien or whatever, low priority
	
	faction = "cricket"

	var/icon_aggro = "cricket_creatine-angry"
	var/wander_icon = "cricket_creatine-hop"

/mob/living/simple_animal/hostile/retaliate/creatinecricket/New()
	..()

	pixel_x = rand(-5, 5) * PIXEL_MULTIPLIER
	pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER

/mob/living/simple_animal/hostile/retaliate/creatinecricket/death(var/gibbed = FALSE)
	..(gibbed)
	playsound(src, pick('sound/effects/gib1.ogg','sound/effects/gib2.ogg','sound/effects/gib3.ogg'), 40, 1) //Splat

/mob/living/simple_animal/hostile/retaliate/creatinecricket/Aggro()
	..()

	icon_living = icon_aggro
	icon_state = icon_living

	spawn(rand(1,14))
		playsound(src, 'sound/effects/cricket_hiss.ogg', 50, 1)

/mob/living/simple_animal/hostile/retaliate/creatinecricket/LoseAggro()
	..()

	icon_living = initial(icon_living)
	icon_state = icon_living

/mob/living/simple_animal/hostile/retaliate/creatinecricket/ex_act()
	return //we swole enough to tank bombs, but not swole enough to tank nukes, we gotta get STRONGER

/mob/living/simple_animal/hostile/retaliate/creatinecricket/reagent_act(id, method, volume)
	if(isDead())
		return

	.=..()

	switch(id)
		if(INSECTICIDE)
			if(method != INGEST)
				death(FALSE)

/mob/living/simple_animal/hostile/retaliate/creatinecricket/wander_move(turf/dest)
	icon_state = wander_icon
	animate(src, pixel_x = rand(-8,8), time=4, loop=1, easing=ELASTIC_EASING)
	..()
	spawn(4)
		wander_icon = icon_living

/mob/living/simple_animal/hostile/retaliate/creatinecricket/king
	name = "cricket king"
	real_name = "cricket king"
	desc = "The peak of cricket form, recognized by his fellow bugs as the rightful king."

	icon_state = "cricket_creatine_king"
	icon_living = "cricket_creatine_king"
	icon_dead = "cricket_creatine_king_dead"

	maxHealth = 150
	health = 150

	size = SIZE_NORMAL

	melee_damage_lower = 10 //don't fuck with this bug
	melee_damage_upper = 25

	treadmill_speed = 4 //peak form bro
	move_to_delay = 2
	turns_per_move = 3

	icon_aggro = "cricket_creatine_king-angry"
	wander_icon = "cricket_creatine_king-hop"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/cricket/king

/mob/living/simple_animal/hostile/retaliate/creatinecricket/king/New()
	..()
	name = pick(
		"The Undercricket",
		"'Macho Crick' Chirping Savage",
		"Hulk Crickan",
		"Radical Steve",
		"'Stone Cold' Crick Austin",
		"The King",
		"Rey Crickterio",
		"Xhong Xina", //I will not apologize
		)
	real_name = name
	if(real_name == "Xhong Xina")
		desc = "[desc] Bing Chilling! +10000 social credit!" //I will not apologize

//TO DO: make it so the cricket king can flex and shit to inspire crickets to get swole (essentially breeding more swole crickets at the expense of regular crickets)
//something something it emits SWOLE pheromones that act like creatine
