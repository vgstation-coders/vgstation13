//Mobs for the Hive away mission. See maps/randomZlevels/hive.dm for more
//They don't have anything to do with the classic xenomorphs

//Basic alien
/mob/living/simple_animal/hostile/hive_alien
	name = "hive denizen"
	desc = "A small crab-like creature with a large growth on its shell. Many thin tentacles emanate from it."

	icon = 'icons/mob/critter.dmi'
	icon_state = "hive_denizen"
	icon_living = "hive_denizen"
	icon_dead = "hive_denizen_dead"

	//Not affected by atmos - the hive is a near vacuum
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	//Don't wander around - multiple reasons for that (for example bluespace lakes that are very lethal to them)
	wander = FALSE

//Shoots napalm bombs. Very slow practically a turret.
/mob/living/simple_animal/hostile/hive_alien/arsonist
	name = "hive arsonist"
	desc = "This twisted creation looks like a mechanic spider with a huge cannon mounted on its back. It's very slow, and mostly uses its eight legs for balancing and adjusting its aim."

	icon_state = "hive_arsonist"
	icon_living = "hive_arsonist"
	icon_dead = "hive_arsonist_dead"

	speed = 50
	turns_per_move = 100

//Turns alien floors into breathing floors. Doesn't wander. Pretty weak but makes it easy for arsonists and executioners to ruin your life
/mob/living/simple_animal/hostile/hive_alien/artificer
	name = "hive artificer"
	desc = "A construct tasked with maintenance and improvement of the hive."

	icon_state = "hive_artificer"
	icon_living = "hive_artificer"
	icon_dead = "hive_artificer_dead"

	size = SIZE_NORMAL
	health = 80
	maxHealth = 80

	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "burns"
	attack_sound = 'sound/weapons/welderattack.ogg'

	turns_per_move = 12
	speed = 2

	wander = FALSE

/mob/living/simple_animal/hostile/hive_alien/artificer/Die()
	..()

	flick("hive_artificer_dying", src)

/mob/living/simple_animal/hostile/hive_alien/artificer/Move()
	.=..()

	if(istype(loc, /turf/unsimulated/floor/evil))
		//Turn into breathing floor (that slows people down) permanently
		var/turf/T = loc
		T.ChangeTurf(/turf/unsimulated/floor/evil/breathing)

//Has 2 modes: movement mode and attack mode. When in movement mode, fast but can't attack. When in attack mode, immobile but dangerous
//Switching between modes takes 0.6-1 seconds
/mob/living/simple_animal/hostile/hive_alien/executioner
	name = "hive executioner"
	desc = "A terrifying monster of an enormous size. It scuttles very quickly on its many legs, and hides hundreds of blades under its carapace."

	icon_state = "hive_executioner_move"
	icon_living = "hive_executioner_move"
	icon_dead = "hive_executioner_dead"

	turns_per_move = 8
	speed = -1

	size = SIZE_HUGE
	health = 300
	maxHealth = 300

	harm_intent_damage = 8
	melee_damage_lower = 40
	melee_damage_upper = 50
	attacktext = "eviscerates"
	attack_sound = 'sound/weapons/slash.ogg'

	var/attack_mode = FALSE

	var/transformation_delay_min = 6
	var/transformation_delay_max = 10

/mob/living/simple_animal/hostile/hive_alien/executioner/proc/mode_movement()
	icon_state = "hive_executioner_move"
	flick("hive_executioner_movemode", src)

	sleep(rand(transformation_delay_min, transformation_delay_max))

	anchored = FALSE
	speed = -1
	turns_per_move = 5
	attack_mode = FALSE

	aggro_vision_range = initial(aggro_vision_range)
	idle_vision_range = initial(aggro_vision_range)
	vision_range = initial(aggro_vision_range)

	//Immediately find a target so that we're not useless for 1 Life() tick!
	FindTarget()

/mob/living/simple_animal/hostile/hive_alien/executioner/proc/mode_attack()
	icon_state = "hive_executioner_attack"
	flick("hive_executioner_attackmode", src)

	sleep(rand(transformation_delay_min, transformation_delay_max))

	anchored = TRUE
	speed = 0
	turns_per_move = 0
	attack_mode = TRUE

	aggro_vision_range = 1
	idle_vision_range = 1
	vision_range = 1

	walk(src, 0)

/mob/living/simple_animal/hostile/hive_alien/executioner/LostTarget()
	if(attack_mode)
		if(!FindTarget()) //If we don't immediately find another target, switch to movement mode
			mode_movement()

	return ..()

/mob/living/simple_animal/hostile/hive_alien/executioner/Goto()
	if(attack_mode) //Can't move in attack mode
		return

	return ..()

/mob/living/simple_animal/hostile/hive_alien/executioner/AttackingTarget()
	if(!attack_mode)
		return mode_attack()

	flick("hive_executioner_attacking", src)

	return ..()

/mob/living/simple_animal/hostile/hive_alien/executioner/wounded
	name = "wounded alien executioner"
	health = 80
