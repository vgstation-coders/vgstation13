/mob/living/complex_animal/frog
	name="\improper Frog"
	desc="Ribbit."
	icon_state="smallfrog"
	icon_living = "smallfrog"
	icon_dead = "smallfrog_dead"
	size=SIZE_TINY
	health=10
	maxHealth=10
	max_food=20
	food_per_tick = -0.001 //there's no bugs to eat so uh...
	food_flags = 0
	base_damage = 5
	damage_variance = 1
	behavior_flags = ANIMAL_BEHAVIOR_AVOID_PRED
	movespeed=4
	kin_check_type_path=/mob/living/complex_animal/frog
	petable=TRUE
	pass_flags = PASSTABLE | PASSRAILING | PASSMACHINE | PASSMOB

/mob/living/complex_animal/frog/get_butchering_products()
	return list(/datum/butchering_product/frog_leg)


/mob/living/complex_animal/frog/get_idle_sounds()
	if(prob(10))
		var/i=rand(1,2)
		switch(i)
			if(1)
				emote("me", MESSAGE_HEAR, "ribbits.")
			if(2)
				emote("me", MESSAGE_HEAR, "croaks.")


/mob/living/complex_animal/frog/trypet(mob/living/carbon/human/M)
	..()
	emote("me", EMOTE_AUDIBLE, "croaks.")
	playsound(loc, 'sound/voice/frogcroak.ogg', 50, 1)


/mob/living/complex_animal/frog/poison
	name="\improper Poison Dart Frog"
	desc="Poisonous, not venomous"
	icon_state="poison_dart_frog"
	icon_living = "poison_dart_frog"
	icon_dead = "poison_dart_frog_dead"
	behavior_flags = ANIMAL_BEHAVIOR_AVOID_PRED | ANIMAL_BEHAVIOR_UNDESIRABLE

/mob/living/complex_animal/frog/poison/attack_hand(mob/living/carbon/human/M)
	..()
	//don't touch with bare hands.
	if(!M.gloves)
		M.reagents.add_reagent(CARPOTOXIN, 10)

/mob/living/complex_animal/frog/poison/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)	
	..()
	if(istype(mover,/mob))
		var/mob/M=mover
		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(!H.shoes) //don't tread on him (without footwear).
				H.reagents?.add_reagent(CARPOTOXIN, 10)
		else		
			M.reagents?.add_reagent(CARPOTOXIN, 10)

