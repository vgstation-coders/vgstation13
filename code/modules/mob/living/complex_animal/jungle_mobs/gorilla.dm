/mob/living/simple_animal/complex/gorilla
	name="\improper Gorilla"
	desc="Gorillas are some of the largest primates. Strong, intelligent, and loyal; they should be treated with care."
	icon_state="spacegorilla"
	icon_living = "spacegorilla"
	icon_dead = "deadgorilla"
	size=SIZE_BIG
	health=100
	maxHealth=100
	max_food=100
	food_flags = ANIMAL_HERBIVORE
	behavior_flags = ANIMAL_BEHAVIOR_PACK_DYNAMICS | ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_DESTRUCTIVE
	movespeed=5
	melee_damage_upper=24 //gorilla grip strong as shit
	melee_damage_lower=16 


/mob/living/simple_animal/complex/gorilla/get_idle_sounds()
	if(prob(10))
		var/i=rand(1,3)
		switch(i)
			if(1)
				emote("me",MESSAGE_HEAR,"grunts.")
			if(2)
				emote("me", MESSAGE_HEAR, "stomps.")
			if(3)
				say("Ook.")


/mob/living/simple_animal/complex/gorilla/get_attack_msg(var/individual)
	var/i=rand(1,3)
	switch(i)
		if(1)
			emote("me", MESSAGE_SEE, "bites \the [individual]!")
		if(2)
			emote("me", MESSAGE_SEE, "bludgeons \the [individual]!")
		if(3)
			emote("me", MESSAGE_SEE, "smacks \the [individual]!")

/mob/living/simple_animal/complex/gorilla/get_butchering_products()
	return list(/datum/butchering_product/skin/human, /datum/butchering_product/teeth/lots)
	