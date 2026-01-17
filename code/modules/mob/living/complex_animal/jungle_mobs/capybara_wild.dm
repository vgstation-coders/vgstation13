/mob/living/simple_animal/complex/capybara_wild
	name="\improper Wild Capybara"
	desc="The capybara is the largest of the rodents. This one is unaccustomed to human contact."
	icon_state="capybara"
	icon_living = "capybara"
	icon_dead = "capybara-dead"
	size=SIZE_SMALL
	health=25
	maxHealth=25
	max_food=30
	mob_max_age=9999999 //a long time.
	food_flags = ANIMAL_HERBIVORE
	behavior_flags = ANIMAL_BEHAVIOR_PACK_DYNAMICS | ANIMAL_BEHAVIOR_AVOID_CAPTURE
	movespeed=1
	pacify_aura = TRUE
	melee_damage_upper=7
	melee_damage_lower=3
	petable=TRUE

/mob/living/simple_animal/complex/capybara_wild/tick_state_idle()
	if(!..())
		return FALSE
	if(prob(33))
		visible_message("\The [src] starts resting.")
		behavior_state=ANIMAL_STATE_SPECIAL
		icon_state="capybara-rest"
		walk(src,0)
	return TRUE

/mob/living/simple_animal/complex/capybara_wild/tick_state_special()
	if(!..())
		return FALSE
	icon_state="capybara-rest"
	if(prob(20))
		behavior_state=ANIMAL_STATE_IDLE
		icon_state="capybara"
		visible_message("\The [src] gets back up.")
	return TRUE

/mob/living/simple_animal/complex/capybara_wild/tick_state_fleeing()
	if(!..())
		return FALSE
	if(prob(33))
		visible_message("\The [src] forgives \the [target].")
		abort_target()
		return FALSE
	return TRUE


/mob/living/simple_animal/complex/capybara_wild/determine_isthreat(var/mob/individual)
	return FALSE

/mob/living/simple_animal/complex/capybara_wild/get_flee_msg(var/individual)
	..()
	icon_state="capybara"


/mob/living/simple_animal/complex/capybara_wild/get_idle_sounds()
	return

//no predators, so leaving this out is probably a bad idea.
/mob/living/simple_animal/complex/capybara_wild/can_offspring(var/mob/living/simple_animal/complex/mate)
	return FALSE

/mob/living/simple_animal/complex/capybara_wild/get_attack_msg(var/individual)
	var/i=rand(1,2)
	switch(i)
		if(1)
			emote("me", MESSAGE_SEE, "nibbles \the [individual]!")
		if(2)
			emote("me", MESSAGE_SEE, "scratches \the [individual]!")


/mob/living/simple_animal/complex/capybara_wild/trypet(mob/living/carbon/human/M)
	..()
	emote("me", MESSAGE_SEE, "closes its eyes for a moment and looks content.")