/mob/living/simple_animal/complex/dinosaur
	name="\improper Dinosaur"
	desc="Boom boom acka lacka boom boom."
	icon_state="dino"
	icon_living = "dino"
	icon_dead = "dino_dead"
	size=SIZE_BIG
	health=100
	maxHealth=100
	armor=list(melee=35,bullet=30,laser=5,energy=0,bomb=0,bio=0,rad=0)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/oogabooga
	max_food=100
	food_flags = ANIMAL_CARNIVORE | ANIMAL_FRUGIVORE
	melee_damage_upper=25
	melee_damage_lower=15
	behavior_flags = ANIMAL_BEHAVIOR_PREDATORY | ANIMAL_BEHAVIOR_PACK_DYNAMICS | ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_DESTRUCTIVE | ANIMAL_BEHAVIOR_AVOID_CAPTURE | ANIMAL_BEHAVIOR_TERRITORIAL
	movespeed=7
	

/mob/living/simple_animal/complex/dinosaur/tick_state_idle()
	if(!..())
		return FALSE
	var/shouldwalk=FALSE
	for(var/mob/living/carbon/M in range(src,7))
		if(M.resting)
			shouldwalk=TRUE
		else
			shouldwalk=FALSE
			break
	if(shouldwalk)
		behavior_state=ANIMAL_STATE_SPECIAL
	return TRUE


/mob/living/simple_animal/complex/dinosaur/verify_target(var/individual,var/max_distance=-1,var/allow_dead=FALSE)
	if (istype(individual,/mob/living/carbon))
		var/mob/living/carbon/C=individual
		if (C.resting)
			return FALSE
	return ..()

/mob/living/simple_animal/complex/dinosaur/tick_state_special()
	if(!..())
		return FALSE
	var/shouldwalk=FALSE
	for(var/mob/living/carbon/M in range(src,7))
		if(M.resting || M.stat==DEAD)
			shouldwalk=TRUE
		else
			shouldwalk=FALSE
			break
	if(!shouldwalk)
		behavior_state=ANIMAL_STATE_IDLE
	else
		walkthedinosaur()
	return TRUE


/mob/living/simple_animal/complex/dinosaur/get_attack_msg(var/individual)
	var/i=rand(1,3)
	switch(i)
		if(1)
			emote("me", MESSAGE_SEE, "bites \the [individual]!")
		if(2)
			emote("me", MESSAGE_SEE, "chomps on \the [individual]!")
		if(3)
			emote("me", MESSAGE_SEE, "nibbles at \the [individual]!")

/mob/living/simple_animal/complex/dinosaur/get_idle_sounds()
	if(prob(10))
		var/i=rand(1,3)
		switch(i)
			if(1)
				emote("me", MESSAGE_HEAR, "growls.")
			if(2)
				emote("me", MESSAGE_HEAR, "roars.")
			if(3)
				emote("me", MESSAGE_HEAR, "stomps.")


/mob/living/simple_animal/complex/dinosaur/determine_tresspass(var/mob/trespasser)	
	if(trespasser.resting)
		return FALSE
	return ..()

/mob/living/simple_animal/complex/dinosaur/determine_isthreat(var/mob/individual)
	if(individual.resting)
		return FALSE
	return ..()

/mob/living/simple_animal/complex/dinosaur/rank_foodsources(var/list/sources)
	var/list/out=..()
	for(var/atom/A in out)
		if(istype(A,/mob/living/carbon)) //mobs on the floor shouldn't be eaten as much.
			var/mob/living/carbon/M = A
			if(M.resting)
				out[A]-=4
	return out

/mob/living/simple_animal/complex/dinosaur/attack(var/victim)
	.=..()
	if(.)
		icon_state="dino-bite"
	return .

/mob/living/simple_animal/complex/dinosaur/get_butchering_products()
	return list(/datum/butchering_product/skin/lizard/lots, /datum/butchering_product/teeth/lots)


/mob/living/simple_animal/complex/dinosaur/proc/walkthedinosaur()
	var/list/dirlist=list(NORTH,SOUTH,EAST,WEST,NORTHWEST,SOUTHEAST,NORTHEAST,SOUTHWEST)
	var/list/dirlist_cardinal=list(NORTH,SOUTH,EAST,WEST)
	for(var/i=0,i<4,i++)
		for(var/mob/living/carbon/M in range(src,7))
			M.dir=pick(dirlist_cardinal)
		if(prob(33))
			Move(get_step(src,pick(dirlist)))
		dir=pick(dirlist_cardinal)
		sleep(5)
	if(prob(20))
		if(world.time % 3==1)
			say("Acka lacka.")
		else
			say("Boom boom.")