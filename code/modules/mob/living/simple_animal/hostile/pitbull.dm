/mob/living/simple_animal/hostile/pitbull
	name = "pitbull"
	icon_state = "pitbull"
	icon_living = "pitbull"
	icon_dead = "pitbull_dead"
	speak_chance = 5
	emote_hear = list("growls", "barks")
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"


	health = 25
	maxHealth = 25
	turns_per_move = 5//I don't know what this does
	speed = 4
	move_to_delay = 3

	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = "wizard"

	//var/mob/creator

/mob/living/simple_animal/hostile/pitbull/New()
	..()
	desc = pick(
		"There is no such thing as a bad dog, only bad owners.",
		"Blame the owner not the breed!",
		"My dog would never do that.",
		"He's a big baby at heart.",
		"Man's best friend.",
		"Over 4 million pitbulls did not kill or hurt anyone today. Stop the myth.",
		"Good with kids")

/mob/living/simple_animal/hostile/pitbull/death()
	..(TRUE)
	var/mob/my_wiz = pitbulls[src]
	pitbulls_count_by_wizards[my_wiz]--
	pitbulls[src] = null
	pitbulls -= src

/mob/living/simple_animal/hostile/pitbull/ListTargets()
	var/list/L = ..()
	for(var/mob/M in L)
		if(pitbulls[src] == M)
			L.Remove(M)
	return L