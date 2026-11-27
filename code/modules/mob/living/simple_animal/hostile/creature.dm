/mob/living/simple_animal/hostile/creature
	name = "creature"
	desc = "A sanity-destroying otherthing."
	speak_emote = list("gibbers")
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	health = 80
	maxHealth = 80
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = "creature"
	speed = 5
	size = SIZE_BIG
	supernatural = TRUE

/mob/living/simple_animal/hostile/creature/cult
	faction = "cult"

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	held_items = list()

/mob/living/simple_animal/hostile/creature/get_butchering_products()
	return list(/datum/butchering_product/teeth/lots)

/mob/living/simple_animal/hostile/creature/cult/CanAttack(var/atom/the_target)
	//IF WE ARE CULT MONSTERS (those who spawn after Nar-Sie has risen) THEN WE DON'T ATTACK CULTISTS
	if(ismob(the_target))
		var/mob/M = the_target
		if(isanycultist(M))
			return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/creature/cult/cultify()
	return


