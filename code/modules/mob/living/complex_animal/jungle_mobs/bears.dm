/mob/living/simple_animal/complex/bear
	name="\improper Bear"
	desc="Does it shit in the woods?"
	icon_state="brownbear"
	icon_living = "brownbear"
	icon_dead = "brownbear_dead"
	faction="bears"
	size=SIZE_BIG
	health=60
	maxHealth=60
	armor=list(melee=10,bullet=20,laser=20,energy=0,bomb=0,bio=0,rad=0)
	max_food=100
	food_flags = ANIMAL_CARNIVORE | ANIMAL_HERBIVORE
	melee_damage_upper=30
	melee_damage_lower=20
	behavior_flags = ANIMAL_BEHAVIOR_PREDATORY | ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_PACK_DYNAMICS | ANIMAL_BEHAVIOR_DESTRUCTIVE | ANIMAL_BEHAVIOR_AVOID_CAPTURE
	movespeed=5
	kin_check_type_path=/mob/living/simple_animal/complex/bear
	max_local_population=5
	var/sea_bear=TRUE

/mob/living/simple_animal/complex/bear/get_idle_sounds()
	if(prob(10))
		var/i=rand(1,2)
		switch(i)
			if(1)
				emote("me", MESSAGE_HEAR, "growls.")
			if(2)
				emote("me", MESSAGE_HEAR, "roars.")

/mob/living/simple_animal/complex/bear/get_attack_msg(var/individual)
	var/i=rand(1,3)
	switch(i)
		if(1)
			emote("me", MESSAGE_SEE, "bites \the [individual]!")
		if(2)
			emote("me", MESSAGE_SEE, "swings at \the [individual]!")
		if(3)
			emote("me", MESSAGE_SEE, "claws \the [individual]!")


/mob/living/simple_animal/complex/bear/verify_target(var/individual,var/max_distance=-1,var/allow_dead=FALSE)
	if(sea_bear)
		for(var/obj/effect/decal/cleanable/crayon/C in get_turf(individual))
			if(!C.on_wall && C.name == "o") //drawing a circle around yourself is the only way to ward off space bears!
				return FALSE
	return ..()

/mob/living/simple_animal/complex/bear/get_butchering_products()
	return list(/datum/butchering_product/skin/bear/brownbear, /datum/butchering_product/teeth/lots)


/mob/living/simple_animal/complex/bear/spare
	name="\proper Spare Bear"
	desc="This bear has adapted a form of camouflage from generations of natural selection in which the omnivores scavenge from space stations and their dumpsters. Its golden skin fools card scanners into opening the door."
	icon_state="sparebear"
	icon_living = "sparebear"
	icon_dead = "sparebear_dead"
	health=250
	maxHealth=250
	armor=list(melee=10,bullet=30,laser=40,energy=0,bomb=0,bio=0,rad=0)
	max_food=200
	mob_max_age=9999999
	healthregen=0.02
	food_per_tick = 0.0005
	melee_damage_upper=40
	melee_damage_lower=30
	behavior_flags = ANIMAL_BEHAVIOR_PREDATORY | ANIMAL_BEHAVIOR_TERRITORIAL | ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_PACK_DYNAMICS | ANIMAL_BEHAVIOR_DESTRUCTIVE | ANIMAL_BEHAVIOR_AVOID_CAPTURE
	animal_flags = ANIMAL_FLAG_IMMORTAL
	movespeed=4
	sea_bear=FALSE

/mob/living/simple_animal/complex/bear/spare/can_offspring(var/mob/living/simple_animal/complex/mate)
	return FALSE

/mob/living/simple_animal/complex/bear/spare/GetAccess()
	return get_all_accesses()

/mob/living/simple_animal/complex/bear/spare/get_butchering_products()
	return list(/datum/butchering_product/skin/bear/spare, /datum/butchering_product/teeth/lots)

/mob/living/simple_animal/complex/bear/spare/aggro_drawn(var/victim,var/state=ANIMAL_STATE_ATTACKING)
	if(!victim)
		return
	target=victim
	behavior_state=state
	get_aggro_msg(victim)
	if( !(behavior_flags & ANIMAL_BEHAVIOR_PACK_DYNAMICS) && !family.len)
		return
	if(istype(target,/mob/living))
		var/mob/living/T=target
		if(T.stat!=DEAD)
			var/list/nearby_objects=range(15,src) //increased range, and ignores visibility. have fun!
			for(var/mob/living/simple_animal/complex/M in nearby_objects)
				if( (behavior_flags & ANIMAL_BEHAVIOR_PACK_DYNAMICS) || (M in family))
					if(is_kin(M) && !M.is_kin(target))
						if(M.behavior_state!=state)
							M.aggro_drawn(victim,state)

/mob/living/simple_animal/complex/bear/panda
	name="\improper Panda Bear"
	desc="Endangered even in space."
	icon_state="panda"
	icon_living = "panda"
	icon_dead = "panda_dead"
	behavior_flags = ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_PACK_DYNAMICS | ANIMAL_BEHAVIOR_DESTRUCTIVE
	movespeed=6
	food_per_tick=0.0015
	

/mob/living/simple_animal/complex/bear/panda/can_offspring(var/mob/living/simple_animal/complex/mate)
	.=..()
	if(prob(75))
		return FALSE

/mob/living/simple_animal/complex/bear/panda/get_butchering_products()
	return list(/datum/butchering_product/skin/bear/panda, /datum/butchering_product/teeth/lots)
	
/mob/living/simple_animal/complex/bear/polar
	name="\improper Polar Bear"
	desc="Its eyes are souless and cold."
	icon_state="polarbear"
	icon_living = "polarbear"
	icon_dead = "polarbear_dead"
	behavior_flags = ANIMAL_BEHAVIOR_PREDATORY | ANIMAL_BEHAVIOR_TERRITORIAL | ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_DESTRUCTIVE | ANIMAL_BEHAVIOR_AVOID_CAPTURE
	melee_damage_upper=45
	melee_damage_lower=25
	health=70
	maxHealth=70
	

/mob/living/simple_animal/complex/bear/polar/get_butchering_products()
	return list(/datum/butchering_product/skin/bear/polarbear, /datum/butchering_product/teeth/lots)


/mob/living/simple_animal/complex/bear/polar/chef
	name="\proper Chef Bear"
	desc="Not to be confused with Chief Bear, leader of bear tribe. This one just likes to cook."
	behavior_flags = ANIMAL_BEHAVIOR_TERRITORIAL | ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_DESTRUCTIVE | ANIMAL_BEHAVIOR_AVOID_CAPTURE
	animal_flags = ANIMAL_FLAG_IMMORTAL
	movespeed=4
	health=100
	mob_max_age=9999999
	melee_damage_upper=50
	melee_damage_lower=20
	maxHealth=100
	food_per_tick=0.0
	healthregen=0.015
	sea_bear=FALSE

/mob/living/simple_animal/complex/bear/polar/chef/can_offspring(var/mob/living/simple_animal/complex/mate)
	return FALSE	