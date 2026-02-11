/mob/living/simple_animal/complex/crocodile
	name = "\improper Crocodile"
	desc = "Not to be confused with an alligator, or even a gharial."
	icon_state="crocodile"
	icon_living="crocodile"
	icon_dead="crocodile-dead"
	size=SIZE_BIG
	health=100
	maxHealth=100
	armor=list(melee=35,bullet=10,laser=15,energy=0,bomb=0,bio=0,rad=0)
	max_food=100
	food_flags = ANIMAL_CARNIVORE
	melee_damage_upper=25
	melee_damage_lower=15
	behavior_flags = ANIMAL_BEHAVIOR_PREDATORY | ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_DESTRUCTIVE | ANIMAL_BEHAVIOR_TERRITORIAL
	movespeed=5
	max_local_population = 3
	mob_max_age = 900 // 30 minutes
	food_per_tick = 0.0001
	var/stuntracker=FALSE //prevents being stunlocked
	
/mob/living/simple_animal/complex/crocodile/tick_state_idle() //we like water.
	.=..()
	if(prob(50))
		return
	var/list/watertiles=list()
	for(var/turf/unsimulated/floor/planetary/water/jungle/W in cache_objects_in_view)
		watertiles+=W
	if(!watertiles.len)
		return
	var/turf/unsimulated/floor/planetary/water/jungle/waterspot = pick(watertiles)
	walk_to(src,waterspot)

/mob/living/simple_animal/complex/crocodile/attack(var/victim)
	.=..()
	if(. && istype(victim,/mob/living/carbon) )
		var/mob/living/carbon/C=victim
		if(!stuntracker)
			C.Knockdown(2)
			C.stop_pulling()
			visible_message("<b>\The [src]</b> knocks <b>\the [target]</b> off their feet!")
			stuntracker=TRUE
		else
			stuntracker=FALSE
/mob/living/simple_animal/complex/crocodile/get_attack_msg(var/individual)
	emote("me", MESSAGE_SEE, "[prob(50) ? "bites" : "chomps"] \the [individual]!")

/mob/living/simple_animal/complex/crocodile/get_idle_sounds()
	if(prob(10))
		var/i=rand(1,2)
		switch(i)
			if(1)
				emote("me", MESSAGE_HEAR, "growls.")
			if(2)
				if(loc.type==/turf/unsimulated/floor/planetary/water/jungle)
					emote("me", MESSAGE_HEAR, "splashes.")
				else
					emote("me", MESSAGE_HEAR, "growls.")


/mob/living/simple_animal/complex/crocodile/schnapps
	name = "Schnapps"
	desc = "Definitely the coolest croc on the planet."
	icon_state="schnapps"
	icon_living="schnapps"
	icon_dead="schnapps-dead"
	behavior_flags = ANIMAL_BEHAVIOR_RETALIATE
	animal_flags = ANIMAL_FLAG_IMMORTAL | ANIMAL_FLAG_NEVER_ROT
	movespeed=6
	health=120
	maxHealth=120
	armor=list(melee=35,bullet=15,laser=20,energy=0,bomb=10,bio=0,rad=0)
	petable=TRUE
	is_pet=TRUE

/mob/living/simple_animal/complex/crocodile/schnapps/get_offspring_cost()
	return 0 //no infinite schnapps.	
/mob/living/simple_animal/complex/crocodile/schnapps/can_offspring()
	return FALSE


/mob/living/simple_animal/complex/crocodile/schnapps/tick_state_attacking()
	.=..()
	if(. && ticks_this_state>4) //forgives you after 10 seconds
		emote("me",MESSAGE_SEE,"looks more calm.")
		abort_target()
		return FALSE
	