//on aggro, these decoys delete themselves and spawn a given replacement atom
/mob/living/simple_animal/hostile/decoy
	wander = 0
	environment_smash = 0
	faction = "decoy"
	vision_range = 5	//no point in having the decoy if it aggros before the player sees it
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	heat_damage_per_tick = 0
	var/invincible = FALSE
	var/to_spawn = null

/mob/living/simple_animal/hostile/decoy/Die()
	if(!invincible)
		..()

/mob/living/simple_animal/hostile/decoy/adjustBruteLoss(var/damage)
	if(!invincible)
		..()

/mob/living/simple_animal/hostile/decoy/ex_act(severity)
	if(invincible)
		return
	..()

/mob/living/simple_animal/hostile/decoy/Aggro()
	if(to_spawn)
		new to_spawn(loc)
	qdel(src)

/mob/living/simple_animal/hostile/decoy/snowman
	name = "snowman"
	desc = "Good day sir."
	icon_state = "snowman"
	icon_living = "snowman"
	icon_dead = ""
	icon='icons/mob/snowman.dmi'
	invincible = TRUE

/mob/living/simple_animal/hostile/decoy/snowman/Aggro()
	if(to_spawn)
		var/S = new to_spawn(loc)
		visible_message("<span class='danger'>\A [S] breaks out from inside \the [src]!")
	qdel(src)

/mob/living/simple_animal/hostile/decoy/snowman/frostgolem
	to_spawn = /mob/living/simple_animal/hostile/humanoid/frostgolem

/mob/living/simple_animal/hostile/decoy/snowman/frostgolem/knight
	to_spawn = /mob/living/simple_animal/hostile/humanoid/frostgolem/knight

/mob/living/simple_animal/hostile/decoy/snowman/frostgolem/wizard
	to_spawn = /mob/living/simple_animal/hostile/humanoid/frostgolem/wizard